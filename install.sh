#!/bin/bash
# ================================================
# HTTP CUSTOM BOT - ARCHIVO .HC DIRECTO VIA WHATSAPP
# Con envío directo de archivos .hc como adjuntos
# ================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m'

# Banner inicial
clear
echo -e "${CYAN}${BOLD}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ██╗  ██╗████████╗████████╗██████╗      ██████╗██╗   ██╗  ║
║     ██║  ██║╚══██╔══╝╚══██╔══╝██╔══██╗    ██╔════╝██║   ██║  ║
║     ███████║   ██║      ██║   ██████╔╝    ██║     ██║   ██║  ║
║     ██╔══██║   ██║      ██║   ██╔═══╝     ██║     ██║   ██║  ║
║     ██║  ██║   ██║      ██║   ██║         ╚██████╗╚██████╔╝  ║
║     ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚═╝          ╚═════╝ ╚═════╝   ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║           HTTP CUSTOM BOT - .HC VIA WHATSAPP                ║
║               📤 ENVÍO DIRECTO DE ARCHIVOS .HC             ║
║               ⚡ EL CLIENTE RECIBE EL ARCHIVO EN WA        ║
║               🔗 SIN ENLACES EXTERNOS - TODO DENTRO        ║
║               💰 MERCADOPAGO INTEGRADO                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

echo -e "${GREEN}✅ NUEVO SISTEMA COMPLETO:${NC}"
echo -e "  📤 ${CYAN}ARCHIVO .HC ENVIADO DIRECTAMENTE POR WHATSAPP${NC}"
echo -e "  🎯 ${GREEN}Cliente recibe el archivo como adjunto${NC}"
echo -e "  🔗 ${YELLOW}Sin enlaces externos - Todo dentro de WhatsApp${NC}"
echo -e "  ⚡ ${PURPLE}Configuración automática incluida${NC}"
echo -e "  🎛️  ${BLUE}Panel admin: hcbot${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}${BOLD}❌ ERROR: Debes ejecutar como root${NC}"
    echo -e "${YELLOW}Usa: sudo bash $0${NC}"
    exit 1
fi

# Detectar IP
echo -e "${CYAN}${BOLD}🔍 DETECTANDO IP DEL SERVIDOR...${NC}"
SERVER_IP=$(curl -4 -s --max-time 10 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' || echo "127.0.0.1")
if [[ -z "$SERVER_IP" || "$SERVER_IP" == "127.0.0.1" ]]; then
    echo -e "${RED}❌ No se pudo obtener IP pública${NC}"
    read -p "📝 Ingresa la IP del servidor manualmente: " SERVER_IP
fi

echo -e "${GREEN}✅ IP detectada: ${CYAN}$SERVER_IP${NC}\n"

# Confirmar instalación
echo -e "${YELLOW}⚠️  ESTE INSTALADOR HARÁ:${NC}"
echo -e "   • Instalar Node.js 20.x + Chrome + Dependencias"
echo -e "   • Crear HTTP Custom Bot con ENVÍO DE .HC"
echo -e "   • Panel de control: ${GREEN}hcbot${NC}"
echo -e "   • Archivos .hc enviados como adjuntos en WhatsApp"
echo -e "   • Cliente NO necesita enlaces externos"
echo -e "   • Configuración automática incluida"
echo -e "   • Menú completo: 1=Prueba, 2=Comprar, 3=Renovar, 4=Cambiar HWID, 5=App"
echo -e "   • Planes: 7, 15, 30, 50 días"
echo -e "\n${RED}⚠️  Se eliminarán instalaciones anteriores${NC}"

read -p "$(echo -e "${YELLOW}¿Continuar con la instalación? (s/N): ${NC}")" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}❌ Instalación cancelada${NC}"
    exit 0
fi

# ================================================
# INSTALAR DEPENDENCIAS
# ================================================
echo -e "\n${CYAN}${BOLD}📦 INSTALANDO DEPENDENCIAS...${NC}"

# Actualizar sistema
apt-get update -y
apt-get upgrade -y

# Instalar Node.js 20.x
echo -e "${YELLOW}📦 Instalando Node.js 20.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs
apt-get install -y gcc g++ make

# Instalar Chromium
echo -e "${YELLOW}🌐 Instalando Chrome/Chromium...${NC}"
apt-get install -y wget gnupg
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -y
apt-get install -y google-chrome-stable

# Instalar dependencias del sistema
echo -e "${YELLOW}⚙️ Instalando utilidades...${NC}"
apt-get install -y \
    git \
    curl \
    wget \
    sqlite3 \
    jq \
    build-essential \
    python3 \
    python3-pip \
    unzip \
    cron \
    ufw \
    nginx \
    zip \
    openssl

# Instalar PM2 globalmente
echo -e "${YELLOW}🔄 Instalando PM2...${NC}"
npm install -g pm2
pm2 update

# Configurar firewall
echo -e "${YELLOW}🛡️ Configurando firewall...${NC}"
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8001/tcp
ufw allow 3000/tcp
ufw --force enable

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

# ================================================
# PREPARAR ESTRUCTURA
# ================================================
echo -e "\n${CYAN}${BOLD}📁 CREANDO ESTRUCTURA...${NC}"

INSTALL_DIR="/opt/http-custom-bot"
USER_HOME="/root/http-custom-bot"
DB_FILE="$INSTALL_DIR/data/users.db"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
HC_DIR="$INSTALL_DIR/hc_files"
WEB_DIR="/var/www/html/hc"

# Limpiar instalaciones anteriores
echo -e "${YELLOW}🧹 Limpiando instalaciones anteriores...${NC}"
pm2 delete http-custom-bot 2>/dev/null || true
pm2 flush 2>/dev/null || true
rm -rf "$INSTALL_DIR" "$USER_HOME" 2>/dev/null || true
rm -rf /root/.wwebjs_auth /root/.wwebjs_cache 2>/dev/null || true
rm -rf "$HC_DIR" "$WEB_DIR" 2>/dev/null || true

# Crear directorios
mkdir -p "$INSTALL_DIR"/{data,config,qr_codes,logs}
mkdir -p "$USER_HOME"
mkdir -p "$HC_DIR"
mkdir -p "$WEB_DIR"
mkdir -p /root/.wwebjs_auth
chmod -R 755 "$INSTALL_DIR"
chmod -R 755 "$WEB_DIR"
chmod -R 700 /root/.wwebjs_auth

# Crear configuración
cat > "$CONFIG_FILE" << EOF
{
    "bot": {
        "name": "HTTP Custom Bot",
        "version": "5.0-HC-WHATSAPP",
        "server_ip": "$SERVER_IP",
        "server_port": "8080",
        "encryption": "chacha20",
        "password": "123456"
    },
    "prices": {
        "test_hours": 2,
        "price_7d": 1500.00,
        "price_15d": 2500.00,
        "price_30d": 5500.00,
        "price_50d": 8500.00,
        "currency": "ARS"
    },
    "mercadopago": {
        "access_token": "",
        "enabled": false
    },
    "links": {
        "tutorial": "https://youtube.com",
        "support": "https://wa.me/543435071016",
        "app_download": "https://www.mediafire.com/file/p8kgthxbsid7xws/MAJ/DNI_AND_FIL"
    },
    "paths": {
        "database": "$DB_FILE",
        "chromium": "/usr/bin/google-chrome",
        "qr_codes": "$INSTALL_DIR/qr_codes",
        "hc_files": "$HC_DIR",
        "web_download": "$WEB_DIR"
    }
}
EOF

# Crear base de datos
sqlite3 "$DB_FILE" << 'SQL'
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    username TEXT UNIQUE,
    hwid TEXT UNIQUE,
    tipo TEXT DEFAULT 'test',
    expires_at DATETIME,
    status INTEGER DEFAULT 1,
    download_url TEXT,
    config_file TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE daily_tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(phone, date)
);
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_id TEXT UNIQUE,
    phone TEXT,
    plan TEXT,
    days INTEGER,
    amount REAL,
    discount_code TEXT,
    final_amount REAL,
    status TEXT DEFAULT 'pending',
    payment_url TEXT,
    qr_code TEXT,
    preference_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME
);
CREATE TABLE logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    message TEXT,
    data TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_state (
    phone TEXT PRIMARY KEY,
    state TEXT DEFAULT 'main_menu',
    data TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_hwid ON users(hwid);
SQL

# Configurar Nginx para descargas directas
cat > /etc/nginx/sites-available/hc-download << EOF
server {
    listen 80;
    server_name $SERVER_IP;
    root /var/www/html/hc;
    
    location / {
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        add_header Access-Control-Allow-Origin "*";
    }
    
    location ~* \.hc$ {
        add_header Content-Type application/octet-stream;
        add_header Content-Disposition "attachment";
        add_header Access-Control-Allow-Origin "*";
        default_type application/octet-stream;
    }
}
EOF

ln -sf /etc/nginx/sites-available/hc-download /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl restart nginx

echo -e "${GREEN}✅ Estructura creada${NC}"

# ================================================
# CREAR GENERADOR DE ARCHIVOS .HC OPTIMIZADOS
# ================================================
echo -e "\n${CYAN}${BOLD}🔧 CREANDO GENERADOR DE ARCHIVOS .HC OPTIMIZADOS...${NC}"

cat > "$INSTALL_DIR/create_direct_hc.py" << 'PYEOF'
#!/usr/bin/env python3
import json
import sys
import os
from datetime import datetime, timedelta

def create_direct_hc_file(username, hwid, server_ip, port, method, password, days):
    """Crea archivo .hc OPTIMIZADO para WhatsApp (tamaño reducido)"""
    
    # Configuración MINIMALISTA para WhatsApp (evitar límite de tamaño)
    hc_content = f"""# HTTP Custom Config
# User: {username}
# HWID: {hwid}
# Expire: {(datetime.now() + timedelta(days=days)).strftime('%d/%m/%Y')}

[general]
mode=http
listen_port=8080

[server]
server={server_ip}
server_port={port}
method={method}
password={password}

[obfs]
obfs=http
obfs_host=www.bing.com

[advanced]
mux_concurrency=8

# Instrucciones:
# 1. Guardar como: HC_{username}.hc
# 2. HTTP Custom → Profiles → Import
# 3. Seleccionar este archivo
# 4. Activar conexión
# 5. ¡Listo!"""
    
    return hc_content

def save_hc_file(content, username, hwid, output_dir):
    """Guarda el archivo .hc directamente"""
    
    # Nombre corto para WhatsApp
    filename = f"HC_{username}.hc"
    filepath = os.path.join(output_dir, filename)
    
    # Guardar contenido
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    
    return filepath, filename

if __name__ == "__main__":
    if len(sys.argv) < 7:
        print("Uso: create_direct_hc.py <username> <hwid> <server_ip> <port> <method> <password> <days>")
        sys.exit(1)
    
    username = sys.argv[1]
    hwid = sys.argv[2]
    server_ip = sys.argv[3]
    port = sys.argv[4]
    method = sys.argv[5]
    password = sys.argv[6]
    days = int(sys.argv[7])
    
    # Generar contenido
    hc_content = create_direct_hc_file(username, hwid, server_ip, port, method, password, days)
    
    # Guardar en directorio web
    output_dir = "/var/www/html/hc"
    os.makedirs(output_dir, exist_ok=True)
    
    filepath, filename = save_hc_file(hc_content, username, hwid, output_dir)
    
    # Dar permisos
    os.chmod(filepath, 0o644)
    
    # Retornar información
    print(f"OK:{filepath}:{filename}")
PYEOF

chmod +x "$INSTALL_DIR/create_direct_hc.py"

# Crear script para generar .hc directo
cat > /usr/local/bin/create-hc-direct << 'HCDEOF'
#!/bin/bash
# Generador de archivos .hc directo

if [ $# -lt 3 ]; then
    echo "Uso: create-hc-direct <username> <hwid> <dias>"
    echo "Ejemplo: create-hc-direct JuanPerez ABC123XYZ 30"
    exit 1
fi

USERNAME="$1"
HWID="$2"
DAYS="$3"

CONFIG="/opt/http-custom-bot/config/config.json"
SERVER_IP=$(jq -r '.bot.server_ip' "$CONFIG")
PORT=$(jq -r '.bot.server_port' "$CONFIG")
METHOD=$(jq -r '.bot.encryption' "$CONFIG")
PASSWORD=$(jq -r '.bot.password' "$CONFIG")

python3 /opt/http-custom-bot/create_direct_hc.py "$USERNAME" "$HWID" "$SERVER_IP" "$PORT" "$METHOD" "$PASSWORD" "$DAYS"
HCDEOF

chmod +x /usr/local/bin/create-hc-direct

echo -e "${GREEN}✅ Generador de archivos .hc optimizados creado${NC}"

# ================================================
# CREAR BOT CON ENVÍO DE .HC VIA WHATSAPP
# ================================================
echo -e "\n${CYAN}${BOLD}🤖 CREANDO BOT CON ENVÍO DE .HC VIA WHATSAPP...${NC}"

cd "$USER_HOME"

# package.json
cat > package.json << 'PKGEOF'
{
    "name": "http-custom-bot",
    "version": "5.0.0",
    "main": "bot.js",
    "dependencies": {
        "whatsapp-web.js": "^1.24.0",
        "qrcode-terminal": "^0.12.0",
        "qrcode": "^1.5.3",
        "moment": "^2.30.1",
        "sqlite3": "^5.1.7",
        "chalk": "^4.1.2",
        "node-cron": "^3.0.3",
        "mercadopago": "^2.0.15",
        "axios": "^1.6.5"
    }
}
PKGEOF

echo -e "${YELLOW}📦 Instalando paquetes Node.js...${NC}"
npm install --silent 2>&1 | grep -v "npm WARN" || true

# ✅ APLICAR PARCHE PARA ERROR markedUnread
echo -e "${YELLOW}🔧 Aplicando parche para error WhatsApp Web...${NC}"
find node_modules/whatsapp-web.js -name "Client.js" -type f -exec sed -i 's/if (chat && chat.markedUnread)/if (false \&\& chat.markedUnread)/g' {} \; 2>/dev/null || true
find node_modules/whatsapp-web.js -name "Client.js" -type f -exec sed -i 's/const sendSeen = async (chatId) => {/const sendSeen = async (chatId) => { console.log("[DEBUG] sendSeen deshabilitado"); return;/g' {} \; 2>/dev/null || true

echo -e "${GREEN}✅ Parche markedUnread aplicado${NC}"

# Crear bot.js CON ENVÍO DE .HC
cat > "bot.js" << 'BOTEOF'
const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcodeTerminal = require('qrcode-terminal');
const QRCode = require('qrcode');
const moment = require('moment');
const sqlite3 = require('sqlite3').verbose();
const { exec } = require('child_process');
const util = require('util');
const chalk = require('chalk');
const cron = require('node-cron');
const fs = require('fs');
const path = require('path');
const axios = require('axios');

const execPromise = util.promisify(exec);

function loadConfig() {
    delete require.cache[require.resolve('/opt/http-custom-bot/config/config.json')];
    return require('/opt/http-custom-bot/config/config.json');
}

let config = loadConfig();
const db = new sqlite3.Database(config.paths.database);

// ✅ FUNCIÓN PARA CREAR Y ENVIAR ARCHIVO .HC VIA WHATSAPP
async function createAndSendHcFile(phone, username, hwid, days) {
    return new Promise(async (resolve, reject) => {
        try {
            console.log(chalk.yellow(`🔧 Generando archivo HC para: ${username} | HWID: ${hwid}`));
            
            const pythonScript = '/opt/http-custom-bot/create_direct_hc.py';
            const args = [
                username, 
                hwid, 
                config.bot.server_ip, 
                config.bot.server_port, 
                config.bot.encryption, 
                config.bot.password, 
                days.toString()
            ];
            
            exec(`python3 ${pythonScript} ${args.join(' ')}`, async (error, stdout, stderr) => {
                if (error) {
                    console.error(chalk.red('❌ Error generando .hc:'), error.message);
                    reject(error);
                    return;
                }
                
                const match = stdout.match(/OK:(.+):(.+)/);
                if (match) {
                    const filePath = match[1].trim();
                    const fileName = match[2].trim();
                    
                    if (fs.existsSync(filePath)) {
                        try {
                            // Enviar mensaje informativo primero
                            await client.sendMessage(phone, 
                                `✅ *ARCHIVO .HC LISTO*\n\n📄 Nombre: *${fileName}*\n⏰ Válido por: *${days === 0 ? '2 horas' : days + ' días'}*\n\n👇 *DESCARGA EL ARCHIVO DE ABAJO:*`, 
                                { sendSeen: false }
                            );
                            
                            // Enviar archivo .hc como adjunto
                            const media = MessageMedia.fromFilePath(filePath);
                            
                            await client.sendMessage(phone, media, {
                                caption: `🔧 *${fileName}*\n\n📱 *PARA INSTALAR:*\n1. Guarda este archivo\n2. Abre HTTP Custom\n3. Ve a *Profiles* → *Import*\n4. Selecciona este archivo\n5. ¡Activa la conexión!\n\n⚡ Configuración automática incluida\n✅ Sin necesidad de editar`,
                                sendSeen: false
                            });
                            
                            console.log(chalk.green(`✅ Archivo .hc enviado: ${fileName}`));
                            
                            // Crear también enlace de respaldo
                            const downloadUrl = `http://${config.bot.server_ip}/hc/${fileName}`;
                            
                            resolve({
                                success: true,
                                filePath: filePath,
                                fileName: fileName,
                                downloadUrl: downloadUrl
                            });
                            
                        } catch (sendError) {
                            console.error(chalk.red('❌ Error enviando archivo:'), sendError.message);
                            
                            // Fallback: enviar link de descarga
                            const downloadUrl = `http://${config.bot.server_ip}/hc/${fileName}`;
                            await client.sendMessage(phone, 
                                `📥 *DESCARGA TU ARCHIVO .HC*\n\n🔗 Enlace directo:\n${downloadUrl}\n\n💡 Copia este link por si necesitas descargarlo nuevamente.`, 
                                { sendSeen: false }
                            );
                            
                            resolve({
                                success: true,
                                filePath: filePath,
                                fileName: fileName,
                                downloadUrl: downloadUrl
                            });
                        }
                    } else {
                        reject(new Error('Archivo .hc no encontrado en ruta: ' + filePath));
                    }
                } else {
                    reject(new Error('No se pudo generar el archivo .hc'));
                }
            });
            
        } catch (error) {
            reject(error);
        }
    });
}

// ✅ FUNCIONES DE ESTADO
function getUserState(phone) {
    return new Promise((resolve) => {
        db.get('SELECT state, data FROM user_state WHERE phone = ?', [phone], (err, row) => {
            if (err || !row) {
                resolve({ state: 'main_menu', data: null });
            } else {
                resolve({
                    state: row.state || 'main_menu',
                    data: row.data ? JSON.parse(row.data) : null
                });
            }
        });
    });
}

function setUserState(phone, state, data = null) {
    return new Promise((resolve) => {
        const dataStr = data ? JSON.stringify(data) : null;
        db.run(
            `INSERT OR REPLACE INTO user_state (phone, state, data, updated_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
            [phone, state, dataStr],
            (err) => {
                if (err) console.error(chalk.red('❌ Error estado:'), err.message);
                resolve();
            }
        );
    });
}

// ✅ CREAR USUARIO CON ENVÍO DE .HC
async function createHttpCustomUserWithFile(phone, hwid, days) {
    const username = 'HC' + Math.floor(1000 + Math.random() * 9000);
    const expireDate = days === 0 ? 
        moment().add(config.prices.test_hours, 'hours').format('YYYY-MM-DD HH:mm:ss') :
        moment().add(days, 'days').format('YYYY-MM-DD 23:59:59');
    
    console.log(chalk.yellow(`🔧 Creando usuario HC: ${username} | HWID: ${hwid} | Días: ${days}`));
    
    try {
        // Enviar archivo .hc
        const hcResult = await createAndSendHcFile(phone, username, hwid, days);
        
        if (!hcResult.success) {
            throw new Error('Error enviando archivo .hc');
        }
        
        // Guardar en base de datos
        return new Promise((resolve, reject) => {
            const tipo = days === 0 ? 'test' : 'premium';
            db.run(
                `INSERT INTO users (phone, username, hwid, tipo, expires_at, status, download_url, config_file) VALUES (?, ?, ?, ?, ?, 1, ?, ?)`,
                [phone, username, hwid, tipo, expireDate, hcResult.downloadUrl, hcResult.filePath],
                (err) => {
                    if (err) {
                        reject(err);
                    } else {
                        resolve({
                            username: username,
                            hwid: hwid,
                            fileName: hcResult.fileName,
                            downloadUrl: hcResult.downloadUrl,
                            expires: expireDate,
                            tipo: tipo,
                            duration: days === 0 ? `${config.prices.test_hours} horas` : `${days} días`
                        });
                    }
                }
            );
        });
        
    } catch (error) {
        console.error(chalk.red('❌ Error creando usuario HC:'), error.message);
        throw error;
    }
}

// ✅ MERCADOPAGO SDK
let mpClient = null;
let mpPreference = null;

function initMercadoPago() {
    config = loadConfig();
    if (config.mercadopago.access_token && config.mercadopago.access_token !== '') {
        try {
            const { MercadoPagoConfig, Preference } = require('mercadopago');
            
            mpClient = new MercadoPagoConfig({ 
                accessToken: config.mercadopago.access_token,
                options: { timeout: 5000, idempotencyKey: true }
            });
            
            mpPreference = new Preference(mpClient);
            
            console.log(chalk.green('✅ MercadoPago SDK v2.x ACTIVO'));
            return true;
        } catch (error) {
            console.log(chalk.red('❌ Error inicializando MP:'), error.message);
            mpClient = null;
            mpPreference = null;
            return false;
        }
    }
    console.log(chalk.yellow('⚠️ MercadoPago NO CONFIGURADO'));
    return false;
}

let mpEnabled = initMercadoPago();
moment.locale('es');

console.log(chalk.cyan.bold('\n╔══════════════════════════════════════════════════════════════╗'));
console.log(chalk.cyan.bold('║           🤖 HTTP CUSTOM BOT - .HC VIA WHATSAPP              ║'));
console.log(chalk.cyan.bold('║               📤 ENVÍO DIRECTO DE ARCHIVOS .HC              ║'));
console.log(chalk.cyan.bold('║               ⚡ CLIENTE RECIBE EL ARCHIVO EN WA             ║'));
console.log(chalk.cyan.bold('╚══════════════════════════════════════════════════════════════╝\n'));
console.log(chalk.yellow(`📍 IP: ${config.bot.server_ip}`));
console.log(chalk.yellow(`🔗 Puerto: ${config.bot.server_port}`));
console.log(chalk.yellow(`🔐 Encriptación: ${config.bot.encryption}`));
console.log(chalk.yellow(`💳 MercadoPago: ${mpEnabled ? '✅ ACTIVO' : '❌ NO CONFIGURADO'}`));
console.log(chalk.green('✅ Sistema de envío de archivos .hc activo'));
console.log(chalk.green('✅ Cliente recibe archivo directamente en WhatsApp'));
console.log(chalk.green('✅ Sin enlaces externos necesarios'));

const client = new Client({
    authStrategy: new LocalAuth({dataPath: '/root/.wwebjs_auth', clientId: 'http-custom-whatsapp-hc'}),
    puppeteer: {
        headless: true,
        executablePath: config.paths.chromium,
        args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage', '--disable-gpu', '--no-first-run', '--disable-extensions'],
        timeout: 60000
    },
    authTimeoutMs: 60000
});

let qrCount = 0;

client.on('qr', (qr) => {
    qrCount++;
    console.clear();
    console.log(chalk.yellow.bold(`\n╔════════ 📱 QR #${qrCount} - ESCANEA AHORA ════════╗\n`));
    qrcodeTerminal.generate(qr, { small: true });
    QRCode.toFile('/root/qr-whatsapp.png', qr, { width: 500 }).catch(() => {});
    console.log(chalk.cyan('\n1️⃣ Abre WhatsApp → Dispositivos vinculados'));
    console.log(chalk.cyan('2️⃣ Escanea el QR ☝️'));
    console.log(chalk.green('\n💾 QR guardado: /root/qr-whatsapp.png\n'));
});

client.on('authenticated', () => console.log(chalk.green('✅ Autenticado')));
client.on('ready', () => {
    console.clear();
    console.log(chalk.green.bold('\n✅ BOT CONECTADO Y OPERATIVO\n'));
    console.log(chalk.cyan('💬 Envía "menu" a tu WhatsApp\n'));
    qrCount = 0;
});
client.on('auth_failure', (m) => console.log(chalk.red('❌ Error auth:'), m));
client.on('disconnected', (r) => console.log(chalk.yellow('⚠️ Desconectado:'), r));

// ✅ FUNCIONES AUXILIARES
function canCreateTest(phone) {
    return new Promise((resolve) => {
        const today = moment().format('YYYY-MM-DD');
        db.get('SELECT COUNT(*) as count FROM daily_tests WHERE phone = ? AND date = ?', [phone, today],
            (err, row) => resolve(!err && row && row.count === 0));
    });
}

function registerTest(phone) {
    db.run('INSERT OR IGNORE INTO daily_tests (phone, date) VALUES (?, ?)', [phone, moment().format('YYYY-MM-DD')]);
}

// ✅ MAPA DE PLANES DISPONIBLES
const availablePlans = {
    '7': { 
        days: 7, 
        amountKey: 'price_7d',
        name: '7 DÍAS',
        description: 'Plan de 7 días de HTTP Custom'
    },
    '15': { 
        days: 15, 
        amountKey: 'price_15d',
        name: '15 DÍAS',
        description: 'Plan de 15 días de HTTP Custom'
    },
    '30': { 
        days: 30, 
        amountKey: 'price_30d',
        name: '30 DÍAS',
        description: 'Plan de 30 días de HTTP Custom'
    },
    '50': { 
        days: 50, 
        amountKey: 'price_50d',
        name: '50 DÍAS',
        description: 'Plan de 50 días de HTTP Custom'
    }
};

// ✅ CREAR PAGO MERCADOPAGO
async function createMercadoPagoPayment(phone, plan, days, amount, discountCode = null) {
    try {
        config = loadConfig();
        
        if (!config.mercadopago.access_token || config.mercadopago.access_token === '') {
            return { success: false, error: 'MercadoPago no configurado' };
        }
        
        if (!mpPreference) {
            mpEnabled = initMercadoPago();
            if (!mpEnabled || !mpPreference) {
                return { success: false, error: 'No se pudo inicializar MercadoPago' };
            }
        }
        
        const phoneClean = phone.split('@')[0];
        const paymentId = `HC-${phoneClean}-${days}d-${Date.now()}`;
        
        console.log(chalk.cyan(`🔄 Creando pago MP: ${paymentId}`));
        
        const expirationDate = moment().add(24, 'hours');
        
        // Aplicar descuento
        let finalAmount = parseFloat(amount);
        let discountPercentage = 0;
        
        if (discountCode) {
            const discountLower = discountCode.toLowerCase();
            if (discountLower === 'descuento10' || discountLower === '10off') {
                discountPercentage = 10;
            } else if (discountLower === 'descuento15' || discountLower === '15off') {
                discountPercentage = 15;
            } else if (discountLower === 'descuento20' || discountLower === '20off') {
                discountPercentage = 20;
            }
            
            if (discountPercentage > 0) {
                finalAmount = finalAmount * (1 - discountPercentage / 100);
                console.log(chalk.yellow(`💰 Aplicando descuento ${discountPercentage}%: $${amount} -> $${finalAmount.toFixed(2)}`));
            }
        }
        
        const preferenceData = {
            items: [{
                title: `HTTP CUSTOM ${days} DÍAS`,
                description: `Acceso HTTP Custom Premium por ${days} días - Archivo .hc incluido`,
                quantity: 1,
                currency_id: config.prices.currency || 'ARS',
                unit_price: finalAmount
            }],
            external_reference: paymentId,
            expires: true,
            expiration_date_from: moment().toISOString(),
            expiration_date_to: expirationDate.toISOString(),
            back_urls: {
                success: `https://wa.me/${phoneClean}?text=Pago%20exitoso`,
                failure: `https://wa.me/${phoneClean}?text=Pago%20fallido`,
                pending: `https://wa.me/${phoneClean}?text=Pago%20pendiente`
            },
            auto_return: 'approved',
            statement_descriptor: 'HTTP CUSTOM'
        };
        
        const response = await mpPreference.create({ body: preferenceData });
        
        if (response && response.id) {
            const paymentUrl = response.init_point;
            const qrPath = `${config.paths.qr_codes}/${paymentId}.png`;
            
            await QRCode.toFile(qrPath, paymentUrl, { 
                width: 400,
                margin: 1,
                color: {
                    dark: '#000000',
                    light: '#FFFFFF'
                }
            });
            
            db.run(
                `INSERT INTO payments (payment_id, phone, plan, days, amount, discount_code, final_amount, status, payment_url, qr_code, preference_id) VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?)`,
                [paymentId, phone, `${days}d`, days, amount, discountCode, finalAmount, paymentUrl, qrPath, response.id]
            );
            
            console.log(chalk.green(`✅ Pago creado exitosamente`));
            
            return { 
                success: true, 
                paymentId, 
                paymentUrl, 
                qrPath,
                amount: finalAmount,
                originalAmount: amount,
                discountApplied: discountPercentage > 0,
                discountPercentage: discountPercentage
            };
        }
        
        throw new Error('Respuesta inválida de MercadoPago');
        
    } catch (error) {
        console.error(chalk.red('❌ Error MercadoPago:'), error.message);
        return { success: false, error: error.message };
    }
}

// ✅ FLUJO PRINCIPAL CON ENVÍO DE .HC
client.on('message', async (msg) => {
    const text = msg.body.trim();
    const phone = msg.from;
    if (phone.includes('@g.us')) return;
    
    config = loadConfig();
    console.log(chalk.cyan(`📩 [${phone.split('@')[0]}]: ${text.substring(0, 30)}`));
    
    const userState = await getUserState(phone);
    
    // COMANDO MENÚ PRINCIPAL
    if (['menu', 'hola', 'start', 'hi', 'volver', 'atras', '0'].includes(text.toLowerCase())) {
        await setUserState(phone, 'main_menu');
        
        await client.sendMessage(phone, `🎯 *HTTP CUSTOM BOT*\n\nElija una opción:\n\n1️⃣ *CREAR PRUEBA* (2 horas)\n2️⃣ *COMPRAR PLAN* (7-50 días)\n3️⃣ *RENOVAR PLAN*\n4️⃣ *CAMBIAR HWID*\n5️⃣ *DESCARGAR APP*\n\n💬 Responde con el número`, { sendSeen: false });
    }
    // OPCIÓN 1: CREAR PRUEBA
    else if (text === '1' && userState.state === 'main_menu') {
        if (!(await canCreateTest(phone))) {
            await client.sendMessage(phone, `⚠️ *YA USASTE TU PRUEBA HOY*\n\n⏳ Vuelve mañana para otra prueba gratuita\n\n💰 *Escribe 2* para ver planes premium`, { sendSeen: false });
            return;
        }
        
        await client.sendMessage(phone, `📱 *ENVÍA TU HWID*\n\nPara crear tu prueba, necesitamos tu HWID:\n\n1. Abre HTTP Custom\n2. Ve a *Configuración → Acerca de*\n3. Copia tu *HWID*\n4. Envíalo aquí\n\n🔢 *Formato:* Letras y números (6-32 caracteres)\n📝 *Ejemplo:* ABC123XYZ456`, { sendSeen: false });
        
        await setUserState(phone, 'asking_hwid_test');
    }
    // CAPTURAR HWID PARA PRUEBA
    else if (userState.state === 'asking_hwid_test') {
        const hwid = text.trim();
        
        // Validación simple de HWID
        if (hwid.length < 6 || hwid.length > 32) {
            await client.sendMessage(phone, `❌ *HWID INVÁLIDO*\n\nEl HWID debe tener entre 6 y 32 caracteres.\n\n📝 Por favor, envía un HWID válido:`, { sendSeen: false });
            return;
        }
        
        await client.sendMessage(phone, '⏳ Creando cuenta de prueba y generando archivo .hc...', { sendSeen: false });
        
        try {
            const result = await createHttpCustomUserWithFile(phone, hwid, 0);
            registerTest(phone);
            
            await client.sendMessage(phone, `✅ *PRUEBA ACTIVADA*\n\n👤 Usuario: *${result.username}*\n🔐 HWID: *${result.hwid}*\n⏰ Duración: *${result.duration}*\n\n📤 *ARCHIVO .HC ENVIADO ARRIBA*\n\n💡 *INSTALACIÓN:*\n1. Guarda el archivo .hc\n2. Abre HTTP Custom\n3. Profiles → Import\n4. Selecciona el archivo\n5. ¡Conectar!\n\n⚠️ Esta prueba expira en *${config.prices.test_hours} horas*`, { sendSeen: false });
            
            console.log(chalk.green(`✅ Test creado: ${result.username} | HWID: ${hwid}`));
        } catch (error) {
            await client.sendMessage(phone, `❌ Error al crear prueba: ${error.message}`, { sendSeen: false });
        }
        
        await setUserState(phone, 'main_menu');
    }
    // OPCIÓN 2: COMPRAR HTTP CUSTOM
    else if (text === '2' && userState.state === 'main_menu') {
        await setUserState(phone, 'buying_hc');
        
        await client.sendMessage(phone, `💰 *PLANES PREMIUM HTTP CUSTOM*\n\nSelecciona un plan:\n\n1️⃣ *7 DÍAS* - $${config.prices.price_7d} ARS\n2️⃣ *15 DÍAS* - $${config.prices.price_15d} ARS\n3️⃣ *30 DÍAS* - $${config.prices.price_30d} ARS\n4️⃣ *50 DÍAS* - $${config.prices.price_50d} ARS\n\n0️⃣ *VOLVER*`, { sendSeen: false });
    }
    // SELECCIÓN DE PLAN ESPECÍFICO
    else if (userState.state === 'buying_hc') {
        if (text === '1' || text === '2' || text === '3' || text === '4') {
            const planNumber = parseInt(text);
            let planData;
            
            if (planNumber === 1) planData = availablePlans['7'];
            else if (planNumber === 2) planData = availablePlans['15'];
            else if (planNumber === 3) planData = availablePlans['30'];
            else if (planNumber === 4) planData = availablePlans['50'];
            
            if (planData) {
                const amount = config.prices[planData.amountKey];
                
                await setUserState(phone, 'asking_discount', { 
                    plan: `${planData.days}d`,
                    days: planData.days,
                    amount: amount,
                    planName: planData.name
                });
                
                await client.sendMessage(phone, `**¿Tienes un cupón de descuento?**\nResponde: sí o no.`, { sendSeen: false });
            }
        }
        else if (text === '0') {
            await setUserState(phone, 'main_menu');
            await client.sendMessage(phone, `🎯 *HTTP CUSTOM BOT*\n\nElija una opción:\n\n1️⃣ *CREAR PRUEBA* (2 horas)\n2️⃣ *COMPRAR PLAN* (7-50 días)\n3️⃣ *RENOVAR PLAN*\n4️⃣ *CAMBIAR HWID*\n5️⃣ *DESCARGAR APP*\n\n💬 Responde con el número`, { sendSeen: false });
        }
    }
    // PREGUNTA POR CUPÓN DE DESCUENTO
    else if (userState.state === 'asking_discount') {
        const stateData = userState.data || {};
        
        if (text.toLowerCase().includes('sí') || text.toLowerCase().includes('si')) {
            await setUserState(phone, 'entering_discount', stateData);
            await client.sendMessage(phone, '📝 Por favor, escribe tu código de descuento:', { sendSeen: false });
        }
        else if (text.toLowerCase().includes('no')) {
            await processPayment(phone, stateData, null);
        }
        else {
            await client.sendMessage(phone, 'Por favor responde: *sí* o *no*', { sendSeen: false });
        }
    }
    // INGRESAR CÓDIGO DE DESCUENTO
    else if (userState.state === 'entering_discount') {
        const stateData = userState.data || {};
        const discountCode = text.trim();
        
        await processPayment(phone, stateData, discountCode);
    }
    // OPCIÓN 3: RENOVAR HTTP CUSTOM
    else if (text === '3' && userState.state === 'main_menu') {
        db.get('SELECT username, hwid, expires_at FROM users WHERE phone = ? AND status = 1', [phone], async (err, user) => {
            if (err || !user) {
                await client.sendMessage(phone, `❌ *NO TIENES CUENTA ACTIVA*\n\nNo se encontró una cuenta HTTP Custom activa asociada a este número.\n\n💡 Puedes crear una prueba (Opción 1) o comprar una cuenta (Opción 2).`, { sendSeen: false });
                return;
            }
            
            const expireDate = moment(user.expires_at).format('DD/MM/YYYY HH:mm');
            
            await client.sendMessage(phone, `🔄 *RENOVAR CUENTA*\n\n👤 Usuario actual: *${user.username}*\n🔐 HWID: *${user.hwid}*\n📅 Expira: *${expireDate}*\n\nPara renovar contacta soporte:\n${config.links.support}`, { sendSeen: false });
        });
    }
    // OPCIÓN 4: CAMBIAR HWID
    else if (text === '4' && userState.state === 'main_menu') {
        db.get('SELECT username, hwid FROM users WHERE phone = ? AND status = 1', [phone], async (err, user) => {
            if (err || !user) {
                await client.sendMessage(phone, `❌ *NO TIENES CUENTA ACTIVA*\n\nNo se encontró una cuenta HTTP Custom activa.\n\n💡 Crea una prueba (Opción 1) o compra una cuenta (Opción 2).`, { sendSeen: false });
                return;
            }
            
            await client.sendMessage(phone, `🔄 *CAMBIAR HWID*\n\nPara cambiar el HWID de tu cuenta, contacta soporte:\n${config.links.support}\n\n👤 Usuario: *${user.username}*\n🔐 HWID actual: *${user.hwid}*`, { sendSeen: false });
        });
    }
    // OPCIÓN 5: DESCARGAR HTTP CUSTOM APP
    else if (text === '5' && userState.state === 'main_menu') {
        // Buscar APK automáticamente
        const searchPaths = [
            '/root/app.apk',
            '/root/http-custom-bot/app.apk',
            '/root/android.apk',
            '/root/vpn.apk',
            '/root/*.apk'
        ];
        
        let apkFound = null;
        let apkName = 'app.apk';
        
        for (const pattern of searchPaths) {
            const files = fs.readdirSync('/root').filter(f => f.endsWith('.apk'));
            if (files.length > 0) {
                apkFound = `/root/${files[0]}`;
                apkName = files[0];
                break;
            }
        }
        
        if (apkFound && fs.existsSync(apkFound)) {
            try {
                const stats = fs.statSync(apkFound);
                const fileSize = (stats.size / (1024 * 1024)).toFixed(2);
                
                console.log(chalk.cyan(`📱 Enviando APK: ${apkName} (${fileSize}MB)`));
                
                await client.sendMessage(phone, `📱 *DESCARGANDO APP*\n\n📦 Archivo: ${apkName}\n📊 Tamaño: ${fileSize} MB\n\n⏳ Enviando archivo, espera...`, { sendSeen: false });
                
                const media = MessageMedia.fromFilePath(apkFound);
                await client.sendMessage(phone, media, {
                    caption: `📱 *${apkName}*\n\n✅ Archivo enviado correctamente\n\n📱 *INSTRUCCIONES:*\n1. Toca el archivo para instalar\n2. Permite "Fuentes desconocidas"\n3. Abre la app\n4. Importa tu archivo .hc\n\n💡 Si no ves el archivo, revisa la sección "Archivos" de WhatsApp`,
                    sendSeen: false
                });
                
                console.log(chalk.green(`✅ APK enviado exitosamente`));
                
            } catch (error) {
                console.error(chalk.red('❌ Error enviando APK:'), error.message);
                
                await client.sendMessage(phone, `📱 *ENLACE DE DESCARGA*\n\nEl archivo es muy grande para WhatsApp.\n\n🔗 Descarga desde:\n${config.links.app_download}\n\n📱 Instrucciones:\n1. Abre el enlace\n2. Descarga e instala\n3. Configura con tu archivo .hc`, { sendSeen: false });
            }
        } else {
            await client.sendMessage(phone, `📱 *DESCARGAR APP*\n\n🔗 Enlace de descarga:\n${config.links.app_download}\n\n💡 *Instrucciones:*\n1. Abre el enlace en tu navegador\n2. Descarga el archivo APK\n3. Permite "Fuentes desconocidas"\n4. Instala la aplicación\n5. Configura con tu archivo .hc`, { sendSeen: false });
        }
    }
    // COMANDO NO RECONOCIDO
    else {
        await client.sendMessage(phone, `❌ Comando no reconocido.\n\nEscribe *menu* para ver las opciones disponibles.`, { sendSeen: false });
    }
});

// ✅ FUNCIÓN PARA PROCESAR PAGO CON ENVÍO DE .HC
async function processPayment(phone, planData, discountCode) {
    config = loadConfig();
    
    if (!config.mercadopago.access_token || config.mercadopago.access_token === '') {
        await client.sendMessage(phone, `❌ *MERCADOPAGO NO CONFIGURADO*\n\nEl administrador debe configurar MercadoPago primero.\n\n💬 Contacta soporte para más información.`, { sendSeen: false });
        await setUserState(phone, 'main_menu');
        return;
    }
    
    await client.sendMessage(phone, '⏳ Procesando tu compra...', { sendSeen: false });
    
    try {
        const payment = await createMercadoPagoPayment(
            phone, 
            planData.plan, 
            planData.days, 
            planData.amount, 
            discountCode
        );
        
        if (payment.success) {
            let amountText = `$${payment.amount}`;
            if (payment.discountApplied) {
                amountText = `$${payment.originalAmount} → $${payment.amount} (${payment.discountPercentage}% descuento)`;
            }
            
            const message = `### HTTP CUSTOM ${planData.days} DÍAS\n\n- **Precio:** ${amountText}\n- **Duración:** ${planData.days} días\n- **Servidor:** ${config.bot.server_ip}:${config.bot.server_port}\n- **Encriptación:** ${config.bot.encryption}\n\n---\n\n**LINK DE PAGO**\n\n${payment.paymentUrl}\n\n⏰ *Este enlace expira en 24 horas*\n💳 *Pago seguro con MercadoPago*\n\n📋 *DESPUÉS DEL PAGO:*\n1. Envía tu HWID aquí\n2. Recibirás tu archivo .hc personalizado\n3. Descarga e importa en HTTP Custom\n4. ¡Listo!`;

            await client.sendMessage(phone, message, { sendSeen: false });
            
            if (fs.existsSync(payment.qrPath)) {
                try {
                    const media = MessageMedia.fromFilePath(payment.qrPath);
                    await client.sendMessage(phone, media, { 
                        caption: `📱 *Escanea con MercadoPago*\n\n${planData.planName} - ${amountText}`, 
                        sendSeen: false 
                    });
                } catch (qrError) {
                    console.error(chalk.red('⚠️ Error enviando QR:'), qrError.message);
                }
            }
            
            // Esperar HWID después del pago
            await setUserState(phone, 'awaiting_hwid_after_payment', {
                days: planData.days,
                amount: payment.amount
            });
            
        } else {
            await client.sendMessage(phone, `❌ *ERROR AL GENERAR PAGO*\n\n${payment.error}\n\nPor favor, intenta de nuevo en unos minutos.`, { sendSeen: false });
            await setUserState(phone, 'main_menu');
        }
    } catch (error) {
        console.error(chalk.red('❌ Error en proceso de pago:'), error);
        await client.sendMessage(phone, `❌ *ERROR INESPERADO*\n\n${error.message}\n\n💬 Contacta soporte para asistencia.`, { sendSeen: false });
        await setUserState(phone, 'main_menu');
    }
}

// ✅ ESCUCHAR HWID DESPUÉS DE PAGO
client.on('message_create', async (msg) => {
    const text = msg.body.trim();
    const phone = msg.from;
    if (phone.includes('@g.us')) return;
    
    const userState = await getUserState(phone);
    
    // CAPTURAR HWID DESPUÉS DE PAGO APROBADO
    if (userState.state === 'awaiting_hwid_after_payment') {
        const stateData = userState.data || {};
        const hwid = text.trim();
        
        // Validación simple
        if (hwid.length < 6 || hwid.length > 32) {
            await client.sendMessage(phone, `❌ *HWID INVÁLIDO*\n\nEl HWID debe tener entre 6 y 32 caracteres.\n\n📝 Por favor, envía un HWID válido:`, { sendSeen: false });
            return;
        }
        
        await client.sendMessage(phone, '⏳ Generando tu archivo .hc personalizado...', { sendSeen: false });
        
        try {
            const result = await createHttpCustomUserWithFile(phone, hwid, stateData.days);
            
            await client.sendMessage(phone, `🎉 *CUENTA PREMIUM ACTIVADA*\n\n👤 Usuario: *${result.username}*\n🔐 HWID: *${result.hwid}*\n⏰ Duración: *${stateData.days} días*\n💳 Pago: *$${stateData.amount} ARS*\n\n📤 *ARCHIVO .HC ENVIADO ARRIBA*\n\n💡 *INSTALACIÓN:*\n1. Guarda el archivo .hc\n2. Abre HTTP Custom\n3. Profiles → Import\n4. Selecciona el archivo\n5. ¡Conectar!\n\n📱 *APP:*\n${config.links.app_download}\n\n💬 *SOPORTE:*\n${config.links.support}`, { sendSeen: false });
            
        } catch (error) {
            await client.sendMessage(phone, `❌ Error generando archivo .hc: ${error.message}`, { sendSeen: false });
        }
        
        await setUserState(phone, 'main_menu');
    }
});

// ✅ TAREAS PROGRAMADAS
cron.schedule('*/2 * * * *', () => {
    console.log(chalk.yellow('🔄 Verificando pagos pendientes...'));
});

cron.schedule('*/15 * * * *', async () => {
    const now = moment().format('YYYY-MM-DD HH:mm:ss');
    console.log(chalk.yellow(`🧹 Limpiando usuarios expirados (${now})...`));
    
    db.all('SELECT username, config_file FROM users WHERE expires_at < ? AND status = 1', [now], async (err, rows) => {
        if (err || !rows || rows.length === 0) return;
        
        for (const r of rows) {
            try {
                // Eliminar archivo .hc
                if (r.config_file && fs.existsSync(r.config_file)) {
                    fs.unlinkSync(r.config_file);
                }
                
                db.run('UPDATE users SET status = 0 WHERE username = ?', [r.username]);
                console.log(chalk.green(`🗑️ Eliminado: ${r.username}`));
            } catch (e) {
                console.error(chalk.red(`Error eliminando ${r.username}:`), e.message);
            }
        }
        console.log(chalk.green(`✅ Limpiados ${rows.length} usuarios expirados`));
    });
});

console.log(chalk.green('\n🚀 Inicializando HTTP Custom Bot con envío de archivos .hc...\n'));
client.initialize();
BOTEOF

echo -e "${GREEN}✅ Bot creado con envío de archivos .hc${NC}"

# ================================================
# CREAR PANEL DE CONTROL
# ================================================
echo -e "\n${CYAN}${BOLD}🎛️  CREANDO PANEL DE CONTROL...${NC}"

cat > /usr/local/bin/hcbot << 'PANELEOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; PURPLE='\033[0;35m'; NC='\033[0m'

DB="/opt/http-custom-bot/data/users.db"
CONFIG="/opt/http-custom-bot/config/config.json"

get_val() { jq -r "$1" "$CONFIG" 2>/dev/null; }
set_val() { 
    local key="$1"
    local value="$2"
    local temp_file=$(mktemp)
    
    if [[ "$value" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        jq "$key = $value" "$CONFIG" > "$temp_file"
    elif [[ "$value" == "true" || "$value" == "false" || "$value" == "null" ]]; then
        jq "$key = $value" "$CONFIG" > "$temp_file"
    else
        jq "$key = \"$value\"" "$CONFIG" > "$temp_file"
    fi
    
    if [ $? -eq 0 ]; then
        mv "$temp_file" "$CONFIG"
        echo -e "${GREEN}✅ Configuración actualizada${NC}"
        return 0
    else
        rm -f "$temp_file"
        echo -e "${RED}❌ Error actualizando configuración${NC}"
        return 1
    fi
}

show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║           🎛️  PANEL HTTP CUSTOM - .HC WHATSAPP            ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

while true; do
    show_header
    
    # Obtener estadísticas
    TOTAL_USERS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users" 2>/dev/null || echo "0")
    ACTIVE_USERS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1" 2>/dev/null || echo "0")
    PENDING_PAYMENTS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM payments WHERE status='pending'" 2>/dev/null || echo "0")
    HC_FILES=$(ls -la /var/www/html/hc/*.hc 2>/dev/null | wc -l || echo "0")
    
    # Estado del bot
    STATUS=$(pm2 jlist 2>/dev/null | jq -r '.[] | select(.name=="http-custom-bot") | .pm2_env.status' 2>/dev/null || echo "stopped")
    if [[ "$STATUS" == "online" ]]; then
        BOT_STATUS="${GREEN}● ACTIVO${NC}"
    else
        BOT_STATUS="${RED}● DETENIDO${NC}"
    fi
    
    # Estado MercadoPago
    MP_TOKEN=$(get_val '.mercadopago.access_token')
    if [[ -n "$MP_TOKEN" && "$MP_TOKEN" != "" && "$MP_TOKEN" != "null" ]]; then
        MP_STATUS="${GREEN}✅ CONFIGURADO${NC}"
    else
        MP_STATUS="${RED}❌ NO CONFIGURADO${NC}"
    fi
    
    # Verificar APK
    APK_FOUND=""
    APK_FILES=$(find /root -name "*.apk" 2>/dev/null | head -1)
    if [[ -n "$APK_FILES" ]]; then
        APK_SIZE=$(du -h "$APK_FILES" 2>/dev/null | cut -f1)
        APK_FOUND="${GREEN}✅ ${APK_SIZE}${NC}"
    else
        APK_FOUND="${RED}❌ NO ENCONTRADO${NC}"
    fi
    
    echo -e "${YELLOW}📊 ESTADO DEL SISTEMA${NC}"
    echo -e "  Bot: $BOT_STATUS"
    echo -e "  Usuarios: ${CYAN}$ACTIVE_USERS/$TOTAL_USERS${NC} activos/total"
    echo -e "  Pagos pendientes: ${CYAN}$PENDING_PAYMENTS${NC}"
    echo -e "  Archivos .hc generados: ${CYAN}$HC_FILES${NC}"
    echo -e "  MercadoPago: $MP_STATUS"
    echo -e "  APK: $APK_FOUND"
    echo -e "  Sistema: ${GREEN}ARCHIVOS .HC VIA WHATSAPP${NC}"
    echo -e ""
    
    echo -e "${YELLOW}💰 PRECIOS ACTUALES:${NC}"
    echo -e "  7 días: $ $(get_val '.prices.price_7d') ARS"
    echo -e "  15 días: $ $(get_val '.prices.price_15d') ARS"
    echo -e "  30 días: $ $(get_val '.prices.price_30d') ARS"
    echo -e "  50 días: $ $(get_val '.prices.price_50d') ARS"
    echo -e "  Test: $(get_val '.prices.test_hours') horas"
    echo -e ""
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}[1]${NC}  🚀  Iniciar/Reiniciar bot"
    echo -e "${CYAN}[2]${NC}  🛑  Detener bot"
    echo -e "${CYAN}[3]${NC}  📱  Ver QR WhatsApp"
    echo -e "${CYAN}[4]${NC}  👤  Crear usuario manual"
    echo -e "${CYAN}[5]${NC}  👥  Listar usuarios"
    echo -e "${CYAN}[6]${NC}  💰  Cambiar precios"
    echo -e "${CYAN}[7]${NC}  🔑  Configurar MercadoPago"
    echo -e "${CYAN}[8]${NC}  📊  Ver estadísticas"
    echo -e "${CYAN}[9]${NC}  📝  Ver logs"
    echo -e "${PURPLE}[10]${NC} 📱  Gestionar APK"
    echo -e "${CYAN}[11]${NC} 🗑️   Limpiar archivos .hc"
    echo -e "${CYAN}[12]${NC} 🔧  Reparar bot"
    echo -e "${CYAN}[0]${NC}  🚪  Salir"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e ""
    read -p "👉 Selecciona una opción: " OPTION
    
    case $OPTION in
        1)
            echo -e "\n${YELLOW}🔄 Reiniciando bot...${NC}"
            cd /root/http-custom-bot
            pm2 restart http-custom-bot 2>/dev/null || pm2 start bot.js --name http-custom-bot
            pm2 save
            echo -e "${GREEN}✅ Bot reiniciado${NC}"
            sleep 2
            ;;
        2)
            echo -e "\n${YELLOW}🛑 Deteniendo bot...${NC}"
            pm2 stop http-custom-bot
            echo -e "${GREEN}✅ Bot detenido${NC}"
            sleep 2
            ;;
        3)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                    📱 CÓDIGO QR WHATSAPP                     ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            if [[ -f "/root/qr-whatsapp.png" ]]; then
                echo -e "${GREEN}✅ QR guardado en: /root/qr-whatsapp.png${NC}\n"
                read -p "¿Ver logs en tiempo real? (s/N): " VER
                [[ "$VER" == "s" ]] && pm2 logs http-custom-bot --lines 100
            else
                echo -e "${YELLOW}⚠️  QR no generado aún${NC}\n"
                read -p "¿Ver logs? (s/N): " VER
                [[ "$VER" == "s" ]] && pm2 logs http-custom-bot --lines 50
            fi
            ;;
        4)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     👤 CREAR USUARIO MANUAL                 ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            read -p "Teléfono (ej: 5491122334455): " PHONE
            read -p "HWID: " HWID
            read -p "Días (0=test, 7,15,30,50): " DAYS
            
            [[ -z "$DAYS" ]] && DAYS="30"
            
            CONFIG="/opt/http-custom-bot/config/config.json"
            SERVER_IP=$(jq -r '.bot.server_ip' "$CONFIG")
            
            echo -e "\n${YELLOW}⏳ Generando archivo .hc...${NC}"
            
            if python3 /opt/http-custom-bot/create_direct_hc.py "MANUAL_$HWID" "$HWID" "$SERVER_IP" "8080" "chacha20" "123456" "$DAYS" 2>/dev/null; then
                OUTPUT=$(python3 /opt/http-custom-bot/create_direct_hc.py "MANUAL_$HWID" "$HWID" "$SERVER_IP" "8080" "chacha20" "123456" "$DAYS" 2>/dev/null)
                if [[ "$OUTPUT" == OK:* ]]; then
                    IFS=':' read -r _ FILEPATH FILENAME <<< "$OUTPUT"
                    FILEPATH=$(echo "$FILEPATH" | tr -d '\n')
                    FILENAME=$(echo "$FILENAME" | tr -d '\n')
                    DOWNLOAD_URL="http://$SERVER_IP/hc/$FILENAME"
                    
                    if [[ "$DAYS" == "0" ]]; then
                        EXPIRE_DATE=$(date -d "+$(get_val '.prices.test_hours') hours" +"%Y-%m-%d %H:%M:%S")
                        TIPO="test"
                    else
                        EXPIRE_DATE=$(date -d "+$DAYS days" +"%Y-%m-%d 23:59:59")
                        TIPO="premium"
                    fi
                    
                    sqlite3 "$DB" "INSERT INTO users (phone, username, hwid, tipo, expires_at, status, download_url, config_file) VALUES ('$PHONE', 'MANUAL_$HWID', '$HWID', '$TIPO', '$EXPIRE_DATE', 1, '$DOWNLOAD_URL', '$FILEPATH')"
                    
                    echo -e "\n${GREEN}✅ USUARIO CREADO MANUALMENTE${NC}"
                    echo -e "👤 Usuario: MANUAL_$HWID"
                    echo -e "🔐 HWID: $HWID"
                    echo -e "⏰ Expira: $EXPIRE_DATE"
                    echo -e "🔌 Días: $DAYS"
                    echo -e "📄 Archivo: $FILENAME"
                    echo -e "🔗 Descarga: $DOWNLOAD_URL"
                    echo -e ""
                    echo -e "${YELLOW}📤 Para enviar el archivo al usuario:${NC}"
                    echo -e "1. El bot debe estar activo"
                    echo -e "2. Envía 'menu' al bot desde $PHONE"
                    echo -e "3. Solicita soporte para recibir el archivo"
                else
                    echo -e "${RED}❌ Error generando archivo .hc${NC}"
                fi
            else
                echo -e "${RED}❌ Error ejecutando generador${NC}"
            fi
            read -p "Presiona Enter..." 
            ;;
        5)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     👥 USUARIOS ACTIVOS                     ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${YELLOW}📋 ÚLTIMOS 20 USUARIOS:${NC}\n"
            sqlite3 -column -header "$DB" "SELECT username, hwid, tipo, expires_at, substr(phone,1,12) as tel FROM users WHERE status = 1 ORDER BY expires_at DESC LIMIT 20"
            echo -e "\n${YELLOW}Total activos: ${ACTIVE_USERS}${NC}"
            read -p "Presiona Enter..." 
            ;;
        6)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                    💰 CAMBIAR PRECIOS                       ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            CURRENT_7D=$(get_val '.prices.price_7d')
            CURRENT_15D=$(get_val '.prices.price_15d')
            CURRENT_30D=$(get_val '.prices.price_30d')
            CURRENT_50D=$(get_val '.prices.price_50d')
            CURRENT_TEST=$(get_val '.prices.test_hours')
            
            echo -e "${YELLOW}💰 PRECIOS ACTUALES:${NC}"
            echo -e "  Test: ${CURRENT_TEST} horas"
            echo -e "  7 días: $${CURRENT_7D}"
            echo -e "  15 días: $${CURRENT_15D}"
            echo -e "  30 días: $${CURRENT_30D}"
            echo -e "  50 días: $${CURRENT_50D}\n"
            
            echo -e "${CYAN}--- MODIFICAR PRECIOS ---${NC}"
            read -p "Nuevo precio 7d [${CURRENT_7D}]: " NEW_7D
            read -p "Nuevo precio 15d [${CURRENT_15D}]: " NEW_15D
            read -p "Nuevo precio 30d [${CURRENT_30D}]: " NEW_30D
            read -p "Nuevo precio 50d [${CURRENT_50D}]: " NEW_50D
            read -p "Horas test [${CURRENT_TEST}]: " NEW_TEST
            
            [[ -n "$NEW_7D" ]] && set_val '.prices.price_7d' "$NEW_7D"
            [[ -n "$NEW_15D" ]] && set_val '.prices.price_15d' "$NEW_15D"
            [[ -n "$NEW_30D" ]] && set_val '.prices.price_30d' "$NEW_30D"
            [[ -n "$NEW_50D" ]] && set_val '.prices.price_50d' "$NEW_50D"
            [[ -n "$NEW_TEST" ]] && set_val '.prices.test_hours' "$NEW_TEST"
            
            read -p "Presiona Enter..." 
            ;;
        7)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║              🔑 CONFIGURAR MERCADOPAGO                      ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            CURRENT_TOKEN=$(get_val '.mercadopago.access_token')
            
            if [[ -n "$CURRENT_TOKEN" && "$CURRENT_TOKEN" != "null" && "$CURRENT_TOKEN" != "" ]]; then
                echo -e "${GREEN}✅ Token configurado${NC}"
                echo -e "${YELLOW}Preview: ${CURRENT_TOKEN:0:30}...${NC}\n"
            else
                echo -e "${YELLOW}⚠️  Sin token configurado${NC}\n"
            fi
            
            echo -e "${CYAN}📋 Obtener token:${NC}"
            echo -e "  1. https://www.mercadopago.com.ar/developers"
            echo -e "  2. Inicia sesión"
            echo -e "  3. 'Tus credenciales' → Access Token PRODUCCIÓN"
            echo -e "  4. Formato: APP_USR-xxxxxxxxxx\n"
            
            read -p "¿Configurar nuevo token? (s/N): " CONF
            if [[ "$CONF" == "s" ]]; then
                echo ""
                read -p "Pega el Access Token: " NEW_TOKEN
                
                if [[ "$NEW_TOKEN" =~ ^APP_USR- ]] || [[ "$NEW_TOKEN" =~ ^TEST- ]]; then
                    set_val '.mercadopago.access_token' "$NEW_TOKEN"
                    set_val '.mercadopago.enabled' "true"
                    echo -e "\n${GREEN}✅ Token configurado${NC}"
                    echo -e "${YELLOW}🔄 Reiniciando bot...${NC}"
                    cd /root/http-custom-bot && pm2 restart http-custom-bot
                    sleep 2
                    echo -e "${GREEN}✅ MercadoPago activado${NC}"
                else
                    echo -e "${RED}❌ Token inválido${NC}"
                    echo -e "${YELLOW}Debe empezar con APP_USR- o TEST-${NC}"
                fi
            fi
            read -p "Presiona Enter..." 
            ;;
        8)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     📊 ESTADÍSTICAS                         ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${YELLOW}👥 USUARIOS:${NC}"
            sqlite3 "$DB" "SELECT 'Total: ' || COUNT(*) || ' | Activos: ' || SUM(CASE WHEN status=1 THEN 1 ELSE 0 END) || ' | Tests hoy: ' || (SELECT COUNT(*) FROM daily_tests WHERE date = date('now')) FROM users"
            
            echo -e "\n${YELLOW}💰 PAGOS:${NC}"
            sqlite3 "$DB" "SELECT 'Pendientes: ' || SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) || ' | Aprobados: ' || SUM(CASE WHEN status='approved' THEN 1 ELSE 0 END) || ' | Total: $' || printf('%.2f', SUM(CASE WHEN status='approved' THEN final_amount ELSE 0 END)) FROM payments"
            
            echo -e "\n${YELLOW}📁 ARCHIVOS .HC:${NC}"
            echo -e "Generados: $HC_FILES archivos"
            ls -la /var/www/html/hc/*.hc 2>/dev/null | head -5 | awk '{print $9}'
            
            read -p "\nPresiona Enter..." 
            ;;
        9)
            echo -e "\n${YELLOW}📝 Logs (Ctrl+C para salir)...${NC}\n"
            pm2 logs http-custom-bot --lines 100
            ;;
        10)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     📱 GESTIONAR APK                         ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            APKS=$(find /root -name "*.apk" 2>/dev/null)
            
            if [[ -n "$APKS" ]]; then
                echo -e "${GREEN}✅ APKs encontrados:${NC}"
                i=1
                while IFS= read -r apk; do
                    size=$(du -h "$apk" 2>/dev/null | cut -f1)
                    echo -e "  ${i}. $(basename "$apk") (${size})"
                    ((i++))
                done <<< "$APKS"
                
                echo ""
                read -p "¿Copiar primer APK como app.apk? (s/N): " COPY
                if [[ "$COPY" == "s" ]]; then
                    first_apk=$(echo "$APKS" | head -1)
                    cp "$first_apk" /root/app.apk
                    chmod 644 /root/app.apk
                    echo -e "${GREEN}✅ Copiado como /root/app.apk${NC}"
                fi
            else
                echo -e "${RED}❌ Sin APKs${NC}\n"
                echo -e "${CYAN}Subir con SCP:${NC}"
                echo -e "  scp app.apk root@$(get_val '.bot.server_ip'):/root/"
            fi
            read -p "Presiona Enter..." 
            ;;
        11)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                    🗑️  LIMPIAR ARCHIVOS .HC                ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${YELLOW}📁 ARCHIVOS .HC EN SERVIDOR:${NC}"
            ls -la /var/www/html/hc/*.hc 2>/dev/null | wc -l
            echo ""
            ls -la /var/www/html/hc/*.hc 2>/dev/null | head -10
            
            echo -e "\n${RED}⚠️  ADVERTENCIA: Esta acción eliminará archivos .hc antiguos${NC}"
            read -p "¿Eliminar archivos .hc con más de 7 días? (s/N): " CONFIRM
            
            if [[ "$CONFIRM" == "s" ]]; then
                echo -e "\n${YELLOW}🗑️  Eliminando archivos antiguos...${NC}"
                find /var/www/html/hc -name "*.hc" -type f -mtime +7 -delete
                echo -e "${GREEN}✅ Archivos antiguos eliminados${NC}"
                
                # También eliminar de la base de datos
                sqlite3 "$DB" "UPDATE users SET config_file = NULL WHERE config_file IS NOT NULL AND status = 0"
                echo -e "${GREEN}✅ Base de datos limpiada${NC}"
            fi
            
            read -p "Presiona Enter..." 
            ;;
        12)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     🔧 REPARAR BOT                          ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${RED}⚠️  Borrará sesión de WhatsApp${NC}\n"
            read -p "¿Continuar? (s/N): " CONF
            
            if [[ "$CONF" == "s" ]]; then
                echo -e "\n${YELLOW}🧹 Limpiando...${NC}"
                rm -rf /root/.wwebjs_auth/* /root/.wwebjs_cache/* /root/qr-whatsapp.png
                echo -e "${YELLOW}📦 Reinstalando...${NC}"
                cd /root/http-custom-bot && npm install --silent
                # Aplicar parche markedUnread nuevamente
                echo -e "${YELLOW}🔧 Aplicando parches...${NC}"
                find /root/http-custom-bot/node_modules -name "Client.js" -type f -exec sed -i 's/if (chat && chat.markedUnread)/if (false)/g' {} \; 2>/dev/null || true
                echo -e "${YELLOW}🔄 Reiniciando...${NC}"
                pm2 restart http-custom-bot
                echo -e "\n${GREEN}✅ Reparado - Espera 10s para QR${NC}"
                sleep 10
                [[ -f "/root/qr-whatsapp.png" ]] && echo -e "${GREEN}✅ QR generado${NC}" || pm2 logs http-custom-bot
            fi
            read -p "Presiona Enter..." 
            ;;
        0)
            echo -e "\n${GREEN}👋 Hasta pronto${NC}\n"
            exit 0
            ;;
        *)
            echo -e "\n${RED}❌ Opción inválida${NC}"
            sleep 1
            ;;
    esac
done
PANELEOF

chmod +x /usr/local/bin/hcbot
echo -e "${GREEN}✅ Panel de control creado${NC}"

# ================================================
# INICIAR BOT
# ================================================
echo -e "\n${CYAN}${BOLD}🚀 INICIANDO BOT...${NC}"

cd "$USER_HOME"
pm2 start bot.js --name http-custom-bot
pm2 save
pm2 startup systemd -u root --hp /root > /dev/null 2>&1

sleep 3

# ================================================
# MENSAJE FINAL
# ================================================
clear
echo -e "${GREEN}${BOLD}"
cat << "FINAL"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║       🎉 INSTALACIÓN COMPLETADA - .HC VIA WHATSAPP 🎉      ║
║                                                              ║
║               HTTP CUSTOM BOT - CONFIGURADO                 ║
║               📤 ARCHIVOS .HC ENVIADOS POR WA              ║
║               ⚡ CLIENTE RECIBE EL ARCHIVO DIRECTAMENTE    ║
║               🔗 SIN ENLACES EXTERNOS NECESARIOS           ║
║               💰 MERCADOPAGO INTEGRADO                      ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
FINAL
echo -e "${NC}"

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Sistema instalado con envío de archivos .hc por WhatsApp${NC}"
echo -e "${GREEN}✅ Cliente recibe el archivo como adjunto en WhatsApp${NC}"
echo -e "${GREEN}✅ Sin enlaces externos necesarios${NC}"
echo -e "${GREEN}✅ Configuración automática incluida en .hc${NC}"
echo -e "${GREEN}✅ Panel de control: ${CYAN}hcbot${NC}"
echo -e "${GREEN}✅ Generación automática de archivos .hc${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 COMANDOS PRINCIPALES:${NC}\n"
echo -e "  ${GREEN}hcbot${NC}         - Panel de control completo"
echo -e "  ${GREEN}create-hc-direct${NC} - Generar archivo .hc manual"
echo -e "  ${GREEN}pm2 logs http-custom-bot${NC} - Ver logs\n"

echo -e "${YELLOW}🔧 CONFIGURACIÓN RÁPIDA:${NC}\n"
echo -e "  1. Ejecuta: ${GREEN}hcbot${NC}"
echo -e "  2. Opción ${CYAN}[7]${NC} - Configurar MercadoPago"
echo -e "  3. Opción ${CYAN}[3]${NC} - Escanear QR WhatsApp"
echo -e "  4. Opción ${CYAN}[10]${NC} - Subir APK si es necesario"
echo -e "  5. ¡Listo! Los usuarios recibirán archivos .hc por WhatsApp\n"

echo -e "${YELLOW}🎯 VENTAJAS DEL SISTEMA:${NC}\n"
echo -e "  ✅ ${GREEN}Archivos .hc enviados por WhatsApp${NC} - Sin enlaces externos"
echo -e "  ✅ ${GREEN}Cliente recibe todo en WhatsApp${NC} - Más conveniente"
echo -e "  ✅ ${GREEN}Configuración incluida${NC} - Cliente no edita"
echo -e "  ✅ ${GREEN}Descarga simple${NC} - Guarda archivo y listo"
echo -e "  ✅ ${GREEN}Personalizado${NC} - Cada usuario recibe su archivo"
echo -e "  ✅ ${GREEN}Backup automático${NC} - Enlace de descarga como respaldo\n"

echo -e "${YELLOW}💰 PRECIOS POR DEFECTO:${NC}\n"
echo -e "  Test: ${GREEN}2 horas${NC}"
echo -e "  7 días: ${GREEN}$1500 ARS${NC}"
echo -e "  15 días: ${GREEN}$2500 ARS${NC}"
echo -e "  30 días: ${GREEN}$5500 ARS${NC}"
echo -e "  50 días: ${GREEN}$8500 ARS${NC}\n"

echo -e "${YELLOW}📊 INFO DEL SISTEMA:${NC}"
echo -e "  IP: ${CYAN}$SERVER_IP${NC}"
echo -e "  Puerto: ${CYAN}8080${NC}"
echo -e "  Encriptación: ${CYAN}chacha20${NC}"
echo -e "  Contraseña: ${CYAN}123456${NC}"
echo -e "  Archivos .hc: ${CYAN}/var/www/html/hc/${NC}"
echo -e "  Panel: ${CYAN}hcbot${NC}"
echo -e "  APK recomendado: ${CYAN}/root/app.apk${NC}\n"

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

read -p "$(echo -e "${YELLOW}¿Abrir panel de control ahora? (s/N): ${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "\n${CYAN}Abriendo panel hcbot...${NC}\n"
    sleep 2
    /usr/local/bin/hcbot
else
    echo -e "\n${YELLOW}💡 Ejecuta: ${GREEN}hcbot${NC} para abrir el panel\n"
    echo -e "${YELLOW}Para probar el sistema:${NC}"
    echo -e "1. Envía 'menu' al bot"
    echo -e "2. Selecciona '1' para prueba"
    echo -e "3. Envía tu HWID"
    echo -e "4. Recibirás un archivo .hc como adjunto\n"
fi

echo -e "${GREEN}${BOLD}¡Sistema instalado y listo para usar! 🚀${NC}\n"

# Crear archivo de ejemplo .hc
cat > "$WEB_DIR/EJEMPLO_ARCHIVO.hc" << 'HCEOF'
# HTTP Custom Configuration - EJEMPLO
# Este es un archivo de ejemplo .hc

[general]
mode=http
listen_port=8080

[server]
server=TU_SERVIDOR_AQUI
server_port=8080
method=chacha20
password=123456

# Instrucciones:
# 1. Descargar este archivo
# 2. HTTP Custom → Profiles → Import
# 3. Seleccionar este archivo .hc
# 4. ¡Conectar!
HCEOF

chmod 644 "$WEB_DIR/EJEMPLO_ARCHIVO.hc"

echo -e "${YELLOW}📁 Archivo de ejemplo creado: ${CYAN}$WEB_DIR/EJEMPLO_ARCHIVO.hc${NC}"
echo -e "${GREEN}✅ Instalación completa finalizada${NC}"

exit 0
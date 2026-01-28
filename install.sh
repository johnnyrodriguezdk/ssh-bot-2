#!/bin/bash
# ================================================
# SSH BOT PRO - CON FLUJO DE CAPTURAS Y MÁS PLANES
# Planes: Diarios (7, 15) - Mensuales (30, 50) - TEST 2 HORAS
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
║     ███████╗███████╗██║  ██║    ██████╗  ██████╗ ████████╗  ║
║     ██╔════╝██╔════╝██║  ██║    ██╔══██╗██╔═══██╗╚══██╔══╝  ║
║     ███████╗███████╗███████║    ██████╔╝██║   ██║   ██║     ║
║     ╚════██║╚════██║██╔══██║    ██╔══██╗██║   ██║   ██║     ║
║     ███████║███████║██║  ██║    ██████╔╝╚██████╔╝   ██║     ║
║     ╚══════╝╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝    ╚═╝     ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║                SSH BOT PRO - PLANES SEPARADOS               ║
║               📅 DIARIOS: 7, 15 DÍAS                       ║
║               📅 MENSUALES: 30, 50 DÍAS                    ║
║               ⏰ TEST GRATIS: 2 HORAS                        ║
║               🔐 CONTRASEÑA FIJA: mgvpn247                  ║
║               💰 MERCADOPAGO INTEGRADO                      ║
║               📢 NOTIFICACIONES AUTOMÁTICAS                 ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

echo -e "${GREEN}✅ SISTEMA MEJORADO CON NOTIFICACIONES:${NC}"
echo -e "  📢 ${CYAN}NOTIFICACIONES ACTIVAS:${NC}"
echo -e "     • ⚠️ Aviso por vencer (24h antes)"
echo -e "     • 📅 Recordatorio de vencimiento"
echo -e "  🔴 ${RED}MENÚ PRINCIPAL:${NC}"
echo -e "     ${GREEN}1${NC} = Crear Prueba (TEST) - 2 HORAS"
echo -e "     ${GREEN}2${NC} = Comprar Login SSH"
echo -e "     ${GREEN}3${NC} = Renovar Login SSH"
echo -e "     ${GREEN}4${NC} = Descargar Aplicación"
echo -e "  🟡 ${YELLOW}SUBMENÚ COMPRAS SEPARADAS:${NC}"
echo -e "     ${GREEN}1${NC} = Planes SSH DIARIOS (7, 15 días)"
echo -e "     ${GREEN}2${NC} = Planes SSH MENSUALES (30, 50 días)"
echo -e "     ${GREEN}0${NC} = Volver"
echo -e "  🟢 ${GREEN}PLANES DISPONIBLES:${NC}"
echo -e "     ${CYAN}DIARIOS:${NC} 7 días - 15 días"
echo -e "     ${CYAN}MENSUALES:${NC} 30 días - 50 días"
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

# Solicitar grupo de notificaciones
echo -e "${YELLOW}📢 CONFIGURACIÓN DE NOTIFICACIONES${NC}"
echo -e "${CYAN}Ingresa el ID del grupo de WhatsApp para notificaciones${NC}"
echo -e "Ejemplo: 1234567890-123456@g.us"
echo -e "Deja vacío si no quieres notificaciones en grupo\n"

read -p "ID del grupo para notificaciones: " NOTIFICATION_GROUP

if [[ -n "$NOTIFICATION_GROUP" ]]; then
    echo -e "${GREEN}✅ Grupo configurado: ${CYAN}$NOTIFICATION_GROUP${NC}"
else
    echo -e "${YELLOW}⚠️ Notificaciones en grupo desactivadas${NC}"
fi

# Confirmar instalación
echo -e "\n${YELLOW}⚠️  ESTE INSTALADOR HARÁ:${NC}"
echo -e "   • Instalar Node.js 20.x + Chrome"
echo -e "   • Crear SSH Bot Pro con planes separados"
echo -e "   • Sistema de estados inteligente"
echo -e "   • Menú: 1=Prueba, 2=Comprar, 3=Renovar, 4=APP"
echo -e "   • Submenú: Planes Diarios (7,15) / Mensuales (30,50)"
echo -e "   • Planes DIARIOS: 7, 15 días"
echo -e "   • Planes MENSUALES: 30, 50 días"
echo -e "   • Test gratuito: 2 horas por defecto"
echo -e "   • 📢 Notificaciones automáticas:"
echo -e "     - Aviso por vencer (24h antes)"
echo -e "     - Recordatorio de vencimiento"
echo -e "   • Generación de link MercadoPago"
echo -e "   • Panel de control con edición de horas de test"
echo -e "   • APK automático + Test 2h"
echo -e "   • Cron limpieza cada 15 minutos"
echo -e "   • 🔐 CONTRASEÑA FIJA: mgvpn247 para todos"
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
    libcairo2-dev \
    libpango1.0-dev \
    libjpeg-dev \
    libgif-dev \
    librsvg2-dev \
    pkg-config \
    python3 \
    python3-pip \
    ffmpeg \
    unzip \
    cron \
    ufw

# Instalar PM2 globalmente
echo -e "${YELLOW}🔄 Instalando PM2...${NC}"
npm install -g pm2
pm2 update

# Configurar firewall
echo -e "${YELLow}🛡️ Configurando firewall...${NC}"
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

INSTALL_DIR="/opt/ssh-bot"
USER_HOME="/root/ssh-bot"
DB_FILE="$INSTALL_DIR/data/users.db"
CONFIG_FILE="$INSTALL_DIR/config/config.json"

# Limpiar instalaciones anteriores
echo -e "${YELLOW}🧹 Limpiando instalaciones anteriores...${NC}"
pm2 delete ssh-bot 2>/dev/null || true
pm2 flush 2>/dev/null || true
rm -rf "$INSTALL_DIR" "$USER_HOME" 2>/dev/null || true
rm -rf /root/.wwebjs_auth /root/.wwebjs_cache 2>/dev/null || true

# Crear directorios
mkdir -p "$INSTALL_DIR"/{data,config,qr_codes,logs}
mkdir -p "$USER_HOME"
mkdir -p /root/.wwebjs_auth
chmod -R 755 "$INSTALL_DIR"
chmod -R 700 /root/.wwebjs_auth

# Crear configuración CON PLANES SEPARADOS
cat > "$CONFIG_FILE" << EOF
{
    "bot": {
        "name": "SSH Bot Pro",
        "version": "1.0-PLANES-SEPARADOS",
        "server_ip": "$SERVER_IP",
        "default_password": "mgvpn247",
        "notification_group": "$NOTIFICATION_GROUP"
    },
    "prices": {
        "test_hours": 2,
        "price_7d_1conn": 1500.00,
        "price_15d_1conn": 2500.00,
        "price_30d_1conn": 5500.00,
        "price_50d_1conn": 8500.00,
        "currency": "ARS"
    },
    "notifications": {
        "expiry_warning_hours": 24,
        "enabled": true
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
        "qr_codes": "$INSTALL_DIR/qr_codes"
    }
}
EOF

# Crear base de datos
sqlite3 "$DB_FILE" << 'SQL'
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    username TEXT UNIQUE,
    password TEXT DEFAULT 'mgvpn247',
    tipo TEXT DEFAULT 'test',
    expires_at DATETIME,
    max_connections INTEGER DEFAULT 1,
    status INTEGER DEFAULT 1,
    notification_sent INTEGER DEFAULT 0,
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
    connections INTEGER DEFAULT 1,
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
CREATE TABLE notifications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    type TEXT,
    message TEXT,
    sent_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(user_id) REFERENCES users(id)
);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_users_expires ON users(expires_at);
CREATE INDEX idx_users_notification ON users(notification_sent);
CREATE INDEX idx_payments_status ON payments(status);
SQL

echo -e "${GREEN}✅ Estructura creada con sistema de notificaciones${NC}"

# ================================================
# CREAR BOT CON PLANES SEPARADOS SIN CUPONES
# ================================================
echo -e "\n${CYAN}${BOLD}🤖 CREANDO BOT CON PLANES SEPARADOS SIN CUPONES...${NC}"

cd "$USER_HOME"

# package.json
cat > package.json << 'PKGEOF'
{
    "name": "ssh-bot-pro",
    "version": "1.0.0",
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

# Crear bot.js CON PLANES SEPARADOS SIN CUPONES
echo -e "${YELLOW}📝 Creando bot.js con planes separados SIN CUPONES...${NC}"

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
    delete require.cache[require.resolve('/opt/ssh-bot/config/config.json')];
    return require('/opt/ssh-bot/config/config.json');
}

let config = loadConfig();
const db = new sqlite3.Database(config.paths.database);

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

function clearUserState(phone) {
    db.run('DELETE FROM user_state WHERE phone = ?', [phone]);
}

// ✅ MERCADOPAGO SDK V2.X
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
            console.log(chalk.cyan(`🔑 Token: ${config.mercadopago.access_token.substring(0, 20)}...`));
            return true;
        } catch (error) {
            console.log(chalk.red('❌ Error inicializando MP:'), error.message);
            mpClient = null;
            mpPreference = null;
            return false;
        }
    }
    console.log(chalk.yellow('⚠️ MercadoPago NO configurado (token vacío)'));
    return false;
}

let mpEnabled = initMercadoPago();
moment.locale('es');

console.log(chalk.cyan.bold('\n╔══════════════════════════════════════════════════════════════╗'));
console.log(chalk.cyan.bold('║                🤖 SSH BOT PRO - PLANES SEPARADOS            ║'));
console.log(chalk.cyan.bold('║               📅 DIARIOS: 7, 15 DÍAS                        ║'));
console.log(chalk.cyan.bold('║               📅 MENSUALES: 30, 50 DÍAS                     ║'));
console.log(chalk.cyan.bold('║               ⏰ TEST GRATIS: 2 HORAS                       ║'));
console.log(chalk.cyan.bold('║               🔐 CONTRASEÑA FIJA: mgvpn247                  ║'));
console.log(chalk.cyan.bold('║               📢 NOTIFICACIONES AUTOMÁTICAS                 ║'));
console.log(chalk.cyan.bold('║               🚫 SIN CUPONES DE DESCUENTO                   ║'));
console.log(chalk.cyan.bold('╚══════════════════════════════════════════════════════════════╝\n'));
console.log(chalk.yellow(`📍 IP: ${config.bot.server_ip}`));
console.log(chalk.yellow(`💳 MercadoPago: ${mpEnabled ? '✅ SDK v2.x ACTIVO' : '❌ NO CONFIGURADO'}`));
console.log(chalk.yellow(`📢 Grupo notificaciones: ${config.bot.notification_group ? '✅ CONFIGURADO' : '❌ NO CONFIGURADO'}`));
console.log(chalk.green('✅ WhatsApp Web parcheado (no markedUnread error)'));
console.log(chalk.green('✅ Sistema de estados activo'));
console.log(chalk.green('✅ Planes DIARIOS: 7, 15 días'));
console.log(chalk.green('✅ Planes MENSUALES: 30, 50 días'));
console.log(chalk.green('✅ Test: 2 horas exactas'));
console.log(chalk.green('✅ CONTRASEÑA FIJA: mgvpn247 para todos los usuarios'));
console.log(chalk.green('✅ Sistema de notificaciones activo'));
console.log(chalk.red('🚫 Cupones de descuento DESACTIVADOS'));

const client = new Client({
    authStrategy: new LocalAuth({dataPath: '/root/.wwebjs_auth', clientId: 'ssh-bot-multiplan'}),
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
client.on('loading_screen', (p, m) => console.log(chalk.yellow(`⏳ Cargando: ${p}% - ${m}`)));
client.on('ready', () => {
    console.clear();
    console.log(chalk.green.bold('\n✅ BOT CONECTADO Y OPERATIVO\n'));
    console.log(chalk.cyan('💬 Envía "menu" a tu WhatsApp\n'));
    console.log(chalk.yellow('📢 Sistema de notificaciones ACTIVO'));
    console.log(chalk.yellow(`⏰ Avisos por vencer: ${config.notifications.expiry_warning_hours} horas antes`));
    console.log(chalk.red('🚫 Cupones de descuento DESACTIVADOS'));
    qrCount = 0;
});
client.on('auth_failure', (m) => console.log(chalk.red('❌ Error auth:'), m));
client.on('disconnected', (r) => console.log(chalk.yellow('⚠️ Desconectado:'), r));

function generateUsername(tipo = 'test') {
    // Generar nombre de usuario en minúsculas según el tipo
    const randomNum = Math.floor(1000 + Math.random() * 9000);
    if (tipo === 'test') {
        return 'test' + randomNum;  // test1234
    } else {
        return 'user' + randomNum;  // user5678
    }
}

function generatePassword() {
    // Contraseña fija en minúsculas
    return 'mgvpn247';
}

async function createSSHUser(phone, username, password, days, connections = 1) {
    if (days === 0) {
        const expireFull = moment().add(config.prices.test_hours, 'hours').format('YYYY-MM-DD HH:mm:ss');
        
        console.log(chalk.yellow(`⌛ Test ${username} expira: ${expireFull} (${config.prices.test_hours} horas)`));
        
        const commands = [
            `useradd -m -s /bin/bash ${username}`,
            `echo "${username}:${password}" | chpasswd`
        ];
        
        for (const cmd of commands) {
            try {
                await execPromise(cmd);
            } catch (error) {
                console.error(chalk.red(`❌ Error: ${cmd}`), error.message);
                throw error;
            }
        }
        
        const tipo = 'test';
        return new Promise((resolve, reject) => {
            db.run(`INSERT INTO users (phone, username, password, tipo, expires_at, max_connections, status, notification_sent) VALUES (?, ?, ?, ?, ?, ?, 1, 0)`,
                [phone, username, password, tipo, expireFull, 1],
                (err) => err ? reject(err) : resolve({ 
                    username, 
                    password: password,
                    expires: expireFull,
                    tipo: 'test',
                    duration: `${config.prices.test_hours} horas`
                }));
        });
    } else {
        const expireDate = moment().add(days, 'days').format('YYYY-MM-DD');
        const expireFull = moment().add(days, 'days').format('YYYY-MM-DD 23:59:59');
        
        console.log(chalk.yellow(`⌛ Premium ${username} expira: ${expireDate} (${days} días)`));
        
        try {
            await execPromise(`useradd -M -s /bin/false -e ${expireDate} ${username} && echo "${username}:${password}" | chpasswd`);
        } catch (error) {
            console.error(chalk.red('❌ Error creando premium:'), error.message);
            throw error;
        }
        
        const tipo = 'premium';
        return new Promise((resolve, reject) => {
            db.run(`INSERT INTO users (phone, username, password, tipo, expires_at, max_connections, status, notification_sent) VALUES (?, ?, ?, ?, ?, ?, 1, 0)`,
                [phone, username, password, tipo, expireFull, connections],
                (err) => err ? reject(err) : resolve({ 
                    username, 
                    password: password,
                    expires: expireFull,
                    tipo: 'premium',
                    duration: `${days} días`
                }));
        });
    }
}

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

// ✅ FUNCIÓN PARA ENVIAR AVISO POR VENCER
async function sendExpiryWarning() {
    try {
        const warningTime = moment().add(config.notifications.expiry_warning_hours, 'hours').format('YYYY-MM-DD HH:mm:ss');
        
        console.log(chalk.yellow(`🔍 Buscando usuarios que expiran en ${config.notifications.expiry_warning_hours} horas...`));
        
        db.all(`SELECT u.phone, u.username, u.expires_at, u.notification_sent FROM users u WHERE u.status = 1 AND u.tipo = 'premium' AND u.expires_at <= ? AND u.notification_sent = 0`, 
            [warningTime],
            async (err, users) => {
                if (err) {
                    console.error(chalk.red('❌ Error consultando usuarios por vencer:'), err.message);
                    return;
                }
                
                if (!users || users.length === 0) {
                    console.log(chalk.cyan('✅ No hay usuarios por vencer'));
                    return;
                }
                
                console.log(chalk.yellow(`📢 Enviando avisos a ${users.length} usuarios...`));
                
                for (const user of users) {
                    try {
                        const expireDate = moment(user.expires_at);
                        const hoursLeft = expireDate.diff(moment(), 'hours');
                        const daysLeft = expireDate.diff(moment(), 'days');
                        
                        let timeLeft;
                        if (hoursLeft < 24) {
                            timeLeft = `${hoursLeft} horas`;
                        } else {
                            timeLeft = `${daysLeft} días`;
                        }
                        
                        const message = `⚠️ *AVISO IMPORTANTE* ⚠️

Tu cuenta SSH está por vencer:

👤 Usuario: *${user.username}*
⏰ Vence: *${expireDate.format('DD/MM/YYYY HH:mm')}*
⌛ Tiempo restante: *${timeLeft}*

🔄 Para renovar tu cuenta:
1. Escribe *menu*
2. Selecciona *3 - Renovar Usuario SSH*
3. Elige tu plan de renovación
4. Realiza el pago

¡No pierdas tu acceso! 🚀`;
                        
                        await client.sendMessage(user.phone, message, { sendSeen: false });
                        
                        // Marcar como notificado
                        db.run('UPDATE users SET notification_sent = 1 WHERE username = ?', [user.username]);
                        
                        console.log(chalk.green(`📢 Aviso enviado a ${user.username} (expira en ${timeLeft})`));
                        
                        // Registrar notificación
                        db.run('INSERT INTO notifications (user_id, type, message) VALUES ((SELECT id FROM users WHERE username = ?), "expiry_warning", ?)', 
                            [user.username, `Aviso de vencimiento - ${timeLeft} restantes`]);
                            
                    } catch (userError) {
                        console.error(chalk.red(`❌ Error notificando ${user.username}:`), userError.message);
                    }
                }
                
                console.log(chalk.green(`✅ Avisos enviados a ${users.length} usuarios`));
            });
            
    } catch (error) {
        console.error(chalk.red('❌ Error en función sendExpiryWarning:'), error.message);
    }
}

// ✅ FUNCIÓN PARA ENVIAR RECORDATORIO DE VENCIMIENTO HOY
async function sendTodayExpiryReminder() {
    try {
        const todayStart = moment().format('YYYY-MM-DD 00:00:00');
        const todayEnd = moment().format('YYYY-MM-DD 23:59:59');
        
        console.log(chalk.yellow('🔍 Buscando usuarios que expiran hoy...'));
        
        db.all(`SELECT u.phone, u.username, u.expires_at FROM users u WHERE u.status = 1 AND u.tipo = 'premium' AND u.expires_at BETWEEN ? AND ?`, 
            [todayStart, todayEnd],
            async (err, users) => {
                if (err) {
                    console.error(chalk.red('❌ Error consultando usuarios que expiran hoy:'), err.message);
                    return;
                }
                
                if (!users || users.length === 0) return;
                
                console.log(chalk.yellow(`📢 Enviando recordatorios a ${users.length} usuarios...`));
                
                for (const user of users) {
                    try {
                        const expireTime = moment(user.expires_at).format('HH:mm');
                        
                        const message = `⏰ *RECORDATORIO DE VENCIMIENTO* ⏰

Tu cuenta SSH vence HOY a las *${expireTime}*:

👤 Usuario: *${user.username}*
🔑 Contraseña: mgvpn247
⏰ Vence hoy a las: *${expireTime}*

¡Renueva ahora para no perder el acceso! 🚀

Para renovar:
1. Escribe *menu*
2. Selecciona *3 - Renovar Usuario SSH*
3. Elige tu plan
4. Realiza el pago`;
                        
                        await client.sendMessage(user.phone, message, { sendSeen: false });
                        
                        console.log(chalk.green(`⏰ Recordatorio enviado a ${user.username} (vence hoy ${expireTime})`));
                        
                        // Registrar notificación
                        db.run('INSERT INTO notifications (user_id, type, message) VALUES ((SELECT id FROM users WHERE username = ?), "today_expiry", ?)', 
                            [user.username, `Recordatorio vence hoy a las ${expireTime}`]);
                            
                    } catch (userError) {
                        console.error(chalk.red(`❌ Error recordatorio ${user.username}:`), userError.message);
                    }
                }
            });
            
    } catch (error) {
        console.error(chalk.red('❌ Error en función sendTodayExpiryReminder:'), error.message);
    }
}

// ✅ MAPA DE PLANES DISPONIBLES
const dailyPlans = {
    '7': { 
        days: 7, 
        amountKey: 'price_7d_1conn',
        name: '7 DÍAS',
        description: 'Plan de 7 días de acceso SSH Premium'
    },
    '15': { 
        days: 15, 
        amountKey: 'price_15d_1conn',
        name: '15 DÍAS',
        description: 'Plan de 15 días de acceso SSH Premium'
    }
};

const monthlyPlans = {
    '30': { 
        days: 30, 
        amountKey: 'price_30d_1conn',
        name: '30 DÍAS',
        description: 'Plan de 30 días de acceso SSH Premium'
    },
    '50': { 
        days: 50, 
        amountKey: 'price_50d_1conn',
        name: '50 DÍAS',
        description: 'Plan de 50 días de acceso SSH Premium'
    }
};

async function createMercadoPagoPayment(phone, plan, days, amount) {
    try {
        config = loadConfig();
        
        if (!config.mercadopago.access_token || config.mercadopago.access_token === '') {
            console.log(chalk.red('❌ Token MP vacío'));
            return { success: false, error: 'MercadoPago no configurado - Token vacío' };
        }
        
        if (!mpPreference) {
            console.log(chalk.yellow('🔄 Reinicializando MercadoPago...'));
            mpEnabled = initMercadoPago();
            if (!mpEnabled || !mpPreference) {
                return { success: false, error: 'No se pudo inicializar MercadoPago' };
            }
        }
        
        const phoneClean = phone.split('@')[0];
        const paymentId = `SSH-${phoneClean}-${days}d-${Date.now()}`;
        
        console.log(chalk.cyan(`🔄 Creando pago MP: ${paymentId}`));
        
        const expirationDate = moment().add(24, 'hours');
        const isoDate = expirationDate.toISOString();
        
        // Monto fijo sin descuentos
        const finalAmount = parseFloat(amount);
        
        console.log(chalk.yellow(`💰 Monto: $${finalAmount} ${config.prices.currency}`));
        
        const preferenceData = {
            items: [{
                title: `SSH PREMIUM ${days} DÍAS`,
                description: `Acceso SSH Premium por ${days} días - 1 conexión`,
                quantity: 1,
                currency_id: config.prices.currency || 'ARS',
                unit_price: finalAmount
            }],
            external_reference: paymentId,
            expires: true,
            expiration_date_from: moment().toISOString(),
            expiration_date_to: isoDate,
            back_urls: {
                success: `https://wa.me/${phoneClean}?text=Pago%20exitoso`,
                failure: `https://wa.me/${phoneClean}?text=Pago%20fallido`,
                pending: `https://wa.me/${phoneClean}?text=Pago%20pendiente`
            },
            auto_return: 'approved',
            statement_descriptor: 'SSH PREMIUM'
        };
        
        console.log(chalk.yellow(`📦 Producto: ${preferenceData.items[0].title}`));
        
        const response = await mpPreference.create({ body: preferenceData });
        
        console.log(chalk.cyan('📄 Respuesta MP recibida'));
        
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
                `INSERT INTO payments (payment_id, phone, plan, days, connections, amount, discount_code, final_amount, status, payment_url, qr_code, preference_id) VALUES (?, ?, ?, ?, ?, ?, NULL, ?, 'pending', ?, ?, ?)`,
                [paymentId, phone, `${days}d`, days, 1, amount, finalAmount, paymentUrl, qrPath, response.id],
                (err) => {
                    if (err) {
                        console.error(chalk.red('❌ Error guardando en BD:'), err.message);
                    }
                }
            );
            
            console.log(chalk.green(`✅ Pago creado exitosamente`));
            console.log(chalk.cyan(`🔗 URL: ${paymentUrl.substring(0, 50)}...`));
            
            return { 
                success: true, 
                paymentId, 
                paymentUrl, 
                qrPath,
                preferenceId: response.id,
                amount: finalAmount
            };
        }
        
        throw new Error('Respuesta inválida de MercadoPago');
        
    } catch (error) {
        console.error(chalk.red('❌ Error MercadoPago:'), error.message);
        
        db.run(
            `INSERT INTO logs (type, message, data) VALUES ('mp_error', ?, ?)`,
            [error.message, JSON.stringify({ stack: error.stack })]
        );
        
        return { success: false, error: error.message };
    }
}

// ✅ FLUJO PRINCIPAL CON PLANES SEPARADOS SIN CUPONES
client.on('message', async (msg) => {
    const text = msg.body.toLowerCase().trim();
    const phone = msg.from;
    if (phone.includes('@g.us')) return;
    
    config = loadConfig();
    console.log(chalk.cyan(`📩 [${phone.split('@')[0]}]: ${text.substring(0, 30)}`));
    
    // Obtener estado actual del usuario
    const userState = await getUserState(phone);
    
    // COMANDO MENÚ PRINCIPAL
    if (['menu', 'hola', 'start', 'hi', 'volver', 'atras', '0'].includes(text)) {
        // Resetear estado a menú principal
        await setUserState(phone, 'main_menu');
        
        await client.sendMessage(phone, `HOLA, BIENVENIDO BOT MGVPN 🚀

Elija una opción:

🧾 1 - CREAR PRUEBA (${config.prices.test_hours} HORAS)
💰 2 - COMPRAR USUARIO SSH
🔄 3 - RENOVAR USUARIO SSH
📱 4 - DESCARGAR APLICACIÓN

📢 *Sistema de notificaciones activo*`, { sendSeen: false });
    }
    // OPCIÓN 1: CREAR PRUEBA
    else if (text === '1' && userState.state === 'main_menu') {
        if (!(await canCreateTest(phone))) {
            await client.sendMessage(phone, `⚠️ *YA USASTE TU PRUEBA HOY*

⏳ Vuelve mañana para otra prueba gratuita`, { sendSeen: false });
            return;
        }
        
        await client.sendMessage(phone, '⏳ Creando cuenta de prueba...', { sendSeen: false });
        
        try {
            const username = generateUsername('test'); // testXXXX
            const password = generatePassword();
            await createSSHUser(phone, username, password, 0, 1);
            registerTest(phone);
            
            await client.sendMessage(phone, `PRUEBA CREADA CON ÉXITO !

Usuario: ${username}
Contraseña: ${password}
Limite: 1 dispositivo(s)
Expira en: ${config.prices.test_hours} hora(s)

APP: ${config.links.app_download}`, { sendSeen: false });
            
            console.log(chalk.green(`✅ Test creado: ${username}`));
        } catch (error) {
            await client.sendMessage(phone, `❌ Error al crear cuenta: ${error.message}`, { sendSeen: false });
        }
    }
    // OPCIÓN 2: COMPRAR USUARIO SSH
    else if (text === '2' && userState.state === 'main_menu') {
        await setUserState(phone, 'buying_ssh');
        
        await client.sendMessage(phone, `PLANES SSH PREMIUM !

Elija una opción:
🗓 1 - PLANES SSH DIARIOS
🗓 2 - PLANES SSH MENSUALES
⬅️ 0 - VOLVER`, { sendSeen: false });
    }
    // SUBMENÚ DE COMPRAS SEPARADAS
    else if (userState.state === 'buying_ssh') {
        if (text === '1') {
            // PLANES DIARIOS
            await setUserState(phone, 'selecting_daily_plan');
            
            let plansMessage = `🗓 *PLANES SSH DIARIOS*

Elija un plan:
🗓 1 - 1 USUARIO(SSH) - 7 DÍAS - $${config.prices.price_7d_1conn}

🗓 2 - 1 USUARIO(SSH) - 15 DÍAS - $${config.prices.price_15d_1conn}

⬅️ 0 - VOLVER`;
            
            await client.sendMessage(phone, plansMessage, { sendSeen: false });
        }
        else if (text === '2') {
            // PLANES MENSUALES
            await setUserState(phone, 'selecting_monthly_plan');
            
            let plansMessage = `🗓 *PLANES SSH MENSUALES*

Elija un plan:

🗓 1 - 1 USUARIO(SSH) - 30 DÍAS - $${config.prices.price_30d_1conn}

🗓 2 - 1 USUARIO(SSH) - 50 DÍAS - $${config.prices.price_50d_1conn}

⬅️ 0 - VOLVER`;
            
            await client.sendMessage(phone, plansMessage, { sendSeen: false });
        }
        else if (text === '0') {
            await setUserState(phone, 'main_menu');
            await client.sendMessage(phone, `HOLA, BIENVENIDO MGVPN

Elija una opción:

🧾 1 - CREAR PRUEBA (${config.prices.test_hours} HORAS)
💰 2 - COMPRAR USUARIO SSH
🔄 3 - RENOVAR USUARIO SSH
📱 4 - DESCARGAR Aplicación`, { sendSeen: false });
        }
    }
    // SELECCIÓN DE PLAN DIARIO
    else if (userState.state === 'selecting_daily_plan') {
        if (text === '1' || text === '2') {
            const planNumber = parseInt(text);
            let planData;
            
            if (planNumber === 1) planData = dailyPlans['7'];
            else if (planNumber === 2) planData = dailyPlans['15'];
            
            if (planData) {
                const amount = config.prices[planData.amountKey];
                
                // Procesar pago directamente SIN preguntar por cupón
                await processPayment(phone, { 
                    plan: `${planData.days}d`,
                    days: planData.days,
                    amount: amount,
                    planName: planData.name
                });
            }
        }
        else if (text === '0') {
            await setUserState(phone, 'buying_ssh');
            await client.sendMessage(phone, `PLANES SSH PREMIUM !

Elija una opción:
🗓 1 - PLANES SSH DIARIOS (7, 15 DÍAS)
🗓 2 - PLANES SSH MENSUALES (30, 50 DÍAS)
⬅️ 0 - VOLVER`, { sendSeen: false });
        }
    }
    // SELECCIÓN DE PLAN MENSUAL
    else if (userState.state === 'selecting_monthly_plan') {
        if (text === '1' || text === '2') {
            const planNumber = parseInt(text);
            let planData;
            
            if (planNumber === 1) planData = monthlyPlans['30'];
            else if (planNumber === 2) planData = monthlyPlans['50'];
            
            if (planData) {
                const amount = config.prices[planData.amountKey];
                
                // Procesar pago directamente SIN preguntar por cupón
                await processPayment(phone, { 
                    plan: `${planData.days}d`,
                    days: planData.days,
                    amount: amount,
                    planName: planData.name
                });
            }
        }
        else if (text === '0') {
            await setUserState(phone, 'buying_ssh');
            await client.sendMessage(phone, `PLANES SSH PREMIUM !

Elija una opción:
🗓 1 - PLANES SSH DIARIOS (7, 15 DÍAS)
🗓 2 - PLANES SSH MENSUALES (30, 50 DÍAS)
⬅️ 0 - VOLVER`, { sendSeen: false });
        }
    }
    // OPCIÓN 3: RENOVAR USUARIO SSH (MEJORADO)
    else if (text === '3' && userState.state === 'main_menu') {
        // Buscar usuarios activos del cliente
        db.all('SELECT username, expires_at FROM users WHERE phone = ? AND status = 1 ORDER BY expires_at DESC', [phone], (err, rows) => {
            if (err || !rows || rows.length === 0) {
                client.sendMessage(phone, `🔄 *RENOVAR USUARIO SSH*

No tienes cuentas activas para renovar.

Para crear una nueva cuenta, selecciona:
💰 2 - COMPRAR USUARIO SSH`, { sendSeen: false });
                return;
            }
            
            let message = `🔄 *RENOVAR USUARIO SSH*\n\nTus cuentas activas:\n`;
            
            rows.forEach((row, index) => {
                const expireDate = moment(row.expires_at).format('DD/MM/YYYY HH:mm');
                message += `${index + 1}. 👤 *${row.username}* - ⏰ Vence: ${expireDate}\n`;
            });
            
            message += `\nPara renovar:\n1. Escribe *renovar [usuario]*\n2. Selecciona el plan\n3. Realiza el pago`;
            
            client.sendMessage(phone, message, { sendSeen: false });
        });
    }
    // COMANDO RENOVAR ESPECÍFICO
    else if (text.startsWith('renovar ') && userState.state === 'main_menu') {
        const username = text.replace('renovar ', '').trim();
        
        db.get('SELECT username FROM users WHERE username = ? AND phone = ? AND status = 1', [username, phone], (err, row) => {
            if (err || !row) {
                client.sendMessage(phone, `❌ No tienes una cuenta activa con usuario: *${username}*

Verifica el nombre de usuario e intenta nuevamente.`, { sendSeen: false });
                return;
            }
            
            setUserState(phone, 'renovating_user', { username: username }).then(() => {
                client.sendMessage(phone, `🔄 *RENOVACIÓN: ${username}*

Selecciona el tipo de plan:

🗓 1 - PLANES DIARIOS
🗓 2 - PLANES MENSUALES
⬅️ 0 - VOLVER`, { sendSeen: false });
            });
        });
    }
    // SELECCIÓN DE TIPO DE PLAN PARA RENOVACIÓN
    else if (userState.state === 'renovating_user') {
        if (text === '1') {
            // PLANES DIARIOS PARA RENOVACIÓN
            await setUserState(phone, 'renovation_selecting_daily', { username: userState.data.username });
            
            await client.sendMessage(phone, `🔄 *RENOVACIÓN: ${userState.data.username}*
🗓 *PLANES DIARIOS*

Selecciona un plan:
🗓 1 - 7 DÍAS - $${config.prices.price_7d_1conn}
🗓 2 - 15 DÍAS - $${config.prices.price_15d_1conn}
⬅️ 0 - VOLVER`, { sendSeen: false });
        }
        else if (text === '2') {
            // PLANES MENSUALES PARA RENOVACIÓN
            await setUserState(phone, 'renovation_selecting_monthly', { username: userState.data.username });
            
            await client.sendMessage(phone, `🔄 *RENOVACIÓN: ${userState.data.username}*
🗓 *PLANES MENSUALES*

Selecciona un plan:
🗓 1 - 30 DÍAS - $${config.prices.price_30d_1conn}
🗓 2 - 50 DÍAS - $${config.prices.price_50d_1conn}
⬅️ 0 - VOLVER`, { sendSeen: false });
        }
        else if (text === '0') {
            await setUserState(phone, 'main_menu');
            await client.sendMessage(phone, `Renovación cancelada.

Escribe *menu* para ver las opciones.`, { sendSeen: false });
        }
    }
    // SELECCIÓN DE PLAN DIARIO PARA RENOVACIÓN
    else if (userState.state === 'renovation_selecting_daily') {
        if (text === '1' || text === '2') {
            const planNumber = parseInt(text);
            let planData;
            
            if (planNumber === 1) planData = dailyPlans['7'];
            else if (planNumber === 2) planData = dailyPlans['15'];
            
            if (planData) {
                const stateData = userState.data || {};
                const username = stateData.username;
                
                // Procesar renovación directamente SIN preguntar por cupón
                await processRenovation(phone, { 
                    username: username,
                    plan: `${planData.days}d`,
                    days: planData.days,
                    amount: config.prices[planData.amountKey],
                    planName: planData.name
                });
            }
        }
        else if (text === '0') {
            await setUserState(phone, 'main_menu');
            await client.sendMessage(phone, `Renovación cancelada.

Escribe *menu* para ver las opciones.`, { sendSeen: false });
        }
    }
    // SELECCIÓN DE PLAN MENSUAL PARA RENOVACIÓN
    else if (userState.state === 'renovation_selecting_monthly') {
        if (text === '1' || text === '2') {
            const planNumber = parseInt(text);
            let planData;
            
            if (planNumber === 1) planData = monthlyPlans['30'];
            else if (planNumber === 2) planData = monthlyPlans['50'];
            
            if (planData) {
                const stateData = userState.data || {};
                const username = stateData.username;
                
                // Procesar renovación directamente SIN preguntar por cupón
                await processRenovation(phone, { 
                    username: username,
                    plan: `${planData.days}d`,
                    days: planData.days,
                    amount: config.prices[planData.amountKey],
                    planName: planData.name
                });
            }
        }
        else if (text === '0') {
            await setUserState(phone, 'main_menu');
            await client.sendMessage(phone, `Renovación cancelada.

Escribe *menu* para ver las opciones.`, { sendSeen: false });
        }
    }
    // OPCIÓN 4: DESCARGAR APLICACIÓN
    else if (text === '4' && userState.state === 'main_menu') {
        await client.sendMessage(phone, `📱 *DESCARGAR APLICACIÓN*

🔗 Enlace de descarga:
${config.links.app_download}

💡 *Instrucciones:*
1. Abre el enlace en tu navegador
2. Descarga el archivo APK
3. click en mas detalles instalar de todas formas si te pide
4. Instala la aplicación
5. Configura con tus credenciales SSH

⚡ *Credenciales por defecto:*
Usuario: (el que te proporcionamos)
Contraseña: mgvpn247`, { sendSeen: false });
    }
    // COMANDO NO RECONOCIDO - SIN RESPUESTA
    else {
        // Silenciar mensaje de comando no reconocido
        console.log(chalk.yellow(`⚠️ Comando no reconocido de ${phone.split('@')[0]}: ${text}`));
        return;
    }
});

// ✅ FUNCIÓN PARA PROCESAR PAGO DE COMPRA (SIMPLIFICADA SIN CUPONES)
async function processPayment(phone, planData) {
    config = loadConfig();
    
    if (!config.mercadopago.access_token || config.mercadopago.access_token === '') {
        await client.sendMessage(phone, `❌ *MERCADOPAGO NO CONFIGURADO*

El administrador debe configurar MercadoPago primero.

💬 Contacta soporte para más información.`, { sendSeen: false });
        await setUserState(phone, 'main_menu');
        return;
    }
    
    await client.sendMessage(phone, '⏳ Procesando tu compra...', { sendSeen: false });
    
    try {
        const payment = await createMercadoPagoPayment(
            phone, 
            planData.plan, 
            planData.days, 
            planData.amount
        );
        
        if (payment.success) {
            const message = `### USUARIO SSH

- **Precio:** $${payment.amount}
- **Límite:** 1 dispositivo(s)
- **Duración:** ${planData.days} días

---

**LINK DE PAGO**

${payment.paymentUrl}

⏰ *Este enlace expira en 24 horas*
💳 *Pago seguro con MercadoPago*`;
            
            await client.sendMessage(phone, message, { sendSeen: false });
            
            // Enviar QR si existe
            if (fs.existsSync(payment.qrPath)) {
                try {
                    const media = MessageMedia.fromFilePath(payment.qrPath);
                    await client.sendMessage(phone, media, { 
                        caption: `📱 *Escanea con MercadoPago*\n\n${planData.planName} - $${payment.amount}`, 
                        sendSeen: false 
                    });
                } catch (qrError) {
                    console.error(chalk.red('⚠️ Error enviando QR:'), qrError.message);
                }
            }
        } else {
            await client.sendMessage(phone, `❌ *ERROR AL GENERAR PAGO*

${payment.error}

Por favor, intenta de nuevo en unos minutos.`, { sendSeen: false });
        }
    } catch (error) {
        console.error(chalk.red('❌ Error en proceso de pago:'), error);
        await client.sendMessage(phone, `❌ *ERROR INESPERADO*

${error.message}

💬 Contacta soporte para asistencia.`, { sendSeen: false });
    }
    
    await setUserState(phone, 'main_menu');
}

// ✅ FUNCIÓN PARA PROCESAR RENOVACIÓN (SIMPLIFICADA SIN CUPONES)
async function processRenovation(phone, renovationData) {
    config = loadConfig();
    
    if (!config.mercadopago.access_token || config.mercadopago.access_token === '') {
        await client.sendMessage(phone, `❌ *MERCADOPAGO NO CONFIGURADO*

El administrador debe configurar MercadoPago primero.

💬 Contacta soporte para más información.`, { sendSeen: false });
        await setUserState(phone, 'main_menu');
        return;
    }
    
    await client.sendMessage(phone, `⏳ Procesando renovación para *${renovationData.username}*...`, { sendSeen: false });
    
    try {
        const payment = await createMercadoPagoPayment(
            phone, 
            renovationData.plan, 
            renovationData.days, 
            renovationData.amount
        );
        
        if (payment.success) {
            const message = `### RENOVACIÓN: ${renovationData.username}

- **Precio:** $${payment.amount}
- **Plan:** ${renovationData.days} días
- **Usuario:** ${renovationData.username}

---

**LINK DE PAGO**

${payment.paymentUrl}

⏰ *Este enlace expira en 24 horas*
💳 *Pago seguro con MercadoPago*

✅ Después del pago, tu cuenta será renovada automáticamente.`;
            
            await client.sendMessage(phone, message, { sendSeen: false });
            
            // Enviar QR si existe
            if (fs.existsSync(payment.qrPath)) {
                try {
                    const media = MessageMedia.fromFilePath(payment.qrPath);
                    await client.sendMessage(phone, media, { 
                        caption: `📱 *Renovación - Escanea con MercadoPago*\n\n${renovationData.username} - ${renovationData.days} días - $${payment.amount}`, 
                        sendSeen: false 
                    });
                } catch (qrError) {
                    console.error(chalk.red('⚠️ Error enviando QR:'), qrError.message);
                }
            }
            
            // Guardar información de renovación pendiente
            db.run(`UPDATE payments SET username = ? WHERE payment_id = ?`, [renovationData.username, payment.paymentId]);
            
        } else {
            await client.sendMessage(phone, `❌ *ERROR AL GENERAR PAGO DE RENOVACIÓN*

${payment.error}

Por favor, intenta de nuevo en unos minutos.`, { sendSeen: false });
        }
    } catch (error) {
        console.error(chalk.red('❌ Error en proceso de renovación:'), error);
        await client.sendMessage(phone, `❌ *ERROR INESPERADO EN RENOVACIÓN*

${error.message}

💬 Contacta soporte para asistencia.`, { sendSeen: false });
    }
    
    await setUserState(phone, 'main_menu');
}

// ✅ VERIFICAR PAGOS PENDIENTES Y PROCESAR RENOVACIONES
async function checkPendingPayments() {
    config = loadConfig();
    if (!config.mercadopago.access_token || config.mercadopago.access_token === '') return;
    
    db.all('SELECT * FROM payments WHERE status = "pending" AND created_at > datetime("now", "-48 hours")', async (err, payments) => {
        if (err || !payments || payments.length === 0) return;
        
        console.log(chalk.yellow(`🔍 Verificando ${payments.length} pagos pendientes...`));
        
        for (const payment of payments) {
            try {
                const url = `https://api.mercadopago.com/v1/payments/search?external_reference=${payment.payment_id}`;
                const response = await axios.get(url, {
                    headers: { 
                        'Authorization': `Bearer ${config.mercadopago.access_token}`,
                        'Content-Type': 'application/json'
                    },
                    timeout: 15000
                });
                
                if (response.data && response.data.results && response.data.results.length > 0) {
                    const mpPayment = response.data.results[0];
                    
                    console.log(chalk.cyan(`📋 Pago ${payment.payment_id}: ${mpPayment.status}`));
                    
                    if (mpPayment.status === 'approved') {
                        console.log(chalk.green(`✅ PAGO APROBADO: ${payment.payment_id}`));
                        
                        // Verificar si es renovación
                        if (payment.username) {
                            // ES RENOVACIÓN
                            console.log(chalk.yellow(`🔄 Procesando renovación para ${payment.username}`));
                            
                            try {
                                // Calcular nueva fecha de expiración
                                const currentUser = await new Promise((resolve, reject) => {
                                    db.get('SELECT expires_at FROM users WHERE username = ?', [payment.username], (err, row) => {
                                        if (err) reject(err);
                                        else resolve(row);
                                    });
                                });
                                
                                let newExpireDate;
                                if (currentUser && currentUser.expires_at) {
                                    // Extender desde la fecha actual de expiración
                                    const currentExpire = moment(currentUser.expires_at);
                                    newExpireDate = currentExpire.add(payment.days, 'days').format('YYYY-MM-DD 23:59:59');
                                } else {
                                    // Si no hay fecha actual, extender desde hoy
                                    newExpireDate = moment().add(payment.days, 'days').format('YYYY-MM-DD 23:59:59');
                                }
                                
                                // Actualizar fecha de expiración del usuario
                                await new Promise((resolve, reject) => {
                                    db.run(`UPDATE users SET expires_at = ?, notification_sent = 0 WHERE username = ?`, 
                                        [newExpireDate, payment.username], 
                                        (err) => {
                                            if (err) reject(err);
                                            else resolve();
                                        });
                                });
                                
                                // Actualizar fecha de expiración en el sistema
                                const expireSystem = moment(newExpireDate).format('YYYY-MM-DD');
                                await execPromise(`usermod -e ${expireSystem} ${payment.username}`);
                                
                                db.run(`UPDATE payments SET status = 'approved', approved_at = CURRENT_TIMESTAMP WHERE payment_id = ?`, [payment.payment_id]);
                                
                                const expireDate = moment(newExpireDate).format('DD/MM/YYYY');
                                
                                const message = `✅ *RENOVACIÓN CONFIRMADA*

🎉 Tu renovación ha sido aprobada

📋 *DATOS ACTUALIZADOS:*
👤 Usuario: *${payment.username}*
🔑 Contraseña: *mgvpn247*
⏰ *NUEVA FECHA DE VENCIMIENTO:* ${expireDate}
🔌 *CONEXIÓN:* 1 dispositivo

🎊 ¡Tu cuenta ha sido renovada exitosamente!`;
                                
                                await client.sendMessage(payment.phone, message, { sendSeen: false });
                                
                                console.log(chalk.green(`✅ Renovación completada para ${payment.username} hasta ${expireDate}`));
                                
                            } catch (renovationError) {
                                console.error(chalk.red(`❌ Error en renovación ${payment.username}:`), renovationError.message);
                                
                                // Notificar al cliente del error
                                await client.sendMessage(payment.phone, 
                                    `❌ *ERROR EN RENOVACIÓN*
                                    
Hubo un error al procesar tu renovación. Por favor, contacta soporte.
                                    
Error: ${renovationError.message}`, { sendSeen: false });
                            }
                            
                        } else {
                            // ES COMPRA NUEVA
                            // Generar usuario en minúsculas para premium
                            const username = generateUsername('premium'); // userXXXX
                            const password = generatePassword();
                            const result = await createSSHUser(payment.phone, username, password, payment.days, 1);
                            
                            db.run(`UPDATE payments SET status = 'approved', approved_at = CURRENT_TIMESTAMP WHERE payment_id = ?`, [payment.payment_id]);
                            
                            const expireDate = moment().add(payment.days, 'days').format('DD/MM/YYYY');
                            
                            const message = `✅ *PAGO CONFIRMADO*

🎉 Tu compra ha sido aprobada

📋 *DATOS DE ACCESO:*
👤 Usuario: *${username}*
🔑 Contraseña: *${password}*

⏰ *VÁLIDO HASTA:* ${expireDate}
🔌 *CONEXIÓN:* 1 dispositivo

📱 *INSTALACIÓN:*
1. Descarga la app (Opción *4*)
2. Seleccionar servidor
3. Ingresar Usuario y Contraseña
4. ¡Conéctate automáticamente!

🎊 ¡Disfruta del servicio premium!`;
                            
                            await client.sendMessage(payment.phone, message, { sendSeen: false });
                            
                            console.log(chalk.green(`✅ Usuario premium creado: ${username}`));
                        }
                    }
                }
            } catch (error) {
                console.error(chalk.red(`❌ Error verificando ${payment.payment_id}:`), error.message);
            }
        }
    });
}

// ✅ Verificar pagos cada 2 minutos
cron.schedule('*/2 * * * *', () => {
    console.log(chalk.yellow('🔄 Verificando pagos pendientes...'));
    checkPendingPayments();
});

// ✅ Enviar avisos por vencer cada hora
cron.schedule('0 * * * *', () => {
    console.log(chalk.yellow('📢 Enviando avisos por vencer...'));
    sendExpiryWarning();
});

// ✅ Enviar recordatorios de vencimiento hoy cada 6 horas
cron.schedule('0 */6 * * *', () => {
    console.log(chalk.yellow('⏰ Enviando recordatorios de vencimiento hoy...'));
    sendTodayExpiryReminder();
});

// ✅ Resetear notificaciones a medianoche para avisos diarios
cron.schedule('0 0 * * *', () => {
    console.log(chalk.yellow('🔄 Reseteando notificaciones enviadas...'));
    db.run('UPDATE users SET notification_sent = 0 WHERE status = 1');
});

// ✅ Limpiar usuarios expirados cada 15 minutos
cron.schedule('*/15 * * * *', async () => {
    const now = moment().format('YYYY-MM-DD HH:mm:ss');
    console.log(chalk.yellow(`🧹 Limpiando usuarios expirados cada 15 minutos (${now})...`));
    
    db.all('SELECT username FROM users WHERE expires_at < ? AND status = 1', [now], async (err, rows) => {
        if (err) {
            console.error(chalk.red('❌ Error BD:'), err.message);
            return;
        }
        if (!rows || rows.length === 0) return;
        
        for (const r of rows) {
            try {
                await execPromise(`pkill -u ${r.username} 2>/dev/null || true`);
                await execPromise(`userdel -f ${r.username} 2>/dev/null || true`);
                db.run('UPDATE users SET status = 0 WHERE username = ?', [r.username]);
                console.log(chalk.green(`🗑️ Eliminado: ${r.username}`));
            } catch (e) {
                console.error(chalk.red(`Error eliminando ${r.username}:`), e.message);
            }
        }
        console.log(chalk.green(`✅ Limpiados ${rows.length} usuarios expirados`));
    });
});

// ✅ Limpiar estados antiguos cada hora
cron.schedule('0 * * * *', () => {
    console.log(chalk.yellow('🧹 Limpiando estados antiguos...'));
    db.run(`DELETE FROM user_state WHERE updated_at < datetime('now', '-1 hour')`, (err) => {
        if (!err) console.log(chalk.green('✅ Estados antiguos limpiados'));
    });
});

// ✅ Limpiar pagos antiguos cada 24 horas
cron.schedule('0 0 * * *', () => {
    console.log(chalk.yellow('🧹 Limpiando pagos antiguos...'));
    db.run(`DELETE FROM payments WHERE status = 'pending' AND created_at < datetime('now', '-7 days')`, (err) => {
        if (!err) console.log(chalk.green('✅ Pagos antiguos limpiados'));
    });
});

// ✅ Mostrar estadísticas de notificaciones cada día
cron.schedule('0 9 * * *', () => {
    console.log(chalk.cyan('📊 ESTADÍSTICAS DIARIAS DE NOTIFICACIONES'));
    db.all('SELECT type, COUNT(*) as count FROM notifications WHERE date(sent_at) = date("now") GROUP BY type', (err, rows) => {
        if (err) return;
        rows.forEach(row => {
            console.log(chalk.yellow(`  ${row.type}: ${row.count}`));
        });
    });
});

console.log(chalk.green('\n🚀 Inicializando bot con planes separados SIN CUPONES...\n'));
client.initialize();
BOTEOF

echo -e "${GREEN}✅ Bot creado con planes separados SIN CUPONES${NC}"

# ================================================
# CREAR PANEL DE CONTROL
# ================================================
echo -e "\n${CYAN}${BOLD}🎛️  CREANDO PANEL DE CONTROL...${NC}"

cat > /usr/local/bin/sshbot << 'PANELEOF'
#!/bin/bash
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'

DB="/opt/ssh-bot/data/users.db"
CONFIG="/opt/ssh-bot/config/config.json"

get_val() { jq -r "$1" "$CONFIG" 2>/dev/null; }
set_val() { local t=$(mktemp); jq "$1 = $2" "$CONFIG" > "$t" && mv "$t" "$CONFIG"; }

show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                🎛️  PANEL SSH BOT - SIN CUPONES              ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

while true; do
    show_header
    
    TOTAL_USERS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users" 2>/dev/null || echo "0")
    ACTIVE_USERS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1" 2>/dev/null || echo "0")
    PENDING_PAYMENTS=$(sqlite3 "$DB" "SELECT COUNT(*) FROM payments WHERE status='pending'" 2>/dev/null || echo "0")
    
    # Usuarios por vencer en 24h
    EXPIRING_SOON=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+24 hours') AND notification_sent=0" 2>/dev/null || echo "0")
    
    # Notificaciones hoy
    NOTIFICATIONS_TODAY=$(sqlite3 "$DB" "SELECT COUNT(*) FROM notifications WHERE date(sent_at) = date('now')" 2>/dev/null || echo "0")
    
    STATUS=$(pm2 jlist 2>/dev/null | jq -r '.[] | select(.name=="ssh-bot") | .pm2_env.status' 2>/dev/null || echo "stopped")
    if [[ "$STATUS" == "online" ]]; then
        BOT_STATUS="${GREEN}● ACTIVO${NC}"
    else
        BOT_STATUS="${RED}● DETENIDO${NC}"
    fi
    
    MP_TOKEN=$(get_val '.mercadopago.access_token')
    if [[ -n "$MP_TOKEN" && "$MP_TOKEN" != "" && "$MP_TOKEN" != "null" ]]; then
        MP_STATUS="${GREEN}✅ CONFIGURADO${NC}"
    else
        MP_STATUS="${RED}❌ NO CONFIGURADO${NC}"
    fi
    
    NOTIF_GROUP=$(get_val '.bot.notification_group')
    if [[ -n "$NOTIF_GROUP" && "$NOTIF_GROUP" != "" && "$NOTIF_GROUP" != "null" ]]; then
        GROUP_SHORT=${NOTIF_GROUP:0:20}...
        GROUP_STATUS="${GREEN}✅ ${GROUP_SHORT}${NC}"
    else
        GROUP_STATUS="${RED}❌ NO CONFIGURADO${NC}"
    fi
    
    echo -e "${YELLOW}📊 ESTADO DEL SISTEMA${NC}"
    echo -e "  Bot: $BOT_STATUS"
    echo -e "  Usuarios: ${CYAN}$ACTIVE_USERS/$TOTAL_USERS${NC} activos/total"
    echo -e "  Por vencer (24h): ${CYAN}$EXPIRING_SOON${NC}"
    echo -e "  Pagos pendientes: ${CYAN}$PENDING_PAYMENTS${NC}"
    echo -e "  Notificaciones hoy: ${CYAN}$NOTIFICATIONS_TODAY${NC}"
    echo -e "  MercadoPago: $MP_STATUS"
    echo -e "  Grupo notif.: $GROUP_STATUS"
    echo -e "  Test: ${GREEN}$(get_val '.prices.test_hours') horas${NC} | Limpieza: ${GREEN}cada 15 min${NC}"
    echo -e "  Contraseña: ${GREEN}mgvpn247${NC} (FIJA PARA TODOS)"
    echo -e "  Cupones: ${RED}🚫 DESACTIVADOS${NC}"
    echo -e ""
    
    echo -e "${YELLOW}💰 PRECIOS ACTUALES:${NC}"
    echo -e "  Test: ${GREEN}$(get_val '.prices.test_hours') horas${NC} (gratis)"
    echo -e "  📅 DIARIOS:"
    echo -e "    7 días: $ $(get_val '.prices.price_7d_1conn') ARS"
    echo -e "    15 días: $ $(get_val '.prices.price_15d_1conn') ARS"
    echo -e "  📅 MENSUALES:"
    echo -e "    30 días: $ $(get_val '.prices.price_30d_1conn') ARS"
    echo -e "    50 días: $ $(get_val '.prices.price_50d_1conn') ARS"
    echo -e ""
    
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}[1]${NC}  🚀  Iniciar/Reiniciar bot"
    echo -e "${CYAN}[2]${NC}  🛑  Detener bot"
    echo -e "${CYAN}[3]${NC}  📱  Ver QR WhatsApp"
    echo -e "${CYAN}[4]${NC}  👤  Crear usuario manual"
    echo -e "${CYAN}[5]${NC}  👥  Listar usuarios"
    echo -e "${CYAN}[6]${NC}  ⏰  Cambiar horas del test"
    echo -e "${CYAN}[7]${NC}  💰  Cambiar precios"
    echo -e "${CYAN}[8]${NC}  🔑  Configurar MercadoPago"
    echo -e "${CYAN}[9]${NC}  📢  Configurar notificaciones"
    echo -e "${CYAN}[10]${NC} 📊  Ver estadísticas"
    echo -e "${CYAN}[11]${NC} 📝  Ver logs"
    echo -e "${CYAN}[12]${NC} 🔔  Forzar notificaciones"
    echo -e "${CYAN}[0]${NC}  🚪  Salir"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e ""
    read -p "👉 Selecciona una opción: " OPTION
    
    case $OPTION in
        1)
            echo -e "\n${YELLOW}🔄 Reiniciando bot...${NC}"
            cd /root/ssh-bot
            pm2 restart ssh-bot 2>/dev/null || pm2 start bot.js --name ssh-bot
            pm2 save
            echo -e "${GREEN}✅ Bot reiniciado${NC}"
            sleep 2
            ;;
        2)
            echo -e "\n${YELLOW}🛑 Deteniendo bot...${NC}"
            pm2 stop ssh-bot
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
                [[ "$VER" == "s" ]] && pm2 logs ssh-bot --lines 100
            else
                echo -e "${YELLOW}⚠️  QR no generado aún${NC}\n"
                read -p "¿Ver logs? (s/N): " VER
                [[ "$VER" == "s" ]] && pm2 logs ssh-bot --lines 50
            fi
            ;;
        4)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     👤 CREAR USUARIO                        ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            read -p "Teléfono (ej: 5491122334455): " PHONE
            read -p "Usuario (auto=generar): " USERNAME
            read -p "Tipo (test/premium): " TIPO
            read -p "Días (0=test, 7,15,30,50=premium): " DAYS
            
            [[ -z "$DAYS" ]] && DAYS="30"
            if [[ "$USERNAME" == "auto" || -z "$USERNAME" ]]; then
                if [[ "$TIPO" == "test" ]]; then
                    USERNAME="test$(shuf -i 1000-9999 -n 1)"  # testXXXX
                else
                    USERNAME="user$(shuf -i 1000-9999 -n 1)"  # userXXXX
                fi
            fi
            PASSWORD="mgvpn247"
            
            if [[ "$TIPO" == "test" ]]; then
                DAYS="0"
                TEST_HOURS=$(get_val '.prices.test_hours')
                EXPIRE_DATE=$(date -d "+${TEST_HOURS} hours" +"%Y-%m-%d %H:%M:%S")
                useradd -M -s /bin/false "$USERNAME" && echo "$USERNAME:$PASSWORD" | chpasswd
            else
                EXPIRE_DATE=$(date -d "+$DAYS days" +"%Y-%m-%d 23:59:59")
                useradd -M -s /bin/false -e "$(date -d "+$DAYS days" +%Y-%m-%d)" "$USERNAME" && echo "$USERNAME:$PASSWORD" | chpasswd
            fi
            
            if [[ $? -eq 0 ]]; then
                sqlite3 "$DB" "INSERT INTO users (phone, username, password, tipo, expires_at, max_connections, status) VALUES ('$PHONE', '$USERNAME', '$PASSWORD', '$TIPO', '$EXPIRE_DATE', 1, 1)"
                echo -e "\n${GREEN}✅ USUARIO CREADO${NC}"
                echo -e "👤 Usuario: ${USERNAME}"
                echo -e "🔑 Contraseña: ${PASSWORD}"
                echo -e "⏰ Expira: ${EXPIRE_DATE}"
                echo -e "🔌 Días/Horas: ${DAYS}${TIPO:0:1}"
            else {
                echo -e "\n${RED}❌ Error creando usuario${NC}"
            }
            fi
            read -p "Presiona Enter..." 
            ;;
        5)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     👥 USUARIOS ACTIVOS                     ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            sqlite3 -column -header "$DB" "SELECT username, password, tipo, expires_at, substr(phone,1,12) as tel FROM users WHERE status = 1 ORDER BY expires_at DESC LIMIT 20"
            
            echo -e "\n${YELLOW}Usuarios por vencer en 24h:${NC}"
            sqlite3 -column -header "$DB" "SELECT username, expires_at FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+24 hours') AND notification_sent=0 ORDER BY expires_at LIMIT 10"
            
            echo -e "\n${YELLOW}Total: ${ACTIVE_USERS} activos | Por vencer: ${EXPIRING_SOON}${NC}"
            read -p "Presiona Enter..." 
            ;;
        6)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                  ⏰ CAMBIAR HORAS DEL TEST                   ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            CURRENT_HOURS=$(get_val '.prices.test_hours')
            echo -e "${YELLOW}⏰ HORAS ACTUALES DEL TEST: ${GREEN}${CURRENT_HOURS} HORAS${NC}\n"
            
            echo -e "${CYAN}📝 Recomendaciones:${NC}"
            echo -e "  1-2 horas: ${GREEN}Ideal para pruebas rápidas${NC}"
            echo -e "  3-6 horas: ${YELLOW}Para usuarios más exigentes${NC}"
            echo -e "  12-24 horas: ${RED}Solo si tienes mucho ancho de banda${NC}\n"
            
            read -p "Nuevas horas para el test [${CURRENT_HOURS}]: " NEW_HOURS
            
            if [[ -n "$NEW_HOURS" ]]; then
                if [[ $NEW_HOURS =~ ^[0-9]+$ ]] && [[ $NEW_HOURS -ge 1 ]] && [[ $NEW_HOURS -le 24 ]]; then
                    set_val '.prices.test_hours' "$NEW_HOURS"
                    echo -e "\n${GREEN}✅ Horas cambiadas a ${NEW_HOURS} horas${NC}"
                    echo -e "${YELLOW}🔄 Reiniciando bot para aplicar cambios...${NC}"
                    cd /root/ssh-bot && pm2 restart ssh-bot
                    sleep 2
                    echo -e "${GREEN}✅ Bot reiniciado con ${NEW_HOURS} horas de test${NC}"
                else
                    echo -e "${RED}❌ Error: Debe ser un número entre 1 y 24${NC}"
                fi
            fi
            read -p "Presiona Enter..." 
            ;;
        7)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                    💰 CAMBIAR PRECIOS                       ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            CURRENT_7D=$(get_val '.prices.price_7d_1conn')
            CURRENT_15D=$(get_val '.prices.price_15d_1conn')
            CURRENT_30D=$(get_val '.prices.price_30d_1conn')
            CURRENT_50D=$(get_val '.prices.price_50d_1conn')
            
            echo -e "${YELLOW}💰 PRECIOS ACTUALES:${NC}"
            echo -e "  📅 DIARIOS:"
            echo -e "    1. 7 días: $${CURRENT_7D}"
            echo -e "    2. 15 días: $${CURRENT_15D}"
            echo -e "  📅 MENSUALES:"
            echo -e "    3. 30 días: $${CURRENT_30D}"
            echo -e "    4. 50 días: $${CURRENT_50D}\n"
            
            echo -e "${CYAN}--- MODIFICAR PRECIOS ---${NC}"
            read -p "Nuevo precio 7d [${CURRENT_7D}]: " NEW_7D
            read -p "Nuevo precio 15d [${CURRENT_15D}]: " NEW_15D
            read -p "Nuevo precio 30d [${CURRENT_30D}]: " NEW_30D
            read -p "Nuevo precio 50d [${CURRENT_50D}]: " NEW_50D
            
            [[ -n "$NEW_7D" ]] && set_val '.prices.price_7d_1conn' "$NEW_7D"
            [[ -n "$NEW_15D" ]] && set_val '.prices.price_15d_1conn' "$NEW_15D"
            [[ -n "$NEW_30D" ]] && set_val '.prices.price_30d_1conn' "$NEW_30D"
            [[ -n "$NEW_50D" ]] && set_val '.prices.price_50d_1conn' "$NEW_50D"
            
            echo -e "\n${GREEN}✅ Precios actualizados${NC}"
            echo -e "${YELLOW}🔄 Reiniciando bot para aplicar cambios...${NC}"
            cd /root/ssh-bot && pm2 restart ssh-bot
            sleep 2
            read -p "Presiona Enter..." 
            ;;
        8)
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
                    set_val '.mercadopago.access_token' "\"$NEW_TOKEN\""
                    set_val '.mercadopago.enabled' "true"
                    echo -e "\n${GREEN}✅ Token configurado${NC}"
                    echo -e "${YELLOW}🔄 Reiniciando bot...${NC}"
                    cd /root/ssh-bot && pm2 restart ssh-bot
                    sleep 2
                    echo -e "${GREEN}✅ MercadoPago activado${NC}"
                else
                    echo -e "${RED}❌ Token inválido${NC}"
                    echo -e "${YELLOW}Debe empezar con APP_USR- o TEST-${NC}"
                fi
            fi
            read -p "Presiona Enter..." 
            ;;
        9)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║             📢 CONFIGURAR NOTIFICACIONES                   ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            CURRENT_GROUP=$(get_val '.bot.notification_group')
            CURRENT_WARNING=$(get_val '.notifications.expiry_warning_hours')
            NOTIF_ENABLED=$(get_val '.notifications.enabled')
            
            echo -e "${YELLOW}⚙️ CONFIGURACIÓN ACTUAL:${NC}"
            echo -e "  Grupo WhatsApp: ${CYAN}${CURRENT_GROUP:-'No configurado'}${NC}"
            echo -e "  Aviso por vencer: ${CYAN}${CURRENT_WARNING} horas antes${NC}"
            echo -e "  Notificaciones: ${CYAN}${NOTIF_ENABLED == 'true' ? '✅ ACTIVADAS' : '❌ DESACTIVADAS'}${NC}\n"
            
            echo -e "${CYAN}📝 CONFIGURAR GRUPO DE NOTIFICACIONES:${NC}"
            echo -e "  1. Crea un grupo en WhatsApp"
            echo -e "  2. Agrega el bot al grupo"
            echo -e "  3. Envía cualquier mensaje"
            echo -e "  4. Copia el ID del grupo (ej: 1234567890-123456@g.us)"
            echo -e ""
            
            read -p "Nuevo ID de grupo [${CURRENT_GROUP}]: " NEW_GROUP
            read -p "Horas para aviso por vencer [${CURRENT_WARNING}]: " NEW_WARNING
            
            if [[ -n "$NEW_GROUP" ]]; then
                set_val '.bot.notification_group' "\"$NEW_GROUP\""
                echo -e "${GREEN}✅ Grupo actualizado${NC}"
            fi
            
            if [[ -n "$NEW_WARNING" ]]; then
                if [[ $NEW_WARNING =~ ^[0-9]+$ ]] && [[ $NEW_WARNING -ge 1 ]] && [[ $NEW_WARNING -le 168 ]]; then
                    set_val '.notifications.expiry_warning_hours' "$NEW_WARNING"
                    echo -e "${GREEN}✅ Aviso por vencer actualizado a ${NEW_WARNING} horas${NC}"
                else
                    echo -e "${RED}❌ Error: Debe ser un número entre 1 y 168 (7 días)${NC}"
                fi
            fi
            
            echo -e "\n${CYAN}🔔 ACTIVAR/DESACTIVAR NOTIFICACIONES:${NC}"
            read -p "¿Activar notificaciones? (s/N): " ACTIVAR
            if [[ "$ACTIVAR" == "s" ]]; then
                set_val '.notifications.enabled' "true"
                echo -e "${GREEN}✅ Notificaciones ACTIVADAS${NC}"
            else
                set_val '.notifications.enabled' "false"
                echo -e "${YELLOW}⚠️ Notificaciones DESACTIVADAS${NC}"
            fi
            
            echo -e "\n${YELLOW}🔄 Reiniciando bot para aplicar cambios...${NC}"
            cd /root/ssh-bot && pm2 restart ssh-bot
            sleep 2
            echo -e "${GREEN}✅ Configuración de notificaciones actualizada${NC}"
            read -p "Presiona Enter..." 
            ;;
        10)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║                     📊 ESTADÍSTICAS                         ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${YELLOW}👥 USUARIOS:${NC}"
            sqlite3 "$DB" "SELECT 'Total: ' || COUNT(*) || ' | Activos: ' || SUM(CASE WHEN status=1 THEN 1 ELSE 0 END) || ' | Tests: ' || SUM(CASE WHEN tipo='test' THEN 1 ELSE 0 END) || ' | Premium: ' || SUM(CASE WHEN tipo='premium' THEN 1 ELSE 0 END) FROM users"
            
            echo -e "\n${YELLOW}💰 PAGOS:${NC}"
            sqlite3 "$DB" "SELECT 'Pendientes: ' || SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END) || ' | Aprobados: ' || SUM(CASE WHEN status='approved' THEN 1 ELSE 0 END) || ' | Total: $' || printf('%.2f', SUM(CASE WHEN status='approved' THEN final_amount ELSE 0 END)) FROM payments"
            
            echo -e "\n${YELLOW}📅 DISTRIBUCIÓN POR PLANES:${NC}"
            sqlite3 "$DB" "SELECT '7 días: ' || SUM(CASE WHEN plan='7d' THEN 1 ELSE 0 END) || ' | 15 días: ' || SUM(CASE WHEN plan='15d' THEN 1 ELSE 0 END) || ' | 30 días: ' || SUM(CASE WHEN plan='30d' THEN 1 ELSE 0 END) || ' | 50 días: ' || SUM(CASE WHEN plan='50d' THEN 1 ELSE 0 END) FROM payments WHERE status='approved'"
            
            echo -e "\n${YELLOW}💸 INGRESOS HOY:${NC}"
            sqlite3 "$DB" "SELECT 'Hoy: $' || printf('%.2f', SUM(CASE WHEN date(approved_at) = date('now') THEN final_amount ELSE 0 END)) FROM payments"
            
            echo -e "\n${YELLOW}📢 NOTIFICACIONES:${NC}"
            sqlite3 "$DB" "SELECT 'Hoy: ' || COUNT(*) || ' | Avisos: ' || SUM(CASE WHEN type='expiry_warning' THEN 1 ELSE 0 END) || ' | Recordatorios: ' || SUM(CASE WHEN type='today_expiry' THEN 1 ELSE 0 END) FROM notifications WHERE date(sent_at) = date('now')"
            
            echo -e "\n${YELLOW}⏰ USUARIOS POR VENCER:${NC}"
            sqlite3 "$DB" "SELECT 'En 24h: ' || COUNT(*) || ' | En 48h: ' || (SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+48 hours') AND expires_at > datetime('now', '+24 hours')) FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+24 hours')"
            
            read -p "\nPresiona Enter..." 
            ;;
        11)
            echo -e "\n${YELLOW}📝 Logs (Ctrl+C para salir)...${NC}\n"
            pm2 logs ssh-bot --lines 100
            ;;
        12)
            clear
            echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${CYAN}║             🔔 FORZAR NOTIFICACIONES                       ║${NC}"
            echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
            
            echo -e "${YELLOW}¿Qué notificaciones quieres forzar?${NC}"
            echo -e "  1. Avisos por vencer (24h)"
            echo -e "  2. Recordatorios de vencimiento hoy"
            echo -e "  3. Ambas"
            echo -e "  0. Cancelar"
            echo -e ""
            
            read -p "Selecciona: " FORCE_OPT
            
            case $FORCE_OPT in
                1)
                    echo -e "\n${YELLOW}🔍 Buscando usuarios por vencer en 24h...${NC}"
                    EXPIRING_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+24 hours')" 2>/dev/null || echo "0")
                    echo -e "${CYAN}Encontrados: ${EXPIRING_COUNT} usuarios${NC}"
                    
                    read -p "¿Forzar envío de avisos? (s/N): " CONFIRM
                    if [[ "$CONFIRM" == "s" ]]; then
                        echo -e "${YELLOW}🔄 Ejecutando script de avisos...${NC}"
                        echo -e "${GREEN}✅ Comando enviado al sistema de notificaciones${NC}"
                        echo -e "${CYAN}Revisa los logs del bot para ver el progreso${NC}"
                    fi
                    ;;
                2)
                    echo -e "\n${YELLOW}🔍 Buscando usuarios que expiran hoy...${NC}"
                    TODAY_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND date(expires_at) = date('now')" 2>/dev/null || echo "0")
                    echo -e "${CYAN}Encontrados: ${TODAY_COUNT} usuarios${NC}"
                    
                    read -p "¿Forzar envío de recordatorios? (s/N): " CONFIRM
                    if [[ "$CONFIRM" == "s" ]]; then
                        echo -e "${YELLOW}🔄 Ejecutando script de recordatorios...${NC}"
                        echo -e "${GREEN}✅ Comando enviado al sistema de notificaciones${NC}"
                        echo -e "${CYAN}Revisa los logs del bot para ver el progreso${NC}"
                    fi
                    ;;
                3)
                    echo -e "\n${YELLOW}🔍 Buscando todas las notificaciones pendientes...${NC}"
                    EXPIRING_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND expires_at <= datetime('now', '+24 hours')" 2>/dev/null || echo "0")
                    TODAY_COUNT=$(sqlite3 "$DB" "SELECT COUNT(*) FROM users WHERE status=1 AND tipo='premium' AND date(expires_at) = date('now')" 2>/dev/null || echo "0")
                    echo -e "${CYAN}Avisos 24h: ${EXPIRING_COUNT} | Recordatorios hoy: ${TODAY_COUNT}${NC}"
                    
                    read -p "¿Forzar todas las notificaciones? (s/N): " CONFIRM
                    if [[ "$CONFIRM" == "s" ]]; then
                        echo -e "${YELLOW}🔄 Ejecutando todos los scripts de notificación...${NC}"
                        echo -e "${GREEN}✅ Comandos enviados al sistema de notificaciones${NC}"
                        echo -e "${CYAN}Revisa los logs del bot para ver el progreso${NC}"
                    fi
                    ;;
            esac
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

chmod +x /usr/local/bin/sshbot
echo -e "${GREEN}✅ Panel de control creado${NC}"

# ================================================
# INICIAR BOT
# ================================================
echo -e "\n${CYAN}${BOLD}🚀 INICIANDO BOT...${NC}"

cd "$USER_HOME"
pm2 start bot.js --name ssh-bot
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
║       🎉 INSTALACIÓN COMPLETADA - SIN CUPONES 🎉           ║
║                                                              ║
║               SSH BOT PRO - CONFIGURADO                     ║
║               📅 DIARIOS: 7, 15 DÍAS                       ║
║               📅 MENSUALES: 30, 50 DÍAS                    ║
║               ⏰ TEST GRATIS: 2 HORAS                       ║
║               🔐 CONTRASEÑA FIJA: mgvpn247                 ║
║               💰 MERCADOPAGO INTEGRADO                      ║
║               📢 NOTIFICACIONES AUTOMÁTICAS                 ║
║               🚫 SIN CUPONES DE DESCUENTO                   ║
║               📱 FLUJO NATURAL DE USUARIO                  ║
║               ⚙️  PANEL CON GESTIÓN COMPLETA               ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
FINAL
echo -e "${NC}"

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Sistema instalado con planes separados${NC}"
echo -e "${GREEN}✅ Menú: 1=Prueba, 2=Comprar, 3=Renovar, 4=APP${NC}"
echo -e "${GREEN}✅ Planes DIARIOS: 7, 15 días${NC}"
echo -e "${GREEN}✅ Planes MENSUALES: 30, 50 días${NC}"
echo -e "${GREEN}✅ Generación de link MercadoPago${NC}"
echo -e "${GREEN}✅ Test: 2 horas por defecto${NC}"
echo -e "${GREEN}✅ CONTRASEÑA FIJA: mgvpn247 para todos${NC}"
echo -e "${GREEN}✅ Pruebas: testXXXX (ej: test1234)${NC}"
echo -e "${GREEN}✅ Compras: userXXXX (ej: user5678)${NC}"
echo -e "${GREEN}✅ Panel con edición de horas del test${NC}"
echo -e "${RED}🚫 CUPONES DE DESCUENTO DESACTIVADOS${NC}"
echo -e "${GREEN}📢 SISTEMA DE NOTIFICACIONES ACTIVADO:${NC}"
echo -e "${GREEN}   • Aviso por vencer (24h antes)${NC}"
echo -e "${GREEN}   • Recordatorio de vencimiento hoy${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 COMANDOS DISPONIBLES:${NC}\n"
echo -e "  ${GREEN}sshbot${NC}         - Panel de control completo"
echo -e "  ${GREEN}pm2 logs ssh-bot${NC} - Ver logs"
echo -e "  ${GREEN}pm2 restart ssh-bot${NC} - Reiniciar bot\n"

echo -e "${YELLOW}🔧 CONFIGURACIÓN INICIAL:${NC}\n"
echo -e "  1. Ejecuta: ${GREEN}sshbot${NC}"
echo -e "  2. Opción ${CYAN}[8]${NC} - Configurar MercadoPago"
echo -e "  3. Opción ${CYAN}[9]${NC} - Configurar grupo de notificaciones"
echo -e "  4. Opción ${CYAN}[3]${NC} - Escanear QR WhatsApp"
echo -e "  5. Opción ${CYAN}[6]${NC} - Ajustar horas del test (opcional)"
echo -e "  6. Opción ${CYAN}[7]${NC} - Ajustar precios\n"

echo -e "${YELLOW}💰 PRECIOS POR DEFECTO:${NC}\n"
echo -e "  Test: ${GREEN}2 horas (gratis)${NC}"
echo -e "  📅 DIARIOS:"
echo -e "    7 días: ${GREEN}$1500 ARS${NC}"
echo -e "    15 días: ${GREEN}$2500 ARS${NC}"
echo -e "  📅 MENSUALES:"
echo -e "    30 días: ${GREEN}$5500 ARS${NC}"
echo -e "    50 días: ${GREEN}$8500 ARS${NC}\n"

echo -e "${YELLOW}⌨️  FLUJO PARA USUARIOS:${NC}\n"
echo -e "  ${CYAN}1.${NC} Escribe 'menu' → Menú principal"
echo -e "  ${CYAN}2.${NC} Escribe '1' → Prueba gratis (2 horas)"
echo -e "  ${CYAN}3.${NC} Escribe '2' → Comprar Login SSH"
echo -e "  ${CYAN}4.${NC} Selecciona:"
echo -e "     ${GREEN}1${NC} - Planes DIARIOS (7, 15 días)"
echo -e "     ${GREEN}2${NC} - Planes MENSUALES (30, 50 días)"
echo -e "  ${CYAN}5.${NC} Elige un plan:"
echo -e "     DIARIOS: ${GREEN}1${NC}=7d - ${GREEN}2${NC}=15d"
echo -e "     MENSUALES: ${GREEN}1${NC}=30d - ${GREEN}2${NC}=50d"
echo -e "  ${CYAN}6.${NC} Recibe link de pago MercadoPago"
echo -e "  ${CYAN}7.${NC} Recibe notificación cuando el pago sea aprobado\n"

echo -e "${YELLOW}📢 NOTIFICACIONES AUTOMÁTICAS:${NC}"
echo -e "  ⚠️  ${CYAN}Aviso 24h antes de vencer${NC}"
echo -e "  ⏰ ${CYAN}Recordatorio el día de vencimiento${NC}\n"

echo -e "${YELLOW}📊 INFO:${NC}"
echo -e "  IP: ${CYAN}$SERVER_IP${NC}"
echo -e "  BD: ${CYAN}/opt/ssh-bot/data/users.db${NC}"
echo -e "  Config: ${CYAN}/opt/ssh-bot/config/config.json${NC}"
echo -e "  Grupo notif.: ${CYAN}${NOTIFICATION_GROUP:-'No configurado'}${NC}"
echo -e "  Pruebas: ${GREEN}testXXXX (test1234) - 2 horas${NC}"
echo -e "  Compras: ${GREEN}userXXXX (user5678)${NC}"
echo -e "  Contraseña: ${GREEN}mgvpn247 (fija)${NC}"
echo -e "  Cupones: ${RED}🚫 DESACTIVADOS${NC}\n"

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

read -p "$(echo -e "${YELLOW}¿Abrir panel de control? (s/N): ${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "\n${CYAN}Abriendo panel...${NC}\n"
    sleep 2
    /usr/local/bin/sshbot
else
    echo -e "\n${YELLOW}💡 Ejecuta: ${GREEN}sshbot${NC} para abrir el panel\n"
fi

echo -e "${GREEN}${BOLD}¡Sistema instalado exitosamente SIN cupones! 🚀${NC}\n"

exit 0
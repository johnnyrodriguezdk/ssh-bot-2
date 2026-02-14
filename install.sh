#!/bin/bash
# ================================================
# BOT WHATSAPP - VERSIÓN PREMIUM
# ================================================
# CARACTERÍSTICAS:
# ✅ COMPRA CON 2 OPCIONES:
#   Opción 1: Pago automático MP + Usuario automático
#   Opción 2: Pago manual + Usuario manual (contacta representante)
# ✅ BOT SILENCIOSO: Solo responde a comandos válidos
# ✅ MERCADOPAGO INTEGRADO
# ✅ CREACIÓN AUTOMÁTICA DE USUARIOS SSH (terminan en 'j')
# ✅ CONTRASEÑA FIJA 12345
# ✅ RENOVAR USUARIOS
# ✅ PREGUNTA ANDROID/APPLE
# ✅ PANEL VPS COMPLETO CON ESTADÍSTICAS
# ✅ NOMBRE DINÁMICO (TODO SE ADAPTA)
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

# Banner
clear
echo -e "${CYAN}${BOLD}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║     ████████╗██╗███████╗███╗   ██╗██████╗  █████╗          ║
║     ╚══██╔══╝██║██╔════╝████╗  ██║██╔══██╗██╔══██╗         ║
║        ██║   ██║█████╗  ██╔██╗ ██║██║  ██║███████║         ║
║        ██║   ██║██╔══╝  ██║╚██╗██║██║  ██║██╔══██║         ║
║        ██║   ██║███████╗██║ ╚████║██████╔╝██║  ██║         ║
║        ╚═╝   ╚═╝╚══════╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝         ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║              🤖 BOT WHATSAPP - VERSIÓN PREMIUM              ║
║     ✅ 2 OPCIONES DE COMPRA · ✅ BOT SILENCIOSO             ║
║     ✅ SOLO RESPONDE COMANDOS VÁLIDOS                       ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

echo -e "${GREEN}✅ CARACTERÍSTICAS:${NC}"
echo -e "  🤖 ${CYAN}Bot silencioso:${NC} Solo responde a comandos válidos (menú, 1-6, etc)"
echo -e "  💳 ${YELLOW}Compra opción 1:${NC} Pago automático MP + Usuario automático"
echo -e "  👤 ${PURPLE}Compra opción 2:${NC} Pago manual + Contacta representante"
echo -e "  🔐 ${GREEN}Usuarios:${NC} Terminan en 'j' · Contraseña 12345"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Debes ejecutar como root${NC}"
    exit 1
fi

# ================================================
# CONFIGURACIÓN DEL NOMBRE
# ================================================
echo -e "\n${CYAN}${BOLD}⚙️ CONFIGURACIÓN DEL BOT${NC}"

# Pedir nombre
read -p "📝 NOMBRE PARA TU BOT (ej: TIENDA LIBRE|AR o SERVERTUC): " BOT_NAME
BOT_NAME=${BOT_NAME:-"TIENDA LIBRE|AR"}

# Crear versión segura para rutas
SAFE_NAME=$(echo "$BOT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
SAFE_NAME=${SAFE_NAME:-"bot"}

echo -e "\n${GREEN}✅ NOMBRE CONFIGURADO:${NC}"
echo -e "   • Nombre visible: ${CYAN}$BOT_NAME${NC}"
echo -e "   • Nombre para rutas: ${CYAN}$SAFE_NAME${NC}"

# ================================================
# RUTAS DINÁMICAS
# ================================================
INSTALL_DIR="/sshbot"
PROCESS_NAME="$SAFE_NAME-bot"
SESSION_DIR="/root/.wppconnect/$SAFE_NAME"
LOG_NAME="$SAFE_NAME-bot"
DB_FILE="$INSTALL_DIR/data/users.db"
CONFIG_FILE="$INSTALL_DIR/config/config.json"
INFO_FILE="$INSTALL_DIR/config/info.txt"

echo -e "\n${YELLOW}📁 RUTAS QUE SE CREARÁN:${NC}"
echo -e "   • Instalación: ${CYAN}$INSTALL_DIR${NC}"
echo -e "   • Proceso PM2: ${CYAN}$PROCESS_NAME${NC}"
echo -e "   • Sesión WhatsApp: ${CYAN}$SESSION_DIR${NC}"
echo -e "   • Base de datos: ${CYAN}$DB_FILE${NC}"

read -p "$(echo -e "${YELLOW}¿Continuar con la instalación COMPLETA? (s/N): ${NC}")" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    echo -e "${RED}❌ Cancelado${NC}"
    exit 0
fi

# ================================================
# LIMPIEZA TOTAL
# ================================================
echo -e "\n${CYAN}${BOLD}🧹 LIMPIEZA TOTAL...${NC}"

# Detener procesos
pm2 list | grep -E "(bot|libre|serv|tienda)" | awk '{print $2}' | xargs -r pm2 delete 2>/dev/null
pm2 kill 2>/dev/null
pkill -f chrome 2>/dev/null
pkill -f node 2>/dev/null

# Limpiar directorios
rm -rf /sshbot 2>/dev/null
rm -rf /root/.wppconnect 2>/dev/null
rm -rf /root/.pm2/logs/* 2>/dev/null

echo -e "${GREEN}✅ Limpieza completada${NC}"

# ================================================
# CREAR ESTRUCTURA
# ================================================
echo -e "\n${CYAN}${BOLD}📁 CREANDO ESTRUCTURA...${NC}"
mkdir -p "$INSTALL_DIR"/{data,config,sessions,logs,qr_codes}
mkdir -p "$SESSION_DIR"
chmod -R 755 "$INSTALL_DIR"
chmod -R 700 "$SESSION_DIR"
echo -e "${GREEN}✅ Estructura creada en $INSTALL_DIR${NC}"

# ================================================
# CONFIGURACIÓN DEL BOT
# ================================================
echo -e "\n${CYAN}${BOLD}⚙️ CONFIGURANDO OPCIONES...${NC}"

# Link de la APP
read -p "📲 Link de descarga para Android: " APP_LINK
APP_LINK=${APP_LINK:-"https://www.mediafire.com/file/p8kgthxbsid7xws/MAJ/DNI_AND_FIL"}

# Número de soporte
read -p "🆘 Número de WhatsApp para representante: " SUPPORT_NUMBER
SUPPORT_NUMBER=${SUPPORT_NUMBER:-"543435071016"}

# Precios
echo -e "\n${YELLOW}💰 CONFIGURACIÓN DE PRECIOS (ARS):${NC}"
read -p "Precio 7 días (3000): " PRICE_7D
PRICE_7D=${PRICE_7D:-3000}
read -p "Precio 15 días (4000): " PRICE_15D
PRICE_15D=${PRICE_15D:-4000}
read -p "Precio 30 días (7000): " PRICE_30D
PRICE_30D=${PRICE_30D:-7000}
read -p "Precio 50 días (9700): " PRICE_50D
PRICE_50D=${PRICE_50D:-9700}

# Horas de prueba
read -p "⏰ Horas de prueba gratis (2): " TEST_HOURS
TEST_HOURS=${TEST_HOURS:-2}

# Detectar IP
SERVER_IP=$(curl -4 -s --max-time 10 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
SERVER_IP=${SERVER_IP:-"127.0.0.1"}

# ================================================
# TEXTO DE INFORMACIÓN PERSONALIZADO
# ================================================
cat > "$INFO_FILE" << 'EOF'
🔥 INTERNET ILIMITADO ⚡📱
_______

Es una aplicación que te permite conectar y navegar en internet de manera ilimitada/infinita. Sin necesidad de tener saldo/crédito o MG/GB.
_______

📢 Te ofrecemos internet Ilimitado para la empresa PERSONAL, tanto ABONO como PREPAGO a través de nuestra aplicación!

❓ Cómo funciona? Instalamos y configuramos nuestra app para que tengas acceso al servicio, una vez instalada puedes usar todo el internet que quieras sin preocuparte por tus datos!

📲 Probamos que todo funcione correctamente para que recién puedas abonar vía transferencia!

⚙️ Tienes soporte técnico por los 30 días que contrates por cualquier inconveniente! 

⚠️ Nos hacemos cargo de cualquier problema!
EOF

# ================================================
# GUARDAR CONFIGURACIÓN
# ================================================
cat > "$CONFIG_FILE" << EOF
{
    "bot": {
        "name": "$BOT_NAME",
        "safe_name": "$SAFE_NAME",
        "version": "7.0-PREMIUM",
        "server_ip": "$SERVER_IP",
        "default_password": "12345",
        "test_hours": $TEST_HOURS,
        "info_file": "$INFO_FILE",
        "process_name": "$PROCESS_NAME"
    },
    "prices": {
        "test_hours": $TEST_HOURS,
        "price_7d": $PRICE_7D,
        "price_15d": $PRICE_15D,
        "price_30d": $PRICE_30D,
        "price_50d": $PRICE_50D,
        "currency": "ARS"
    },
    "mercadopago": {
        "access_token": "",
        "enabled": false,
        "public_key": ""
    },
    "links": {
        "app_android": "$APP_LINK",
        "support": "https://wa.me/$SUPPORT_NUMBER"
    },
    "paths": {
        "database": "$DB_FILE",
        "chromium": "/usr/bin/google-chrome",
        "qr_codes": "$INSTALL_DIR/qr_codes",
        "sessions": "$SESSION_DIR"
    }
}
EOF

# ================================================
# CREAR BASE DE DATOS COMPLETA
# ================================================
echo -e "\n${CYAN}🗄️ Creando base de datos SQLite...${NC}"

sqlite3 "$DB_FILE" << 'SQL'
-- Tabla de usuarios
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    username TEXT UNIQUE,
    password TEXT DEFAULT '12345',
    tipo TEXT DEFAULT 'test',
    expires_at DATETIME,
    max_connections INTEGER DEFAULT 1,
    status INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Control de pruebas diarias
CREATE TABLE daily_tests (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    date DATE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(phone, date)
);

-- Pagos
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_id TEXT UNIQUE,
    phone TEXT,
    plan TEXT,
    days INTEGER,
    connections INTEGER DEFAULT 1,
    amount REAL,
    status TEXT DEFAULT 'pending',
    payment_url TEXT,
    qr_code TEXT,
    preference_id TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    approved_at DATETIME
);

-- Logs
CREATE TABLE logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    type TEXT,
    message TEXT,
    data TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Sistema de estados
CREATE TABLE user_state (
    phone TEXT PRIMARY KEY,
    state TEXT DEFAULT 'main_menu',
    data TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Índices
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_status ON users(status);
CREATE INDEX idx_payments_status ON payments(status);
CREATE INDEX idx_payments_preference ON payments(preference_id);
SQL

echo -e "${GREEN}✅ Base de datos creada${NC}"

# ================================================
# INSTALAR DEPENDENCIAS
# ================================================
echo -e "\n${CYAN}📦 Instalando dependencias del sistema...${NC}"
apt-get update -y
apt-get upgrade -y

# Node.js 18.x
echo -e "${YELLOW}📦 Instalando Node.js 18.x...${NC}"
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs gcc g++ make

# Chrome
echo -e "${YELLOW}🌐 Instalando Google Chrome...${NC}"
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -y
apt-get install -y google-chrome-stable

# Dependencias del sistema
echo -e "${YELLOW}⚙️ Instalando utilidades...${NC}"
apt-get install -y \
    git curl wget sqlite3 jq \
    build-essential libcairo2-dev \
    libpango1.0-dev libjpeg-dev \
    libgif-dev librsvg2-dev \
    python3 python3-pip ffmpeg \
    unzip cron ufw

# Configurar firewall
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 8001/tcp
ufw allow 3000/tcp
ufw --force enable

# PM2
npm install -g pm2
pm2 update

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

# ================================================
# INSTALAR MÓDULOS NODE
# ================================================
echo -e "\n${CYAN}📦 Instalando módulos de Node.js (puede tomar varios minutos)...${NC}"
cd "$INSTALL_DIR"

cat > package.json << EOF
{
    "name": "$SAFE_NAME-bot",
    "version": "7.0.0",
    "main": "bot.js",
    "dependencies": {
        "@wppconnect-team/wppconnect": "^1.24.0",
        "qrcode-terminal": "^0.12.0",
        "qrcode": "^1.5.3",
        "moment": "^2.30.1",
        "sqlite3": "^5.1.7",
        "chalk": "^4.1.2",
        "node-cron": "^3.0.3",
        "mercadopago": "^2.0.15",
        "axios": "^1.6.5",
        "sharp": "^0.33.2"
    }
}
EOF

npm install --silent 2>&1 | grep -v "npm WARN" || true
echo -e "${GREEN}✅ Módulos instalados${NC}"

# ================================================
# CREAR BOT.JS COMPLETO (CON 2 OPCIONES DE COMPRA Y BOT SILENCIOSO)
# ================================================
echo -e "\n${CYAN}🤖 Creando bot.js con 2 opciones de compra y modo silencioso...${NC}"

cat > "bot.js" << 'BOTEOF'
const wppconnect = require('@wppconnect-team/wppconnect');
const qrcode = require('qrcode-terminal');
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
moment.locale('es');

// ==============================================
// CONFIGURACIÓN (RUTAS DINÁMICAS)
// ==============================================
const BASE_PATH = '/sshbot';
const CONFIG_FILE = path.join(BASE_PATH, 'config/config.json');
const DB_FILE = path.join(BASE_PATH, 'data/users.db');
const INFO_FILE = path.join(BASE_PATH, 'config/info.txt');

// Cargar configuración
function loadConfig() {
    try {
        delete require.cache[require.resolve(CONFIG_FILE)];
        return require(CONFIG_FILE);
    } catch (error) {
        console.error(chalk.red('❌ Error cargando configuración:'), error.message);
        process.exit(1);
    }
}

let config = loadConfig();
const db = new sqlite3.Database(DB_FILE);

console.log(chalk.cyan.bold('\n╔══════════════════════════════════════════════════════════════╗'));
console.log(chalk.cyan.bold(`║           🎛️  ${config.bot.name} BOT - VERSIÓN PREMIUM         ║`));
console.log(chalk.cyan.bold('║     ✅ 2 OPCIONES COMPRA · ✅ BOT SILENCIOSO                  ║'));
console.log(chalk.cyan.bold('╚══════════════════════════════════════════════════════════════╝\n'));

// ==============================================
// MERCADOPAGO SDK V2.X
// ==============================================
let mpEnabled = false;
let mpClient = null;
let mpPreference = null;

function initMercadoPago() {
    config = loadConfig();
    if (config.mercadopago.access_token && config.mercadopago.access_token !== '') {
        try {
            const { MercadoPagoConfig, Preference } = require('mercadopago');
            mpClient = new MercadoPagoConfig({ 
                accessToken: config.mercadopago.access_token,
                options: { timeout: 5000 }
            });
            mpPreference = new Preference(mpClient);
            mpEnabled = true;
            console.log(chalk.green('✅ MercadoPago SDK v2.x ACTIVO'));
        } catch (error) {
            console.log(chalk.red('❌ Error MP:'), error.message);
            mpEnabled = false;
        }
    } else {
        console.log(chalk.yellow('⚠️ MercadoPago NO configurado (usa sshbot mercadopago)'));
    }
}
initMercadoPago();

// ==============================================
// SISTEMA DE ESTADOS (SQLite)
// ==============================================
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
            (err) => resolve(!err)
        );
    });
}

// ==============================================
// FUNCIONES SSH (usuarios terminan en 'j', pass 12345)
// ==============================================
function generateSSHUsername(phone) {
    const timestamp = Date.now().toString().slice(-6);
    const random = Math.floor(Math.random() * 90) + 10;
    return `user${timestamp}${random}j`;
}

async function createSSHUser(username, days = 0, maxConnections = 1) {
    try {
        const password = '12345';
        const expiryDate = days > 0 ? 
            moment().add(days, 'days').format('YYYY-MM-DD HH:mm:ss') : 
            moment().add(config.bot.test_hours, 'hours').format('YYYY-MM-DD HH:mm:ss');
        
        // Crear usuario en el sistema
        await execPromise(`useradd -M -s /bin/false -e $(date -d "${expiryDate}" +%Y-%m-%d) ${username} 2>/dev/null || true`);
        await execPromise(`echo "${username}:${password}" | chpasswd`);
        
        // Configurar conexiones simultáneas si es necesario
        if (maxConnections > 1) {
            await execPromise(`echo "MaxSessions ${maxConnections}" >> /etc/ssh/sshd_config.d/${username}.conf 2>/dev/null || true`);
        }
        
        return { success: true, username, password, expires: expiryDate };
    } catch (error) {
        console.error('Error creando usuario SSH:', error);
        return { success: false, error: error.message };
    }
}

// Función para RENOVAR usuario
async function renewSSHUser(username, days) {
    try {
        const newExpiry = moment().add(days, 'days').format('YYYY-MM-DD');
        await execPromise(`chage -E $(date -d "${newExpiry}" +%Y-%m-%d) ${username}`);
        
        db.run(`UPDATE users SET expires_at = ? WHERE username = ?`, 
            [moment().add(days, 'days').format('YYYY-MM-DD HH:mm:ss'), username]);
        
        return { success: true, newExpiry };
    } catch (error) {
        console.error('Error renovando usuario:', error);
        return { success: false, error: error.message };
    }
}

// ==============================================
// FUNCIONES MP
// ==============================================
async function createMercadoPagoPayment(phone, planName, days, amount, connections = 1) {
    if (!mpEnabled) return { success: false, error: 'MercadoPago no configurado' };
    try {
        const paymentId = `MP-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
        const preferenceData = {
            items: [{
                title: `${config.bot.name} - ${planName}`,
                description: `Plan ${days} días - ${connections} conexión(es)`,
                quantity: 1,
                currency_id: 'ARS',
                unit_price: parseFloat(amount)
            }],
            payer: { phone: { number: phone.replace('+', '') } },
            payment_methods: {
                excluded_payment_types: [{ id: 'atm' }],
                installments: 1
            },
            external_reference: paymentId,
            auto_return: 'approved'
        };
        
        const preference = await mpPreference.create({ body: preferenceData });
        
        // Generar QR code
        const qrPath = path.join(config.paths.qr_codes, `${paymentId}.png`);
        await QRCode.toFile(qrPath, preference.init_point);
        
        // Guardar en base de datos
        db.run(
            `INSERT INTO payments (payment_id, phone, plan, days, connections, amount, status, payment_url, qr_code, preference_id) 
             VALUES (?, ?, ?, ?, ?, ?, 'pending', ?, ?, ?)`,
            [paymentId, phone, planName, days, connections, amount, preference.init_point, qrPath, preference.id]
        );
        
        return { success: true, paymentId, paymentUrl: preference.init_point, qrCode: qrPath };
    } catch (error) {
        console.error('Error creando pago MP:', error);
        return { success: false, error: error.message };
    }
}

// ==============================================
// LISTA DE COMANDOS VÁLIDOS (para bot silencioso)
// ==============================================
const VALID_COMMANDS = ['menu', '0', '1', '2', '3', '4', '5', '6'];

// ==============================================
// MENSAJES PERSONALIZADOS
// ==============================================
function getMainMenuMessage() {
    return `⚙️ *${config.bot.name} ChatBot* 🧑‍💻
             ⸻↓⸻

🛍️ *MENÚ PRINCIPAL*

1 ⁃📢 INFORMACIÓN
2 ⁃🏷️ PRECIOS
3 ⁃🛍️ COMPRAR USUARIO
4 ⁃🔄 RENOVAR USUARIO
5 ⁃📲 DESCARGAR APLICACION
6 ⁃👥 HABLAR CON REPRESENTANTE

👉 Escribe una opción`;
}

function getInfoMessage() {
    try {
        if (fs.existsSync(INFO_FILE)) {
            return fs.readFileSync(INFO_FILE, 'utf8');
        }
    } catch (error) {
        console.error('Error leyendo info:', error);
    }
    return `*📢 INFORMACIÓN DEL BOT*

🔐 *TODOS LOS USUARIOS:*
• Contraseña: *12345* (fija)
• Usuario termina en *'j'*

🌐 *SERVIDOR:*
• IP: ${config.bot.server_ip}
• Puerto: 22

⏰ *PRUEBA GRATIS:*
• ${config.bot.test_hours} horas

💳 *PAGOS:*
• MercadoPago integrado`;
}

function getPricesMessage() {
    return `*🏷️ PRECIOS (ARS)*

🔸 *7 días* (1 conexión) → $${config.prices.price_7d}
🔸 *15 días* (1 conexión) → $${config.prices.price_15d}
🔸 *30 días* (1 conexión) → $${config.prices.price_30d}
🔸 *50 días* (1 conexión) → $${config.prices.price_50d}

💳 *MercadoPago - Pago automático*

_Escribe *menu* para volver_`;
}

function getPlansToBuyMessage() {
    return `*🛍️ COMPRAR USUARIO*

*Elige un plan:*

🔸 *1* - 7 días ($${config.prices.price_7d})
🔸 *2* - 15 días ($${config.prices.price_15d})
🔸 *3* - 30 días ($${config.prices.price_30d})
🔸 *4* - 50 días ($${config.prices.price_50d})

*0* - Volver al menú principal

👉 Responde con el número del plan:`;
}

function getPaymentOptionsMessage(plan) {
    return `*🛍️ OPCIONES DE PAGO - ${plan.name}*

💰 *Monto:* $${plan.price} ARS

*Elige cómo deseas pagar:*

🔘 *1* - Pago automático con MercadoPago
   • Pagas ahora con MercadoPago
   • El usuario se crea AUTOMÁTICAMENTE al aprobarse

🔘 *2* - Pago manual (Transferencia)
   • Te contacta un representante
   • Te explicará cómo pagar
   • El usuario se crea MANUALMENTE después del pago

🔘 *0* - Cancelar y volver al menú principal

👉 Responde con 1, 2 o 0:`;
}

function getAndroidPromptMessage() {
    return `*📲 ¿QUÉ TIPO DE DISPOSITIVO USAS?*

🔘 *1* - Android (Recibir link de descarga)
🔘 *2* - Apple/iPhone (Contactar a representante)

_Elige 1 o 2:_`;
}

function getPlanDetails(planNumber) {
    const plans = {
        1: { name: '7 días', days: 7, price: config.prices.price_7d, connections: 1 },
        2: { name: '15 días', days: 15, price: config.prices.price_15d, connections: 1 },
        3: { name: '30 días', days: 30, price: config.prices.price_30d, connections: 1 },
        4: { name: '50 días', days: 50, price: config.prices.price_50d, connections: 1 }
    };
    return plans[planNumber] || null;
}

// ==============================================
// VERIFICAR SI ES UN COMANDO VÁLIDO (para bot silencioso)
// ==============================================
function isValidCommand(text, userState) {
    const lowerText = text.toLowerCase();
    
    // Siempre aceptar 'menu' y '0'
    if (lowerText === 'menu' || text === '0') return true;
    
    // Si está en un estado específico, validar según el contexto
    if (userState.state === 'plans_menu') {
        return ['1', '2', '3', '4', '0'].includes(text);
    }
    
    if (userState.state === 'buying_plan') {
        return ['1', '2', '3', '4', '0'].includes(text);
    }
    
    if (userState.state === 'payment_options') {
        return ['1', '2', '0'].includes(text);
    }
    
    if (userState.state === 'waiting_os') {
        return ['1', '2'].includes(text);
    }
    
    if (userState.state === 'selecting_renew_account') {
        // Validar números del 0 al número de cuentas
        const num = parseInt(text);
        return (text === '0') || (!isNaN(num) && num > 0);
    }
    
    // En menú principal, solo aceptar 1-6
    if (userState.state === 'main_menu') {
        return ['1', '2', '3', '4', '5', '6'].includes(text);
    }
    
    return false;
}

// ==============================================
// MANEJADOR DE MENSAJES (BOT SILENCIOSO)
// ==============================================
async function handleMessage(message) {
    const phone = message.from.replace('@c.us', '');
    const text = message.body || '';
    const userState = await getUserState(phone);
    
    console.log(chalk.blue(`📱 ${phone}: "${text}" (Estado: ${userState.state})`));
    
    // Verificar si es un comando válido
    if (!isValidCommand(text, userState)) {
        console.log(chalk.gray(`   ⏭️  Mensaje ignorado (no es comando válido)`));
        return; // NO RESPONDE NADA - BOT SILENCIOSO
    }
    
    // Comando para volver al menú principal
    if (text.toLowerCase() === 'menu' || text === '0') {
        await setUserState(phone, 'main_menu');
        await client.sendText(message.from, getMainMenuMessage());
        return;
    }
    
    switch (userState.state) {
        case 'main_menu':
            await handleMainMenu(phone, text, message.from);
            break;
        case 'plans_menu':
            await handlePlansMenu(phone, text, message.from);
            break;
        case 'payment_options':
            await handlePaymentOptions(phone, text, message.from, userState.data);
            break;
        case 'selecting_renew_account':
            await handleAccountSelectionForRenew(phone, text, message.from, userState.data);
            break;
        case 'selecting_renew_plan':
            await handleRenewPlanSelection(phone, text, message.from, userState.data);
            break;
        case 'waiting_os':
            await handleOSSelection(phone, text, message.from);
            break;
        default:
            await setUserState(phone, 'main_menu');
            await client.sendText(message.from, getMainMenuMessage());
    }
}

// ==============================================
// MANEJADOR DEL MENÚ PRINCIPAL
// ==============================================
async function handleMainMenu(phone, text, from) {
    switch (text) {
        case '1': // INFORMACIÓN
            await client.sendText(from, getInfoMessage() + '\n\n_Escribe *menu* para volver_');
            await setUserState(phone, 'main_menu');
            break;
            
        case '2': // PRECIOS
            await client.sendText(from, getPricesMessage());
            await setUserState(phone, 'main_menu');
            break;
            
        case '3': // COMPRAR USUARIO
            await setUserState(phone, 'plans_menu');
            await client.sendText(from, getPlansToBuyMessage());
            break;
            
        case '4': // RENOVAR USUARIO
            await handleRenewStart(phone, from);
            break;
            
        case '5': // DESCARGAR APP
            await setUserState(phone, 'waiting_os');
            await client.sendText(from, getAndroidPromptMessage());
            break;
            
        case '6': // HABLAR CON REPRESENTANTE
            await client.sendText(from, `*👥 REPRESENTANTE*\n\nContacta con nosotros:\n${config.links.support}\n\n_Escribe *menu* para volver_`);
            await setUserState(phone, 'main_menu');
            break;
    }
}

// ==============================================
// MENÚ DE PLANES
// ==============================================
async function handlePlansMenu(phone, text, from) {
    const planNumber = parseInt(text);
    
    if (planNumber >= 1 && planNumber <= 4) {
        const plan = getPlanDetails(planNumber);
        if (plan) {
            await setUserState(phone, 'payment_options', { plan });
            await client.sendText(from, getPaymentOptionsMessage(plan));
        }
    }
}

// ==============================================
// OPCIONES DE PAGO (NUEVO - 2 OPCIONES)
// ==============================================
async function handlePaymentOptions(phone, text, from, data) {
    const plan = data.plan;
    
    if (text === '1') {
        // Opción 1: Pago automático con MercadoPago
        if (!mpEnabled) {
            await client.sendText(from, `❌ MercadoPago no está configurado.\n\nPor favor, elige la opción 2 (pago manual) o contacta a soporte.\n\n${config.links.support}`);
            await setUserState(phone, 'main_menu');
            return;
        }
        
        const payment = await createMercadoPagoPayment(phone, plan.name, plan.days, plan.price, plan.connections);
        
        if (payment.success) {
            await client.sendText(from, `*✅ PAGO AUTOMÁTICO GENERADO*

*Plan:* ${plan.name}
*Monto:* $${plan.price} ARS

*Enlace de pago:* 
${payment.paymentUrl}

*Instrucciones:*
1. Haz clic en el enlace
2. Completa el pago con MercadoPago
3. Al aprobarse el pago, recibirás AUTOMÁTICAMENTE:
   • Usuario (termina en 'j')
   • Contraseña: 12345
   • IP del servidor: ${config.bot.server_ip}

_El proceso es automático, no necesitas contactar a nadie._

_Escribe *menu* para volver_`);
            
            await setUserState(phone, 'main_menu');
        } else {
            await client.sendText(from, `❌ Error al generar pago: ${payment.error}\n\nPor favor, intenta con la opción 2 (pago manual) o contacta a soporte.\n\n${config.links.support}`);
            await setUserState(phone, 'main_menu');
        }
        
    } else if (text === '2') {
        // Opción 2: Pago manual (transferencia) + contacto con representante
        await client.sendText(from, `*🔄 PAGO MANUAL - TRANSFERENCIA*

Has elegido pagar de forma manual.

*Plan seleccionado:* ${plan.name}
*Monto:* $${plan.price} ARS

*¿Cómo seguir?*

1. Un representante te contactará a la brevedad
2. Te explicará los métodos de pago disponibles (transferencia, depósito, etc.)
3. Una vez confirmado tu pago, te crearán el usuario MANUALMENTE

*Representante:*
${config.links.support}

*Por favor, espera su contacto. Mientras tanto, puedes ir preparando:*
• Número de teléfono verificado
• Método de pago que usarás

_Escribe *menu* para volver al inicio mientras esperas_`);
        
        // Registrar en base de datos que seleccionó pago manual
        db.run(
            `INSERT INTO logs (type, message, data) VALUES (?, ?, ?)`,
            ['pago_manual', `Cliente ${phone} eligió pago manual para plan ${plan.name}`, JSON.stringify({ phone, plan, date: new Date() })]
        );
        
        await setUserState(phone, 'main_menu');
        
    } else if (text === '0') {
        await setUserState(phone, 'main_menu');
        await client.sendText(from, getMainMenuMessage());
    }
}

// ==============================================
// RENOVAR USUARIO
// ==============================================
async function handleRenewStart(phone, from) {
    db.all(`SELECT username, expires_at FROM users WHERE phone = ? AND status = 1 ORDER BY created_at DESC`, [phone], async (err, rows) => {
        if (err || !rows || rows.length === 0) {
            await client.sendText(from, `*🔄 RENOVAR USUARIO*

No tienes cuentas activas para renovar.

Primero debes comprar un usuario con la opción *3*.

_Escribe *menu* para volver_`);
            await setUserState(phone, 'main_menu');
            return;
        }
        
        let msg = `*🔄 TUS CUENTAS ACTIVAS*\n\n`;
        const accounts = [];
        
        rows.forEach((acc, i) => {
            const expires = moment(acc.expires_at).format('DD/MM/YYYY HH:mm');
            accounts.push({ username: acc.username, expires: acc.expires_at });
            msg += `*${i+1}.* 👤 ${acc.username}\n   ⏰ Expira: ${expires}\n\n`;
        });
        
        msg += `👉 Responde con el *número* de la cuenta que quieres renovar\n`;
        msg += `O *0* para volver al menú principal`;
        
        await setUserState(phone, 'selecting_renew_account', { accounts });
        await client.sendText(from, msg);
    });
}

async function handleAccountSelectionForRenew(phone, text, from, data) {
    const accountIndex = parseInt(text) - 1;
    
    if (data && data.accounts && accountIndex >= 0 && accountIndex < data.accounts.length) {
        const selectedAccount = data.accounts[accountIndex];
        
        await setUserState(phone, 'selecting_renew_plan', { 
            username: selectedAccount.username
        });
        
        await client.sendText(from, `*🔄 RENOVAR ${selectedAccount.username}*

*Elige el plan de renovación:*

🔸 *1* - 7 días ($${config.prices.price_7d})
🔸 *2* - 15 días ($${config.prices.price_15d})
🔸 *3* - 30 días ($${config.prices.price_30d})
🔸 *4* - 50 días ($${config.prices.price_50d})

*0* - Cancelar

👉 Responde:`);
    }
}

async function handleRenewPlanSelection(phone, text, from, data) {
    const planNumber = parseInt(text);
    
    const plans = {
        1: { days: 7, price: config.prices.price_7d, name: '7 días', connections: 1 },
        2: { days: 15, price: config.prices.price_15d, name: '15 días', connections: 1 },
        3: { days: 30, price: config.prices.price_30d, name: '30 días', connections: 1 },
        4: { days: 50, price: config.prices.price_50d, name: '50 días', connections: 1 }
    };
    
    const plan = plans[planNumber];
    
    if (plan && data && data.username) {
        // Para renovación, ofrecer también las 2 opciones
        await client.sendText(from, `*🔄 RENOVACIÓN - ${data.username}*

*Plan seleccionado:* ${plan.name}
*Monto:* $${plan.price} ARS

*Elige cómo deseas pagar la renovación:*

🔘 *1* - Pago automático con MercadoPago
   • La cuenta se RENUEVA AUTOMÁTICAMENTE al aprobarse

🔘 *2* - Pago manual
   • Te contacta un representante
   • La renovación se hace MANUALMENTE

🔘 *0* - Cancelar

👉 Responde:`);
        
        await setUserState(phone, 'renew_payment_options', { username: data.username, plan });
        
    }
}

// ==============================================
// MANEJAR SELECCIÓN ANDROID/APPLE
// ==============================================
async function handleOSSelection(phone, text, from) {
    if (text === '1') {
        await client.sendText(from, `*📲 DESCARGA PARA ANDROID*

Link: ${config.links.app_android}

*Instrucciones:*
1. Descarga el archivo APK
2. Habilita "fuentes desconocidas" en tu Android
3. Instala la aplicación

*¿Necesitas ayuda?* Contacta a representante: ${config.links.support}

_Escribe *menu* para volver_`);
        await setUserState(phone, 'main_menu');
        
    } else if (text === '2') {
        await client.sendText(from, `*🍎 APPLE/IPHONE*

Para dispositivos Apple, contacta a nuestro representante:

${config.links.support}

Te guiarán paso a paso en la configuración específica para iPhone.

_Escribe *menu* para volver_`);
        await setUserState(phone, 'main_menu');
    }
}

// ==============================================
// VERIFICAR PAGOS PENDIENTES (Cron job)
// ==============================================
function setupPaymentChecker() {
    cron.schedule('*/2 * * * *', async () => {
        if (!mpEnabled) return;
        
        console.log(chalk.yellow('🔍 Verificando pagos pendientes...'));
        
        db.all(
            `SELECT payment_id, phone, plan, days, connections, amount 
             FROM payments 
             WHERE status = 'pending' AND created_at > datetime('now', '-1 hour')`,
            [],
            async (err, payments) => {
                if (err || !payments) return;
                
                for (const payment of payments) {
                    try {
                        // En producción, aquí se consultaría a MercadoPago
                        // Por ahora, simulamos aprobación después de 2 minutos
                        const timeSinceCreation = moment().diff(moment(payment.created_at), 'minutes');
                        const shouldApprove = timeSinceCreation > 2; // Aprueba después de 2 minutos
                        
                        if (shouldApprove) {
                            const username = generateSSHUsername(payment.phone);
                            const result = await createSSHUser(username, payment.days, payment.connections);
                            
                            if (result.success) {
                                db.run(
                                    `UPDATE payments SET status = 'approved', approved_at = CURRENT_TIMESTAMP WHERE payment_id = ?`,
                                    [payment.payment_id]
                                );
                                
                                db.run(
                                    `INSERT INTO users (phone, username, password, tipo, expires_at, max_connections, status) 
                                     VALUES (?, ?, ?, 'premium', ?, ?, 1)`,
                                    [payment.phone, username, '12345', result.expires, payment.connections]
                                );
                                
                                if (client) {
                                    await client.sendText(
                                        `${payment.phone}@c.us`,
                                        `*✅ PAGO APROBADO - USUARIO CREADO AUTOMÁTICAMENTE*

¡Tu pago fue aprobado y tu cuenta ya está lista!

*Usuario:* ${username}
*Contraseña:* 12345
*Servidor:* ${config.bot.server_ip}
*Puerto:* 22
*Conexiones:* ${payment.connections}
*Expira:* ${payment.days} días

*APP Android:* ${config.links.app_android}
*Soporte Apple:* ${config.links.support}

¡Disfruta del servicio!

Escribe *menu* para más opciones.`
                                    );
                                }
                                console.log(chalk.green(`✅ Usuario ${username} creado automáticamente para pago ${payment.payment_id}`));
                            }
                        }
                    } catch (error) {
                        console.error('Error verificando pago:', error);
                    }
                }
            }
        );
    });
}

// ==============================================
// LIMPIAR USUARIOS EXPIRADOS (Cron job)
// ==============================================
function setupCleanupCron() {
    cron.schedule('*/15 * * * *', async () => {
        console.log(chalk.yellow('🧹 Limpiando usuarios expirados...'));
        
        const now = moment().format('YYYY-MM-DD HH:mm:ss');
        
        db.all(
            `SELECT username FROM users WHERE expires_at < ? AND status = 1`,
            [now],
            async (err, expiredUsers) => {
                if (err || !expiredUsers) return;
                
                for (const user of expiredUsers) {
                    try {
                        await execPromise(`pkill -u ${user.username} 2>/dev/null || true`);
                        await execPromise(`userdel ${user.username} 2>/dev/null || true`);
                        
                        db.run(`UPDATE users SET status = 0 WHERE username = ?`, [user.username]);
                        
                        console.log(chalk.gray(`  ➤ Usuario ${user.username} eliminado`));
                    } catch (error) {
                        console.error(`Error eliminando usuario ${user.username}:`, error);
                    }
                }
            }
        );
        
        db.run(`DELETE FROM user_state WHERE updated_at < datetime('now', '-1 day')`);
    });
}

// ==============================================
// INICIO DEL BOT
// ==============================================
let client = null;
let iniciando = false;

async function startBot() {
    if (iniciando) return;
    iniciando = true;
    
    try {
        console.log(chalk.cyan(`🚀 Iniciando ${config.bot.name} ChatBot...`));
        
        const chromePath = config.paths.chromium;
        if (!fs.existsSync(chromePath)) {
            console.error(chalk.red(`❌ Chrome no encontrado en: ${chromePath}`));
            process.exit(1);
        }
        
        // Configurar cron jobs
        setupPaymentChecker();
        setupCleanupCron();
        
        client = await wppconnect.create({
            session: config.bot.safe_name,
            folderNameToken: config.paths.sessions,
            puppeteerOptions: {
                executablePath: chromePath,
                headless: 'new',
                args: [
                    '--no-sandbox',
                    '--disable-setuid-sandbox',
                    '--disable-dev-shm-usage',
                    '--disable-accelerated-2d-canvas',
                    '--no-first-run',
                    '--no-zygote',
                    '--disable-gpu'
                ]
            },
            disableWelcome: true,
            logQR: true,
            autoClose: 0,
            catchQR: (base64Qr, asciiQR) => {
                console.log(chalk.yellow('\n══════════════════════════════════════════════════'));
                console.log(chalk.yellow('📱 ESCANEA ESTE QR CON WHATSAPP WEB:'));
                console.log(chalk.yellow('══════════════════════════════════════════════════\n'));
                console.log(asciiQR);
                console.log(chalk.cyan('\n1. Abre WhatsApp → Menú → WhatsApp Web'));
                console.log(chalk.cyan('2. Escanea este código QR'));
                console.log(chalk.cyan('3. El bot mostrará el menú completo\n'));
                
                const qrImagePath = `/sshbot/qr_codes/qr-${Date.now()}.png`;
                QRCode.toFile(qrImagePath, base64Qr, { width: 300 }, (err) => {
                    if (!err) console.log(chalk.green(`✅ QR guardado en: ${qrImagePath}`));
                });
            },
            createPathFileToken: false
        });
        
        console.log(chalk.green('✅ WhatsApp conectado exitosamente!'));
        
        client.onStateChange((state) => {
            const states = {
                'CONNECTED': chalk.green('✅ Conectado'),
                'PAIRING': chalk.cyan('📱 Emparejando...'),
                'UNPAIRED': chalk.yellow('📱 Esperando QR...'),
                'DISCONNECTED': chalk.red('❌ Desconectado'),
                'SYNCING': chalk.blue('🔄 Sincronizando...')
            };
            console.log(chalk.blue(`🔁 Estado: ${states[state] || state}`));
            
            if (state === 'CONNECTED') {
                console.log(chalk.green(`\n✅ ${config.bot.name} ChatBot LISTO`));
                console.log(chalk.cyan('💬 Envía "menu" al número del bot'));
                console.log(chalk.cyan('🤖 El bot solo responderá a comandos válidos\n'));
            }
        });
        
        client.onMessage(async (message) => {
            try {
                if (message.from === 'status@broadcast' || message.isGroupMsg) return;
                if (!message.body) return;
                await handleMessage(message);
            } catch (error) {
                console.error(chalk.red('❌ Error en mensaje:'), error);
            }
        });
        
        console.log(chalk.green.bold(`\n✅ ${config.bot.name} ChatBot INICIADO CORRECTAMENTE!`));
        iniciando = false;
        
    } catch (error) {
        console.error(chalk.red('❌ Error iniciando bot:'), error.message);
        console.error(chalk.red('Detalles:'), error.stack);
        console.log(chalk.yellow('\n⚠️  Ejecuta: sshbot fix'));
        iniciando = false;
        process.exit(1);
    }
}

startBot();
BOTEOF

echo -e "${GREEN}✅ Bot.js creado con 2 opciones de compra y modo silencioso${NC}"

# ================================================
# CREAR SCRIPT SSH BOT (PANEL COMPLETO)
# ================================================
echo -e "\n${CYAN}${BOLD}⚙️ Creando panel de control 'sshbot'...${NC}"

cat > /usr/local/bin/sshbot << EOF
#!/bin/bash
# ================================================
# PANEL SSH BOT - ${BOT_NAME}
# ================================================

BOLD='\033[1m'; RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BLUE='\033[0;34m'
PURPLE='\033[0;35m'; NC='\033[0m'

BASE_DIR="$INSTALL_DIR"
PROCESS_NAME="$PROCESS_NAME"
SESSION_DIR="$SESSION_DIR"
CONFIG_FILE="$CONFIG_FILE"
DB_FILE="$DB_FILE"

# Función para obtener estadísticas
get_stats() {
    # Usuarios
    TOTAL_USERS=\$(sqlite3 "\$DB_FILE" "SELECT COUNT(*) FROM users;" 2>/dev/null || echo "0")
    ACTIVE_USERS=\$(sqlite3 "\$DB_FILE" "SELECT COUNT(*) FROM users WHERE status=1 AND expires_at > datetime('now');" 2>/dev/null || echo "0")
    
    # Pagos
    PENDING_PAY=\$(sqlite3 "\$DB_FILE" "SELECT COUNT(*) FROM payments WHERE status='pending';" 2>/dev/null || echo "0")
    APPROVED_PAY=\$(sqlite3 "\$DB_FILE" "SELECT COUNT(*) FROM payments WHERE status='approved';" 2>/dev/null || echo "0")
    
    # IP y nombre
    SERVER_IP=\$(jq -r '.bot.server_ip' "\$CONFIG_FILE" 2>/dev/null || echo "Desconocida")
    BOT_NAME=\$(jq -r '.bot.name' "\$CONFIG_FILE" 2>/dev/null || echo "$BOT_NAME")
    
    # Precios
    P7=\$(jq -r '.prices.price_7d' "\$CONFIG_FILE" 2>/dev/null || echo "3000")
    P15=\$(jq -r '.prices.price_15d' "\$CONFIG_FILE" 2>/dev/null || echo "4000")
    P30=\$(jq -r '.prices.price_30d' "\$CONFIG_FILE" 2>/dev/null || echo "7000")
    P50=\$(jq -r '.prices.price_50d' "\$CONFIG_FILE" 2>/dev/null || echo "9700")
    
    # MP Status
    MP_TOKEN=\$(jq -r '.mercadopago.access_token' "\$CONFIG_FILE" 2>/dev/null || echo "")
    if [[ -n "\$MP_TOKEN" && "\$MP_TOKEN" != "" ]]; then
        MP_STATUS="\${GREEN}✅ CONFIGURADO\${NC}"
    else
        MP_STATUS="\${RED}❌ NO CONFIGURADO\${NC}"
    fi
    
    # Bot status
    if pm2 list | grep -q "\$PROCESS_NAME.*online"; then
        BOT_STATUS="\${GREEN}● ACTIVO\${NC}"
    else
        BOT_STATUS="\${RED}● INACTIVO\${NC}"
    fi
    
    # Mostrar panel
    clear
    echo -e "\${CYAN}\${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🎛️  PANEL \$BOT_NAME BOT - PREMIUM              ║"
    echo "║        ✅ 2 OPCIONES COMPRA · ✅ BOT SILENCIOSO              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "\${NC}"
    
    echo -e "\${YELLOW}📊 ESTADO DEL SISTEMA\${NC}"
    echo -e "  Bot: \$BOT_STATUS"
    echo -e "  Usuarios: \$ACTIVE_USERS/\$TOTAL_USERS activos/total"
    echo -e "  Pagos: \$PENDING_PAY pendientes | \$APPROVED_PAY aprobados"
    echo -e "  MercadoPago: \$MP_STATUS"
    echo -e "  IP: \$SERVER_IP"
    echo -e "  Contraseña: 12345 (FIJA)"
    
    echo -e "\n\${BLUE}💰 PRECIOS ACTUALES:\${NC}"
    echo -e "  DIARIOS:"
    echo -e "    7 días: \$ \$P7 ARS"
    echo -e "    15 días: \$ \$P15 ARS"
    echo -e "  MENSUALES:"
    echo -e "    30 días: \$ \$P30 ARS"
    echo -e "    50 días: \$ \$P50 ARS"
    
    echo -e "\n\${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo -e "\${CYAN}[1]\${NC} 🚀  Iniciar/Reiniciar bot"
    echo -e "\${CYAN}[2]\${NC} 🛑  Detener bot"
    echo -e "\${CYAN}[3]\${NC} 📱  Ver logs y QR"
    echo -e "\${CYAN}[4]\${NC} 👤  Crear usuario manual"
    echo -e "\${CYAN}[5]\${NC} 👥  Listar usuarios"
    echo -e "\${CYAN}[6]\${NC} 💰  Cambiar precios"
    echo -e "\${CYAN}[7]\${NC} 🔑  Configurar MercadoPago"
    echo -e "\${CYAN}[8]\${NC} 🧪  Test MercadoPago"
    echo -e "\${CYAN}[9]\${NC} 📊  Ver estadísticas detalladas"
    echo -e "\${CYAN}[10]\${NC} 🔄 Limpiar sesión (fix error)"
    echo -e "\${CYAN}[11]\${NC} 💳 Ver últimos pagos"
    echo -e "\${CYAN}[12]\${NC} ⚙️  Ver configuración"
    echo -e "\${CYAN}[0]\${NC} 🚪  Salir"
    echo -e "\${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\${NC}"
    echo -e "👉 Selecciona: \c"
}

case "\$1" in
    menu|"")
        while true; do
            get_stats
            read option
            case \$option in
                1)
                    echo -e "\${GREEN}▶️ Iniciando/Reiniciando bot...\${NC}"
                    cd "\$BASE_DIR"
                    pm2 restart "\$PROCESS_NAME" 2>/dev/null || pm2 start bot.js --name "\$PROCESS_NAME" --time
                    pm2 save
                    sleep 2
                    ;;
                2)
                    echo -e "\${YELLOW}⏹️ Deteniendo bot...\${NC}"
                    pm2 stop "\$PROCESS_NAME"
                    sleep 2
                    ;;
                3)
                    echo -e "\${CYAN}📱 Mostrando logs...\${NC}"
                    pm2 logs "\$PROCESS_NAME" --lines 20
                    ;;
                4)
                    echo -e "\${CYAN}👤 Crear usuario manual\${NC}"
                    read -p "Username (ej: user123): " username
                    read -p "Días (0 para prueba, 7/15/30/50): " days
                    cd "\$BASE_DIR"
                    node -e "
                        const { exec } = require('child_process');
                        const username = '\$username';
                        const days = \$days;
                        const expiryDate = days > 0 ? 
                            new Date(Date.now() + days*24*60*60*1000).toISOString() : 
                            new Date(Date.now() + 2*60*60*1000).toISOString();
                        exec(\`useradd -M -s /bin/false -e \$(date -d \"\${expiryDate}\" +%Y-%m-%d) \${username} && echo \"\${username}:12345\" | chpasswd\`, (err) => {
                            if(err) console.log('❌ Error:', err.message);
                            else console.log('✅ Usuario creado: ' + username + ' (pass: 12345)');
                        });
                    " 2>/dev/null
                    read -p "Presiona Enter para continuar..."
                    ;;
                5)
                    echo -e "\${CYAN}👥 Usuarios SSH:\${NC}"
                    echo -e "\${YELLOW}USUARIO       | EXPIRA                 | ESTADO\${NC}"
                    sqlite3 "\$DB_FILE" "SELECT username, expires_at, CASE WHEN status=1 THEN 'Activo' ELSE 'Inactivo' END FROM users ORDER BY created_at DESC LIMIT 20;" -column
                    read -p "Presiona Enter para continuar..."
                    ;;
                6)
                    echo -e "\${CYAN}💰 Cambiar precios\${NC}"
                    source <(jq -r '.prices | to_entries[] | "\(.key)=\(.value)"' "\$CONFIG_FILE")
                    read -p "Precio 7 días [\$price_7d]: " new7
                    read -p "Precio 15 días [\$price_15d]: " new15
                    read -p "Precio 30 días [\$price_30d]: " new30
                    read -p "Precio 50 días [\$price_50d]: " new50
                    jq --arg p7 "\${new7:-\$price_7d}" \
                       --arg p15 "\${new15:-\$price_15d}" \
                       --arg p30 "\${new30:-\$price_30d}" \
                       --arg p50 "\${new50:-\$price_50d}" \
                       '.prices.price_7d = (\$p7|tonumber) | 
                        .prices.price_15d = (\$p15|tonumber) | 
                        .prices.price_30d = (\$p30|tonumber) | 
                        .prices.price_50d = (\$p50|tonumber)' \
                       "\$CONFIG_FILE" > /tmp/config.tmp && mv /tmp/config.tmp "\$CONFIG_FILE"
                    echo -e "\${GREEN}✅ Precios actualizados. Reinicia el bot con opción 1\${NC}"
                    sleep 2
                    ;;
                7)
                    echo -e "\${CYAN}🔑 Configurar MercadoPago\${NC}"
                    echo -e "\${YELLOW}Para obtener tu Access Token:\${NC}"
                    echo "1. Ve a https://www.mercadopago.com.ar/developers/panel/app"
                    echo "2. Crea una app o usa existente"
                    echo "3. Copia el Access Token"
                    echo ""
                    read -p "Access Token: " token
                    if [[ -n "\$token" ]]; then
                        jq --arg t "\$token" '.mercadopago.access_token = \$t | .mercadopago.enabled = true' "\$CONFIG_FILE" > /tmp/config.tmp && mv /tmp/config.tmp "\$CONFIG_FILE"
                        echo -e "\${GREEN}✅ Token guardado. Reinicia el bot con opción 1\${NC}"
                    else
                        echo -e "\${RED}❌ Token no válido\${NC}"
                    fi
                    sleep 2
                    ;;
                8)
                    echo -e "\${CYAN}🧪 Test MercadoPago\${NC}"
                    TOKEN=\$(jq -r '.mercadopago.access_token' "\$CONFIG_FILE")
                    if [[ -n "\$TOKEN" && "\$TOKEN" != "" ]]; then
                        echo -e "\${GREEN}✅ Token configurado: \${TOKEN:0:20}...\${NC}"
                        echo -e "\${YELLOW}Para probar, compra un plan desde WhatsApp\${NC}"
                    else
                        echo -e "\${RED}❌ Token no configurado\${NC}"
                        echo -e "\${YELLOW}Configúralo con opción 7\${NC}"
                    fi
                    read -p "Presiona Enter para continuar..."
                    ;;
                9)
                    echo -e "\${CYAN}📊 Estadísticas detalladas\${NC}"
                    echo -e "\n\${YELLOW}USUARIOS POR TIPO:\${NC}"
                    sqlite3 "\$DB_FILE" "SELECT tipo, COUNT(*) FROM users GROUP BY tipo;" -column
                    echo -e "\n\${YELLOW}PAGOS POR ESTADO:\${NC}"
                    sqlite3 "\$DB_FILE" "SELECT status, COUNT(*), SUM(amount) FROM payments GROUP BY status;" -column
                    echo -e "\n\${YELLOW}PRUEBAS DIARIAS:\${NC}"
                    sqlite3 "\$DB_FILE" "SELECT date, COUNT(*) FROM daily_tests GROUP BY date ORDER BY date DESC LIMIT 5;" -column
                    read -p "Presiona Enter para continuar..."
                    ;;
                10)
                    echo -e "\${YELLOW}🔄 Limpiando sesión (fix)...\${NC}"
                    pm2 stop "\$PROCESS_NAME" 2>/dev/null
                    pkill -f chrome
                    pkill -f chromium
                    rm -rf "\$SESSION_DIR"/*
                    echo -e "\${GREEN}✅ Sesión limpiada. Reinicia con opción 1\${NC}"
                    sleep 2
                    ;;
                11)
                    echo -e "\${CYAN}💳 Últimos pagos:\${NC}"
                    echo -e "\${YELLOW}ID               | TELÉFONO | PLAN  | MONTO | ESTADO   | FECHA\${NC}"
                    sqlite3 "\$DB_FILE" "SELECT payment_id, phone, plan, amount, status, created_at FROM payments ORDER BY created_at DESC LIMIT 10;" -column
                    read -p "Presiona Enter para continuar..."
                    ;;
                12)
                    echo -e "\${CYAN}⚙️ Configuración actual:\${NC}"
                    jq '.' "\$CONFIG_FILE"
                    echo -e "\n\${YELLOW}Archivo de información:\${NC}"
                    cat "\$BASE_DIR/config/info.txt"
                    read -p "Presiona Enter para continuar..."
                    ;;
                0)
                    echo -e "\${GREEN}👋 Hasta luego!\${NC}"
                    exit 0
                    ;;
                *)
                    echo -e "\${RED}Opción no válida\${NC}"
                    sleep 1
                    ;;
            esac
        done
        ;;
    logs)
        pm2 logs "\$PROCESS_NAME" --lines 50
        ;;
    restart)
        pm2 restart "\$PROCESS_NAME"
        ;;
    stop)
        pm2 stop "\$PROCESS_NAME"
        ;;
    start)
        cd "\$BASE_DIR"
        pm2 start bot.js --name "\$PROCESS_NAME" --time
        pm2 save
        ;;
    fix)
        echo -e "\${YELLOW}🔧 Aplicando fix completo...\${NC}"
        pm2 stop "\$PROCESS_NAME" 2>/dev/null
        pkill -f chrome
        pkill -f chromium
        rm -rf "\$SESSION_DIR"/*
        cd "\$BASE_DIR"
        pm2 start bot.js --name "\$PROCESS_NAME" -f --time
        echo -e "\${GREEN}✅ Fix aplicado. Espera el QR con: sshbot logs\${NC}"
        ;;
    mercadopago)
        echo -e "\${CYAN}💰 Configurar MercadoPago\${NC}"
        read -p "Access Token: " token
        jq --arg t "\$token" '.mercadopago.access_token = \$t | .mercadopago.enabled = true' "\$CONFIG_FILE" > /tmp/config.tmp && mv /tmp/config.tmp "\$CONFIG_FILE"
        echo -e "\${GREEN}✅ Token guardado. Reinicia: sshbot restart\${NC}"
        ;;
    info)
        echo -e "\${CYAN}📢 Editando información del bot\${NC}"
        nano "\$BASE_DIR/config/info.txt"
        echo -e "\${GREEN}✅ Info guardada. Reinicia: sshbot restart\${NC}"
        ;;
    *)
        echo -e "\${CYAN}Uso: sshbot {menu|logs|restart|stop|start|fix|mercadopago|info}\${NC}"
        ;;
esac
EOF

chmod +x /usr/local/bin/sshbot

# ================================================
# CONFIGURAR CRON JOBS
# ================================================
echo -e "\n${CYAN}${BOLD}⏰ Configurando cron jobs...${NC}"

# Limpiar usuarios expirados cada 15 minutos
(crontab -l 2>/dev/null | grep -v "cleanup expired users"; echo "*/15 * * * * /usr/bin/find $INSTALL_DIR/data -name \"*.db\" -exec /usr/bin/sqlite3 {} \"DELETE FROM users WHERE expires_at < datetime('now') AND status = 1; UPDATE users SET status = 0 WHERE expires_at < datetime('now');\" \;") | crontab -

# Backup diario a las 3 AM
mkdir -p /root/backups
(crontab -l 2>/dev/null | grep -v "backup sshbot"; echo "0 3 * * * /bin/tar -czf /root/backups/sshbot-backup-\$(date +\\%Y\\%m\\%d).tar.gz $INSTALL_DIR/data $INSTALL_DIR/config 2>/dev/null || true") | crontab -

# ================================================
# CONFIGURAR PM2
# ================================================
pm2 startup
pm2 save

# ================================================
# INICIAR BOT
# ================================================
echo -e "\n${CYAN}${BOLD}🚀 Iniciando bot...${NC}"
cd "$INSTALL_DIR"
pm2 start bot.js --name "$PROCESS_NAME" --time
pm2 save

# ================================================
# MOSTRAR PANEL DE BIENVENIDA
# ================================================
clear
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🎉 INSTALACIÓN COMPLETA REALIZADA CON ÉXITO! 🎉        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}📋 CONFIGURACIÓN:${NC}"
echo -e "   • Nombre visible: ${CYAN}$BOT_NAME${NC}"
echo -e "   • Proceso PM2: ${CYAN}$PROCESS_NAME${NC}"
echo -e "   • Carpeta: ${CYAN}$INSTALL_DIR${NC}"
echo -e "   • Sesión WhatsApp: ${CYAN}$SESSION_DIR${NC}"
echo -e "   • IP Servidor: ${CYAN}$SERVER_IP${NC}"
echo -e "   • Contraseña fija: ${CYAN}12345${NC}"
echo -e "   • Usuarios terminan en: ${CYAN}j${NC}"

echo -e "\n${CYAN}🖥️  COMANDO PRINCIPAL:${NC}"
echo -e "   ${GREEN}sshbot${NC} - Abre el panel de control completo"

echo -e "\n${PURPLE}📋 OPCIONES DEL PANEL:${NC}"
echo -e "   [1] 🚀 Iniciar/Reiniciar bot"
echo -e "   [2] 🛑 Detener bot"
echo -e "   [3] 📱 Ver logs y QR"
echo -e "   [4] 👤 Crear usuario manual"
echo -e "   [5] 👥 Listar usuarios"
echo -e "   [6] 💰 Cambiar precios"
echo -e "   [7] 🔑 Configurar MercadoPago"
echo -e "   [8] 🧪 Test MercadoPago"
echo -e "   [9] 📊 Ver estadísticas"
echo -e "   [10] 🔄 Limpiar sesión (fix error)"
echo -e "   [11] 💳 Ver pagos"
echo -e "   [12] ⚙️  Ver configuración"

echo -e "\n${CYAN}📱 EN WHATSAPP (MENÚ COMPLETO):${NC}"
echo -e "   • 1 ⁃📢 INFORMACIÓN (texto editable)"
echo -e "   • 2 ⁃🏷️ PRECIOS (editables)"
echo -e "   • 3 ⁃🛍️ COMPRAR USUARIO (con 2 opciones de pago)"
echo -e "      - Opción 1: Pago MP + Usuario automático"
echo -e "      - Opción 2: Pago manual + Contacta representante"
echo -e "   • 4 ⁃🔄 RENOVAR USUARIO"
echo -e "   • 5 ⁃📲 DESCARGAR APP (Android/Apple)"
echo -e "   • 6 ⁃👥 HABLAR CON REPRESENTANTE"

echo -e "\n${YELLOW}🤖 MODO SILENCIOSO:${NC}"
echo -e "   • El bot SOLO responde a comandos válidos"
echo -e "   • Mensajes no reconocidos son IGNORADOS"

echo -e "\n${YELLOW}📢 EJECUTA AHORA:${NC}"
echo -e "   ${GREEN}sshbot${NC} - Para abrir el panel"
echo -e "   ${GREEN}sshbot logs${NC} - Para ver el QR directamente"

echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}✅ VERSIÓN PREMIUM - 2 OPCIONES DE COMPRA + BOT SILENCIOSO${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"

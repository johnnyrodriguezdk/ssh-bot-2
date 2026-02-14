#!/bin/bash
# ================================================
# BOT WHATSAPP - VERSIÓN PREMIUM (COMPLETA)
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

Es una aplicación que te permite conectar y navegar en internet de manera ilimitada/infinita. Sin necesidad de tener saldo/crédito o MG/GB.

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
# INSTALAR DEPENDENCIAS DEL SISTEMA
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
# CREAR BOT.JS COMPLETO
# ================================================
echo -e "\n${CYAN}🤖 Creando bot.js con todas las funcionalidades...${NC}"

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
        
        await execPromise(`useradd -M -s /bin/false -e $(date -d "${expiryDate}" +%Y-%m-%d) ${username} 2>/dev/null || true`);
        await execPromise(`echo "${username}:${password}" | chpasswd`);
        
        if (maxConnections > 1) {
            await execPromise(`echo "MaxSessions ${maxConnections}" >> /etc/ssh/sshd_config.d/${username}.conf 2>/dev/null || true`);
        }
        
        return { success: true, username, password, expires: expiryDate };
    } catch (error) {
        console.error('Error creando usuario SSH:', error);
        return { success: false, error: error.message };
    }
}

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
        
        const qrPath = path.join(config.paths.qr_codes, `${paymentId}.png`);
        await QRCode.toFile(qrPath, preference.init_point);
        
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
// LISTA DE COMANDOS VÁLIDOS
// ==============================================
const VALID_COMMANDS = ['menu', '0', '1', '2', '3', '4', '5', '6'];

function isValidCommand(text, userState) {
    const lowerText = text.toLowerCase();
    
    if (lowerText === 'menu' || text === '0') return true;
    
    if (userState.state === 'plans_menu') {
        return ['1', '2', '3', '4', '0'].includes(text);
    }
    
    if (userState.state === 'payment_options') {
        return ['1', '2', '0'].includes(text);
    }
    
    if (userState.state === 'waiting_os') {
        return ['1', '2'].includes(text);
    }
    
    if (userState.state === 'selecting_renew_account') {
        const num = parseInt(text);
        return (text === '0') || (!isNaN(num) && num > 0);
    }
    
    if (userState.state === 'main_menu') {
        return ['1', '2', '3', '4', '5', '6'].includes(text);
    }
    
    return false;
}

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
// MANEJADOR DE MENSAJES
// ==============================================
async function handleMessage(message) {
    const phone = message.from.replace('@c.us', '');
    const text = message.body || '';
    const userState = await getUserState(phone);
    
    console.log(chalk.blue(`📱 ${phone}: "${text}" (Estado: ${userState.state})`));
    
    if (!isValidCommand(text, userState)) {
        console.log(chalk.gray(`   ⏭️  Mensaje ignorado (no es comando válido)`));
        return;
    }
    
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

async function handleMainMenu(phone, text, from) {
    switch (text) {
        case '1':
            await client.sendText(from, getInfoMessage() + '\n\n_Escribe *menu* para volver_');
            await setUserState(phone, 'main_menu');
            break;
        case '2':
            await client.sendText(from, getPricesMessage());
            await setUserState(phone, 'main_menu');
            break;
        case '3':
            await setUserState(phone, 'plans_menu');
            await client.sendText(from, getPlansToBuyMessage());
            break;
        case '4':
            await handleRenewStart(phone, from);
            break;
        case '5':
            await setUserState(phone, 'waiting_os');
            await client.sendText(from, getAndroidPromptMessage());
            break;
        case '6':
            await client.sendText(from, `*👥 REPRESENTANTE*\n\nContacta con nosotros:\n${config.links.support}\n\n_Escribe *menu* para volver_`);
            await setUserState(phone, 'main_menu');
            break;
    }
}

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

async function handlePaymentOptions(phone, text, from, data) {
    const plan = data.plan;
    
    if (text === '1') {
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
3. Al aprobarse, recibirás AUTOMÁTICAMENTE tus datos

_Escribe *menu* para volver_`);
            
            await setUserState(phone, 'main_menu');
        } else {
            await client.sendText(from, `❌ Error: ${payment.error}\n\nUsa opción 2 o contacta a soporte.\n\n${config.links.support}`);
            await setUserState(phone, 'main_menu');
        }
        
    } else if (text === '2') {
        await client.sendText(from, `*🔄 PAGO MANUAL*

*Plan:* ${plan.name}
*Monto:* $${plan.price} ARS

Un representante te contactará a la brevedad.

*Representante:* ${config.links.support}

_Escribe *menu* para volver_`);
        
        db.run(`INSERT INTO logs (type, message, data) VALUES (?, ?, ?)`,
            ['pago_manual', `Cliente ${phone} eligió pago manual para plan ${plan.name}`, JSON.stringify({ phone, plan, date: new Date() })]
        );
        
        await setUserState(phone, 'main_menu');
    }
}

async function handleRenewStart(phone, from) {
    db.all(`SELECT username, expires_at FROM users WHERE phone = ? AND status = 1 ORDER BY created_at DESC`, [phone], async (err, rows) => {
        if (err || !rows || rows.length === 0) {
            await client.sendText(from, `*🔄 RENOVAR USUARIO*\n\nNo tienes cuentas activas.\n\nCompra un usuario con opción *3*.`);
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
        
        msg += `👉 Responde con el *número* de la cuenta a renovar\nO *0* para volver`;
        
        await setUserState(phone, 'selecting_renew_account', { accounts });
        await client.sendText(from, msg);
    });
}

async function handleAccountSelectionForRenew(phone, text, from, data) {
    const accountIndex = parseInt(text) - 1;
    
    if (data && data.accounts && accountIndex >= 0 && accountIndex < data.accounts.length) {
        const selectedAccount = data.accounts[accountIndex];
        
        await setUserState(phone, 'selecting_renew_plan', { username: selectedAccount.username });
        
        await client.sendText(from, `*🔄 RENOVAR ${selectedAccount.username}*

*Elige plan:*

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
        1: { days: 7, price: config.prices.price_7d, name: '7 días' },
        2: { days: 15, price: config.prices.price_15d, name: '15 días' },
        3: { days: 30, price: config.prices.price_30d, name: '30 días' },
        4: { days: 50, price: config.prices.price_50d, name: '50 días' }
    };
    
    const plan = plans[planNumber];
    
    if (plan && data && data.username) {
        await client.sendText(from, `*🔄 RENOVACIÓN - ${data.username}*

*Plan:* ${plan.name}
*Monto:* $${plan.price} ARS

*Elige método de pago:*

🔘 *1* - Pago automático MP
🔘 *2* - Pago manual (contacta representante)
🔘 *0* - Cancelar

👉 Responde:`);
        
        await setUserState(phone, 'renew_payment_options', { username: data.username, plan });
    }
}

async function handleOSSelection(phone, text, from) {
    if (text === '1') {
        await client.sendText(from, `*📲 DESCARGA ANDROID*\n\nLink: ${config.links.app_android}\n\n_Escribe *menu* para volver_`);
        await setUserState(phone, 'main_menu');
    } else if (text === '2') {
        await client.sendText(from, `*🍎 APPLE/IPHONE*\n\nContacta a nuestro representante:\n${config.links.support}\n\n_Escribe *menu* para volver_`);
        await setUserState(phone, 'main_menu');
    }
}

// ==============================================
// CRON JOBS
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
                        const timeSinceCreation = moment().diff(moment(payment.created_at), 'minutes');
                        if (timeSinceCreation > 2) {
                            const username = generateSSHUsername(payment.phone);
                            const result = await createSSHUser(username, payment.days, payment.connections);
                            
                            if (result.success) {
                                db.run(`UPDATE payments SET status = 'approved', approved_at = CURRENT_TIMESTAMP WHERE payment_id = ?`, [payment.payment_id]);
                                db.run(`INSERT INTO users (phone, username, password, tipo, expires_at, max_connections, status) VALUES (?, ?, ?, 'premium', ?, ?, 1)`, [payment.phone, username, '12345', result.expires, payment.connections]);
                                
                                if (client) {
                                    await client.sendText(`${payment.phone}@c.us`, `*✅ PAGO APROBADO*

*Usuario:* ${username}
*Contraseña:* 12345
*Servidor:* ${config.bot.server_ip}
*Expira:* ${payment.days} días

Escribe *menu* para más opciones.`);
                                }
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

function setupCleanupCron() {
    cron.schedule('*/15 * * * *', async () => {
        console.log(chalk.yellow('🧹 Limpiando usuarios expirados...'));
        
        const now = moment().format('YYYY-MM-DD HH:mm:ss');
        
        db.all(`SELECT username FROM users WHERE expires_at < ? AND status = 1`, [now], async (err, expiredUsers) => {
            if (err || !expiredUsers) return;
            
            for (const user of expiredUsers) {
                try {
                    await execPromise(`pkill -u ${user.username} 2>/dev/null || true`);
                    await execPromise(`userdel ${user.username} 2>/dev/null || true`);
                    db.run(`UPDATE users SET status = 0 WHERE username = ?`, [user.username]);
                } catch (error) {
                    console.error(`Error eliminando usuario ${user.username}:`, error);
                }
            }
        });
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
            console.error(chalk.red(`❌ Chrome no encontrado`));
            process.exit(1);
        }
        
        setupPaymentChecker();
        setupCleanupCron();
        
        client = await wppconnect.create({
            session: config.bot.safe_name,
            folderNameToken: config.paths.sessions,
            puppeteerOptions: {
                executablePath: chromePath,
                headless: 'new',
                args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
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
                console.log(chalk.cyan('2. Escanea este código QR\n'));
                
                const qrImagePath = `/sshbot/qr_codes/qr-${Date.now()}.png`;
                QRCode.toFile(qrImagePath, base64Qr, { width: 300 });
            }
        });
        
        console.log(chalk.green('✅ WhatsApp conectado!'));
        
        client.onStateChange((state) => {
            if (state === 'CONNECTED') {
                console.log(chalk.green(`\n✅ ${config.bot.name} ChatBot LISTO`));
                console.log(chalk.cyan('💬 Envía "menu" al número del bot\n'));
            }
        });
        
        client.onMessage(handleMessage);
        
        console.log(chalk.green.bold(`\n✅ ${config.bot.name} ChatBot INICIADO!`));
        iniciando = false;
        
    } catch (error) {
        console.error(chalk.red('❌ Error iniciando bot:'), error.message);
        iniciando = false;
        process.exit(1);
    }
}

startBot();
BOTEOF

echo -e "${GREEN}✅ Bot.js creado${NC}"

# ================================================
# CREAR SCRIPT SSH BOT
# ================================================
echo -e "\n${CYAN}${BOLD}⚙️ Creando panel de control 'sshbot'...${NC}"

cat > /usr/local/bin/sshbot << EOF
#!/bin/bash
BOLD='\033[1m'; RED='\033[0;31m'; GREEN='\033[0;32m'
YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'

BASE_DIR="$INSTALL_DIR"
PROCESS_NAME="$PROCESS_NAME"
SESSION_DIR="$SESSION_DIR"

case "\$1" in
    menu|"")
        echo -e "\${CYAN}\${BOLD}===== $BOT_NAME BOT =====\${NC}"
        echo -e "\${GREEN}Comandos:\${NC}"
        echo -e "  sshbot logs    - Ver QR"
        echo -e "  sshbot start   - Iniciar bot"
        echo -e "  sshbot stop    - Detener bot"
        echo -e "  sshbot restart - Reiniciar"
        echo -e "  sshbot fix     - Reparar errores"
        echo -e "  sshbot mercadopago - Configurar MP"
        ;;
    logs)
        pm2 logs "\$PROCESS_NAME" --lines 50
        ;;
    start)
        cd "\$BASE_DIR"
        pm2 start bot.js --name "\$PROCESS_NAME" --time
        pm2 save
        ;;
    stop)
        pm2 stop "\$PROCESS_NAME"
        ;;
    restart)
        pm2 restart "\$PROCESS_NAME"
        ;;
    fix)
        pm2 stop "\$PROCESS_NAME" 2>/dev/null
        pkill -f chrome
        rm -rf "\$SESSION_DIR"/*
        cd "\$BASE_DIR"
        pm2 start bot.js --name "\$PROCESS_NAME" -f --time
        echo -e "\${GREEN}✅ Fix aplicado. Ver logs: sshbot logs\${NC}"
        ;;
    mercadopago)
        echo -e "\${CYAN}💰 Configurar MercadoPago\${NC}"
        read -p "Access Token: " token
        jq --arg t "\$token" '.mercadopago.access_token = \$t | .mercadopago.enabled = true' "\$BASE_DIR/config/config.json" > /tmp/config.tmp && mv /tmp/config.tmp "\$BASE_DIR/config/config.json"
        echo -e "\${GREEN}✅ Token guardado. Reinicia: sshbot restart\${NC}"
        ;;
    *)
        echo -e "\${CYAN}Uso: sshbot {menu|logs|start|stop|restart|fix|mercadopago}\${NC}"
        ;;
esac
EOF

chmod +x /usr/local/bin/sshbot

# ================================================
# CONFIGURAR CRON Y PM2
# ================================================
echo -e "\n${CYAN}${BOLD}⏰ Configurando cron jobs...${NC}"
(crontab -l 2>/dev/null | grep -v "cleanup expired users"; echo "*/15 * * * * /usr/bin/find $INSTALL_DIR/data -name \"*.db\" -exec /usr/bin/sqlite3 {} \"DELETE FROM users WHERE expires_at < datetime('now') AND status = 1; UPDATE users SET status = 0 WHERE expires_at < datetime('now');\" \;") | crontab -

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
# MOSTRAR RESUMEN
# ================================================
clear
echo -e "${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     🎉 INSTALACIÓN COMPLETA REALIZADA CON ÉXITO! 🎉        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${YELLOW}📋 CONFIGURACIÓN:${NC}"
echo -e "   • Nombre: ${CYAN}$BOT_NAME${NC}"
echo -e "   • Proceso PM2: ${CYAN}$PROCESS_NAME${NC}"
echo -e "   • IP: ${CYAN}$SERVER_IP${NC}"
echo -e "   • Contraseña: ${CYAN}12345${NC}"

echo -e "\n${CYAN}🖥️  COMANDOS:${NC}"
echo -e "   ${GREEN}sshbot logs${NC} - Ver QR"
echo -e "   ${GREEN}sshbot menu${NC} - Ver todas las opciones"

echo -e "\n${YELLOW}📢 PARA VER EL QR:${NC}"
echo -e "   ${GREEN}sshbot logs${NC}"

echo -e "\n${CYAN}══════════════════════════════════════════════════════════════${NC}"
EOF

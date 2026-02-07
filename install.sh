#!/bin/bash
# ================================================
# SSH BOT PRO - VERSIÓN COMPLETA CON RENOVACIÓN
# ✅ MercadoPago funcionando
# ✅ Renovación de usuarios
# ✅ Estados persistentes
# ================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

clear
echo -e "${CYAN}${BOLD}"
cat << "BANNER"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║            🤖 BOT MGVPN - CON RENOVACIÓN                 ║
║             ✅ COMPRA + RENOVACIÓN + MERCADOPAGO           ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
BANNER
echo -e "${NC}"

# Verificar root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}❌ Debes ejecutar como root${NC}"
    exit 1
fi

# Detectar IP
echo -e "${CYAN}🔍 Detectando IP...${NC}"
SERVER_IP=$(curl -4 -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}' || echo "127.0.0.1")
if [[ -z "$SERVER_IP" || "$SERVER_IP" == "127.0.0.1" ]]; then
    read -p "📝 Ingresa la IP del servidor: " SERVER_IP
fi

echo -e "${GREEN}✅ IP: ${CYAN}$SERVER_IP${NC}\n"

read -p "$(echo -e "${YELLOW}¿Instalar? (s/N): ${NC}")" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Ss]$ ]]; then
    exit 0
fi

# ================================================
# INSTALAR DEPENDENCIAS
# ================================================
echo -e "\n${CYAN}📦 Instalando dependencias...${NC}"

apt-get update -y
apt-get upgrade -y

# Node.js 18.x
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Chrome
apt-get install -y wget
wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -
echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get update -y
apt-get install -y google-chrome-stable

# Dependencias
apt-get install -y git curl wget sqlite3 jq python3 unzip

# PM2
npm install -g pm2

echo -e "${GREEN}✅ Dependencias instaladas${NC}"

# ================================================
# CREAR ESTRUCTURA
# ================================================
echo -e "\n${CYAN}📁 Creando estructura...${NC}"

INSTALL_DIR="/root/sshbot"
mkdir -p "$INSTALL_DIR"/{data,qr_codes}

# Configuración
cat > "$INSTALL_DIR/config.json" << EOF
{
    "bot": {
        "server_ip": "$SERVER_IP",
        "default_password": "mgvpn247"
    },
    "prices": {
        "test_hours": 1,
        "price_7d": 1500,
        "price_15d": 2500,
        "price_30d": 4000,
        "price_50d": 6000
    },
    "mercadopago": {
        "access_token": "",
        "enabled": false
    },
    "links": {
        "app_download": "https://www.mediafire.com/file/p8kgthxbsid7xws/MAJ/DNI_AND_FIL"
    }
}
EOF

# Base de datos COMPLETA
sqlite3 "$INSTALL_DIR/data/users.db" << 'SQL'
CREATE TABLE users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    phone TEXT,
    username TEXT UNIQUE,
    password TEXT DEFAULT 'mgvpn247',
    tipo TEXT,
    expires_at DATETIME,
    status INTEGER DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE payments (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_id TEXT UNIQUE,
    phone TEXT,
    username TEXT,
    plan TEXT,
    days INTEGER,
    amount REAL,
    status TEXT DEFAULT 'pending',
    payment_url TEXT,
    qr_code TEXT,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE user_states (
    phone TEXT PRIMARY KEY,
    state TEXT DEFAULT 'menu',
    data TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
SQL

echo -e "${GREEN}✅ Estructura creada${NC}"

# ================================================
# CREAR BOT COMPLETO
# ================================================
echo -e "\n${CYAN}🤖 Creando bot completo...${NC}"

cd "$INSTALL_DIR"

cat > package.json << 'PKGEOF'
{
    "name": "sshbot",
    "version": "1.0.0",
    "main": "bot.js",
    "dependencies": {
        "@wppconnect-team/wppconnect": "^1.25.0",
        "qrcode-terminal": "^0.12.0",
        "qrcode": "^1.5.3",
        "moment": "^2.29.4",
        "sqlite3": "^5.1.6",
        "axios": "^1.6.0"
    }
}
PKGEOF

npm install --silent

# BOT.JS COMPLETO CON RENOVACIÓN
cat > bot.js << 'BOTEOF'
const wppconnect = require('@wppconnect-team/wppconnect');
const qrcode = require('qrcode-terminal');
const QRCode = require('qrcode');
const moment = require('moment');
const sqlite3 = require('sqlite3').verbose();
const { exec } = require('child_process');
const util = require('util');
const fs = require('fs');
const axios = require('axios');

const execPromise = util.promisify(exec);
moment.locale('es');

const config = require('./config.json');
const db = new sqlite3.Database('./data/users.db');

console.log('🚀 SSH BOT PRO - INICIANDO');
console.log(`📱 IP: ${config.bot.server_ip}`);

// ========== FUNCIONES DE ESTADO ==========
function getState(phone) {
    return new Promise((resolve) => {
        db.get('SELECT state, data FROM user_states WHERE phone = ?', [phone], (err, row) => {
            if (err || !row) {
                resolve({ state: 'menu', data: null });
            } else {
                resolve({
                    state: row.state || 'menu',
                    data: row.data ? JSON.parse(row.data) : null
                });
            }
        });
    });
}

function setState(phone, state, data = null) {
    return new Promise((resolve) => {
        const dataStr = data ? JSON.stringify(data) : null;
        db.run(
            `INSERT OR REPLACE INTO user_states (phone, state, data, updated_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)`,
            [phone, state, dataStr],
            (err) => {
                if (err) console.error('Error estado:', err.message);
                resolve();
            }
        );
    });
}

// ========== FUNCIONES SSH ==========
async function createSSHUser(phone, username, days) {
    const password = config.bot.default_password;
    
    try {
        if (days === 0) {
            // Test
            const expire = moment().add(config.prices.test_hours, 'hours').format('YYYY-MM-DD HH:mm:ss');
            await execPromise(`useradd -m -s /bin/bash ${username} && echo "${username}:${password}" | chpasswd`);
            
            db.run(`INSERT INTO users (phone, username, password, tipo, expires_at) VALUES (?, ?, ?, 'test', ?)`,
                [phone, username, password, expire]);
            
            return { success: true, username, password };
        } else {
            // Premium
            const expire = moment().add(days, 'days').format('YYYY-MM-DD 23:59:59');
            await execPromise(`useradd -M -s /bin/false -e ${moment().add(days, 'days').format('YYYY-MM-DD')} ${username} && echo "${username}:${password}" | chpasswd`);
            
            db.run(`INSERT INTO users (phone, username, password, tipo, expires_at) VALUES (?, ?, ?, 'premium', ?)`,
                [phone, username, password, expire]);
            
            return { success: true, username, password };
        }
    } catch (error) {
        return { success: false, error: error.message };
    }
}

// ========== RENOVAR USUARIO ==========
async function renewSSHUser(username, days) {
    try {
        // Obtener fecha actual de expiración
        const user = await new Promise((resolve, reject) => {
            db.get('SELECT expires_at FROM users WHERE username = ?', [username], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
        
        let newExpire;
        if (user && user.expires_at) {
            // Extender desde la fecha actual
            const currentExpire = moment(user.expires_at);
            newExpire = currentExpire.add(days, 'days').format('YYYY-MM-DD 23:59:59');
        } else {
            // Si no hay fecha, extender desde hoy
            newExpire = moment().add(days, 'days').format('YYYY-MM-DD 23:59:59');
        }
        
        // Actualizar en sistema
        const systemExpire = moment(newExpire).format('YYYY-MM-DD');
        await execPromise(`usermod -e ${systemExpire} ${username}`);
        
        // Actualizar en BD
        db.run(`UPDATE users SET expires_at = ? WHERE username = ?`, [newExpire, username]);
        
        return { success: true, username, newExpire };
        
    } catch (error) {
        return { success: false, error: error.message };
    }
}

// ========== MERCADOPAGO ==========
async function createMercadoPagoPayment(phone, days, price, planName, username = null) {
    try {
        if (!config.mercadopago.access_token) {
            return { success: false, error: 'MercadoPago no configurado' };
        }
        
        const phoneClean = phone.replace('@c.us', '');
        const paymentId = `ssh-${phoneClean}-${Date.now()}`;
        
        console.log(`🔄 Creando pago MP: ${paymentId}`);
        
        const preferenceData = {
            items: [{
                title: username ? `RENOVACIÓN SSH ${planName}` : `SSH ${planName}`,
                description: username ? 
                    `Renovación de ${username} por ${days} días` : 
                    `Acceso SSH por ${days} días`,
                quantity: 1,
                currency_id: "ARS",
                unit_price: price
            }],
            external_reference: paymentId,
            expires: true,
            expiration_date_from: moment().toISOString(),
            expiration_date_to: moment().add(24, 'hours').toISOString(),
            back_urls: {
                success: "https://www.mercadopago.com.ar",
                failure: "https://www.mercadopago.com.ar",
                pending: "https://www.mercadopago.com.ar"
            },
            auto_return: "approved"
        };
        
        const response = await axios.post(
            'https://api.mercadopago.com/checkout/preferences',
            preferenceData,
            {
                headers: {
                    'Authorization': `Bearer ${config.mercadopago.access_token}`,
                    'Content-Type': 'application/json'
                }
            }
        );
        
        if (response.data && response.data.init_point) {
            const paymentUrl = response.data.init_point;
            const qrPath = `./qr_codes/${paymentId}.png`;
            
            await QRCode.toFile(qrPath, paymentUrl, { width: 400 });
            
            // Guardar en BD
            db.run(
                `INSERT INTO payments (payment_id, phone, username, plan, days, amount, payment_url, qr_code) VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
                [paymentId, phone, username, planName, days, price, paymentUrl, qrPath]
            );
            
            console.log(`✅ Pago creado: ${paymentId}`);
            
            return { 
                success: true, 
                paymentUrl, 
                qrPath,
                amount: price,
                paymentId
            };
        }
        
        return { success: false, error: 'Error en respuesta de MP' };
        
    } catch (error) {
        console.error('❌ Error MP:', error.message);
        return { success: false, error: error.message };
    }
}

// ========== VERIFICAR PAGOS ==========
async function checkPendingPayments(client) {
    if (!config.mercadopago.access_token) return;
    
    try {
        const payments = await new Promise((resolve, reject) => {
            db.all('SELECT * FROM payments WHERE status = "pending"', (err, rows) => {
                if (err) reject(err);
                else resolve(rows || []);
            });
        });
        
        for (const payment of payments) {
            try {
                const response = await axios.get(
                    `https://api.mercadopago.com/v1/payments/search?external_reference=${payment.payment_id}`,
                    {
                        headers: {
                            'Authorization': `Bearer ${config.mercadopago.access_token}`
                        }
                    }
                );
                
                if (response.data.results && response.data.results[0]?.status === 'approved') {
                    console.log(`✅ Pago aprobado: ${payment.payment_id}`);
                    
                    // Actualizar estado del pago
                    db.run('UPDATE payments SET status = "approved" WHERE payment_id = ?', [payment.payment_id]);
                    
                    if (payment.username) {
                        // ES RENOVACIÓN
                        const result = await renewSSHUser(payment.username, payment.days);
                        
                        if (result.success) {
                            const msg = `✅ *RENOVACIÓN CONFIRMADA*

👤 Usuario: ${payment.username}
⏰ Nueva expiración: ${moment(result.newExpire).format('DD/MM/YYYY')}
🔑 Contraseña: ${config.bot.default_password}

¡Tu cuenta ha sido renovada exitosamente!`;
                            
                            await client.sendText(payment.phone, msg);
                        } else {
                            await client.sendText(payment.phone, `❌ Error en renovación: ${result.error}`);
                        }
                        
                    } else {
                        // ES COMPRA NUEVA
                        const username = 'user' + Math.floor(1000 + Math.random() * 9000);
                        const result = await createSSHUser(payment.phone, username, payment.days);
                        
                        if (result.success) {
                            const msg = `✅ *PAGO CONFIRMADO*

👤 Usuario: ${username}
🔑 Contraseña: ${config.bot.default_password}
⏰ Expira: ${moment().add(payment.days, 'days').format('DD/MM/YYYY')}
📱 App: ${config.links.app_download}

¡Disfruta tu servicio premium!`;
                            
                            await client.sendText(payment.phone, msg);
                        } else {
                            await client.sendText(payment.phone, `❌ Error: ${result.error}`);
                        }
                    }
                }
            } catch (error) {
                console.error(`Error verificando pago ${payment.payment_id}:`, error.message);
            }
        }
    } catch (error) {
        console.error('Error en checkPendingPayments:', error);
    }
}

// ========== INICIAR BOT ==========
async function startBot() {
    try {
        console.log('🔗 Conectando WhatsApp...');
        
        const client = await wppconnect.create({
            session: 'sshbot',
            headless: true,
            useChrome: true,
            logQR: true,
            browserArgs: ['--no-sandbox'],
            puppeteerOptions: {
                executablePath: '/usr/bin/google-chrome',
                headless: 'new'
            }
        });
        
        console.log('✅ WhatsApp conectado!');
        
        // Manejar mensajes
        client.onMessage(async (message) => {
            try {
                const text = message.body.toLowerCase().trim();
                const from = message.from;
                
                if (from.includes('@g.us')) return;
                
                console.log(`📩 ${from}: ${text}`);
                
                const userState = await getState(from);
                
                // ===== MENÚ PRINCIPAL =====
                if (['menu', 'hola', 'start', 'hi', '0'].includes(text)) {
                    await setState(from, 'menu');
                    
                    const menu = `🚀 * BOT MGVPN*

1️⃣ *PRUEBA GRATIS* (1 hora)
2️⃣ *COMPRAR PLAN* 
3️⃣ *RENOVAR USUARIO*
4️⃣ *DESCARGAR APP*
5️⃣ *SOPORTE*

Escribe el número:`;
                    
                    await client.sendText(from, menu);
                    return;
                }
                
                // ===== OPCIÓN 1: PRUEBA =====
                if (text === '1' && userState.state === 'menu') {
                    await client.sendText(from, '⏳ Creando prueba...');
                    
                    const username = 'test' + Math.floor(1000 + Math.random() * 9000);
                    const result = await createSSHUser(from, username, 0);
                    
                    if (result.success) {
                        const msg = `✅ *PRUEBA CREADA*

👤 Usuario: ${username}
🔑 Contraseña: ${config.bot.default_password}
⏰ Expira: 1 hora
📱 App: ${config.links.app_download}

Instrucciones:
1. Entra Al Enlace Descarga el APK 
2. Abrir - Click "Más detalles"
3. Click "Instalar de todas formas"
4. Configura con tu usuario y contraseña `;
                        
                        await client.sendText(from, msg);
                    } else {
                        await client.sendText(from, `❌ Error: ${result.error}`);
                    }
                    return;
                }
                
                // ===== OPCIÓN 2: COMPRAR =====
                if (text === '2' && userState.state === 'menu') {
                    await setState(from, 'buying');
                    
                    const menu = `🌐 *SELECCIONAR TIPO DE PLAN*

1️⃣ PLANES DIARIOS
2️⃣ PLANES MENSUALES

0️⃣ Volver`;
                    
                    await client.sendText(from, menu);
                    return;
                }
                
                // ===== OPCIÓN 3: RENOVAR =====
                if (text === '3' && userState.state === 'menu') {
                    // Buscar usuarios del cliente
                    const users = await new Promise((resolve, reject) => {
                        db.all('SELECT username, expires_at FROM users WHERE phone = ? AND status = 1 ORDER BY expires_at DESC', 
                            [from], (err, rows) => {
                            if (err) reject(err);
                            else resolve(rows || []);
                        });
                    });
                    
                    if (users.length === 0) {
                        await client.sendText(from, `❌ *NO TIENES USUARIOS ACTIVOS*

Para crear uno nuevo, selecciona:
2️⃣ COMPRAR PLAN`);
                        return;
                    }
                    
                    let userList = `🔄 *TUS USUARIOS ACTIVOS*\n\n`;
                    users.forEach((user, index) => {
                        const expireDate = moment(user.expires_at).format('DD/MM/YYYY');
                        userList += `${index + 1}. 👤 *${user.username}* - ⏰ Expira: ${expireDate}\n`;
                    });
                    
                    userList += `\nPara renovar, escribe:\n*renovar [usuario]*\n\nEjemplo: renovar ${users[0].username}`;
                    
                    await client.sendText(from, userList);
                    return;
                }
                
                // ===== COMANDO RENOVAR =====
                if (text.startsWith('renovar ') && userState.state === 'menu') {
                    const username = text.replace('renovar ', '').trim();
                    
                    // Verificar que el usuario pertenece al cliente
                    const user = await new Promise((resolve, reject) => {
                        db.get('SELECT username FROM users WHERE username = ? AND phone = ? AND status = 1', 
                            [username, from], (err, row) => {
                            if (err) reject(err);
                            else resolve(row);
                        });
                    });
                    
                    if (!user) {
                        await client.sendText(from, `❌ *USUARIO NO ENCONTRADO*

Verifica que el nombre de usuario sea correcto y que te pertenezca.

Para ver tus usuarios activos, escribe *menu* y selecciona *3*`);
                        return;
                    }
                    
                    await setState(from, 'renewing', { username });
                    
                    const menu = `🔄 *RENOVAR: ${username}*

Selecciona el tipo de plan:

1️⃣ PLANES DIARIOS
2️⃣ PLANES MENSUALES

0️⃣ volver`;
                    
                    await client.sendText(from, menu);
                    return;
                }
                
                // ===== RENOVACIÓN - SELECCIONAR TIPO =====
                if (userState.state === 'renewing') {
                    if (text === '1') {
                        await setState(from, 'renewing_daily', { username: userState.data.username });
                        
                        const plans = `🌐 *PLANES DIARIOS PARA RENOVACIÓN*

1️⃣ 7 DÍAS - $${config.prices.price_7d}
2️⃣ 15 DÍAS - $${config.prices.price_15d}

0️⃣ Volver`;
                        
                        await client.sendText(from, plans);
                        return;
                    }
                    
                    if (text === '2') {
                        await setState(from, 'renewing_monthly', { username: userState.data.username });
                        
                        const plans = `🌐 *PLANES MENSUALES PARA RENOVACIÓN*

1️⃣ 30 DÍAS - $${config.prices.price_30d}
2️⃣ 50 DÍAS - $${config.prices.price_50d}

0️⃣ Volver`;
                        
                        await client.sendText(from, plans);
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'menu');
                        await client.sendText(from, 'Renovación cancelada.');
                        return;
                    }
                }
                
                // ===== RENOVACIÓN - PLAN DIARIO =====
                if (userState.state === 'renewing_daily') {
                    const plans = {
                        '1': { days: 7, price: config.prices.price_7d, name: '7 DÍAS' },
                        '2': { days: 15, price: config.prices.price_15d, name: '15 DÍAS' }
                    };
                    
                    if (plans[text]) {
                        const plan = plans[text];
                        const username = userState.data.username;
                        
                        await setState(from, 'processing_renewal', { username, plan });
                        
                        if (!config.mercadopago.access_token) {
                            await client.sendText(from, `⚠️ *MERCADOPAGO NO CONFIGURADO*

Contacta al administrador para configurar.`);
                            await setState(from, 'menu');
                            return;
                        }
                        
                        await client.sendText(from, `⏳ Generando pago de renovación para ${username}...`);
                        
                        const payment = await createMercadoPagoPayment(
                            from, 
                            plan.days, 
                            plan.price, 
                            plan.name,
                            username
                        );
                        
                        if (payment.success) {
                            const msg = `💳 *RENOVACIÓN ${plan.name}*

👤 Usuario: ${username}
💰 Monto: $${payment.amount}
⏰ Días adicionales: ${plan.days}

✅ *Enlace de pago:*
${payment.paymentUrl}

📱 *Escanea el QR que se enviará a continuación*`;
                            
                            await client.sendText(from, msg);
                            
                            if (fs.existsSync(payment.qrPath)) {
                                try {
                                    await client.sendImage(
                                        from,
                                        payment.qrPath,
                                        'qr-pago.jpg',
                                        `Renovación: ${username}\n${plan.name} - $${payment.amount}`
                                    );
                                } catch (qrError) {}
                            }
                            
                        } else {
                            await client.sendText(from, `❌ *ERROR AL GENERAR PAGO*

${payment.error}`);
                        }
                        
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'renewing', { username: userState.data.username });
                        await client.sendText(from, 'Volviendo...');
                        return;
                    }
                }
                
                // ===== RENOVACIÓN - PLAN MENSUAL =====
                if (userState.state === 'renewing_monthly') {
                    const plans = {
                        '1': { days: 30, price: config.prices.price_30d, name: '30 DÍAS' },
                        '2': { days: 50, price: config.prices.price_50d, name: '50 DÍAS' }
                    };
                    
                    if (plans[text]) {
                        const plan = plans[text];
                        const username = userState.data.username;
                        
                        await setState(from, 'processing_renewal', { username, plan });
                        
                        if (!config.mercadopago.access_token) {
                            await client.sendText(from, `⚠️ *MERCADOPAGO NO CONFIGURADO*

Contacta al administrador para configurar.`);
                            await setState(from, 'menu');
                            return;
                        }
                        
                        await client.sendText(from, `⏳ Generando pago de renovación para ${username}...`);
                        
                        const payment = await createMercadoPagoPayment(
                            from, 
                            plan.days, 
                            plan.price, 
                            plan.name,
                            username
                        );
                        
                        if (payment.success) {
                            const msg = `💳 *RENOVACIÓN ${plan.name}*

👤 Usuario: ${username}
💰 Monto: $${payment.amount}
⏰ Días adicionales: ${plan.days}

✅ *Enlace de pago:*
${payment.paymentUrl}

📱 *Escanea el QR que se enviará a continuación*`;
                            
                            await client.sendText(from, msg);
                            
                            if (fs.existsSync(payment.qrPath)) {
                                try {
                                    await client.sendImage(
                                        from,
                                        payment.qrPath,
                                        'qr-pago.jpg',
                                        `Renovación: ${username}\n${plan.name} - $${payment.amount}`
                                    );
                                } catch (qrError) {}
                            }
                            
                        } else {
                            await client.sendText(from, `❌ *ERROR AL GENERAR PAGO*

${payment.error}`);
                        }
                        
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'renewing', { username: userState.data.username });
                        await client.sendText(from, 'Volviendo...');
                        return;
                    }
                }
                
                // ===== COMPRA - SELECCIONAR TIPO =====
                if (userState.state === 'buying') {
                    if (text === '1') {
                        await setState(from, 'selecting_daily');
                        
                        const plans = `🌐 *PLANES DIARIOS*

1️⃣ 7 DÍAS - $${config.prices.price_7d}
2️⃣ 15 DÍAS - $${config.prices.price_15d}

0️⃣ Volver`;
                        
                        await client.sendText(from, plans);
                        return;
                    }
                    
                    if (text === '2') {
                        await setState(from, 'selecting_monthly');
                        
                        const plans = `🌐 *PLANES MENSUALES*

1️⃣ 30 DÍAS - $${config.prices.price_30d}
2️⃣ 50 DÍAS - $${config.prices.price_50d}

0️⃣ Volver`;
                        
                        await client.sendText(from, plans);
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'menu');
                        await client.sendText(from, 'Volviendo al menú...');
                        return;
                    }
                }
                
                // ===== COMPRA - PLAN DIARIO =====
                if (userState.state === 'selecting_daily') {
                    const plans = {
                        '1': { days: 7, price: config.prices.price_7d, name: '7 DÍAS' },
                        '2': { days: 15, price: config.prices.price_15d, name: '15 DÍAS' }
                    };
                    
                    if (plans[text]) {
                        const plan = plans[text];
                        
                        if (!config.mercadopago.access_token) {
                            await client.sendText(from, `⚠️ *MERCADOPAGO NO CONFIGURADO*

Contacta al administrador para configurar.`);
                            await setState(from, 'menu');
                            return;
                        }
                        
                        await client.sendText(from, `⏳ Generando pago para ${plan.name}...`);
                        
                        const payment = await createMercadoPagoPayment(
                            from, 
                            plan.days, 
                            plan.price, 
                            plan.name
                        );
                        
                        if (payment.success) {
                            const msg = `💳 *PAGO ${plan.name}*

💰 Monto: $${payment.amount}
⏰ Duración: ${plan.days} días

✅ *Enlace de pago:*
${payment.paymentUrl}

📱 *Escanea el QR que se enviará a continuación*`;
                            
                            await client.sendText(from, msg);
                            
                            if (fs.existsSync(payment.qrPath)) {
                                try {
                                    await client.sendImage(
                                        from,
                                        payment.qrPath,
                                        'qr-pago.jpg',
                                        `${plan.name} - $${payment.amount}`
                                    );
                                } catch (qrError) {}
                            }
                            
                        } else {
                            await client.sendText(from, `❌ *ERROR AL GENERAR PAGO*

${payment.error}`);
                        }
                        
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'buying');
                        await client.sendText(from, 'Volviendo...');
                        return;
                    }
                }
                
                // ===== COMPRA - PLAN MENSUAL =====
                if (userState.state === 'selecting_monthly') {
                    const plans = {
                        '1': { days: 30, price: config.prices.price_30d, name: '30 DÍAS' },
                        '2': { days: 50, price: config.prices.price_50d, name: '50 DÍAS' }
                    };
                    
                    if (plans[text]) {
                        const plan = plans[text];
                        
                        if (!config.mercadopago.access_token) {
                            await client.sendText(from, `⚠️ *MERCADOPAGO NO CONFIGURADO*

Contacta al administrador para configurar.`);
                            await setState(from, 'menu');
                            return;
                        }
                        
                        await client.sendText(from, `⏳ Generando pago para ${plan.name}...`);
                        
                        const payment = await createMercadoPagoPayment(
                            from, 
                            plan.days, 
                            plan.price, 
                            plan.name
                        );
                        
                        if (payment.success) {
                            const msg = `💳 *PAGO ${plan.name}*

💰 Monto: $${payment.amount}
⏰ Duración: ${plan.days} días

✅ *Enlace de pago:*
${payment.paymentUrl}

📱 *Escanea el QR que se enviará a continuación*`;
                            
                            await client.sendText(from, msg);
                            
                            if (fs.existsSync(payment.qrPath)) {
                                try {
                                    await client.sendImage(
                                        from,
                                        payment.qrPath,
                                        'qr-pago.jpg',
                                        `${plan.name} - $${payment.amount}`
                                    );
                                } catch (qrError) {}
                            }
                            
                        } else {
                            await client.sendText(from, `❌ *ERROR AL GENERAR PAGO*

${payment.error}`);
                        }
                        
                        return;
                    }
                    
                    if (text === '0') {
                        await setState(from, 'buying');
                        await client.sendText(from, 'Volviendo...');
                        return;
                    }
                }
                
                // ===== OPCIÓN 4: APP =====
                if (text === '4' && userState.state === 'menu') {
                    const msg = `📱 *DESCARGAR APP*

🔗 ${config.links.app_download}

Instrucciones:
1. Descarga el APK
2. Click "Más detalles"
3. Click "Instalar de todas formas"
4. Configura con tus credenciales`;
                    
                    await client.sendText(from, msg);
                    return;
                }
                
                // ===== OPCIÓN 5: SOPORTE =====
                if (text === '5' && userState.state === 'menu') {
                    await client.sendText(from, `📞 *SOPORTE*

Para ayuda contacta:
https://wa.me/543435071016`);
                    return;
                }
                
                // ===== MENSAJE NO RECONOCIDO =====
                if (userState.state === 'menu') {
                    await client.sendText(from, '⚠️ Escribe *menu* para ver opciones');
                } else {
                    await client.sendText(from, '⚠️ Opción no válida. Escribe *0* para volver');
                }
                
            } catch (error) {
                console.error('❌ Error:', error);
            }
        });
        
        // Verificar pagos cada 2 minutos
        setInterval(() => {
            checkPendingPayments(client);
        }, 120000);
        
        // Limpiar estados antiguos
        setInterval(() => {
            const hourAgo = moment().subtract(1, 'hour').format('YYYY-MM-DD HH:mm:ss');
            db.run("DELETE FROM user_states WHERE updated_at < ?", [hourAgo]);
        }, 3600000);
        
        console.log('✅ Bot listo!');
        
    } catch (error) {
        console.error('❌ Error:', error);
        setTimeout(startBot, 5000);
    }
}

// Iniciar
startBot();

process.on('SIGINT', () => {
    console.log('🛑 Cerrando...');
    process.exit();
});
BOTEOF

echo -e "${GREEN}✅ Bot creado con renovación${NC}"

# ================================================
# CREAR PANEL DE CONTROL
# ================================================
echo -e "\n${CYAN}🎛️  Creando panel de control...${NC}"

cat > /usr/local/bin/sshbot << 'PANELEOF'
#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

INSTALL_DIR="/root/sshbot"
CONFIG="$INSTALL_DIR/config.json"
DB="$INSTALL_DIR/data/users.db"

get_val() {
    jq -r "$1" "$CONFIG" 2>/dev/null || echo ""
}

set_val() {
    local temp=$(mktemp)
    jq "$1 = $2" "$CONFIG" > "$temp" && mv "$temp" "$CONFIG"
}

show_header() {
    clear
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                🎛️  CONTROL SSH BOT                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}\n"
}

while true; do
    show_header
    
    # Estado del bot
    if pm2 status | grep -q "online.*sshbot"; then
        STATUS="${GREEN}● ACTIVO${NC}"
    else
        STATUS="${RED}● DETENIDO${NC}"
    fi
    
    # Estado MP
    MP_TOKEN=$(get_val '.mercadopago.access_token')
    if [[ -n "$MP_TOKEN" && "$MP_TOKEN" != "null" ]]; then
        MP_STATUS="${GREEN}✅ CONFIGURADO${NC}"
    else
        MP_STATUS="${RED}❌ NO CONFIGURADO${NC}"
    fi
    
    echo -e "${YELLOW}📊 ESTADO:${NC} $STATUS"
    echo -e "${YELLOW}💰 MERCADOPAGO:${NC} $MP_STATUS"
    echo -e "${YELLOW}📱 IP:${NC} $(get_val '.bot.server_ip')"
    echo -e ""
    
    echo -e "${CYAN}[1]${NC} 🚀 Iniciar/Reiniciar bot"
    echo -e "${CYAN}[2]${NC} 🛑 Detener bot"
    echo -e "${CYAN}[3]${NC} 📱 Ver logs y QR"
    echo -e "${CYAN}[4]${NC} 👤 Crear usuario"
    echo -e "${CYAN}[5]${NC} 👥 Ver usuarios"
    echo -e "${CYAN}[6]${NC} 🔑 Configurar MP"
    echo -e "${CYAN}[7]${NC} 💰 Cambiar precios"
    echo -e "${CYAN}[8]${NC} 🔄 Renovar usuario"
    echo -e "${CYAN}[9]${NC} 🧹 Limpiar sesión"
    echo -e "${CYAN}[0]${NC} 🚪 Salir"
    echo -e ""
    
    read -p "👉 Opción: " OPT
    
    case $OPT in
        1)
            echo -e "\n${YELLOW}🔄 Iniciando...${NC}"
            cd "$INSTALL_DIR"
            pm2 start bot.js --name sshbot 2>/dev/null || pm2 restart sshbot
            pm2 save 2>/dev/null
            echo -e "${GREEN}✅ Bot iniciado${NC}"
            sleep 2
            ;;
        2)
            echo -e "\n${YELLOW}🛑 Deteniendo...${NC}"
            pm2 stop sshbot 2>/dev/null
            echo -e "${GREEN}✅ Bot detenido${NC}"
            sleep 2
            ;;
        3)
            echo -e "\n${YELLOW}📱 Mostrando logs...${NC}"
            echo -e "${CYAN}Presiona Ctrl+C para salir${NC}\n"
            pm2 logs sshbot --lines 50
            ;;
        4)
            echo -e "\n${CYAN}👤 CREAR USUARIO${NC}"
            read -p "Teléfono: " PHONE
            read -p "Tipo (test/premium): " TIPO
            read -p "Días (0=test): " DAYS
            
            if [[ "$TIPO" == "test" ]]; then
                USERNAME="test$(shuf -i 1000-9999 -n 1)"
                DAYS=0
                EXPIRE=$(date -d "+1 hour" +"%Y-%m-%d %H:%M:%S")
                useradd -m -s /bin/bash "$USERNAME" && echo "$USERNAME:mgvpn247" | chpasswd
            else
                USERNAME="user$(shuf -i 1000-9999 -n 1)"
                EXPIRE=$(date -d "+$DAYS days" +"%Y-%m-%d 23:59:59")
                useradd -M -s /bin/false -e "$(date -d "+$DAYS days" +%Y-%m-%d)" "$USERNAME" && echo "$USERNAME:mgvpn247" | chpasswd
            fi
            
            sqlite3 "$DB" "INSERT INTO users (phone, username, password, tipo, expires_at) VALUES ('$PHONE', '$USERNAME', 'mgvpn247', '$TIPO', '$EXPIRE')"
            
            echo -e "\n${GREEN}✅ CREADO${NC}"
            echo -e "👤 $USERNAME"
            echo -e "🔑 mgvpn247"
            echo -e "⏰ $EXPIRE"
            read -p "Enter..."
            ;;
        5)
            echo -e "\n${CYAN}👥 USUARIOS${NC}"
            sqlite3 -column -header "$DB" "SELECT username, phone, tipo, expires_at FROM users WHERE status=1"
            echo ""
            read -p "Enter..."
            ;;
        6)
            echo -e "\n${CYAN}🔑 CONFIGURAR MERCADOPAGO${NC}"
            echo -e "Para obtener el token:"
            echo -e "1. https://www.mercadopago.com.ar/developers"
            echo -e "2. Inicia sesión"
            echo -e "3. Ve a 'Tus credenciales'"
            echo -e "4. Copia 'Access Token PRODUCCIÓN'"
            echo -e ""
            
            CURRENT=$(get_val '.mercadopago.access_token')
            if [[ -n "$CURRENT" ]]; then
                echo -e "Token actual: ${CURRENT:0:20}..."
            fi
            
            read -p "Nuevo token: " TOKEN
            if [[ -n "$TOKEN" ]]; then
                set_val '.mercadopago.access_token' "\"$TOKEN\""
                set_val '.mercadopago.enabled' "true"
                echo -e "${GREEN}✅ Token guardado${NC}"
            fi
            read -p "Enter..."
            ;;
        7)
            echo -e "\n${CYAN}💰 CAMBIAR PRECIOS${NC}"
            
            CURRENT_7D=$(get_val '.prices.price_7d')
            CURRENT_15D=$(get_val '.prices.price_15d')
            CURRENT_30D=$(get_val '.prices.price_30d')
            CURRENT_50D=$(get_val '.prices.price_50d')
            
            echo -e "Actual:"
            echo -e "  7d: $${CURRENT_7D}"
            echo -e "  15d: $${CURRENT_15D}"
            echo -e "  30d: $${CURRENT_30D}"
            echo -e "  50d: $${CURRENT_50D}"
            echo -e ""
            
            read -p "Nuevo 7d: " NEW_7D
            read -p "Nuevo 15d: " NEW_15D
            read -p "Nuevo 30d: " NEW_30D
            read -p "Nuevo 50d: " NEW_50D
            
            [[ -n "$NEW_7D" ]] && set_val '.prices.price_7d' "$NEW_7D"
            [[ -n "$NEW_15D" ]] && set_val '.prices.price_15d' "$NEW_15D"
            [[ -n "$NEW_30D" ]] && set_val '.prices.price_30d' "$NEW_30D"
            [[ -n "$NEW_50D" ]] && set_val '.prices.price_50d' "$NEW_50D"
            
            echo -e "${GREEN}✅ Precios actualizados${NC}"
            read -p "Enter..."
            ;;
        8)
            echo -e "\n${CYAN}🔄 RENOVAR USUARIO${NC}"
            read -p "Nombre de usuario: " USERNAME
            read -p "Días adicionales: " DAYS
            
            # Verificar que el usuario existe
            if ! id "$USERNAME" &>/dev/null; then
                echo -e "${RED}❌ Usuario no existe${NC}"
                read -p "Enter..."
                continue
            fi
            
            # Extender fecha
            CURRENT_EXPIRE=$(chage -l "$USERNAME" | grep "Account expires" | cut -d: -f2 | xargs)
            if [[ "$CURRENT_EXPIRE" == "never" ]]; then
                NEW_EXPIRE=$(date -d "+$DAYS days" +%Y-%m-%d)
            else
                CURRENT_DATE=$(date -d "$CURRENT_EXPIRE" +%Y-%m-%d)
                NEW_EXPIRE=$(date -d "$CURRENT_DATE + $DAYS days" +%Y-%m-%d)
            fi
            
            # Actualizar en sistema
            usermod -e "$NEW_EXPIRE" "$USERNAME"
            
            # Actualizar en BD
            NEW_EXPIRE_FULL="${NEW_EXPIRE} 23:59:59"
            sqlite3 "$DB" "UPDATE users SET expires_at = '$NEW_EXPIRE_FULL' WHERE username = '$USERNAME'"
            
            echo -e "${GREEN}✅ RENOVADO${NC}"
            echo -e "👤 $USERNAME"
            echo -e "⏰ Nueva expiración: $NEW_EXPIRE"
            read -p "Enter..."
            ;;
        9)
            echo -e "\n${YELLOW}🧹 Limpiando...${NC}"
            pm2 stop sshbot 2>/dev/null
            rm -rf /root/.wppconnect/*
            echo -e "${GREEN}✅ Sesión limpiada${NC}"
            echo -e "${YELLOW}📱 Escanea nuevo QR al iniciar${NC}"
            sleep 2
            ;;
        0)
            echo -e "\n${GREEN}👋 Hasta luego${NC}"
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
echo -e "${GREEN}✅ Panel creado${NC}"

# ================================================
# INICIAR BOT
# ================================================
echo -e "\n${CYAN}🚀 Iniciando bot...${NC}"

cd "$INSTALL_DIR"
pm2 start bot.js --name sshbot
pm2 save

sleep 2

# ================================================
# MENSAJE FINAL
# ================================================
clear
echo -e "${GREEN}${BOLD}"
cat << "FINAL"
╔══════════════════════════════════════════════════════════════╗
║                                                              ║
║         ✅ SSH BOT PRO - INSTALACIÓN COMPLETADA            ║
║             🚀 CON RENOVACIÓN FUNCIONAL                    ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
FINAL
echo -e "${NC}"

echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Opciones completas:${NC}"
echo -e "  1️⃣  Prueba gratis (1 hora)"
echo -e "  2️⃣  Comprar plan (MercadoPago)"
echo -e "  3️⃣  🔥 RENOVAR USUARIO (NUEVO)"
echo -e "  4️⃣  Descargar app"
echo -e "  5️⃣  Soporte"
echo -e "${GREEN}✅ Estados persistentes${NC}"
echo -e "${GREEN}✅ MercadoPago funcionando${NC}"
echo -e "${GREEN}✅ Verificación automática de pagos${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════════════════${NC}\n"

echo -e "${YELLOW}📋 CÓMO RENOVAR:${NC}"
echo -e "1. Escribe *menu* al bot"
echo -e "2. Selecciona *3 - RENOVAR USUARIO*"
echo -e "3. Verás tu lista de usuarios"
echo -e "4. Escribe *renovar [usuario]*"
echo -e "5. Selecciona el plan de renovación"
echo -e "6. Recibirás link de pago MP"
echo -e "7. Al pagar, se renueva AUTOMÁTICAMENTE"
echo -e "\n"

echo -e "${YELLOW}⚡ COMANDOS:${NC}"
echo -e "  ${GREEN}sshbot${NC}          - Panel de control"
echo -e "  ${GREEN}pm2 logs sshbot${NC} - Ver logs/QR"
echo -e "\n"

echo -e "${GREEN}${BOLD}¡Bot completo con renovación funcionando! 🎉${NC}\n"

read -p "$(echo -e "${YELLOW}¿Ver logs ahora? (s/N): ${NC}")" -n 1 -r
echo
if [[ $REPLY =~ ^[Ss]$ ]]; then
    echo -e "\n${CYAN}📱 Espera el QR...${NC}\n"
    pm2 logs sshbot
fi

exit 0
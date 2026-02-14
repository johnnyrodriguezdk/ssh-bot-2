#!/bin/bash

# ====================================================
# INSTALADOR PERSONALIZADO - BOT SSH WHATSAPP
# Versión modificada con cambio de nombre desde menú
# Basado en: martincho247/ssh-bot
# ====================================================

set -e  # Detener en caso de error

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo y banner
print_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║    🤖 BOT SSH WHATSAPP - INSTALADOR      ║"
    echo "║         CON CAMBIO DE NOMBRE             ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Funciones para mensajes
print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# ====================================================
# CONFIGURACIÓN INICIAL
# ====================================================
print_banner

# Variables configurables por defecto
DEFAULT_BOT_NAME="🤖 SSH Manager Bot"
DEFAULT_DIR="$HOME/ssh-bot-whatsapp"
REPO_URL="https://github.com/martincho247/ssh-bot.git"

# Preguntar nombre del bot
echo -e "${CYAN}"
echo "══════════════════════════════════════════"
echo "        CONFIGURACIÓN DEL BOT"
echo "══════════════════════════════════════════"
echo -e "${NC}"

echo -n "¿Qué nombre quieres para tu bot? "
echo -e "${YELLOW}(Ej: 🤖 Mi Bot SSH)${NC}: "
read -r BOT_NAME
BOT_NAME="${BOT_NAME:-$DEFAULT_BOT_NAME}"

# Preguntar número de WhatsApp
echo ""
echo -n "Ingresa tu número de WhatsApp ${YELLOW}(con código país)${NC}"
echo -e "\n${CYAN}Ejemplo: 51912345678 para Perú${NC}: "
read -r ADMIN_NUMBER

# Validar número
if [[ ! "$ADMIN_NUMBER" =~ ^[0-9]{10,13}$ ]]; then
    print_error "Número inválido. Debe tener 10-13 dígitos."
    echo "Ejemplos válidos:"
    echo "  • Perú: 51912345678"
    echo "  • México: 5215512345678"
    echo "  • España: 34612345678"
    exit 1
fi

# Confirmar instalación
echo ""
echo -e "${CYAN}══════════════════════════════════════════${NC}"
print_info "Resumen de configuración:"
echo -e "${CYAN}══════════════════════════════════════════${NC}"
echo -e "🤖 ${YELLOW}Nombre del bot:${NC} $BOT_NAME"
echo -e "📱 ${YELLOW}Número admin:${NC} $ADMIN_NUMBER"
echo -e "📁 ${YELLOW}Directorio:${NC} $DEFAULT_DIR"
echo -e "${CYAN}══════════════════════════════════════════${NC}"

echo -ne "\n¿Continuar con la instalación? (s/n): "
read -r CONFIRMAR
if [[ ! "$CONFIRMAR" =~ ^[SsYy]$ ]]; then
    print_warning "Instalación cancelada por el usuario."
    exit 0
fi

# ====================================================
# 1. VERIFICAR DEPENDENCIAS DEL SISTEMA
# ====================================================
print_success "Iniciando instalación..."
echo ""
print_info "PASO 1: Verificando dependencias del sistema"

# Verificar sistema operativo
if [ -f /etc/os-release ]; then
    . /etc/os-release
    print_info "Sistema detectado: $NAME $VERSION"
fi

# Verificar Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node -v)
    print_success "Node.js encontrado: $NODE_VERSION"
else
    print_warning "Node.js no encontrado. Instalando..."
    
    if [ "$ID" = "ubuntu" ] || [ "$ID" = "debian" ]; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt update
        sudo apt install -y nodejs npm
    elif [ "$ID" = "centos" ] || [ "$ID" = "fedora" ] || [ "$ID" = "rhel" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
        sudo yum install -y nodejs
    elif [ "$ID" = "arch" ] || [ "$ID" = "manjaro" ]; then
        sudo pacman -S nodejs npm
    else
        print_error "Sistema no soportado automáticamente."
        print_info "Por favor instala Node.js manualmente desde:"
        print_info "https://nodejs.org/"
        exit 1
    fi
    
    print_success "Node.js instalado correctamente"
fi

# Verificar NPM
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm -v)
    print_success "NPM encontrado: versión $NPM_VERSION"
else
    print_error "NPM no encontrado. Instálalo manualmente."
    exit 1
fi

# Verificar Git
if command -v git &> /dev/null; then
    print_success "Git encontrado"
else
    print_warning "Git no encontrado. Instalando..."
    if command -v apt &> /dev/null; then
        sudo apt install -y git
    elif command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v pacman &> /dev/null; then
        sudo pacman -S git
    else
        print_error "No se pudo instalar Git. Instálalo manualmente."
        exit 1
    fi
    print_success "Git instalado correctamente"
fi

# ====================================================
# 2. CLONAR REPOSITORIO
# ====================================================
echo ""
print_info "PASO 2: Clonando repositorio del bot"

if [ -d "$DEFAULT_DIR" ]; then
    print_warning "El directorio $DEFAULT_DIR ya existe."
    echo -n "¿Quieres sobrescribirlo? (s/n): "
    read -r RESP_OVERWRITE
    if [[ "$RESP_OVERWRITE" =~ ^[Ss]$ ]]; then
        rm -rf "$DEFAULT_DIR"
        print_success "Directorio anterior eliminado"
    else
        print_info "Usando directorio existente"
    fi
fi

# Clonar repositorio
print_info "Clonando desde: $REPO_URL"
git clone "$REPO_URL" "$DEFAULT_DIR" || {
    print_error "Error al clonar el repositorio"
    exit 1
}
print_success "Repositorio clonado exitosamente"

cd "$DEFAULT_DIR"

# ====================================================
# 3. INSTALAR DEPENDENCIAS NPM
# ====================================================
echo ""
print_info "PASO 3: Instalando dependencias de Node.js"

# Verificar package.json
if [ ! -f "package.json" ]; then
    print_warning "package.json no encontrado. Creando uno básico..."
    
    cat > package.json << EOF
{
  "name": "whatsapp-ssh-bot",
  "version": "2.0.0",
  "description": "Bot de WhatsApp para gestión SSH con cambio de nombre",
  "main": "index.js",
  "scripts": {
    "start": "node index.js",
    "dev": "nodemon index.js",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "dependencies": {
    "qrcode-terminal": "^0.12.0",
    "whatsapp-web.js": "^1.23.0",
    "express": "^4.18.2"
  },
  "engines": {
    "node": ">=14.0.0"
  },
  "keywords": ["whatsapp", "bot", "ssh", "automation"],
  "author": "Usuario Personalizado",
  "license": "MIT"
}
EOF
fi

# Instalar dependencias
print_info "Instalando paquetes NPM (esto puede tomar unos minutos)..."
npm install || {
    print_error "Error al instalar dependencias NPM"
    print_info "Intentando con --force..."
    npm install --force || {
        print_error "Error crítico en instalación NPM"
        exit 1
    }
}
print_success "Dependencias instaladas correctamente"

# ====================================================
# 4. CREAR ARCHIVOS DE CONFIGURACIÓN PERSONALIZADOS
# ====================================================
echo ""
print_info "PASO 4: Creando configuración personalizada"

# Crear config.json con nombre personalizado
cat > config.json << EOF
{
  "botName": "$BOT_NAME",
  "adminNumber": "${ADMIN_NUMBER}@c.us",
  "version": "2.0.0",
  "features": {
    "changeName": true,
    "sshAccess": true,
    "systemMonitor": true,
    "autoRestart": false
  },
  "security": {
    "allowedCommands": ["status", "disk", "memory", "restart", "name", "config", "help"],
    "requireAuth": true,
    "maxSessionHours": 24
  },
  "settings": {
    "sessionPath": "./session",
    "logsPath": "./logs",
    "backupPath": "./backups"
  }
}
EOF
print_success "Archivo config.json creado"

# Crear archivo de comandos personalizados (commands.js)
cat > commands.js << 'EOF'
// ============================================
// COMANDOS PERSONALIZADOS DEL BOT
// Incluye función para cambiar nombre
// ============================================

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Cargar configuración
const CONFIG_FILE = path.join(__dirname, 'config.json');
let config = {};

try {
    if (fs.existsSync(CONFIG_FILE)) {
        config = JSON.parse(fs.readFileSync(CONFIG_FILE, 'utf8'));
    }
} catch (error) {
    console.error('Error cargando configuración:', error);
}

// Exportar configuración actual
exports.config = config;

// Funciones auxiliares
exports.isAdmin = (number) => {
    return number === config.adminNumber;
};

exports.getBotName = () => {
    return config.botName || '🤖 Bot SSH';
};

// COMANDOS DISPONIBLES
exports.commands = {
    // Menú principal
    menu: () => {
        return `
🌟 *${exports.getBotName()}* 🌟

📋 *MENÚ PRINCIPAL*

🔹 *1* - Estado del sistema
🔹 *2* - Espacio en disco  
🔹 *3* - Uso de memoria
🔹 *4* - Usuarios conectados
🔹 *5* - Cambiar nombre del bot ✏️
🔹 *6* - Ver configuración ⚙️
🔹 *7* - Ayuda ❓
🔹 *8* - Reiniciar servicios 🔄

💡 *Envía el número del comando*
📝 *Ejemplo:* Envía *1* para estado del sistema
        `;
    },

    // Estado del sistema
    status: () => {
        try {
            const os = require('os');
            const uptime = Math.floor(os.uptime() / 3600);
            const load = os.loadavg()[0].toFixed(2);
            
            return `📊 *ESTADO DEL SISTEMA*

• 🖥️ Hostname: ${os.hostname()}
• 🚀 Uptime: ${uptime} horas
• ⚡ Carga del sistema: ${load}
• 💾 Memoria total: ${(os.totalmem() / 1024 / 1024 / 1024).toFixed(2)} GB
• 🆓 Memoria libre: ${(os.freemem() / 1024 / 1024 / 1024).toFixed(2)} GB
• 📈 Uso: ${((1 - os.freemem() / os.totalmem()) * 100).toFixed(1)}%
• 👥 CPUs: ${os.cpus().length}`;
        } catch (error) {
            return "❌ Error al obtener estado del sistema";
        }
    },

    // Espacio en disco
    disk: () => {
        try {
            const output = execSync('df -h / | tail -1').toString().trim();
            const parts = output.split(/\s+/);
            
            return `💾 *ESPACIO EN DISCO*

• 📂 Sistema de archivos: ${parts[0]}
• 📦 Tamaño total: ${parts[1]}
• 📊 Usado: ${parts[2]} (${parts[4]})
• 📉 Libre: ${parts[3]}
• 📍 Montado en: ${parts[5]}`;
        } catch (error) {
            return "❌ Error al verificar espacio en disco";
        }
    },

    // Memoria
    memory: () => {
        try {
            const os = require('os');
            const total = os.totalmem();
            const free = os.freemem();
            const used = total - free;
            const percent = (used / total * 100).toFixed(1);
            
            return `🧠 *USO DE MEMORIA*

• 💿 Total: ${(total / 1024 / 1024 / 1024).toFixed(2)} GB
• 📈 Usado: ${(used / 1024 / 1024 / 1024).toFixed(2)} GB
• 📉 Libre: ${(free / 1024 / 1024 / 1024).toFixed(2)} GB
• 📊 Porcentaje: ${percent}%`;
        } catch (error) {
            return "❌ Error al verificar memoria";
        }
    },

    // Usuarios conectados
    users: () => {
        try {
            const output = execSync('who | wc -l').toString().trim();
            const users = parseInt(output) || 0;
            
            if (users === 0) {
                return "👤 *USUARIOS CONECTADOS*\n\nNo hay usuarios conectados actualmente";
            } else {
                const userList = execSync('who | cut -d" " -f1 | sort | uniq').toString().trim();
                return `👥 *USUARIOS CONECTADOS*\n\n• Total: ${users} usuario(s)\n• Lista: ${userList.split('\n').join(', ')}`;
            }
        } catch (error) {
            return "❌ Error al verificar usuarios";
        }
    },

    // Cambiar nombre del bot
    changename: (newName, user) => {
        // Verificar permisos
        if (!exports.isAdmin(user)) {
            return "⛔ *ACCESO DENEGADO*\n\nSolo el administrador puede cambiar el nombre del bot.";
        }
        
        // Validar nombre
        if (!newName || newName.trim().length < 2) {
            return "❌ *NOMBRE INVÁLIDO*\n\nEl nombre debe tener al menos 2 caracteres.";
        }
        
        if (newName.length > 100) {
            return "❌ *NOMBRE DEMASIADO LARGO*\n\nMáximo 100 caracteres permitidos.";
        }
        
        const oldName = exports.getBotName();
        const cleanName = newName.trim();
        
        // Actualizar configuración
        try {
            config.botName = cleanName;
            fs.writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));
            
            // Registrar cambio
            const logEntry = `[${new Date().toISOString()}] Nombre cambiado: "${oldName}" -> "${cleanName}" por ${user}\n`;
            fs.appendFileSync('name_changes.log', logEntry);
            
            return `✅ *NOMBRE CAMBIADO EXITOSAMENTE*

🔸 *Anterior:* ${oldName}
🔸 *Nuevo:* ${cleanName}

El cambio se aplicará inmediatamente en el menú principal.`;
        } catch (error) {
            console.error('Error cambiando nombre:', error);
            return "❌ *ERROR*\n\nNo se pudo cambiar el nombre. Intenta nuevamente.";
        }
    },

    // Ver configuración
    showconfig: (user) => {
        if (!exports.isAdmin(user)) {
            return "⛔ *ACCESO DENEGADO*\n\nSolo el administrador puede ver la configuración.";
        }
        
        return `⚙️ *CONFIGURACIÓN DEL BOT*

• 🤖 Nombre: ${exports.getBotName()}
• 👑 Administrador: ${config.adminNumber.replace('@c.us', '')}
• 🚀 Versión: ${config.version}
• 📅 Instalado: $(date -r ${CONFIG_FILE} '+%d/%m/%Y %H:%M')

🔧 *Características:*
${config.features.changeName ? '  • ✏️ Cambiar nombre: ✅ Activado' : '  • ✏️ Cambiar nombre: ❌ Desactivado'}
${config.features.sshAccess ? '  • 🔐 Acceso SSH: ✅ Activado' : '  • 🔐 Acceso SSH: ❌ Desactivado'}
${config.features.systemMonitor ? '  • 📊 Monitor: ✅ Activado' : '  • 📊 Monitor: ❌ Desactivado'}

📋 *Comandos permitidos:*
${config.security.allowedCommands.map(cmd => `  • ${cmd}`).join('\n')}`;
    },

    // Ayuda
    help: () => {
        return `🆘 *AYUDA - ${exports.getBotName()}*

📚 *COMANDOS DISPONIBLES:*

*Básicos:*
• *menu* - Mostrar este menú
• *1* o *status* - Estado del sistema
• *2* o *disk* - Espacio en disco
• *3* o *memory* - Uso de memoria
• *4* o *users* - Usuarios conectados

*Administración:*
• *5* o *name [nuevo]* - Cambiar nombre del bot
• *6* o *config* - Ver configuración
• *8* o *restart* - Reiniciar servicios

📝 *EJEMPLOS:*
• Envía *1* para estado del sistema
• Envía *name Mi Nuevo Bot* para cambiar nombre
• Envía *config* para ver configuración

🔐 *Nota:* Algunos comandos requieren permisos de administrador.`;
    },

    // Reiniciar servicios
    restart: (user) => {
        if (!exports.isAdmin(user)) {
            return "⛔ *ACCESO DENEGADO*\n\nSolo el administrador puede reiniciar servicios.";
        }
        
        return `🔄 *REINICIO DE SERVICIOS*

*Opciones disponibles:*
• restart bot - Reiniciar este bot
• restart ssh - Reiniciar servicio SSH
• restart all - Reiniciar todos los servicios

📝 *Uso:* restart [opción]
⚠️ *Advertencia:* Esta acción puede interrumpir servicios.`;
    }
};
EOF
print_success "Archivo commands.js creado con comandos personalizados"

# Crear archivo principal del bot (index.js)
cat > index.js << 'EOF'
#!/usr/bin/env node

// ============================================
// BOT PRINCIPAL DE WHATSAPP SSH
// Con función para cambiar nombre desde menú
// ============================================

const qrcode = require('qrcode-terminal');
const { Client, LocalAuth } = require('whatsapp-web.js');
const fs = require('fs');
const path = require('path');

// Cargar comandos personalizados
const commandModule = require('./commands.js');
const commands = commandModule.commands;
let config = commandModule.config;

// Configuración del cliente WhatsApp
const client = new Client({
    authStrategy: new LocalAuth({
        clientId: "ssh-whatsapp-bot"
    }),
    puppeteer: {
        headless: true,
        args: ['--no-sandbox', '--disable-setuid-sandbox']
    },
    webVersionCache: {
        type: 'remote',
        remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html'
    }
});

// Variables de estado
let waitingForNameChange = {};
let sessionActive = false;

// Evento cuando se genera código QR
client.on('qr', (qr) => {
    console.log('\n' + '='.repeat(50));
    console.log('🔄 ESCANEA ESTE CÓDIGO QR CON WHATSAPP');
    console.log('='.repeat(50) + '\n');
    
    qrcode.generate(qr, { small: true });
    
    console.log('\n' + '='.repeat(50));
    console.log('📱 Abre WhatsApp en tu teléfono');
    console.log('📸 Ve a Ajustes → Dispositivos vinculados');
    console.log('✅ Escanea el código QR mostrado arriba');
    console.log('='.repeat(50) + '\n');
});

// Evento cuando el cliente está listo
client.on('ready', () => {
    sessionActive = true;
    console.log('\n' + '='.repeat(50));
    console.log(`🤖 ${config.botName} - CONECTADO EXITOSAMENTE`);
    console.log('='.repeat(50));
    console.log(`⏰ Hora de inicio: ${new Date().toLocaleString()}`);
    console.log(`📱 Número del bot: ${client.info.wid.user}`);
    console.log(`👑 Administrador: ${config.adminNumber}`);
    console.log(`🚀 Versión: ${config.version}`);
    console.log('='.repeat(50) + '\n');
    
    // Opcional: Enviar mensaje de inicio al admin
    try {
        client.sendMessage(config.adminNumber, 
            `✅ *${config.botName} está en línea!*\n\n` +
            `📅 Hora de inicio: ${new Date().toLocaleString()}\n` +
            `💻 Host: ${require('os').hostname()}\n` +
            `📋 Usa *menu* para ver los comandos disponibles.`
        );
    } catch (error) {
        console.log('Nota: No se pudo enviar mensaje de inicio al admin');
    }
});

// Evento de autenticación fallida
client.on('auth_failure', (msg) => {
    console.error('❌ Error de autenticación:', msg);
    sessionActive = false;
});

// Evento de desconexión
client.on('disconnected', (reason) => {
    console.log('⚠️  Cliente desconectado:', reason);
    sessionActive = false;
});

// ============================================
// MANEJADOR DE MENSAJES PRINCIPAL
// ============================================
client.on('message', async (message) => {
    try {
        // Ignorar mensajes del propio bot o de grupos
        if (message.fromMe || message.isGroup) return;
        
        const text = message.body.trim();
        const sender = message.from;
        
        console.log(`📩 Mensaje de ${sender}: ${text}`);
        
        // Comando MENU
        if (text.toLowerCase() === 'menu' || text === '0') {
            const menu = commands.menu();
            await message.reply(menu);
            return;
        }
        
        // Comandos numéricos del menú
        switch (text) {
            case '1':
                await message.reply(commands.status());
                break;
                
            case '2':
                await message.reply(commands.disk());
                break;
                
            case '3':
                await message.reply(commands.memory());
                break;
                
            case '4':
                await message.reply(commands.users());
                break;
                
            case '5':
                // Comando para cambiar nombre
                waitingForNameChange[sender] = true;
                await message.reply(
                    `✏️ *CAMBIO DE NOMBRE DEL BOT*\n\n` +
                    `Nombre actual: *${commandModule.getBotName()}*\n\n` +
                    `Por favor, envía el nuevo nombre para el bot:\n` +
                    `(Máximo 100 caracteres)`
                );
                break;
                
            case '6':
                // Ver configuración
                await message.reply(commands.showconfig(sender));
                break;
                
            case '7':
                // Ayuda
                await message.reply(commands.help());
                break;
                
            case '8':
                // Reiniciar servicios
                await message.reply(commands.restart(sender));
                break;
                
            default:
                // Manejar cambio de nombre (si estamos esperando)
                if (waitingForNameChange[sender]) {
                    delete waitingForNameChange[sender];
                    const response = commands.changename(text, sender);
                    await message.reply(response);
                    
                    // Actualizar configuración en memoria
                    config = commandModule.config;
                    return;
                }
                
                // Comandos por texto
                const lowerText = text.toLowerCase();
                if (lowerText.startsWith('name ') || lowerText.startsWith('nombre ')) {
                    const newName = text.substring(text.indexOf(' ') + 1);
                    const response = commands.changename(newName, sender);
                    await message.reply(response);
                    
                    // Actualizar configuración en memoria
                    config = commandModule.config;
                } else if (lowerText === 'status' || lowerText === 'estado') {
                    await message.reply(commands.status());
                } else if (lowerText === 'disk' || lowerText === 'disco') {
                    await message.reply(commands.disk());
                } else if (lowerText === 'memory' || lowerText === 'memoria') {
                    await message.reply(commands.memory());
                } else if (lowerText === 'users' || lowerText === 'usuarios') {
                    await message.reply(commands.users());
                } else if (lowerText === 'config' || lowerText === 'configuracion') {
                    await message.reply(commands.showconfig(sender));
                } else if (lowerText === 'help' || lowerText === 'ayuda') {
                    await message.reply(commands.help());
                } else if (lowerText.startsWith('restart')) {
                    await message.reply(commands.restart(sender));
                } else if (text) {
                    // Mensaje no reconocido
                    await message.reply(
                        `❓ *COMANDO NO RECONOCIDO*\n\n` +
                        `Envíaste: "${text}"\n\n` +
                        `Usa *menu* para ver los comandos disponibles o *help* para ayuda.`
                    );
                }
                break;
        }
    } catch (error) {
        console.error('Error procesando mensaje:', error);
        try {
            await message.reply(
                `❌ *ERROR INTERNO*\n\n` +
                `Ocurrió un error al procesar tu solicitud.\n` +
                `Por favor, intenta nuevamente más tarde.`
            );
        } catch (e) {
            console.error('No se pudo enviar mensaje de error:', e);
        }
    }
});

// ============================================
// INICIAR EL BOT
// ============================================
console.log('='.repeat(50));
console.log('🚀 INICIANDO BOT SSH WHATSAPP');
console.log('='.repeat(50));
console.log(`🤖 Nombre: ${config.botName}`);
console.log(`👤 Usuario del sistema: ${process.env.USER || 'desconocido'}`);
console.log(`📂 Directorio: ${__dirname}`);
console.log(`🕐 Fecha: ${new Date().toLocaleString()}`);
console.log('='.repeat(50));

// Manejar cierre limpio
process.on('SIGINT', async () => {
    console.log('\n\n⚠️  Recibida señal de interrupción. Cerrando bot...');
    if (sessionActive) {
        try {
            await client.destroy();
            console.log('✅ Cliente WhatsApp cerrado correctamente');
        } catch (error) {
            console.error('Error al cerrar cliente:', error);
        }
    }
    process.exit(0);
});

// Inicializar cliente
client.initialize().catch(error => {
    console.error('❌ Error al inicializar el bot:', error);
    process.exit(1);
});
EOF
print_success "Archivo index.js creado con la lógica del bot"

# Hacer ejecutable el archivo principal
chmod +x index.js

# Crear archivos adicionales
print_info "Creando archivos adicionales..."

# Crear .gitignore
cat > .gitignore << EOF
node_modules/
session/
*.log
*.backup
.DS_Store
.env
config.local.json
EOF

# Crear README personalizado
cat > README_CUSTOM.md << EOF
# 🤖 ${BOT_NAME} - Bot SSH para WhatsApp

Bot personalizado para gestión remota de servidores SSH mediante WhatsApp.

## ✨ Características

✅ **Cambio de nombre desde el menú** - Opción 5  
✅ **Monitoreo del sistema** - Estado, disco, memoria  
✅ **Acceso seguro** - Solo administradores autorizados  
✅ **Interfaz intuitiva** - Menú numérico fácil de usar  

## 📋 Comandos Disponibles

*Envía el número o texto correspondiente:*

1. **Estado del sistema** - Información del servidor
2. **Espacio en disco** - Uso de almacenamiento  
3. **Uso de memoria** - Estadísticas de RAM
4. **Usuarios conectados** - Sesiones activas
5. **Cambiar nombre del bot** - Personaliza el nombre ✏️
6. **Ver configuración** - Ajustes actuales
7. **Ayuda** - Esta información
8. **Reiniciar servicios** - Opciones de reinicio

## ⚙️ Configuración

- **Nombre del bot:** ${BOT_NAME}
- **Administrador:** ${ADMIN_NUMBER}
- **Directorio:** ${DEFAULT_DIR}
- **Instalado:** $(date)

## 🚀 Uso Rápido

\`\`\`bash
cd ${DEFAULT_DIR}
npm start
\`\`\`

## 🔒 Seguridad

- Solo ${ADMIN_NUMBER} tiene acceso completo
- Los cambios de nombre quedan registrados en \`name_changes.log\`
- Sesión local almacenada en carpeta \`session/\`

## 📞 Soporte

Bot personalizado basado en [martincho247/ssh-bot](https://github.com/martincho247/ssh-bot)
EOF

# Crear script de actualización
cat > update_bot.sh << 'EOF'
#!/bin/bash
echo "🔄 Actualizando Bot SSH WhatsApp..."
cd "$(dirname "$0")"
git pull
npm install
echo "✅ Actualización completada"
echo "Reinicia el bot para aplicar cambios: npm start"
EOF
chmod +x update_bot.sh

# ====================================================
# 5. CONFIGURAR SERVICIO AUTOMÁTICO (OPCIONAL)
# ====================================================
echo ""
print_info "PASO 5: Configuración adicional"

# Preguntar por servicio automático
echo -ne "\n${YELLOW}¿Deseas crear un servicio para ejecutar automáticamente al iniciar el sistema?${NC} (s/n): "
read -r SERVICE_ANSWER

if [[ "$SERVICE_ANSWER" =~ ^[Ss]$ ]]; then
    print_info "Creando servicio systemd..."
    
    # Crear archivo de servicio
    SERVICE_FILE="/etc/systemd/system/whatsapp-ssh-bot.service"
    
    sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=WhatsApp SSH Bot - ${BOT_NAME}
After=network.target
Wants=network.target

[Service]
Type=simple
User=${USER}
WorkingDirectory=${DEFAULT_DIR}
Environment="PATH=/usr/bin:/bin:/usr/local/bin:/home/${USER}/.nvm/versions/node/$(node -v)/bin"
ExecStart=$(which node) ${DEFAULT_DIR}/index.js
Restart=on-failure
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=whatsapp-bot

# Seguridad
NoNewPrivileges=true
ProtectSystem=strict
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF
    
    # Recargar systemd y habilitar servicio
    sudo systemctl daemon-reload
    sudo systemctl enable whatsapp-ssh-bot.service
    
    print_success "Servicio creado: whatsapp-ssh-bot.service"
    print_info "Comandos de servicio:"
    print_info "  sudo systemctl start whatsapp-ssh-bot"
    print_info "  sudo systemctl stop whatsapp-ssh-bot"
    print_info "  sudo systemctl status whatsapp-ssh-bot"
    print_info "  sudo journalctl -u whatsapp-ssh-bot -f"
fi

# ====================================================
# 6. INSTALACIÓN COMPLETADA
# ====================================================
print_banner
print_success "¡INSTALACIÓN COMPLETADA EXITOSAMENTE! 🎉"
echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "🤖 ${YELLOW}NOMBRE DEL BOT:${NC} $BOT_NAME"
echo -e "📱 ${YELLOW}ADMINISTRADOR:${NC} $ADMIN_NUMBER"
echo -e "📁 ${YELLOW}DIRECTORIO:${NC} $DEFAULT_DIR"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${GREEN}🚀 PARA INICIAR EL BOT:${NC}"
echo -e "   cd $DEFAULT_DIR"
echo -e "   npm start"
echo ""
echo -e "${BLUE}📱 CONEXIÓN CON WHATSAPP:${NC}"
echo -e "   1. Abre WhatsApp en tu teléfono"
echo -e "   2. Ve a Ajustes → Dispositivos vinculados"
echo -e "   3. Escanea el código QR que aparecerá"
echo ""
echo -e "${PURPLE}📋 COMANDOS DISPONIBLES:${NC}"
echo -e "   • Envía 'menu' para ver opciones"
echo -e "   • Envía '5' para cambiar nombre del bot ✏️"
echo -e "   • Envía 'help' para ayuda detallada"
echo ""
echo -e "${YELLOW}🔧 MANTENIMIENTO:${NC}"
echo -e "   • Actualizar: cd $DEFAULT_DIR && ./update_bot.sh"
echo -e "   • Ver logs: tail -f $DEFAULT_DIR/whatsapp.log"
echo ""

if [[ "$SERVICE_ANSWER" =~ ^[Ss]$ ]]; then
    echo -e "${GREEN}⚙️  SERVICIO AUTOMÁTICO:${NC}"
    echo -e "   • Iniciar ahora: sudo systemctl start whatsapp-ssh-bot"
    echo -e "   • Ver estado: sudo systemctl status whatsapp-ssh-bot"
    echo ""
fi

echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ ¡Tu bot está listo para usar!${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"

# Crear archivo de inicio rápido
cat > "$HOME/iniciar-bot.sh" << EOF
#!/bin/bash
echo "🚀 Iniciando ${BOT_NAME}..."
cd "$DEFAULT_DIR"
npm start
EOF
chmod +x "$HOME/iniciar-bot.sh"

print_success "Archivo de inicio rápido creado: ~/iniciar-bot.sh"
echo ""
print_info "✨ Instalación finalizada a las: $(date)"

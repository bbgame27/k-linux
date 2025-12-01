#!/bin/bash

echo "🎉 เริ่มการตั้งค่า Termux Custom Shell (v2.5: ถามซ้ำจนกว่าจะตอบถูก)..."

pkg update -y
pkg install neofetch bash-completion -y

rm -f ~/.bashrc ~/.profile ~/mysudo ~/k_display.sh ~/.mysudo_cache ~/authenticate_init.sh 
touch ~/.bashrc ~/.profile
mkdir -p ~/.config/neofetch/

cat << 'EOF_LOGO' > ~/k_logo.txt
\033[31mKKKK      KKKK\033[0m
\033[31mKKKK    KKKK\033[0m
\033[31mKKKK  KKKK\033[0m
\033[31mKKKKKKKK\033[0m
\033[31mKKKK  KKKK\033[0m
\033[31mKKKK    KKKK\033[0m
\033[31mKKKK      KKKK\033[0m
EOF_LOGO

cat << 'EOF_CONF' > ~/.config/neofetch/config.conf
image_source="/data/data/com.termux/files/home/k_logo.txt"
image_backend="ascii"
user="u_k111"
host="fake_root"
print_info() {
    info title
    info underline
    info "OS" distro
    info "Host" host
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "CPU" cpu
    info "Memory" memory
}
EOF_CONF

cat << 'EOF_AUTH' > ~/authenticate_init.sh
#!/bin/bash
CACHE_FILE=~/.mysudo_cache
REQUIRED_PASSWORD_FILE=~/.mysudo_pass 
BYPASS_KEYWORD="BYPASS_K_SET"

echo "Select Language / เลือกภาษา:"
echo "1) Thai (ไทย)"
echo "2) English"
while true; do
    echo -n "Enter choice [1 or 2]: "
    read LANG_CHOICE
    
    if [ "$LANG_CHOICE" == "1" ]; then
        break
    elif [ "$LANG_CHOICE" == "2" ]; then
        break
    else
        echo "Invalid choice. Please select 1 or 2."
    fi
done

if [ ! -f "$REQUIRED_PASSWORD_FILE" ]; then
    
    if [ "$LANG_CHOICE" == "1" ]; then
        echo "================================================="
        echo "⚙️ การตั้งค่าครั้งแรก: กรุณาตั้งรหัสผ่านใหม่"
        echo " (หรือกด k เพื่อข้ามการตั้งค่ารหัสผ่าน)"
        echo "================================================="
        SETUP_PROMPT_1="ตั้งรหัสผ่านใหม่ (ซ่อน):"
        SETUP_PROMPT_2="ยืนยันรหัสผ่านใหม่ (ซ่อน):"
        SETUP_SUCCESS="✅ ตั้งรหัสผ่านสำเร็จ"
        SETUP_SKIP="✅ ข้ามการตั้งรหัสผ่าน" 
        SETUP_ERROR="รหัสผ่านไม่ตรงกัน หรือว่างเปล่า กรุณาลองใหม่"
        ERROR_MSG="รหัสผ่านผิด กรุณาลองใหม่อีกครั้ง" 
        BYPASS_MSG="⚠️ ข้ามการยืนยันตัวตน (Bypass) แล้ว"
    else 
        echo "================================================="
        echo "⚙️ First Time Setup: Please set your new password"
        echo " (or press k to skip password setup)"
        echo "================================================="
        SETUP_PROMPT_1="Set new password (hidden):"
        SETUP_PROMPT_2="Confirm new password (hidden):"
        SETUP_SUCCESS="✅ Password set successfully."
        SETUP_SKIP="✅ Password setup skipped."
        SETUP_ERROR="Passwords do not match or are empty. Please try again."
        ERROR_MSG="Incorrect password. Please try again."
        BYPASS_MSG="⚠️ Authentication bypassed."
    fi
    
    while true; do
        echo -n "$SETUP_PROMPT_1 "
        read -s NEW_PASSWORD_1
        echo ""

        if [ "$NEW_PASSWORD_1" == "k" ] || [ "$NEW_PASSWORD_1" == "K" ]; then
            echo "$BYPASS_KEYWORD" > "$REQUIRED_PASSWORD_FILE" 
            chmod 600 "$REQUIRED_PASSWORD_FILE" 
            echo "$SETUP_SKIP"
            break
        fi
        
        echo -n "$SETUP_PROMPT_2 "
        read -s NEW_PASSWORD_2
        echo ""
        
        if [ "$NEW_PASSWORD_1" == "$NEW_PASSWORD_2" ] && [ -n "$NEW_PASSWORD_1" ]; then
            echo "$NEW_PASSWORD_1" > "$REQUIRED_PASSWORD_FILE"
            chmod 600 "$REQUIRED_PASSWORD_FILE" 
            echo "$SETUP_SUCCESS"
            break
        else
            echo "$SETUP_ERROR"
        fi
    done
fi

REQUIRED_PASSWORD=$(cat "$REQUIRED_PASSWORD_FILE")

if [ -z "$ERROR_MSG" ]; then
    if [ "$LANG_CHOICE" == "1" ]; then
        ERROR_MSG="รหัสผ่านผิด กรุณาลองใหม่อีกครั้ง" 
        BYPASS_MSG="⚠️ ข้ามการยืนยันตัวตน (Bypass) แล้ว"
    else
        ERROR_MSG="Incorrect password. Please try again."
        BYPASS_MSG="⚠️ Authentication bypassed."
    fi
fi

if [ "$REQUIRED_PASSWORD" == "$BYPASS_KEYWORD" ]; then
    if [ "$LANG_CHOICE" == "1" ]; then
        PROMPT_LANG="รหัสผ่านเพื่อเข้าใช้งาน (กด k หรือ Enter):" 
    else
        PROMPT_LANG="password to unlock (press k or Enter):" 
    fi
else
    if [ "$LANG_CHOICE" == "1" ]; then
        PROMPT_LANG="รหัสผ่านเพื่อเข้าใช้งาน:" 
    else
        PROMPT_LANG="password to unlock:" 
    fi
fi

while true; do
    echo -n "$PROMPT_LANG "
    read -s PASSWORD
    echo "" 

    IS_VALID=0
    
    if [ "$REQUIRED_PASSWORD" == "$BYPASS_KEYWORD" ]; then
        if [ "$PASSWORD" == "k" ] || [ "$PASSWORD" == "K" ]; then
            IS_VALID=1
        elif [ -z "$PASSWORD" ]; then
            IS_VALID=1
        fi
    fi
    
    if [ "$PASSWORD" == "$REQUIRED_PASSWORD" ]; then
        IS_VALID=1
    fi

    if [ "$IS_VALID" -eq 1 ]; then
        if [ "$REQUIRED_PASSWORD" == "$BYPASS_KEYWORD" ] && ([ "$PASSWORD" == "k" ] || [ "$PASSWORD" == "K" ]); then
            echo "$BYPASS_MSG"
        fi
        
        date +%s > "$CACHE_FILE"
        break
    else
        echo "$ERROR_MSG"
    fi
done
EOF_AUTH
chmod +x ~/authenticate_init.sh

cat << 'EOF_SUDO' > ~/mysudo
#!/bin/bash
CACHE_FILE=~/.mysudo_cache
CACHE_TIMEOUT=2592000

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    LANG_CHOICE="2" 

    if [ "$LANG_CHOICE" == "1" ]; then
        echo "mysudo (ตัวจำลอง sudo สำหรับ Termux) เวอร์ชัน 2.5"
        echo "การใช้งาน: mysudo [options] command [arguments]"
        echo "---"
        echo "คำสั่งเฉพาะ"
        echo "  sudo apt <คำสั่ง>      - ใช้เพื่อจัดการแพ็คเกจ (เช่น sudo apt install)"
        echo "  sudo git <คำสั่ง>      - เพื่อรันคำสั่ง 'git' ที่คุณติดตั้งไว้"
        echo "---"
        echo "ชื่อเล่น (Alias) ที่สร้างขึ้น:"
        echo "  sudo command  - รันคำสั่งด้วยระบบปลดล็อกเซสชัน"
        echo "  neo           - รัน neofetch (sudo neofetch)"
        echo "---"
        echo "ตัวเลือก:"
        echo "  -h, --help    - แสดงข้อความช่วยเหลือนี้"
    else
        echo "mysudo (Termux Custom Sudo) Version 2.5"
        echo "Usage: mysudo [options] command [arguments]"
        echo "---"
        echo "Specific Commands"
        echo "  sudo apt <command>    - Used to manage packages (e.g. sudo apt install)."
        echo "  sudo git <command>    - To run the installed 'git' command."
        echo "---"
        echo "Custom Aliases:"
        echo "  sudo command  - Run command with session unlock logic."
        echo "  neo           - Run neofetch (sudo neofetch)."
        echo "---"
        echo "Options:"
        echo "  -h, --help    - Display this help message and exit."
    fi
    exit 0
fi

if [ -z "$1" ]; then
    echo "usage: mysudo command"
    exit 1
fi

if [ -f "$CACHE_FILE" ] && [ $(( $(date +%s) - $(cat "$CACHE_FILE") )) -le $CACHE_TIMEOUT ]; then
    "$@"
else
    echo "Access denied. Please reopen Termux to start the session."
    exit 1
fi
EOF_SUDO
chmod +x ~/mysudo

cat << 'EOF_BASHRC' > ~/.bashrc

rm -f ~/.mysudo_cache

~/authenticate_init.sh

if [ $? -ne 0 ]; then
    return
fi

PS1='[\033[31mroot\033[0m@@K]\n|>  '

alias mysudo='~/mysudo'
alias neo='~/mysudo neofetch'
alias sudo='~/mysudo'
alias ls='ls --color=auto'
alias ll='ls -alF --color=auto'
alias apt='pkg'
EOF_BASHRC

cat << 'EOF_PROFILE' > ~/.profile
if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi
EOF_PROFILE

echo "================================================="
echo "✅ ติดตั้งสำเร็จ!"
echo "กรุณาปิดแอป Termux แล้วเปิดใหม่"
================================================="

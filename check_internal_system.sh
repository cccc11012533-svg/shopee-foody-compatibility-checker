#!/bin/bash

###############################################################################
# Shopee Foody Drive - System Internal Check Script
# ตรวจสอบระบบภายในแอป และดึง log/data
###############################################################################

# สีสำหรับแสดงผล
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ฟังก์ชันแสดงหัวข้อ
print_header() {
    echo -e "\n${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

###############################################################################
# เริ่มตรวจสอบ
###############################################################################

print_header "Shopee Foody Drive - System Internal Checker"

APP_PACKAGE="com.shopee.foody.drive"
APP_DIR="/data/data/$APP_PACKAGE"
LOG_DIR="/data/data/$APP_PACKAGE/logs"
DB_DIR="/data/data/$APP_PACKAGE/databases"
SHARED_PREF="/data/data/$APP_PACKAGE/shared_prefs"

###############################################################################
# 1. ตรวจสอบการติดตั้ง
###############################################################################

print_header "1. ตรวจสอบการติดตั้งแอป"

if pm list packages | grep -q "$APP_PACKAGE"; then
    print_success "แอป Shopee Foody Drive ติดตั้งแล้ว"
    
    # ดึงข้อมูลแอป
    APP_VERSION=$(dumpsys package $APP_PACKAGE | grep versionName | head -1 | awk '{print $NF}')
    APP_PATH=$(pm path $APP_PACKAGE | sed 's/package://')
    
    echo -e "   Package: ${CYAN}$APP_PACKAGE${NC}"
    echo -e "   Version: ${CYAN}$APP_VERSION${NC}"
    echo -e "   Path: ${CYAN}$APP_PATH${NC}"
else
    print_error "แอป Shopee Foody Drive ไม่ได้ติดตั้ง"
    exit 1
fi

###############################################################################
# 2. ตรวจสอบ Data Directory
###############################################################################

print_header "2. ตรวจสอบ Data Directory"

if [ -d "$APP_DIR" ]; then
    print_success "พบ App Data Directory"
    
    # ขนาด
    APP_SIZE=$(du -sh "$APP_DIR" 2>/dev/null | cut -f1)
    echo -e "   ขนาด Data: ${CYAN}$APP_SIZE${NC}"
    
    # ทำการแสดง Subdirectories
    echo -e "\n${YELLOW}📁 Subdirectories:${NC}"
    ls -lh "$APP_DIR" 2>/dev/null | tail -n +2 | while read line; do
        echo "   $line"
    done
else
    print_error "ไม่พบ App Data Directory"
fi

###############################################################################
# 3. ตรวจสอบ Shared Preferences
###############################################################################

print_header "3. ตรวจสอบ Shared Preferences (ข้อมูลการตั้งค่า)"

if [ -d "$SHARED_PREF" ]; then
    print_success "พบ Shared Preferences"
    
    echo -e "\n${YELLOW}📄 ไฟล์ Preferences:${NC}"
    ls -lh "$SHARED_PREF" 2>/dev/null | tail -n +2 | while read line; do
        FILENAME=$(echo "$line" | awk '{print $NF}')
        echo "   📄 $FILENAME"
    done
    
    # ตรวจสอบ Login Status
    if [ -f "$SHARED_PREF/com.shopee.foody.drive_preferences.xml" ]; then
        echo -e "\n${YELLOW}🔐 ตรวจสอบสถานะ Login:${NC}"
        cat "$SHARED_PREF/com.shopee.foody.drive_preferences.xml" 2>/dev/null | grep -i "login\|user\|token" | head -5
    fi
else
    print_warning "ไม่พบ Shared Preferences"
fi

###############################################################################
# 4. ตรวจสอบ Databases
###############################################################################

print_header "4. ตรวจสอบ Databases"

if [ -d "$DB_DIR" ]; then
    print_success "พบ Database Directory"
    
    echo -e "\n${YELLOW}🗄️  Database Files:${NC}"
    ls -lh "$DB_DIR" 2>/dev/null | tail -n +2 | while read line; do
        echo "   $line"
    done
else
    print_warning "ไม่พบ Database Directory"
fi

###############################################################################
# 5. ตรวจสอบ Logs
###############################################################################

print_header "5. ตรวจสอบ Log Files"

if [ -d "$LOG_DIR" ]; then
    print_success "พบ Log Directory"
    
    echo -e "\n${YELLOW}📋 Log Files:${NC}"
    ls -lh "$LOG_DIR" 2>/dev/null | tail -n +2 | while read line; do
        echo "   $line"
    done
    
    # แสดง Recent Logs
    echo -e "\n${YELLOW}📝 Recent Log Entries:${NC}"
    if [ -f "$LOG_DIR/crash.log" ]; then
        echo "   🔴 Crash Log Found!"
        tail -20 "$LOG_DIR/crash.log" 2>/dev/null
    fi
else
    print_info "ไม่พบ Log Directory (อาจเป็นเรื่องปกติ)"
fi

###############################################################################
# 6. ดึง Logcat
###############################################################################

print_header "6. Logcat Output (ข้อมูลระบบ)"

echo -e "${YELLOW}📊 Recent Logcat for Shopee Foody:${NC}\n"

# ตรวจสอบว่า Logcat มีข้อมูลเกี่ยวกับแอปหรือไม่
logcat -d *:S "$APP_PACKAGE:V" 2>/dev/null | tail -50

if [ $? -ne 0 ]; then
    print_warning "ไม่สามารถเข้าถึง Logcat (อาจต้อง Root)"
    print_info "ลองคำสั่ง: adb logcat | grep foody"
fi

###############################################################################
# 7. ตรวจสอบ App Permissions
###############################################################################

print_header "7. ตรวจสอบสิทธิ์ (Permissions)"

echo -e "${YELLOW}✅ Granted Permissions:${NC}"
dumpsys package $APP_PACKAGE | grep "android.permission" | grep "granted" | head -10

echo -e "\n${YELLOW}❌ Denied Permissions:${NC}"
dumpsys package $APP_PACKAGE | grep "android.permission" | grep "denied" | head -10

###############################################################################
# 8. ตรวจสอบ App Runtime Info
###############################################################################

print_header "8. ตรวจสอบ Runtime Information"

echo -e "${YELLOW}📊 Process Info:${NC}"
ps -ef | grep "$APP_PACKAGE" | grep -v grep

if [ $? -eq 0 ]; then
    print_success "แอปกำลังทำงานอยู่"
else
    print_warning "แอปไม่ได้ทำงาน (อาจถูกปิด)"
fi

###############################################################################
# 9. ตรวจสอบ Network Connection
###############################################################################

print_header "9. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต"

echo -e "${YELLOW}🌐 Network Status:${NC}"

# ตรวจสอบ WiFi
wifi_info=$(dumpsys wifi | grep "mNetworkInfo" | head -1)
echo "   WiFi: $wifi_info"

# ตรวจสอบ Data Connection
data_info=$(dumpsys telephony.registry | grep "mDataConnectionState" | head -1)
echo "   Mobile Data: $data_info"

# ตรวจสอบ DNS
echo -e "\n${YELLOW}DNS Resolution:${NC}"
nslookup api.shopee.co.th 2>/dev/null | head -5

###############################################################################
# 10. ตรวจสอบ Memory
###############################################################################

print_header "10. ตรวจสอบ Memory Usage"

echo -e "${YELLOW}💾 Memory Info:${NC}"

# ทั้งระบบ
free -h | head -3

# แอปเฉพาะ
APP_MEM=$(dumpsys meminfo $APP_PACKAGE 2>/dev/null | grep "TOTAL" | awk '{print $2}')
if [ ! -z "$APP_MEM" ]; then
    print_success "Memory Usage ของแอป: ${CYAN}$APP_MEM KB${NC}"
fi

###############################################################################
# 11. ตรวจสอบ Network Requests
###############################################################################

print_header "11. ตรวจสอบ Network Connections"

echo -e "${YELLOW}🔗 Active Connections to Shopee:${NC}"
netstat -ant 2>/dev/null | grep -i "shopee\|api\.shopee" || echo "   ไม่พบการเชื่อมต่อ"

###############################################################################
# 12. ตรวจสอบ Battery Usage
###############################################################################

print_header "12. ตรวจสอบ Battery Usage"

echo -e "${YELLOW}🔋 Battery Info:${NC}"
dumpsys battery | grep -E "level|temperature|health|status"

###############################################################################
# 13. ตรวจสอบ Crash Reports
###############################################################################

print_header "13. ตรวจสอบ Crash Reports"

CRASH_DIR="/data/anr"
if [ -d "$CRASH_DIR" ]; then
    echo -e "${YELLOW}💥 ANR/Crash Files:${NC}"
    ls -lhrt "$CRASH_DIR" 2>/dev/null | tail -5
else
    print_info "ไม่พบ Crash Directory"
fi

###############################################################################
# 14. สรุปสถานะ
###############################################################################

print_header "14. สรุปผล"

echo -e "${CYAN}✅ ตรวจสอบเสร็จแล้ว${NC}\n"

echo "📋 สิ่งที่ควรตรวจสอบต่อ:"
echo "   1. ตรวจสอบ Logcat เพื่อหาข้อผิดพลาด"
echo "   2. ตรวจสอบว่าแอปกำลังทำงานหรือไม่"
echo "   3. ตรวจสอบการเชื่อมต่ออินเทอร์เน็ต"
echo "   4. ตรวจสอบ Battery ไม่ต่ำเกินไป"
echo "   5. ตรวจสอบ Memory ว่างพอหรือไม่"

echo -e "\n${YELLOW}📞 หากปัญหายังคงเกิดขึ้น:${NC}"
echo "   - ติดต่อ Shopee Support"
echo "   - ถอนและติดตั้งแอปใหม่"
echo "   - Factory Reset เครื่อง (ถ้าจำเป็น)"

print_header "สิ้นสุดการตรวจสอบ"

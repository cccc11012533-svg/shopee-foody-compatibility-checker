#!/bin/bash

###############################################################################
# Shopee Foody Drive Compatibility Checker for OPPO Reno6 Z 5G
# ตรวจสอบความเข้ากันได้ของแอป Shopee Foody Drive
###############################################################################

# สีสำหรับแสดงผล
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ฟังก์ชันแสดงหัวข้อ
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# ฟังก์ชันแสดงผลสำเร็จ
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# ฟังก์ชันแสดงข้อผิดพลาด
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# ฟังก์ชันแสดงคำเตือน
print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

###############################################################################
# เริ่มตรวจสอบ
###############################################################################

print_header "Shopee Foody Drive Compatibility Checker"
echo "เครื่อง: OPPO Reno6 Z 5G (ColorOS 13.0 / Android 13)"
echo ""

###############################################################################
# 1. ตรวจสอบ APK Manifest
###############################################################################

print_header "1. ตรวจสอบ APK Information"

APK_PATH="/data/app/com.shopee.foody.drive-*/base.apk"
APK_NAME="com.shopee.foody.drive"

if [ -f "$APK_PATH" ] 2>/dev/null; then
    print_success "พบแอป Shopee Foody Drive"
    
    # ดึงข้อมูล APK
    APK_VERSION=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "versionName" | cut -d"'" -f2)
    APK_SDK=$(aapt dump badging "$APK_PATH" 2>/dev/null | grep "sdkVersion" | cut -d"'" -f2)
    
    echo "   Package: $APK_NAME"
    echo "   Version: $APK_VERSION"
    echo "   Min SDK: $APK_SDK"
else
    print_warning "แอป Shopee Foody Drive ยังไม่ได้ติดตั้ง"
fi

###############################################################################
# 2. ตรวจสอบ Android Version
###############################################################################

print_header "2. ตรวจสอบเวอร์ชัน Android"

ANDROID_VERSION=$(getprop ro.build.version.release)
ANDROID_SDK=$(getprop ro.build.version.sdk)
DEVICE_MODEL=$(getprop ro.model)
DEVICE_BRAND=$(getprop ro.brand)

echo "Brand: $DEVICE_BRAND"
echo "Model: $DEVICE_MODEL"
echo "Android Version: $ANDROID_VERSION"
echo "SDK Level: $ANDROID_SDK"

# ตรวจสอบความเข้ากันได้
if [ "$ANDROID_SDK" -ge 21 ]; then
    print_success "Android version เข้ากันได้ (ต้องการ SDK 21+)"
else
    print_error "Android version ไม่เข้ากันได้ (ต้องการ SDK 21+)"
fi

###############################################################################
# 3. ตรวจสอบ RAM
###############################################################################

print_header "3. ตรวจสอบ RAM"

TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
AVAILABLE_RAM=$(free -h | awk '/^Mem:/ {print $7}')

echo "Total RAM: $TOTAL_RAM"
echo "Available RAM: $AVAILABLE_RAM"

if [ $(echo "$AVAILABLE_RAM" | cut -d'G' -f1) -ge 2 ]; then
    print_success "RAM เพียงพอสำหรับแอป (ต้องการ 2GB+)"
else
    print_warning "RAM อาจไม่เพียงพอ (แนะนำ 2GB+)"
fi

###############################################################################
# 4. ตรวจสอบ Storage
###############################################################################

print_header "4. ตรวจสอบพื้นที่จัดเก็บ"

STORAGE_TOTAL=$(df /data | awk 'NR==2 {print $2}')
STORAGE_USED=$(df /data | awk 'NR==2 {print $3}')
STORAGE_AVAILABLE=$(df /data | awk 'NR==2 {print $4}')

STORAGE_TOTAL_GB=$(echo "scale=2; $STORAGE_TOTAL / 1048576" | bc)
STORAGE_AVAILABLE_GB=$(echo "scale=2; $STORAGE_AVAILABLE / 1048576" | bc)

echo "Total Storage: ${STORAGE_TOTAL_GB} GB"
echo "Available Storage: ${STORAGE_AVAILABLE_GB} GB"

if (( $(echo "$STORAGE_AVAILABLE_GB > 1" | bc -l) )); then
    print_success "พื้นที่จัดเก็บเพียงพอ (ต้องการ 1GB+)"
else
    print_error "พื้นที่จัดเก็บไม่เพียงพอ (ต้องการ 1GB+)"
    echo "   ⚠ ลองลบไฟล์ที่ไม่ใช้เพื่อเพิ่มพื้นที่ว่าง"
fi

###############################################################################
# 5. ตรวจสอบสิทธิ์แอป
###############################################################################

print_header "5. ตรวจสอบสิทธิ์แอป (Permissions)"

echo "ตรวจสอบสิทธิ์ที่จำเป็น:"
echo ""

# ฟังก์ชันตรวจสอบสิทธิ์
check_permission() {
    local perm=$1
    local perm_name=$2
    
    if pm list permissions -u | grep -q "$perm"; then
        print_success "$perm_name: ได้รับอนุญาต"
    else
        print_warning "$perm_name: ยังไม่ได้รับอนุญาต"
    fi
}

check_permission "android.permission.ACCESS_FINE_LOCATION" "Location (GPS)"
check_permission "android.permission.POST_NOTIFICATIONS" "Notifications"
check_permission "android.permission.INTERNET" "Internet"
check_permission "android.permission.ACCESS_NETWORK_STATE" "Network Access"

###############################################################################
# 6. ตรวจสอบ CPU/Processor
###############################################################################

print_header "6. ตรวจสอบ CPU Information"

CPU_ABI=$(getprop ro.product.cpu.abi)
CPU_CORES=$(nproc)

echo "CPU ABI: $CPU_ABI"
echo "CPU Cores: $CPU_CORES"

if [ "$CPU_CORES" -ge 4 ]; then
    print_success "CPU ทรงพลังเพียงพอ ($CPU_CORES cores)"
else
    print_warning "CPU cores ค่อนข้างน้อย ($CPU_CORES cores)"
fi

###############################################################################
# 7. ตรวจสอบ Battery
###############################################################################

print_header "7. ตรวจสอบแบตเตอรี่"

BATTERY_LEVEL=$(cat /sys/class/power_supply/battery/capacity 2>/dev/null || echo "Unknown")
BATTERY_STATUS=$(cat /sys/class/power_supply/battery/status 2>/dev/null || echo "Unknown")

echo "Battery Level: $BATTERY_LEVEL%"
echo "Battery Status: $BATTERY_STATUS"

if [ "$BATTERY_LEVEL" -gt 20 ]; then
    print_success "แบตเตอรี่เพียงพอ (มากกว่า 20%)"
else
    print_warning "แบตเตอรี่ต่ำ ควรชาร์จเพิ่ม"
fi

###############################################################################
# 8. ตรวจสอบการเชื่อมต่อเน็ต
###############################################################################

print_header "8. ตรวจสอบการเชื่อมต่อเน็ต"

# ตรวจสอบการเชื่อมต่อ
if ping -c 1 8.8.8.8 &> /dev/null; then
    print_success "อินเทอร์เน็ตเชื่อมต่อได้"
else
    print_error "ไม่สามารถเชื่อมต่ออินเทอร์เน็ต"
fi

###############################################################################
# 9. ส่วนแนะนำ
###############################################################################

print_header "9. คำแนะนำการแก้ไข"

echo "หากแอป Shopee Foody Drive ยังไม่ทำงาน ลองทำดังนี้:"
echo ""
echo "1. ล้างแคช:"
echo "   $ adb shell pm clear com.shopee.foody.drive"
echo ""
echo "2. รีสตาร์ตแอป:"
echo "   $ adb shell am force-stop com.shopee.foody.drive"
echo ""
echo "3. ตรวจสอบ log:"
echo "   $ adb logcat | grep foody"
echo ""
echo "4. ถอนและติดตั้งใหม่:"
echo "   $ adb uninstall com.shopee.foody.drive"
echo ""
echo "5. ปิด VPN/Proxy และลองใหม่"
echo ""

###############################################################################
# 10. สรุปผล
###############################################################################

print_header "10. สรุปผลการตรวจสอบ"

echo "✓ ตรวจสอบเสร็จแล้ว"
echo ""
echo "หากยังมีปัญหา โปรดติดต่อ Shopee Support ที่:"
echo "- Shopee Help Center: help.shopee.co.th"
echo "- Chat support ผ่านแอป Shopee"
echo ""

print_header "สิ้นสุดการตรวจสอบ"

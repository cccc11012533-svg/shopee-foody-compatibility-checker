#!/bin/bash

# Shopee Foody Driver - Quick Version Check
APP="com.shopee.foody.driver.th"

echo "🔍 ตรวจสอบ: $APP"
echo ""

# เช็ค version
dumpsys package $APP | grep versionName

# เช็ค status
pm list packages | grep -q $APP && echo "✅ ติดตั้งแล้ว" || echo "❌ ไม่ติดตั้ง"

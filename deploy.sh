#!/bin/bash

# Dừng mã nếu có lỗi xảy ra
set -e
echo "🚀 Cấp quyền cho toàn bộ hình ảnh và dữ liệu..."
chmod -R 755 assets
chmod -R 755 web

echo "🚀 Bắt đầu build ứng dụng Flutter Web..."

# Build bản release
# flutter build web --release
flutter build web --release

echo "✅ Build thành công! Đang đẩy lên Vercel..."

# Lệnh deploy của Vercel (chỉ trỏ vào thư mục build web)
# Sử dụng bộ chứng chỉ hệ thống để giải quyết lỗi "unable to get local issuer certificate"
export NODE_EXTRA_CA_CERTS=/etc/ssl/cert.pem
vercel --prod build/web

echo "🎉 Bùm! Deploy đã hoàn tất. App của bạn đã live!"

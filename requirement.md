# Yêu cầu Dự án: Tarot Web App (Flutter)

## 1. Tổng quan Dự án (Project Overview)
- **Mục tiêu:** Xây dựng một ứng dụng web xem bài Tarot đơn giản, tối ưu cho giao diện mobile (Mobile-first Web App) sử dụng framework Flutter.
- **Dữ liệu:** Sử dụng bộ dataset cục bộ bao gồm:
  - File `tarot-images.json`: Chứa dữ liệu chi tiết của 78 lá bài (Tên, keyword, fortune telling, light/shadow meaning, v.v.).
  - Thư mục `cards/`: Chứa 78 hình ảnh tương ứng (Kích thước mỗi ảnh 350x600px, tổng dung lượng khoảng 7.37MB).

## 2. Các Tính năng chính (Key Features)

### 2.1. Giao diện (UI/UX)
- **Chuẩn Mobile-first:** Giao diện responsive, lướt mượt mà và hiển thị hoàn hảo trên các kích thước màn hình điện thoại khi chạy trên trình duyệt web.
- **Theme/Aesthetics:** Mang phong cách bí ẩn, huyền bí (Khuyến nghị: Dark theme, nền gradient tối màu như tím đậm vũ trụ, xanh đen, kết hợp ánh sáng mờ/glow hắt ra từ các lá bài).
- **Trải nghiệm mượt mà (Animations):**
  - Hiệu ứng rải bài (Fan spread hoặc dàn bài ra màn hình).
  - Hiệu ứng lật bài (3D Flip Animation) chân thực, mượt mà (60fps).
  - Transition mượt khi chuyển từ màn hình rút bài sang màn hình luận giải chi tiết.

### 2.2. Chọn Hình thức Trải bài (Card Spreads)
Người dùng có thể chọn số lượng bài để rút theo các nhu cầu khác nhau:
1. **Rút 1 lá (One-Card Draw):** Dành cho câu hỏi nhanh, thông điệp trong ngày, hoặc xem lời khuyên tổng quan.
2. **Rút 3 lá (Past/Present/Future):** Trải bài thông dụng cho Quá khứ - Hiện tại - Tương lai.
*(Có thể nâng cấp chèn thêm trải bài 5 lá hoặc Celtic Cross 10 lá trong tương lai, nhưng MVP sẽ tập trung vào 1 lá và 3 lá).*

### 2.3. Logic Rút Bài
- Hiển thị mô phỏng một cỗ bài 78 lá đang úp mặt.
- Áp dụng logic ngẫu nhiên (Random) để đảm bảo không lá bài nào bị rút trùng lặp trong một phiên xem.
- Người dùng chạm (tap) vào các lá bài ngẫu nhiên đang úp để chọn. 
- Sau khi chọn đủ số lượng, tự động chuyển giao diện hoặc có nút xác nhận để tiến hành "Lật bài".

### 2.4. Luận Giải Đa Dạng (Interpretations)
Khi lật bài, hiển thị chi tiết các luồng thông tin phong phú của lá bài dựa vào JSON:
- Tên lá bài (Name) & Ảnh lá bài (Image).
- Số (Number) & Loại thứ bậc (Major/Minor Arcana), Chất (Suit).
- **Fortune Telling:** Cụm từ tiên đoán ngắn gọn, dễ hiểu.
- **Keywords:** Các từ khóa chính.
- **Meanings (Light & Shadow):** 
  - Nghĩa Sáng (Tích cực/Thuận).
  - Nghĩa Tối (Tiêu cực/Nghịch/Lời Cảnh báo).
- **Câu hỏi tự gẫm (Questions to Ask):** Giúp người xem liên hệ vào chính cuộc sống của họ.
*(UI phần đọc luận giải cần sắp xếp dưới dạng thẻ Card hoặc Accordion/Tabs để không bị ngợp chữ trên màn hình nhỏ).*

## 3. Kiến trúc kỹ thuật dự kiến (Technical Notes)
- **Quản lý trạng thái (State Management):** Dùng `Provider`, `Riverpod` hoặc standard `Bloc`/`Cubit` để quản lý luồng dữ liệu Load thẻ bài -> Cỗ bài khả dụng -> Bài đã rút.
- **Xử lý Dữ liệu:** 
  - Parse `tarot-images.json` thành các class Model (ví dụ `TarotCard`).
  - Toàn bộ assets (thêm `assets/data/` và `assets/images/`) cần được khai báo trong `pubspec.yaml`.
- **Hiệu năng Web (Performance):** 
  - Pre-cache các ảnh quan trọng hoặc hiển thị placeholder/shimmer loading trong lúc đợi lật bài.
  - Cấu trúc lại file HTML (`web/index.html`) để tối ưu hóa loading trên web điện thoại và hỗ trợ kích hoạt PWA (Progressive Web App) sau này.

## 4. Các bước triển khai (Implementation Phases)
1. **Setup:** Copy files dataset vào thư mục `assets`. Khởi tạo Model classes. Check parse JSON load lên list dữ liệu.
2. **Scaffold UI:** Code các giao diện khung (Home, Màn hình Chọn Bài, Màn hình Kết Quả), setup routing an toàn.
3. **Core logic & Animations:** Xây dựng widget lật bài (Flip Card Widget), logic random rút bài và điều phối danh sách bài rút.
4. **Detail UI:** Trình bày đẹp mắt màn hình Luận giải.
5. **Testing & Tuning:** Kiểm tra trên Mobile Browser, tối ưu CSS/Web render, chèn thêm logic PWA.

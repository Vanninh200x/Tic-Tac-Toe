# Estimate — Flutter Board Game

## Tóm tắt

Game bàn cờ 2D viết bằng Flutter, với game engine thuần Dart, chơi hai người trên cùng thiết bị, chơi với AI và đấu trực tiếp qua Bluetooth. Bàn cờ hỗ trợ kích thước 3×3, 5×5, 15×15, 20×20 và kích thước tùy chỉnh; luật thắng được cấu hình theo số quân liên tiếp.

Ước lượng thời gian bên dưới là **ngày công của một lập trình viên Flutter có kinh nghiệm**; kết nối Bluetooth cần được xác nhận trên thiết bị Android thật.

## Phạm vi dự kiến

- App Flutter mới, tách riêng khỏi dự án Unity hiện có trong workspace.
- Android là nền tảng ưu tiên; build và kiểm tra Android App Bundle (`.aab`).
- Màn hình menu, bàn cờ, cài đặt và kết quả ván đấu.
- Chế độ hai người chơi trên cùng thiết bị.
- Chế độ người chơi đấu với AI:
  - Minimax cho bàn nhỏ.
  - Alpha-beta pruning và heuristic cho bàn lớn, có giới hạn thời gian tính nước đi.
- Bàn cờ được vẽ bằng `CustomPainter`, hỗ trợ chạm chọn ô, kéo và zoom.
- Cài đặt và thống kê cơ bản lưu cục bộ bằng SharedPreferences.
- Unit test cho luật, kiểm tra nước đi, phát hiện thắng/hòa và các trường hợp biên.
- Chế độ Bluetooth Classic trực tiếp qua RFCOMM, không cần Internet; kiểm thử liên thiết bị cần hai điện thoại Android thật.

## Ngoài phạm vi

- Quảng cáo và Google Mobile Ads.
- Analytics.
- Chơi trực tuyến qua Internet, máy chủ, tài khoản người dùng hoặc matchmaking.
- Thiết kế đồ họa/animation cao cấp, âm thanh, localization nhiều ngôn ngữ.
- Phát hành và vận hành dịch vụ backend.
- Đảm bảo mọi kích thước bàn cờ đều có thể chạy AI ở độ khó cao. Bàn lớn cần giới hạn độ sâu/thời gian hoặc dùng heuristic.

## Ước lượng theo hạng mục

| Hạng mục | Ước lượng |
|---|---:|
| Chốt luật, luồng màn hình và tiêu chí nghiệm thu | 1–2 ngày |
| Khởi tạo app Flutter, cấu trúc thư mục và điều hướng | 1–2 ngày |
| Game domain thuần Dart và unit test | 3–5 ngày |
| Vẽ bàn cờ, xử lý tọa độ chạm, pan và zoom | 3–5 ngày |
| Menu, cài đặt, giao diện ván đấu và kết quả | 2–4 ngày |
| AI cho bàn nhỏ/lớn, tinh chỉnh thời gian và độ khó | 3–6 ngày |
| Lưu cài đặt và thống kê cơ bản | 1–2 ngày |
| Kiểm thử tích hợp, sửa lỗi và hoàn thiện trải nghiệm | 2–4 ngày |
| Cấu hình Android và xác minh build `.aab` | 1–2 ngày |
| **Tổng phần cốt lõi (chưa gồm Bluetooth)** | **17–32 ngày** |

Các khoảng trên là ngày công và có thể chồng lấn giữa một số hạng mục sau khi game domain và giao diện đã ổn định.

## Bluetooth trực tiếp — RFCOMM

Ứng dụng có luồng tạo phòng và tham gia phòng bằng Bluetooth Classic RFCOMM. Máy chủ phát dịch vụ Boardly với UUID riêng; máy khách tìm thiết bị, ghép đôi khi cần, kết nối bảo mật và nhận cấu hình bàn từ máy chủ. Nước đi, lượt hiện tại và lệnh chơi lại được đồng bộ qua kết nối trực tiếp, không dùng Wi-Fi, Internet hay backend.

| Phương án | Phạm vi | Ước lượng bổ sung |
|---|---|---:|
| Kết nối trực tiếp, không cần Internet | RFCOMM, ghép đôi/kết nối, đồng bộ nước đi và xử lý mất kết nối | 5–10 ngày |
| Chơi từ xa qua Internet | Thiết kế backend hoặc dịch vụ realtime, đồng bộ trạng thái, xử lý reconnect và kiểm thử mạng | 10–18 ngày trở lên |

Máy chủ cần chấp nhận hộp thoại hệ thống để hiển thị Bluetooth trong tối đa 5 phút. Hai điện thoại nên được ghép đôi trong cài đặt Bluetooth nếu không nhìn thấy nhau; Android 11 trở xuống còn yêu cầu bật dịch vụ vị trí khi quét. Bluetooth Classic server mode không được hỗ trợ trên iOS trong plugin hiện tại; tính năng này nhắm tới Android. Chơi từ xa không phải là Bluetooth và cần một kiến trúc mạng riêng.

## Tổng kế hoạch tham khảo

- **Bản cốt lõi, không có Bluetooth:** 17–32 ngày công.
- **Bản cốt lõi + kết nối trực tiếp:** 22–42 ngày công.
- **Bản cốt lõi + chơi từ xa:** từ 27–50 ngày công, chưa bao gồm thời gian/cost vận hành backend.
- Với một lập trình viên làm toàn thời gian, bản cốt lõi tương đương khoảng **4–7 tuần lịch**. Bluetooth trực tiếp có thể nâng tổng thời gian lên khoảng **5–9 tuần**; đây là ước lượng lập kế hoạch, không phải cam kết ngày phát hành.

Tham khảo :


https://play.google.com/store/apps/details?id=uk.co.aifactory.tictactoe


https://play.google.com/store/apps/details?id=onetap.game.tictactoe


<img width="645" height="642" alt="image" src="https://github.com/user-attachments/assets/cc275768-6fbd-4f2c-9cc8-59173fb90cfd" />
<img width="2027" height="1440" alt="image" src="https://github.com/user-attachments/assets/e5eadea8-8dc6-4f36-8149-d8df6bd24cb7" />


## Rủi ro và điều kiện ảnh hưởng estimate

1. **Luật game chưa được chốt đầy đủ:** cần xác định số quân liên tiếp để thắng, luật áp dụng cho từng kích thước bàn, điều kiện hòa và việc có cấm nước đi hay không.
2. **AI bàn lớn:** độ khó và thời gian phản hồi phụ thuộc kích thước bàn, số quân thắng, thuật toán và thiết bị. Cần thống nhất mức độ AI chấp nhận được.
3. **“Không giới hạn” kích thước bàn:** có thể hỗ trợ kích thước tùy chỉnh, nhưng hiệu năng và UX không thể cam kết không giới hạn tuyệt đối. Cần đặt giới hạn thực tế sau khi đo trên thiết bị mục tiêu.
4. **Bluetooth:** plugin và quyền truy cập khác nhau theo phiên bản Android; cần prototype sớm trước khi cam kết estimate triển khai.
5. **Phát hành Google Play:** estimate chỉ tính cấu hình và kiểm tra artifact `.aab`, không tính thời gian xét duyệt của Google hoặc công việc pháp lý/tài khoản nhà phát triển.

## Thứ tự triển khai đề xuất

1. Chốt luật game, phạm vi Android và tiêu chí nghiệm thu.
2. Xây dựng game engine thuần Dart và unit test.
3. Làm UI bàn cờ, menu, cài đặt và kết quả.
4. Thêm AI; đo thời gian phản hồi ở các kích thước bàn mục tiêu.
5. Thêm chế độ hai người cùng thiết bị và lưu cài đặt/thống kê.
6. Kiểm thử ghép đôi, tạo phòng, đồng bộ lượt và khôi phục sau ngắt kết nối trên hai điện thoại Android thật.
7. Kiểm thử hồi quy và tạo Android App Bundle.

> Estimate này là bản sơ bộ dựa trên mô tả hiện tại. Các hạng mục Bluetooth, luật cụ thể và mức độ AI cần được xác nhận trước khi chốt kế hoạch phát hành.

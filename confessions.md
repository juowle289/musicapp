# Hướng dẫn xây dựng App "Góc hóng drama DNU" (Student Confessions)
**Công nghệ:** Flutter + Firebase Cloud Firestore (Realtime)

---

## 🏗️ Phần 1: Thiết lập Firebase Console (Trên Web)

1.  Truy cập [Firebase Console](https://console.firebase.google.com/) và đăng nhập tài khoản Google.
2.  Nhấn **Create a project** (Tạo dự án).
    * Đặt tên: `StudentConfessions`.
    * Google Analytics: Tắt đi cho đỡ rối (hoặc để mặc định).
    * Nhấn **Create project**.
3.  **Tạo Database:**
    * Ở menu bên trái, chọn **Build** -> **Firestore Database**.
    * Nhấn **Create database**.
    * **Quan trọng:** Chọn **Start in Test Mode** (Chế độ kiểm thử).
        > *Lưu ý: Chế độ này cho phép mọi người đọc/ghi dữ liệu trong 30 ngày. Rất tiện để Demo mà không lo lỗi quyền truy cập.*
    * Chọn Location (Vị trí máy chủ): Chọn `asia-southeast1` (Singapore) cho gần Việt Nam để tốc độ nhanh nhất.
    * Nhấn **Enable**.

---

## 🛠️ Phần 2: Khởi tạo Project Flutter (Trên máy tính)

Mở Terminal (hoặc CMD/PowerShell) tại thư mục bạn muốn lưu code:

```bash
# 1. Tạo dự án mới
flutter create student_confessions

# 2. Đi vào thư mục dự án
cd student_confessions

# 3. Cài đặt các thư viện cần thiết
flutter pub add firebase_core cloud_firestore

```

**Cấu hình Android (Bắt buộc để tránh lỗi):**
Mở file `android/app/build.gradle`. Tìm dòng `minSdkVersion` và sửa thành **21** (vì Firebase yêu cầu Android 5.0 trở lên):


``
`gradle
defaultConfig {
    // ...
    minSdkVersion 21  // Sửa số cũ thành 21
    // ...
}

```

---

## 🔌 Phần 3: Kết nối Flutter với Firebase

- Sử dụng `FlutterFire CLI`.

**Bước 1: Cài công cụ**
Cài firebase tools
```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli

```

**Bước 2: Đăng nhập và Cấu hình**
Tại thư mục dự án (`student_confessions`), chạy lần lượt:

```bash
# 1. Đăng nhập Google 
firebase login

# 2. Tự động cấu hình và liên kết
flutterfire configure

```
* Khi được hỏi chọn Project: Chọn `StudentConfessions` (vừa tạo ở Phần 1).
* Khi được hỏi chọn Platform: Dùng phím mũi tên và phím cách (Space) để chọn **Android** và **iOS**, **Web**. Nhấn Enter.
* *Kết quả:* tạo ra file `lib/firebase_options.dart`.

---

## 💻 Phần 4: Viết Code 
Mở file `lib/main.dart`, xóa toàn bộ code cũ và thay thế bằng code sau.

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart'; // File được sinh ra ở bước cấu hình

void main() async {
  // BẮT BUỘC: Đảm bảo Flutter binding đã sẵn sàng trước khi gọi Firebase
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase với cấu hình tự động
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange, // Màu chủ đạo nổi bật
        useMaterial3: true,
      ),
      home: const ConfessionPage(),
    );
  }
}

class ConfessionPage extends StatefulWidget {
  const ConfessionPage({super.key});

  @override
  State<ConfessionPage> createState() => _ConfessionPageState();
}

class _ConfessionPageState extends State<ConfessionPage> {
  final TextEditingController _controller = TextEditingController();
  
  // Tạo kết nối đến Collection 'confessions' trên Cloud
  final CollectionReference _confessionsRef =
      FirebaseFirestore.instance.collection('confessions');

  // --- CHỨC NĂNG 1: ĐĂNG BÀI (CREATE) ---
  void _postConfession() {
    if (_controller.text.trim().isEmpty) return;

    _confessionsRef.add({
      'content': _controller.text,
      'likes': 0,
      // Dùng serverTimestamp để lấy giờ chuẩn của Google (tránh sai giờ máy khách)
      'timestamp': FieldValue.serverTimestamp(), 
    });

    _controller.clear();
    Navigator.of(context).pop(); // Đóng dialog
  }

  // --- CHỨC NĂNG 2: THẢ TIM (UPDATE) ---
  void _likePost(String docId) {
    // Dùng increment(1) để tăng số an toàn trong môi trường Realtime
    _confessionsRef.doc(docId).update({
      'likes': FieldValue.increment(1),
    });
  }

  // Hiển thị hộp thoại nhập
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Góc Hóng Biến 🤫"),
        content: TextField(
          controller: _controller,
          decoration: const InputDecoration(
            hintText: "Bạn đang nghĩ gì? (Ẩn danh)",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Hủy"),
          ),
          FilledButton(
            onPressed: _postConfession,
            child: const Text("Đăng bài"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🔥 Student Confessions"),
        centerTitle: true,
        backgroundColor: Colors.deepOrange.shade100,
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        label: const Text("Đăng bài"),
        icon: const Icon(Icons.edit),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),

      // --- CHỨC NĂNG 3: HIỂN THỊ REALTIME (READ) ---
      body: StreamBuilder<QuerySnapshot>(
        // Lắng nghe dữ liệu, sắp xếp mới nhất lên đầu
        stream: _confessionsRef.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          // 1. Xử lý lỗi
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }
          // 2. Xử lý khi đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.requireData;

          // 3. Hiển thị danh sách trống
          if (data.size == 0) {
            return const Center(
              child: Text("Chưa có biến nào. Hãy là người đầu tiên!", 
              style: TextStyle(color: Colors.grey)),
            );
          }

          // 4. Hiển thị dữ liệu
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: data.size,
            itemBuilder: (context, index) {
              var post = data.docs[index];
              var content = post['content'];
              var likes = post['likes'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.primaries[index % Colors.primaries.length],
                            child: const Icon(Icons.person_outline, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          const Text("Người giấu tên", style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(content, style: const TextStyle(fontSize: 16)),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _likePost(post.id),
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            label: Text(
                              "$likes Lượt thả tim",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

```

---

## 🚀 Phần 5: Chạy thử và Demo

1. Kết nối thiết bị thật hoặc bật máy ảo Android/iOS.
2. Chạy lệnh:
```bash
flutter run

```

3. **Kịch bản Demo:**
* **Bước 1:** Mở App trên 2 thiết bị khác nhau (ví dụ: 1 máy ảo, 1 máy thật hoặc chạy thêm bản Web bằng lệnh `flutter run -d chrome`).
* **Bước 2:** Trên máy A, nhấn nút "Đăng bài" -> Nhập "Hello mọi người".
* **Bước 3:** Quan sát máy B -> Status xuất hiện ngay lập tức (Realtime).
* **Bước 4:** Trên máy B, bấm "Thả tim" liên tục -> Số like trên máy A nhảy số theo.



---

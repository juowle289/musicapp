# 🎵 MusicApp - Melodies in your Pocket

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" />
  <img src="https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white" />
</p>

MusicApp là một ứng dụng nghe nhạc hiện đại được xây dựng bằng **Flutter**, tích hợp **Cloud Firestore** để đồng bộ hóa dữ liệu và **SQLite** để tối ưu hóa trải nghiệm người dùng offline. Ứng dụng sở hữu giao diện kết hợp giữa phong cách Cupertino mượt mà và Material Design 3 hiện đại với các hiệu ứng đổ bóng mềm mại.

---

### ✨ Tính năng nổi bật

* **Trình phát nhạc thông minh**: Hỗ trợ phát, tạm dừng, tua nhanh/chậm 10 giây và điều chỉnh âm lượng trực quan thông qua `MusicProvider`.
* **Tìm kiếm đa năng**: Tìm kiếm bài hát và playlist theo thời gian thực với giao diện tối ưu hóa cho cả Dark Mode và Light Mode.
* **Quản lý yêu thích**: Lưu giữ những bản nhạc yêu thích cá nhân hóa theo từng tài khoản người dùng.
* **Đồng bộ đám mây**: Sử dụng Firebase để bảo mật tài khoản và Firestore để lưu trữ dữ liệu bài hát vĩnh viễn.
* **Giao diện nghệ thuật**: MiniPlayer với đĩa xoay Vinyl lấp lánh và hiệu ứng đổ bóng Gradient theo màu sắc album.

---

### 📸 Ảnh chụp màn hình

<p align="center">
  <img src="https://via.placeholder.com/200x400?text=Search+Page" width="230" alt="Search Page" /> 
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="https://via.placeholder.com/200x400?text=Player+Page" width="230" alt="Player Page" />
</p>

---

### 🛠 Công nghệ sử dụng

* **Frontend**: Flutter & Dart.
* **State Management**: Provider (`MultiProvider`, `Consumer`).
* **Audio Engine**: `audioplayers` xử lý phát nhạc và điều khiển âm thanh.
* **Backend**: Firebase (Auth, Firestore, Storage).
* **Local DB**: SQLite (`sqflite`).

---

### 🚀 Cài đặt và Chạy thử

1.  **Clone dự án**:
    ```bash
    git clone [https://github.com/juowle289/musicapp.git](https://github.com/juowle289/musicapp.git)
    ```

2.  **Cài đặt dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Cấu hình Firebase**:
    * Thêm file `google-services.json` vào thư mục `android/app/`.

4.  **Chạy ứng dụng**:
    ```bash
    flutter run
    ```

---

### 📝 Cấu trúc thư mục chính

* `lib/datas/providers/`: Quản lý logic phát nhạc (`MusicProvider`) và trạng thái ứng dụng.
* `lib/presentation/pages/`: Chứa giao diện các trang như Tìm kiếm (`SearchPage`) và Chi tiết bài hát.
* `lib/datas/models/`: Định nghĩa cấu trúc dữ liệu cho `Song` và `Playlist`.
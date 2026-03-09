import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  bool _isLoading = true;
  String? _errorMessage;

  static const String _emailKey = "userEmail";
  static const String _isLoggedInKey = "isLoggedIn";

  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadAuthFromPrefs();
    _checkCurrentUser();
  }

  // Kiểm tra user hiện tại từ Firebase
  void _checkCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _isAuthenticated = true;
      _userEmail = user.email;
    }
    _isLoading = false;
    notifyListeners();
  }

  // Tải thông tin auth từ bộ nhớ
  Future<void> _loadAuthFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool(_isLoggedInKey) ?? false;
    _userEmail = prefs.getString(_emailKey);
    _isLoading = false;
    notifyListeners();
  }

  // Đăng nhập bằng Firebase
  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isAuthenticated = true;
      _userEmail = credential.user?.email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  // Đăng ký bằng Firebase
  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      _isAuthenticated = true;
      _userEmail = credential.user?.email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, true);
      await prefs.setString(_emailKey, email);

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      
      _isAuthenticated = false;
      _userEmail = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isLoggedInKey, false);
      await prefs.remove(_emailKey);

      notifyListeners();
    } catch (e) {
      // Xử lý lỗi đăng xuất
    }
  }

  // Chuyển đổi mã lỗi Firebase sang thông báo tiếng Việt
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'invalid-email':
        return 'Email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu phải có ít nhất 6 ký tự.';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng thử lại sau.';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng.';
      default:
        return 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }

  // Xóa thông báo lỗi
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

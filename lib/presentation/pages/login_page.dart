import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    show Brightness, Colors, LinearGradient, Alignment, BoxShadow, Scaffold;
import 'package:provider/provider.dart';
import 'package:musicapp/datas/providers/auth_provider.dart';
import 'package:musicapp/datas/providers/theme_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (_isSignUp && password != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu không khớp');
      return;
    }

    if (password.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 6 ký tự');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();

    try {
      if (_isSignUp) {
        await authProvider.signUp(email, password);
      } else {
        await authProvider.signIn(email, password);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDarkMode = themeProvider.isDarkMode;
        final darkBackground = const Color(0xFF121212);

        return Scaffold(
          backgroundColor: isDarkMode ? darkBackground : Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // const SizedBox(height: 60),

                    // Logo/Icon
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDarkMode
                                ? [
                                    const Color(0xFFFEEC93),
                                    const Color(0xFFE6C84A),
                                  ]
                                : [Colors.black, Colors.grey[800]!],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  (isDarkMode
                                          ? const Color(0xFFFEEC93)
                                          : Colors.black)
                                      .withValues(alpha: 0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.music_note_2,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Title
                    Text(
                      _isSignUp ? 'Tạo tài khoản' : 'Chào mừng trở lại',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : CupertinoColors.label,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _isSignUp
                          ? 'Đăng ký để sử dụng ứng dụng'
                          : 'Đăng nhập để tiếp tục',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode
                            ? Colors.grey[400]
                            : CupertinoColors.systemGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 30),

                    // Email field
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      placeholder: 'Nhập email của bạn',
                      isDarkMode: isDarkMode,
                      keyboardType: TextInputType.emailAddress,
                    ),

                    const SizedBox(height: 20),

                    // Password field
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      placeholder: 'Nhập mật khẩu',
                      isDarkMode: isDarkMode,
                      obscureText: true,
                    ),

                    // Confirm password field (only for sign up)
                    if (_isSignUp) ...[
                      const SizedBox(height: 20),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Xác nhận mật khẩu',
                        placeholder: 'Nhập lại mật khẩu',
                        isDarkMode: isDarkMode,
                        obscureText: true,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit button
                    SizedBox(
                      height: 56,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        color: isDarkMode
                            ? const Color(0xFFFEEC93)
                            : Colors.black,
                        borderRadius: BorderRadius.circular(28),
                        onPressed: _isLoading ? null : _submit,
                        child: _isLoading
                            ? CupertinoActivityIndicator(
                                color: isDarkMode ? Colors.black : Colors.white,
                              )
                            : Text(
                                _isSignUp ? 'Đăng ký' : 'Đăng nhập',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.black
                                      : Colors.white,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Toggle sign in/sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp
                              ? 'Đã có tài khoản? '
                              : 'Chưa có tài khoản? ',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[400]
                                : CupertinoColors.systemGrey,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _errorMessage = null;
                            });
                          },
                          child: Text(
                            _isSignUp ? 'Đăng nhập' : 'Đăng ký',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isDarkMode
                                  ? const Color(0xFFFEEC93)
                                  : CupertinoColors.activeBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required bool isDarkMode,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDarkMode ? Colors.grey[400] : CupertinoColors.systemGrey,
          ),
        ),
        const SizedBox(height: 7),
        CupertinoTextField(
          controller: controller,
          placeholder: placeholder,
          keyboardType: keyboardType,
          obscureText: obscureText,
          placeholderStyle: TextStyle(
            color: isDarkMode
                ? Colors.grey[500]
                : CupertinoColors.placeholderText,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : CupertinoColors.systemGrey6,
            borderRadius: BorderRadius.circular(12),
          ),
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white : CupertinoColors.label,
          ),
        ),
      ],
    );
  }
}

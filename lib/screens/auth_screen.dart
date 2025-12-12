

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'list_screen.dart'; 
import '../core/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isRegisterMode = false;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.dangerRed,
        ),
      );
    }
  }

  void _submitAuthForm() async {
    final isValid = _formKey.currentState?.validate();
    if (isValid != true) return;

    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        // Реєстрація
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // Вхід
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const ListScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Виникла помилка. Спробуйте ще раз.';
      if (e.code == 'weak-password') {
        message = 'Пароль занадто слабкий.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Акаунт з такою поштою вже існує.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Неправильний email або пароль.';
      }
      _showErrorSnackBar(message);
    } catch (e) {
      //_showErrorSnackBar('Невідома помилка. Спробуйте пізніше.');
      print('!!!!!! FIREBASE AUTH ERROR: $e'); 
      _showErrorSnackBar('Помилка входу. Деталі в консолі.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _googleSignIn() async {
  setState(() => _isLoading = true);
  try {
    // 1. Створюємо екземпляр GoogleSignIn з Web Client ID
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: '605329036211-5m29vrnrupachsn7dmsku1i31ug8sg4q.apps.googleusercontent.com',
    );

    // 2. Ініціюємо процес входу
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // 3. Якщо користувач скасував вхід, виходимо з функції
    if (googleUser == null) { 
      setState(() => _isLoading = false);
      return;
    }

    // 4. Отримуємо токени автентифікації від Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // 5. Створюємо облікові дані для Firebase на основі токенів Google
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 6. Виконуємо вхід у Firebase з цими обліковими даними
    await FirebaseAuth.instance.signInWithCredential(credential);
    
    // 7. Якщо все успішно, переходимо на головний екран
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ListScreen()),
      );
    }
  } catch (e) {
    print('!!!!!! FIREBASE GOOGLE SIGN IN ERROR: $e'); 
    _showErrorSnackBar('Помилка входу через Google. Спробуйте ще раз.');
  } finally {
     if (mounted) setState(() => _isLoading = false);
  }
}
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      body: Center(
        child: SingleChildScrollView( 
          child: ConstrainedBox( 
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4.0, 
              shadowColor: Colors.black.withOpacity(0.05),
              color: AppColors.cardWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const FaIcon(FontAwesomeIcons.bagShopping, color: AppColors.textDark, size: 56),
                        const SizedBox(height: 16),
                        Text(
                          _isRegisterMode ? 'Створення акаунту' : 'Вхід в акаунт',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        const Text('Менеджер покупок — SH-2025-V14', style: TextStyle(color: AppColors.textDark)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_isRegisterMode)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: CustomTextField(
                                controller: _nameController,
                                labelText: "Ваше ім'я",
                                hintText: "Дарина",
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Будь ласка, введіть ваше ім'я.";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          CustomTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            hintText: 'email@example.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || !value.contains('@') || !value.contains('.')) {
                                return 'Будь ласка, введіть коректний email.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            controller: _passwordController,
                            labelText: 'Пароль',
                            hintText: 'мін. 6 символів',
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Пароль має бути не менше 6 символів.';
                              }
                              return null;
                            },
                          ),
                          if (_isRegisterMode)
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: CustomTextField(
                                controller: _confirmPasswordController,
                                labelText: 'Підтвердіть пароль',
                                hintText: 'повторіть пароль',
                                isPassword: true,
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Паролі не співпадають.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          const SizedBox(height: 24),
                          if (_isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Column(
                              children: [
                                CustomButton(
                                  text: _isRegisterMode ? 'Зареєструватися' : 'Увійти',
                                  onPressed: _submitAuthForm,
                                ),
                                const SizedBox(height: 12),
                                const Text("або", style: TextStyle(color: AppColors.textLight)),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: "Увійти через Google",
                                  icon: FontAwesomeIcons.google,
                                  type: ButtonType.ghost,
                                  onPressed: _googleSignIn,
                                ),
                              ],
                            ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isRegisterMode ? 'Вже є акаунт? ' : 'Немає акаунту? ',
                                style: const TextStyle(color: AppColors.textLight),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _isRegisterMode = !_isRegisterMode);
                                },
                                child: Text(
                                  _isRegisterMode ? 'Увійти' : 'Зареєструватися',
                                  style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
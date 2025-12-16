
// import 'dart:typed_data'; // Для веб-завантаження
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:image_picker/image_picker.dart';
// import '../core/app_colors.dart';
// import '../core/widgets/custom_button.dart';
// import '../core/widgets/custom_text_field.dart';
// import 'auth_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final user = FirebaseAuth.instance.currentUser;
//   late final TextEditingController _nameController;
  
//   bool _isSaving = false;
//   bool _isUploadingImage = false;
  
//   // Змінна для миттєвого відображення нового фото
//   String? _avatarUrl;

//   @override
//   void initState() {
//     super.initState();
//     _nameController = TextEditingController(text: user?.displayName ?? '');
//     // На старті беремо фото з профілю користувача
//     _avatarUrl = user?.photoURL;
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     super.dispose();
//   }

//   Future<void> _pickAndUploadImage() async {
//     if (user == null) return;

//     final picker = ImagePicker();
//     final XFile? image = await picker.pickImage(
//       source: ImageSource.gallery,
//       imageQuality: 80,
//     );

//     if (image == null) return;

//     setState(() => _isUploadingImage = true);

//     try {
//       // 1. Отримання посилання на Storage
//       final storageRef = FirebaseStorage.instance
//           .ref()
//           .child('user_avatars')
//           .child('${user!.uid}.jpg');

//       final Uint8List imageBytes = await image.readAsBytes();

//       // 2. Завантаження даних
//       await storageRef.putData(
//         imageBytes, 
//         SettableMetadata(contentType: 'image/jpeg'),
//       );

//       // 3. Отримання URL та оновлення Firebase Auth
//       final String downloadUrl = await storageRef.getDownloadURL();

//       await user!.updatePhotoURL(downloadUrl);
//       await user!.reload();
      
//       if (mounted) {
//         setState(() {
//           _avatarUrl = downloadUrl;
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Фото профілю успішно оновлено!'),
//             backgroundColor: AppColors.darkGreen,
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Помилка: $e'),
//             backgroundColor: AppColors.dangerRed,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => _isUploadingImage = false);
//     }
//   }

//   Future<void> _saveProfileChanges() async {
//     if (user == null || _nameController.text.trim().isEmpty) return;

//     setState(() => _isSaving = true);
//     try {
//       await user!.updateDisplayName(_nameController.text.trim());
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Дані успішно збережено!'),
//             backgroundColor: AppColors.darkGreen,
//           ),
//         );
//       }
//     } catch (e) {
//       // Обробка помилок
//     } finally {
//       if (mounted) setState(() => _isSaving = false);
//     }
//   }

//   // ignore: unused_element
//   Future<void> _refreshUserData() async {
//     // 1. Перезавантажуємо дані користувача з Firebase Auth
//     await user?.reload();
    
//     // 2. Оновлюємо локальний стан (щоб UI побачив зміни)
//     if (mounted) {
//       setState(() {
//         // Оновлюємо контролер тексту та посилання на фото
//         _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
//         _avatarUrl = FirebaseAuth.instance.currentUser?.photoURL;
//       });
//     }
//   }
  
//   void _showDeleteAccountDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Видалення акаунту'),
//           content: const Text('Ця дія є незворотною. Ви впевнені?'),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Скасувати'),
//             ),
//             FilledButton(
//               style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
//               onPressed: () async {
//                 try {
//                   await user?.delete();
//                   if (mounted) {
//                     Navigator.of(context).pushAndRemoveUntil(
//                       MaterialPageRoute(builder: (context) => const AuthScreen()),
//                       (Route<dynamic> route) => false,
//                     );
//                   }
//                 } on FirebaseAuthException {
//                    if (mounted) Navigator.of(context).pop();
//                 }
//               },
//               child: const Text('Видалити'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.backgroundGrey,
//       appBar: AppBar(
//         elevation: 1,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: const Text('Профіль'),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           _buildProfileHeader(),
//           const SizedBox(height: 24),
//           _buildPersonalDataCard(),
//           const SizedBox(height: 16),
//           _buildAccountManagementCard(),
//         ],
//       ),
//     );
//   }

//   Widget _buildProfileHeader() {
//     const double avatarRadius = 90.0; 

//     return Column(
//       children: [
//         GestureDetector(
//           onTap: _isUploadingImage ? null : _pickAndUploadImage,
//           child: Stack(
//             children: [
//               CircleAvatar(
//                 radius: avatarRadius, // ТУТ ЗМІНИЛИ РОЗМІР
//                 // Використовуємо _avatarUrl для відображення
//                 backgroundImage: (_avatarUrl != null)
//                     ? NetworkImage(_avatarUrl!)
//                     : const AssetImage('assets/avatar.png') as ImageProvider,
//                 backgroundColor: Colors.grey.shade300,
//                 child: _isUploadingImage 
//                   ? const CircularProgressIndicator(color: AppColors.darkGreen) 
//                   : null,
//               ),
//               Positioned(
//                 bottom: 0,
//                 right: 4, // Трохи зсунули, щоб пасувало до нового розміру
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: AppColors.darkGreen,
//                     shape: BoxShape.circle,
//                     border: Border.all(color: Colors.white, width: 3),
//                   ),
//                   child: const Padding(
//                     padding: EdgeInsets.all(12.0), // Збільшили кнопку камери
//                     child: Icon(
//                       FontAwesomeIcons.camera, 
//                       color: Colors.white, 
//                       size: 20 // Збільшили іконку
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 20),
//         Text(
//           user?.displayName ?? 'Користувач',
//           style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           user?.email ?? 'Немає email',
//           style: const TextStyle(fontSize: 16, color: AppColors.textLight),
//         ),
//       ],
//     );
//   }

//   Widget _buildPersonalDataCard() {
//     return Card(
//       elevation: 1,
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Особисті дані', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             CustomTextField(
//               controller: _nameController,
//               labelText: "Ім'я",
//               hintText: "Ваше ім'я",
//             ),
//             const SizedBox(height: 24),
//             _isSaving 
//               ? const Center(child: CircularProgressIndicator())
//               : CustomButton(text: 'Зберегти зміни', onPressed: _saveProfileChanges),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAccountManagementCard() {
//     return Card(
//       elevation: 1,
//       margin: EdgeInsets.zero,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('Керування акаунтом', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             CustomButton(
//               text: 'Видалити акаунт',
//               onPressed: _showDeleteAccountDialog,
//               type: ButtonType.danger,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../core/app_colors.dart';
import '../core/widgets/custom_button.dart';
import '../core/widgets/custom_text_field.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? get user => FirebaseAuth.instance.currentUser;
  
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _avatarUrl;

  Future<Map<String, dynamic>>? _statisticsFuture;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: user?.displayName ?? '');
    _bioController = TextEditingController();
    _avatarUrl = user?.photoURL;
    _statisticsFuture = _fetchUserStatistics();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _fetchUserStatistics() async {
    if (user == null) return {};

    int totalLists = 0;
    int totalItemsBought = 0;
    String bio = '';

    try {
      final listsSnapshot = await FirebaseFirestore.instance
          .collection('shopping_lists')
          .where('userId', isEqualTo: user!.uid)
          .get();
      
      totalLists = listsSnapshot.docs.length;
      for (var doc in listsSnapshot.docs) {
        totalItemsBought += (doc.data()['boughtCount'] ?? 0) as int;
      }

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        bio = userDoc.data()?['bio'] ?? '';
      }

      if (mounted) {
        _bioController.text = bio;
      }
    } catch (e) {
      print("Помилка завантаження статистики: $e");
    }

    return {
      'totalLists': totalLists,
      'totalItemsBought': totalItemsBought,
    };
  }

  Future<void> _pickAndUploadImage() async {
    if (user == null) return;

    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final storageRef = FirebaseStorage.instance.ref().child('user_avatars').child('${user!.uid}.jpg');
      final Uint8List imageBytes = await image.readAsBytes();

      await storageRef.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

      final String downloadUrl = await storageRef.getDownloadURL();
      await user!.updatePhotoURL(downloadUrl);
      
      if (mounted) {
        setState(() => _avatarUrl = downloadUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото профілю успішно оновлено!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка завантаження фото: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  Future<void> _saveProfileChanges() async {
    if (user == null) return;
    
    final newName = _nameController.text.trim();
    final newBio = _bioController.text.trim();

    setState(() => _isSaving = true);
    try {
      if (newName.isNotEmpty && newName != user!.displayName) {
        await user!.updateDisplayName(newName);
      }
      
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
        {'bio': newBio},
        SetOptions(merge: true),
      );
      
      setState(() {});
      FocusScope.of(context).unfocus(); // Ховаємо клавіатуру

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дані успішно збережено!')),
        );
      }
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка збереження: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
  
  Future<void> _refreshUserData() async {
    await user?.reload();
    _statisticsFuture = _fetchUserStatistics(); // Перезавантажуємо і статистику
    if (mounted) {
      setState(() {
        _nameController.text = FirebaseAuth.instance.currentUser?.displayName ?? '';
        _avatarUrl = FirebaseAuth.instance.currentUser?.photoURL;
      });
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Дані оновлено')),
      );
    }
  }
  
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Видалення акаунту'),
          content: const Text('Ця дія є незворотною. Ви впевнені?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Скасувати'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.dangerRed),
              onPressed: () async {
                try {
                  await user?.delete();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (Route<dynamic> route) => false,
                    );
                  }
                } on FirebaseAuthException catch (e) {
                   if (mounted) Navigator.of(context).pop();
                   String message = "Сталася помилка.";
                   if (e.code == 'requires-recent-login') {
                     message = "Для видалення акаунту потрібно повторно увійти.";
                   }
                   ScaffoldMessenger.of(context).showSnackBar(
                     SnackBar(content: Text(message)),
                   );
                }
              },
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _changePassword() async {
    if (user == null) return;

    String? newPassword;
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Зміна пароля'),
        content: Form(
          key: formKey,
          child: TextFormField(
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Новий пароль'),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Пароль має бути не менше 6 символів.';
              }
              return null;
            },
            onChanged: (value) => newPassword = value,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Скасувати')),
          FilledButton(
            onPressed: () async {
              if (formKey.currentState?.validate() == true && newPassword != null) {
                try {
                  await user!.updatePassword(newPassword!);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Пароль успішно змінено!')),
                  );
                } on FirebaseAuthException catch (e) {
                  Navigator.of(ctx).pop();
                  String message = "Сталася помилка.";
                  if (e.code == 'requires-recent-login') {
                    message = "Ця операція вимагає нещодавнього входу. Будь ласка, перезайдіть.";
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(message), backgroundColor: AppColors.dangerRed),
                  );
                }
              }
            },
            child: const Text('Змінити'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Профіль'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUserData,
            tooltip: 'Оновити дані',
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: FutureBuilder<Map<String, dynamic>>(
            future: _statisticsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final stats = snapshot.data ?? {};

              return ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildProfileHeader(),
                  const SizedBox(height: 24),
                  _buildStatisticsCard(stats),
                  const SizedBox(height: 16),
                  _buildPersonalDataCard(),
                  const SizedBox(height: 16),
                  _buildAccountManagementCard(),
                ],
              );
            }
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    const double avatarRadius = 60.0; 

    return Column(
      children: [
        GestureDetector(
          onTap: _isUploadingImage ? null : _pickAndUploadImage,
          child: Stack(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundImage: (_avatarUrl != null)
                    ? NetworkImage(_avatarUrl!)
                    : const AssetImage('assets/avatar.png') as ImageProvider,
                backgroundColor: Colors.grey.shade300,
                child: _isUploadingImage 
                  ? const CircularProgressIndicator(color: AppColors.darkGreen) 
                  : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.darkGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(FontAwesomeIcons.camera, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _nameController.text.isNotEmpty ? _nameController.text : (user?.displayName ?? 'Користувач'),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? 'Немає email',
          style: const TextStyle(fontSize: 16, color: AppColors.textLight),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> stats) {
    final registrationDate = user?.metadata.creationTime;
    final formattedDate = registrationDate != null
        ? DateFormat('d MMMM yyyy', 'uk_UA').format(registrationDate)
        : 'невідомо';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ваша активність', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.solidClock, size: 20, color: AppColors.textLight),
              title: const Text('Учасник з'),
              trailing: Text(formattedDate, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.listCheck, size: 20, color: AppColors.textLight),
              title: const Text('Створено списків'),
              trailing: Text(stats['totalLists']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const Divider(height: 1, indent: 56),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.solidSquareCheck, size: 20, color: AppColors.textLight),
              title: const Text('Куплено товарів'),
              trailing: Text(stats['totalItemsBought']?.toString() ?? '0', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalDataCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Особисті дані', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _nameController,
              labelText: "Ім'я",
              hintText: "Ваше ім'я",
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Про себе',
                hintText: 'Розкажіть трохи про себе...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 150,
            ),
            const SizedBox(height: 16),
            _isSaving 
              ? const Center(child: CircularProgressIndicator())
              : CustomButton(text: 'Зберегти зміни', onPressed: _saveProfileChanges),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountManagementCard() {
    final bool isEmailUser = user?.providerData.any((userInfo) => userInfo.providerId == 'password') ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Керування акаунтом', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (isEmailUser) ...[
              CustomButton(
                text: 'Змінити пароль',
                onPressed: _changePassword,
                type: ButtonType.ghost,
              ),
              const SizedBox(height: 12),
            ],
            CustomButton(
              text: 'Видалити акаунт',
              onPressed: _showDeleteAccountDialog,
              type: ButtonType.danger,
            ),
          ],
        ),
      ),
    );
  }
}
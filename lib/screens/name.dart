import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:pingme/models/user_model.dart';

import 'package:pingme/repositories/chat_repository.dart';
import 'package:pingme/screens/contact.dart';

import 'package:pingme/services/image_service.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() {
    return _ProfileSetupScreenState();
  }
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final formKey = GlobalKey<FormState>();

  final ImagePicker picker = ImagePicker();

  final ChatRepository chatRepository = ChatRepository();

  final ImageService imageService = ImageService();

  File? selectedImage;

  String name = '';

  bool isLoading = false;

  Future<void> pickImage() async {
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });
  }

  Future<void> saveProfile() async {
    final isValid = formKey.currentState!.validate();

    if (!isValid || selectedImage == null) {
      return;
    }

    formKey.currentState!.save();

    setState(() {
      isLoading = true;
    });

    try {
      final imageUrl = await imageService.uploadImage(selectedImage!);

      final user = FirebaseAuth.instance.currentUser!;

      final token = await FirebaseMessaging.instance.getToken();

      UserModel newUser = UserModel(
        uid: user.uid,

        name: name,

        phoneNumber: user.phoneNumber ?? '',

        profileImage: imageUrl,

        chatBoardIds: [],

        fcmToken: token ?? '',
      );

      await chatRepository.saveUser(newUser);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const ContactScreen();
          },
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: formKey,

            child: Column(
              children: [
                GestureDetector(
                  onTap: pickImage,

                  child: CircleAvatar(
                    radius: 50,

                    backgroundImage: selectedImage != null
                        ? FileImage(selectedImage!)
                        : null,

                    child: selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 40)
                        : null,
                  ),
                ),

                const SizedBox(height: 20),

                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Username',

                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter username';
                    }

                    return null;
                  },

                  onSaved: (value) {
                    name = value!;
                  },
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,

                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveProfile,

                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Save Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:pingme/appBar/commonAppBar.dart';
// import 'package:pingme/screens/contact.dart';
// // import 'package:pingme/screens/otp.dart';

// class NameScreen extends StatefulWidget{
//   const NameScreen({super.key});

//   @override
//   State<NameScreen> createState() {
//     return _NameScreenState();
//   }
// }

// class _NameScreenState extends State<NameScreen>{
//   final formKey = GlobalKey<FormState>();
//   var name = '';

//   @override
//   Widget build(BuildContext context) {
    
//     return Scaffold(
//       appBar: CommonAppBar.build(context),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text('Please Enter details'),
//             Card(

//               child: Form(
//                 key: formKey,
//                 child: Column(
//                   children: [
//                     TextFormField(
//                       decoration: InputDecoration(label: Text('Name')),
//                       keyboardType: TextInputType.name,
//                       autocorrect: false,
//                       validator: (value) {
//                         if (value == null || value.trim().length < 4) {
//                           return 'not valid name';
//                         }
//                         return null;
//                       },

//                       onSaved: (value) {
//                         name = value!;
//                       },
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         final isValid = formKey.currentState!.validate();

//                         if (!isValid) {
//                           return;
//                         }

//                         formKey.currentState!.save();
//                         Navigator.of(context).push(
//                           MaterialPageRoute(
//                             builder: (context) {
//                               return ContactScreen();
//                             },
//                           ),
//                         );
//                       },
//                       child: Text('Register'),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );

//   }
  
// }

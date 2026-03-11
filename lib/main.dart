import 'dart:io';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supbase_flutter_coures/screans/addnote.dart';
import 'package:supbase_flutter_coures/screans/auth.dart';
import 'package:supbase_flutter_coures/screans/home.dart';
import 'package:supbase_flutter_coures/screans/viewnote.dart';
import 'package:supbase_flutter_coures/services/auth.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: "https://tsjlpuldbyjiijsrepjx.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzamxwdWxkYnlqaWlqc3JlcGp4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzMwNjc5MzUsImV4cCI6MjA4ODY0MzkzNX0.Ive58YsFOne92L7DuDmW_pDagxCDt_9Oc-w9hBJHKqs",
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  // File? _image;

  Future<String> uploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    String uuidImage = DateTime.now().toIso8601String();
    String fileName = image?.name ?? 'default_image.jpg';
    String extension = image?.path.split('.').last ?? 'jpg';

    String filePath =
        'public/${image?.path}/${uuidImage}_${fileName}.${extension}';
    try {
      if (image != null) {
        // Upload the image to Supabase Storage
        await Supabase.instance.client.storage
            .from('notes')
            .upload(filePath, File(image.path));
        print('Image uploaded successfully!');
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return filePath;
  }

  String getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black87,
        colorScheme: ColorScheme.dark(),
      ),
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final session = snapshot.data?.session;
          if (session != null) {
            return Home();
          } else {
            return AuthPage();
          }
        },
      ),
      routes: {
        "home": (context) => Home(),
        "auth": (context) => AuthPage(),
        "addnote": (context) => Addnote(),
      },
    );
  }
}

// Scaffold(
//         body: Column(
//           children: [
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await AuthSupa().signUp(
//                       "alameryanis@gmail.com",
//                       "anees12345",
//                     );
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("signUp"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await AuthSupa().signin(
//                       "alameryanis@gmail.com",
//                       "anees12345",
//                     );
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("signIn"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await AuthSupa().logout();
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("logout"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: Text(
//                 Supabase.instance.client.auth.currentUser?.email ?? "no user",
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await Supabase.instance.client.from("notes").insert({
//                       "title": "note2",
//                       "content": "content2",
//                     });
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("insert data"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     List data = await Supabase.instance.client
//                         .from("notes")
//                         .select();
//                     print(data);
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("get data"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await Supabase.instance.client
//                         .from("notes")
//                         .update({
//                           "title": "updated note",
//                           "content": "updated content",
//                           "updated_at": DateTime.now().toIso8601String(),
//                         })
//                         .eq(
//                           "id",
//                           "cc2ee2a6-3651-462a-bdc6-7747d488a816",
//                         ); // Assuming you want to update a specific note
//                     // print(data);
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("update data"),
//               ),
//             ),
//             SizedBox(height: 20),
//             Center(
//               child: ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     await Supabase.instance.client
//                         .from("notes")
//                         .delete()
//                         .eq(
//                           "id",
//                           "cc2ee2a6-3651-462a-bdc6-7747d488a816",
//                         ); // Assuming you want to update a specific note
//                     // print(data);
//                   } catch (e) {
//                     print(e);
//                   }
//                 },
//                 child: Text("delete data"),
//               ),
//             ),
//           ],
//         ),
//       ),

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supbase_flutter_coures/component/textformfield.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Addnote extends StatefulWidget {
  const Addnote({super.key});

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  String? selectedImagePath;
  XFile? _pickedImage;
  String? _imageUplodedPath;

  uploadImage(XFile image) async {
    String uuidImage = DateTime.now().toIso8601String();
    // String extension = image.path.split('.').last;
    String fileName = image.name;
    String filePath = 'public/${uuidImage}_${fileName}';
    _imageUplodedPath = filePath;
    // setState(() {
    // });
    try {
      await Supabase.instance.client.storage
          .from('notes')
          .upload(filePath, File(image.path));
      print('Image uploaded successfully!');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _pickedImage = image ?? null;
      selectedImagePath = image?.path;
    });
  }

  String getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Note"), backgroundColor: Colors.black87),
      body: Container(
        padding: EdgeInsets.all(30),
        child: ListView(
          children: [
            SizedBox(height: 20),
            Form(
              child: Column(
                children: [
                  FormInput(
                    label: "Title",
                    hintText: "Enter note title",
                    controller: titleController,
                  ),
                  SizedBox(height: 20),
                  FormInput(
                    label: "Content",
                    hintText: "Enter note content",
                    controller: contentController,
                    maxLines: 8,
                  ),
                  SizedBox(height: 20),
                  Container(
                    height: 200,
                    // width: 300,
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    child: _pickedImage != null
                        ? Image.file(File(_pickedImage!.path))
                        : Placeholder(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      AwesomeDialog(
                        context: context,
                        title: "Choose Source",
                        dialogType: DialogType.noHeader,
                        animType: AnimType.bottomSlide,
                        btnOkOnPress: () {},
                        body: Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            children: [
                              IconButton(
                                onPressed: () {
                                  selectedImagePath = null;
                                  pickImage(ImageSource.camera);
                                },
                                icon: Icon(Icons.camera_alt_outlined),
                              ),
                              IconButton(
                                onPressed: () {
                                  selectedImagePath = null;
                                  pickImage(ImageSource.gallery);
                                },
                                icon: Icon(Icons.browse_gallery_outlined),
                              ),
                            ],
                          ),
                        ),
                      ).show();
                    },
                    child: Text("Get Image"),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        uploadImage(_pickedImage!);
                        await Supabase.instance.client.from("notes").insert({
                          "title": titleController.text,
                          "content": contentController.text,
                          "image_path": _imageUplodedPath,
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Note added successfully!"),
                            duration: Duration(seconds: 2),
                            backgroundColor: const Color.fromARGB(
                              255,
                              81,
                              76,
                              175,
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      } catch (e) {
                        AwesomeDialog(
                          context: context,
                          title: "Error",
                          dialogType: DialogType.error,
                          desc: e.toString(),
                          btnOkOnPress: () {},
                        ).show();
                      }
                    },
                    child: Text("Add Note"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
  XFile? _pickedImage;
  String? _imageUploadedPath;
  bool _isSaving = false;
  String? _titleError;

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  Future<void> _uploadImage(XFile image) async {
    final String uuidImage = DateTime.now().toIso8601String();
    final String fileName = image.name;
    final String filePath = 'public/${uuidImage}_$fileName';
    _imageUploadedPath = filePath;
    try {
      await Supabase.instance.client.storage
          .from('notes')
          .upload(filePath, File(image.path));
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  void _showImageSourceDialog() {
    AwesomeDialog(
      context: context,
      title: "Choose Source",
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.browse_gallery_outlined),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    ).show();
  }

  Future<void> _addNote() async {
    final String title = titleController.text.trim();

    // Validation
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title is required'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _titleError = null;
    });

    try {
      if (_pickedImage != null) {
        await _uploadImage(_pickedImage!);
      }

      await Supabase.instance.client.from("notes").insert({
        "title": title,
        "content": contentController.text.trim(),
        "image_path": _imageUploadedPath,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Note added successfully!"),
            duration: Duration(seconds: 2),
            backgroundColor: Color.fromARGB(255, 81, 76, 175),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          context: context,
          title: "Error",
          dialogType: DialogType.error,
          desc: e.toString(),
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
        backgroundColor: Colors.black87,
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            // Title field — plain TextField so we can show inline error
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
              child: TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 247, 241, 241),
                ),
                onChanged: (_) {
                  if (_titleError != null) {
                    setState(() => _titleError = null);
                  }
                },
                decoration: InputDecoration(
                  labelText: "Title *",
                  hintText: "Enter note title",
                  errorText: _titleError,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 234, 214, 140),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: const BorderSide(color: Colors.redAccent),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FormInput(
              label: "Content",
              hintText: "Enter note content",
              controller: contentController,
              maxLines: 8,
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 200,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: Colors.grey[800],
                child: _pickedImage != null
                    ? Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _showImageSourceDialog,
                icon: const Icon(Icons.image),
                label: const Text("Select Image"),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _addNote,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text("Add Note"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditNote extends StatefulWidget {
  final String noteId;
  final String initialTitle;
  final String initialContent;
  final String? initialImagePath;

  const EditNote({
    super.key,
    required this.noteId,
    required this.initialTitle,
    required this.initialContent,
    this.initialImagePath,
  });

  @override
  State<EditNote> createState() => _EditNoteState();
}

class _EditNoteState extends State<EditNote> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  XFile? _pickedImage;
  String? _imageUploadedPath;
  bool _isSaving = false;
  String? _titleError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _imageUploadedPath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
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

  Future<void> _uploadImage(XFile image) async {
    final String uuidImage = DateTime.now().toIso8601String();
    final String filePath = 'public/${uuidImage}_${image.name}';
    try {
      await Supabase.instance.client.storage
          .from('notes')
          .upload(filePath, File(image.path));
      _imageUploadedPath = filePath;
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  Future<void> _saveNote() async {
    final String title = _titleController.text.trim();

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
      String? newImagePath = _imageUploadedPath;

      if (_pickedImage != null) {
        // Delete old image first
        if (newImagePath != null && newImagePath.isNotEmpty) {
          try {
            await Supabase.instance.client.storage.from('notes').remove([
              newImagePath,
            ]);
          } catch (e) {
            debugPrint('Error deleting old image: $e');
          }
        }
        // Upload new image
        await _uploadImage(_pickedImage!);
        newImagePath = _imageUploadedPath;
      }

      await Supabase.instance.client
          .from('notes')
          .update({
            'title': title,
            'content': _contentController.text.trim(),
            'image_path': newImagePath,
          })
          .eq('id', widget.noteId);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Note"),
        backgroundColor: Colors.black87,
        actions: [
          _isSaving
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _saveNote,
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Note",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              onChanged: (_) {
                if (_titleError != null) {
                  setState(() => _titleError = null);
                }
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: "Title *",
                errorText: _titleError,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 10,
              minLines: 3,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Content",
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: _pickedImage != null
                    ? Image.file(File(_pickedImage!.path), fit: BoxFit.cover)
                    : (_imageUploadedPath != null &&
                              _imageUploadedPath!.isNotEmpty
                          ? Image.network(
                              _getImagePublicUrl(_imageUploadedPath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[800],
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey[600] ?? Colors.grey,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            )
                          : Container(
                              color: Colors.grey[800],
                              child: const Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            )),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _showImageSourceDialog,
                icon: const Icon(Icons.image),
                label: const Text("Change Image"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

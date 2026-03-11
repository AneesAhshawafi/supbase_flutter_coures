import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';
import 'package:supbase_flutter_coures/core/utils/validators.dart';
import 'package:supbase_flutter_coures/data/repositories/note_repository.dart';
import 'package:supbase_flutter_coures/services/storage_service.dart';
import 'package:supbase_flutter_coures/shared/theme/app_theme.dart';
import 'package:supbase_flutter_coures/shared/widgets/app_snackbar.dart';

class Addnote extends StatefulWidget {
  const Addnote({super.key});

  @override
  State<Addnote> createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _noteRepo = NoteRepository();
  final _storageService = StorageService();

  XFile? _pickedImage;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 80);
    if (image != null) setState(() => _pickedImage = image);
  }

  void _showImageSourceDialog() {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.noHeader,
      animType: AnimType.bottomSlide,
      title: 'Select Image',
      body: Padding(
        padding: const EdgeInsets.all(8),
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
              leading: const Icon(Icons.photo_library_outlined),
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? imagePath;
      if (_pickedImage != null) {
        imagePath = await _storageService.uploadImage(_pickedImage!);
      }

      await _noteRepo.create(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: imagePath,
      );

      if (mounted) {
        AppSnackbar.success(context, 'Note added!');
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
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
                  onPressed: _submit,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ── Title ──────────────────────────────────────────────────
            TextFormField(
              controller: _titleController,
              autofocus: true,
              validator: NoteValidators.title,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'Enter note title',
              ),
            ),
            const SizedBox(height: 16),

            // ── Content ────────────────────────────────────────────────
            TextFormField(
              controller: _contentController,
              maxLines: 10,
              minLines: 4,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Write your note here…',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // ── Image preview ──────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 180,
                color: AppTheme.cardHoverColor,
                child: _pickedImage != null
                    ? Image.file(
                        File(_pickedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: AppTheme.mutedColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No image selected',
                            style: TextStyle(color: AppTheme.mutedColor),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Image picker button ────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _showImageSourceDialog,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _pickedImage == null ? 'Add Image' : 'Change Image',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: AppTheme.borderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

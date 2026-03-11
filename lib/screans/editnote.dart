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
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _noteRepo = NoteRepository();
  final _storageService = StorageService();

  XFile? _pickedImage;
  String? _currentImagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
    _currentImagePath = widget.initialImagePath;
  }

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      String? newImagePath = _currentImagePath;

      if (_pickedImage != null) {
        // Delete old image (best-effort)
        if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
          await _storageService.deleteImage(_currentImagePath!);
        }
        newImagePath = await _storageService.uploadImage(_pickedImage!);
      }

      await _noteRepo.update(
        id: widget.noteId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imagePath: newImagePath,
      );

      if (mounted) {
        AppSnackbar.success(context, 'Note saved!');
        Navigator.of(context).pop();
      }
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    if (_pickedImage != null) {
      return Image.file(
        File(_pickedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }
    if (_currentImagePath != null && _currentImagePath!.isNotEmpty) {
      return Image.network(
        _storageService.getPublicUrl(_currentImagePath!),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => _imagePlaceholder(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.image_outlined, size: 48, color: AppTheme.mutedColor),
        const SizedBox(height: 8),
        Text('No image', style: TextStyle(color: AppTheme.mutedColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
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
                  onPressed: _save,
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
                child: _buildImagePreview(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Image picker button ────────────────────────────────────
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _showImageSourceDialog,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text(
                _pickedImage == null && (_currentImagePath == null || _currentImagePath!.isEmpty)
                    ? 'Add Image'
                    : 'Change Image',
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

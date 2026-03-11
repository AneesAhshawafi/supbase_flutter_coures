import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';
import 'package:supbase_flutter_coures/data/models/note.dart';
import 'package:supbase_flutter_coures/data/repositories/note_repository.dart';
import 'package:supbase_flutter_coures/screans/editnote.dart';
import 'package:supbase_flutter_coures/services/storage_service.dart';
import 'package:supbase_flutter_coures/shared/theme/app_theme.dart';
import 'package:supbase_flutter_coures/shared/widgets/app_snackbar.dart';
import 'package:supbase_flutter_coures/shared/widgets/loading_overlay.dart';

class ViewNote extends StatefulWidget {
  final String noteId;

  const ViewNote({super.key, required this.noteId});

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  final _noteRepo = NoteRepository();
  final _storageService = StorageService();
  bool _loading = false;

  Future<void> _delete(Note note) async {
    setState(() => _loading = true);
    try {
      await _noteRepo.delete(note.id);
      // Best-effort image cleanup
      if (note.hasImage) await _storageService.deleteImage(note.imagePath!);
      if (mounted) Navigator.of(context).pop();
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _confirmDelete(Note note) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.bottomSlide,
      title: 'Delete Note?',
      desc: 'This action cannot be undone.',
      btnOkText: 'Delete',
      btnOkOnPress: () => _delete(note),
      btnCancelOnPress: () {},
    ).show();
  }

  void _openEdit(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditNote(
          noteId: note.id,
          initialTitle: note.title,
          initialContent: note.content,
          initialImagePath: note.imagePath,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Note')),
      body: StreamBuilder<Note?>(
        stream: _noteRepo.watchOne(widget.noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final note = snapshot.data;
          if (note == null) {
            return const Center(child: Text('Note not found or deleted'));
          }

          return LoadingOverlay(
            isLoading: _loading,
            child: CustomScrollView(
              slivers: [
                // ── Image header (if present) ──────────────────────────
                if (note.hasImage)
                  SliverAppBar(
                    automaticallyImplyLeading: false,
                    expandedHeight: 240,
                    pinned: false,
                    flexibleSpace: FlexibleSpaceBar(
                      background: CachedNetworkImage(
                        imageUrl: _storageService.getPublicUrl(note.imagePath!),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.cardHoverColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.cardHoverColor,
                          child: const Center(
                            child: Icon(Icons.broken_image_outlined, size: 48),
                          ),
                        ),
                      ),
                    ),
                  ),

                // ── Content area ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Actions row ──────────────────────────────
                        Row(
                          children: [
                            _buildActionChip(
                              icon: Icons.edit_outlined,
                              label: 'Edit',
                              onTap: _loading ? null : () => _openEdit(note),
                            ),
                            const SizedBox(width: 10),
                            _buildActionChip(
                              icon: Icons.delete_outline,
                              label: 'Delete',
                              onTap: _loading
                                  ? null
                                  : () => _confirmDelete(note),
                              isDestructive: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Title ────────────────────────────────────
                        Text(
                          note.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),

                        // ── Date ─────────────────────────────────────
                        Text(
                          _formatDate(note.createdAt),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),

                        // ── Content ──────────────────────────────────
                        Text(
                          note.content.isEmpty
                              ? 'No content'
                              : note.content,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(height: 1.7),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? AppTheme.errorColor : AppTheme.primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

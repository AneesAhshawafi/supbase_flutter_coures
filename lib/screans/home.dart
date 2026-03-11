import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';
import 'package:supbase_flutter_coures/data/models/note.dart';
import 'package:supbase_flutter_coures/data/repositories/note_repository.dart';
import 'package:supbase_flutter_coures/screans/editnote.dart';
import 'package:supbase_flutter_coures/screans/viewnote.dart';
import 'package:supbase_flutter_coures/services/auth.dart';
import 'package:supbase_flutter_coures/shared/theme/app_theme.dart';
import 'package:supbase_flutter_coures/shared/widgets/app_snackbar.dart';
import 'package:supbase_flutter_coures/shared/widgets/loading_overlay.dart';
import 'package:supbase_flutter_coures/shared/widgets/note_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _noteRepo = NoteRepository();
  final _authService = AuthService();
  bool _loading = false;

  Future<void> _deleteNote(Note note) async {
    setState(() => _loading = true);
    try {
      await _noteRepo.delete(note.id);
      // Image deletion is handled in ViewNote / EditNote (best-effort)
      if (mounted) AppSnackbar.success(context, 'Note deleted');
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
      btnOkOnPress: () => _deleteNote(note),
      btnCancelOnPress: () {},
    ).show();
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, 'auth', (_) => false);
      }
    } on AppException catch (e) {
      if (mounted) AppSnackbar.error(context, e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, 'addnote'),
        tooltip: 'New Note',
        child: const Icon(Icons.add),
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        child: StreamBuilder<List<Note>>(
          stream: _noteRepo.watchAll(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load notes',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
              );
            }

            final notes = snapshot.data ?? [];

            if (notes.isEmpty) return const _EmptyState();

            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.7,
              ),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return NoteCard(
                  note: note,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ViewNote(noteId: note.id),
                    ),
                  ),
                  onEdit: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditNote(
                        noteId: note.id,
                        initialTitle: note.title,
                        initialContent: note.content,
                        initialImagePath: note.imagePath,
                      ),
                    ),
                  ),
                  onDelete: () => _confirmDelete(note),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 88,
              color: AppTheme.mutedColor.withAlpha(120),
            ),
            const SizedBox(height: 20),
            Text(
              'No notes yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.mutedColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first note',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

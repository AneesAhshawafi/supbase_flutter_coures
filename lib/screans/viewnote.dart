import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:supbase_flutter_coures/screans/editnote.dart';

class ViewNote extends StatefulWidget {
  final String noteId;
  const ViewNote({super.key, required this.noteId});
  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  bool _loading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  String _getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
  }

  Future<void> _deleteNote(String? imagePath) async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client
          .from('notes')
          .delete()
          .eq('id', widget.noteId);
      if (imagePath != null && imagePath.isNotEmpty) {
        await Supabase.instance.client.storage
            .from('notes')
            .remove([imagePath]);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting note: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Row(
          children: [Expanded(child: Text("Current Note"))],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('notes')
            .stream(primaryKey: ['id'])
            .eq('id', widget.noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Note not found or deleted"));
          }
          final noteMap = snapshot.data!.first;
          return Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Divider(color: Colors.grey[400]),
                    const SizedBox(height: 5),
                    Expanded(
                      child: Card(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[700],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Top action row ──────────────────────────
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    // Delete button
                                    InkWell(
                                      onTap: _loading
                                          ? null
                                          : () {
                                              AwesomeDialog(
                                                context: context,
                                                dialogType: DialogType.warning,
                                                animType: AnimType.bottomSlide,
                                                title: "Warning!",
                                                desc:
                                                    "Are you really want to delete this note?",
                                                btnOkText: "Confirm!",
                                                btnOkOnPress: () {
                                                  _deleteNote(
                                                    noteMap['image_path'],
                                                  );
                                                },
                                                btnCancelOnPress: () {},
                                              ).show();
                                            },
                                      child: Icon(
                                        Icons.delete,
                                        size: 25,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Edit button → navigate to EditNote screen
                                    InkWell(
                                      onTap: _loading
                                          ? null
                                          : () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditNote(
                                                    noteId: widget.noteId,
                                                    initialTitle:
                                                        noteMap['title'] ?? '',
                                                    initialContent:
                                                        noteMap['content'] ??
                                                        '',
                                                    initialImagePath:
                                                        noteMap['image_path'],
                                                  ),
                                                ),
                                              );
                                            },
                                      child: Icon(
                                        Icons.edit_outlined,
                                        size: 25,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    // Note title centered
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          noteMap["title"] ?? "Your Note",
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(color: Colors.grey[400]),
                              const SizedBox(height: 10),
                              // ── Note image ──────────────────────────────
                              if (noteMap["image_path"] != null &&
                                  noteMap["image_path"]
                                      .toString()
                                      .isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Expanded(
                                  flex: 2,
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _getImagePublicUrl(
                                          noteMap["image_path"],
                                        ),
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Center(
                                                child: Icon(
                                                  Icons.broken_image_rounded,
                                                  color: Colors.grey[600],
                                                  size: 40,
                                                ),
                                              );
                                            },
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 10),
                              // ── Note content ────────────────────────────
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  child: SingleChildScrollView(
                                    child: Text(
                                      noteMap["content"] ?? "",
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Loading overlay ──────────────────────────────────────────
              if (_loading)
                Container(
                  color: Colors.black45,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

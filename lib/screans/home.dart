import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supbase_flutter_coures/screans/editnote.dart';
import 'package:supbase_flutter_coures/screans/viewnote.dart';
import 'package:supbase_flutter_coures/services/auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> notes = [];
  bool _loading = false;

  String getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
  }

  Future<void> _deleteNote(dynamic noteId, String? imagePath) async {
    setState(() => _loading = true);
    try {
      await Supabase.instance.client.from('notes').delete().eq('id', noteId);
      if (imagePath != null && imagePath.isNotEmpty) {
        await Supabase.instance.client.storage.from('notes').remove([
          imagePath,
        ]);
      }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "addnote");
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await AuthSupa().logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    "auth",
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AwesomeDialog(
                    context: context,
                    title: "Error",
                    dialogType: DialogType.error,
                    desc: e.toString(),
                    btnOkOnPress: () {},
                  ).show();
                }
              }
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: Supabase.instance.client
                .from("notes")
                .stream(primaryKey: ["id"])
                .order("created_at", ascending: false),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              notes = snapshot.data ?? [];
              return notes.isEmpty
                  ? Center(
                      child: Text(
                        "No notes available",
                        style: TextStyle(fontSize: 18, color: Colors.grey[100]),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                          ),
                      itemCount: notes.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ViewNote(
                                  noteId: notes[index]['id'].toString(),
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[800],
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Row(
                                      children: [
                                        // ── Delete button ──────────────
                                        InkWell(
                                          onTap: _loading
                                              ? null
                                              : () {
                                                  AwesomeDialog(
                                                    context: context,
                                                    dialogType:
                                                        DialogType.warning,
                                                    animType:
                                                        AnimType.bottomSlide,
                                                    title: "Warning!",
                                                    desc:
                                                        "Are you really want to delete this note?",
                                                    btnOkText: "Confirm!",
                                                    btnOkOnPress: () {
                                                      _deleteNote(
                                                        notes[index]['id'],
                                                        notes[index]['image_path'],
                                                      );
                                                    },
                                                    btnCancelOnPress: () {},
                                                  ).show();
                                                },
                                          child: Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        // ── Edit button ────────────────
                                        InkWell(
                                          onTap: _loading
                                              ? null
                                              : () {
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (context) => EditNote(
                                                        noteId:
                                                            notes[index]['id']
                                                                .toString(),
                                                        initialTitle:
                                                            notes[index]['title'] ??
                                                            '',
                                                        initialContent:
                                                            notes[index]['content'] ??
                                                            '',
                                                        initialImagePath:
                                                            notes[index]['image_path'],
                                                      ),
                                                    ),
                                                  );
                                                },
                                          child: Icon(
                                            Icons.edit_outlined,
                                            size: 20,
                                            color: Colors.grey[400],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: double.infinity,
                                          child: Text(
                                            notes[index]["title"] ?? "No Title",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blueAccent[700],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Expanded(
                                          child: Text(
                                            notes[index]["content"] ??
                                                "No Content",
                                            style: const TextStyle(
                                              fontSize: 14,
                                              height: 1.3,
                                            ),
                                            overflow: TextOverflow.fade,
                                          ),
                                        ),
                                        if (notes[index]["image_path"] !=
                                                null &&
                                            notes[index]["image_path"]
                                                .toString()
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 10),
                                          Expanded(
                                            flex: 2,
                                            child: SizedBox(
                                              width: double.infinity,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.network(
                                                  getImagePublicUrl(
                                                    notes[index]["image_path"],
                                                  ),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) {
                                                        return Center(
                                                          child: Icon(
                                                            Icons
                                                                .broken_image_rounded,
                                                            color: Colors
                                                                .grey[600],
                                                            size: 40,
                                                          ),
                                                        );
                                                      },
                                                  loadingBuilder: (context, child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Center(
                                                      child: SizedBox(
                                                        width: 24,
                                                        height: 24,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          value:
                                                              loadingProgress
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
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
            },
          ),
          // ── Full-screen loading overlay during delete ──────────────────
          if (_loading)
            Container(
              color: Colors.black45,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

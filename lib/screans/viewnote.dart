import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class ViewNote extends StatefulWidget {
  final String noteId;
  const ViewNote({super.key, required this.noteId});
  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  bool _loading = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  Map<String, dynamic>? noteData;
  int currentIndex = 0;
  TextEditingController editTitleNoteTextController = TextEditingController();
  TextEditingController editBodyNoteTextController = TextEditingController();

  @override
  void initState() {
    // getData();
    super.initState();
  }

  @override
  void dispose() {
    editTitleNoteTextController.dispose();
    editBodyNoteTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          //header
          children: [Expanded(child: Text("Current Note"))],
        ),
      ),
      key: scaffoldKey,
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from('notes')
            .stream(primaryKey: ['id'])
            .eq('id', widget.noteId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Note not found or deleted"));
          }
          final noteMap = snapshot.data!.first;
          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Divider(color: Colors.grey[400]),
                SizedBox(height: 5),
                Expanded(
                  child: Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[700],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.warning,
                                      animType: AnimType.bottomSlide,
                                      title: "Warning!",
                                      desc:
                                          "Are you really want to delete this note?",
                                      btnOkText: "confirm!",
                                      btnOkOnPress: () async {
                                        bool isConnected =
                                            await InternetConnectionChecker
                                                .instance
                                                .hasConnection;

                                        if (isConnected) {
                                          setState(() {
                                            _loading = true;
                                          });
                                          await Supabase.instance.client
                                              .from('notes')
                                              .delete()
                                              .eq('id', widget.noteId);
                                          if (mounted) {
                                            setState(() {
                                              _loading = false;
                                            });
                                            Navigator.of(
                                              context,
                                            ).pop(); // Back to notes list
                                          }
                                        } else {
                                          Supabase.instance.client
                                              .from('notes')
                                              .delete()
                                              .eq('id', widget.noteId);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Note deleted locally. It will sync automatically.",
                                              ),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          if (mounted) {
                                            Navigator.of(context).pop();
                                          }
                                        }
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
                                SizedBox(width: 20),
                                InkWell(
                                  onTap: () {
                                    editTitleNoteTextController.text =
                                        noteMap["title"] ?? "";
                                    editBodyNoteTextController.text =
                                        noteMap["content"] ?? "";
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.noHeader,
                                      animType: AnimType.bottomSlide,
                                      title: "Edit Note",
                                      body: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              "Edit Note",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                // color: Colors.white,
                                              ),
                                              controller:
                                                  editTitleNoteTextController,
                                              autofocus: true,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Note Title",
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                // color: Colors.black,
                                              ),
                                              controller:
                                                  editBodyNoteTextController,
                                              maxLines: 5,
                                              minLines: 1,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(),
                                                labelText: "Note Content",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      btnOkText: "Save",
                                      btnOkOnPress: () async {
                                        if (editTitleNoteTextController.text
                                            .trim()
                                            .isNotEmpty) {
                                          bool isConnected =
                                              await InternetConnectionChecker
                                                  .instance
                                                  .hasConnection;

                                          if (isConnected) {
                                            await Supabase.instance.client
                                                .from('notes')
                                                .update({
                                                  'title':
                                                      editTitleNoteTextController
                                                          .text
                                                          .trim(),
                                                  'content':
                                                      editBodyNoteTextController
                                                          .text
                                                          .trim(),
                                                })
                                                .eq('id', widget.noteId);
                                          } else {
                                            Supabase.instance.client
                                                .from('notes')
                                                .update({
                                                  'title':
                                                      editTitleNoteTextController
                                                          .text
                                                          .trim(),
                                                  'content':
                                                      editBodyNoteTextController
                                                          .text
                                                          .trim(),
                                                })
                                                .eq('id', widget.noteId);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Note edited locally. It will sync automatically.",
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      btnCancelText: "Cancel",
                                      btnCancelOnPress: () {},
                                    ).show();
                                  },
                                  child: Icon(
                                    Icons.edit_outlined,
                                    size: 25,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                // SizedBox(width: 50),
                                Expanded(
                                  // widthFactor: double.infinity,
                                  child: Center(
                                    child: Text(
                                      noteMap["title"] ?? "Your Note",
                                      style: TextStyle(
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
                          SizedBox(height: 10),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(10),
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: Colors.grey),
                              // ),
                              child: SingleChildScrollView(
                                child: Text(
                                  noteMap["content"] ?? "",
                                  style: TextStyle(fontSize: 18),
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
          );
        },
      ),
    );
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supbase_flutter_coures/screans/viewnote.dart';
import 'package:supbase_flutter_coures/services/auth.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, dynamic>> notes = [];
  bool _loading = false;
  TextEditingController editTitleNoteTextController = TextEditingController();
  TextEditingController editContentNoteTextController = TextEditingController();
  XFile? _pickedImage;
  String? _imageUplodedPath;
  String? selectedImagePath;
  @override
  void dispose() {
    // TODO: implement dispose
    editTitleNoteTextController.dispose();
    editContentNoteTextController.dispose();
    super.dispose();
  }

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

  String getImagePublicUrl(String imagePath) {
    return Supabase.instance.client.storage
        .from('notes')
        .getPublicUrl(imagePath);
  }

  pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    setState(() {
      _pickedImage = image ?? null;
      selectedImagePath = image?.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, "addnote");
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.black87,
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await AuthSupa().logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "auth",
                  (route) => false,
                );
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
            icon: Icon(Icons.logout),
          ),
        ],
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: Supabase.instance.client
            .from("notes")
            .stream(primaryKey: ["id"])
            .order("created_at", ascending: false),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    // mainAxisSpacing: 10,
                    // crossAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ViewNote(noteId: notes[index]['id'].toString()),
                          ),
                        );
                      },
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[800],
                          ),
                          child: Column(
                            children: [
                              Padding(
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
                                          btnOkText: "confifrm!",
                                          btnOkOnPress: () async {
                                            bool isConnected =
                                                await InternetConnectionChecker
                                                    .instance
                                                    .hasConnection;

                                            if (isConnected) {
                                              _loading = true;
                                              await Supabase.instance.client
                                                  .from('notes')
                                                  .delete()
                                                  .eq('id', notes[index]['id']);
                                              await Supabase
                                                  .instance
                                                  .client
                                                  .storage
                                                  .from('notes')
                                                  .remove([
                                                    notes[index]['image_path'],
                                                  ]);
                                              _loading = false;
                                            } else {
                                              // Offline mode: Fire and forget
                                              Supabase.instance.client
                                                  .from('notes')
                                                  .delete()
                                                  .eq('id', notes[index]['id']);
                                              Supabase.instance.client.storage
                                                  .from('notes')
                                                  .remove([
                                                    notes[index]['image_path'],
                                                  ]);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Note deleted locally. It will sync automatically.",
                                                  ),
                                                  backgroundColor:
                                                      Colors.orange,
                                                ),
                                              );
                                            }
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
                                    SizedBox(width: 10),
                                    InkWell(
                                      onTap: () {
                                        editTitleNoteTextController.text =
                                            notes[index]["title"];
                                        editContentNoteTextController.text =
                                            notes[index]["content"];
                                        _imageUplodedPath =
                                            notes[index]["image_path"];
                                        AwesomeDialog(
                                          context: context,
                                          dialogType: DialogType.noHeader,
                                          animType: AnimType.bottomSlide,
                                          title: "Rename Note",
                                          body: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                            child: Column(
                                              children: [
                                                Text(
                                                  "Rename Note Title",
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
                                                    // color: Colors.black,
                                                  ),
                                                  controller:
                                                      editTitleNoteTextController,
                                                  autofocus: true,

                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: "New Title",
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
                                                      editContentNoteTextController,
                                                  autofocus: true,
                                                  maxLines: 20,
                                                  minLines: 1,
                                                  decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText: "New Content",
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                SizedBox(
                                                  height: 200,
                                                  child: _pickedImage != null
                                                      ? Image.file(
                                                          File(
                                                            _pickedImage!.path,
                                                          ),
                                                        )
                                                      : Placeholder(),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    AwesomeDialog(
                                                      context: context,
                                                      title: "Choose Source",
                                                      dialogType:
                                                          DialogType.noHeader,
                                                      animType:
                                                          AnimType.bottomSlide,
                                                      btnOkOnPress: () {},
                                                      body: Container(
                                                        padding: EdgeInsets.all(
                                                          10,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            IconButton(
                                                              onPressed: () {
                                                                pickImage(
                                                                  ImageSource
                                                                      .camera,
                                                                );
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              icon: Icon(
                                                                Icons
                                                                    .camera_alt_outlined,
                                                              ),
                                                            ),
                                                            IconButton(
                                                              onPressed: () {
                                                                pickImage(
                                                                  ImageSource
                                                                      .gallery,
                                                                );
                                                                Navigator.of(
                                                                  context,
                                                                ).pop();
                                                              },
                                                              icon: Icon(
                                                                Icons
                                                                    .browse_gallery_outlined,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ).show();
                                                  },
                                                  child: Text("Change Image"),
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
                                                // Optional: Delete old image if it exists
                                                if (_imageUplodedPath != null &&
                                                    _imageUplodedPath!
                                                        .isNotEmpty) {
                                                  await Supabase
                                                      .instance
                                                      .client
                                                      .storage
                                                      .from('notes')
                                                      .remove([
                                                        _imageUplodedPath!,
                                                      ]);
                                                }

                                                await Supabase.instance.client
                                                    .from('notes')
                                                    .update({
                                                      'title':
                                                          editTitleNoteTextController
                                                              .text
                                                              .trim(),
                                                      'content':
                                                          editContentNoteTextController
                                                              .text
                                                              .trim(),
                                                      'image_path':
                                                          _imageUplodedPath,
                                                    })
                                                    .eq(
                                                      'id',
                                                      notes[index]['id'],
                                                    );
                                              } else {
                                                // Optional: Delete old image if it exists
                                                if (_imageUplodedPath != null &&
                                                    _imageUplodedPath!
                                                        .isNotEmpty) {
                                                  Supabase
                                                      .instance
                                                      .client
                                                      .storage
                                                      .from('notes')
                                                      .remove([
                                                        _imageUplodedPath!,
                                                      ]);
                                                }
                                                Supabase.instance.client
                                                    .from('notes')
                                                    .update({
                                                      'title':
                                                          editTitleNoteTextController
                                                              .text
                                                              .trim(),
                                                      'content':
                                                          editContentNoteTextController
                                                              .text
                                                              .trim(),
                                                      'image_path':
                                                          _imageUplodedPath,
                                                    })
                                                    .eq(
                                                      'id',
                                                      notes[index]['id'],
                                                    );

                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "Note renamed locally. It will sync automatically.",
                                                    ),
                                                    backgroundColor:
                                                        Colors.orange,
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
                                        size: 20,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                // width:double.infinity,
                                // height:100,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                        notes[index]["content"] ?? "No Content",
                                        style: TextStyle(
                                          fontSize: 14,
                                          // color: Colors.grey[800],
                                          height: 1.3,
                                        ),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ),
                                    if (notes[index]["image_path"] != null &&
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
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
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
                                                    child:
                                                        CircularProgressIndicator(
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

                    // ListTile(
                    //   tileColor: Colors.white12,
                    //   title: Text(notes[index]["title"]),
                    //   subtitle: Text(notes[index]["content"]),
                    //   trailing: Text(notes[index]["id"]),
                    // );
                  },
                );
        },
      ),
    );
  }
}

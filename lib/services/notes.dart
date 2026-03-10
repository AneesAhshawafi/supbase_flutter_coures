import 'package:supabase_flutter/supabase_flutter.dart';

class DataNotes {
  final supa = Supabase.instance.client;

  create(String title, String content) async {
     await
supa.from("notes").insert({"title":title,"content":content});

  }
  read() {}
  update() {}
  delete() {}
  updloadImage() {}
}

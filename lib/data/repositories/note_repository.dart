import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supbase_flutter_coures/core/errors/app_exception.dart';
import 'package:supbase_flutter_coures/data/models/note.dart';

/// Repository for all Supabase `notes` table operations.
/// Screens should depend on this class — never call Supabase directly.
class NoteRepository {
  static final _client = Supabase.instance.client;
  static const _table = 'notes';

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Real-time stream of all notes ordered by creation date (newest first).
  Stream<List<Note>> watchAll() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data.map(Note.fromJson).toList());
  }

  /// Real-time stream of a single note by [id]. Emits null if deleted.
  Stream<Note?> watchOne(String id) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) => data.isEmpty ? null : Note.fromJson(data.first));
  }

  // ── Mutations ──────────────────────────────────────────────────────────────

  /// Creates a new note.
  Future<void> create({
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      await _client.from(_table).insert({
        'title': title,
        'content': content,
        'image_path': imagePath,
      });
    } catch (e) {
      throw DatabaseException('Failed to create note.', originalError: e);
    }
  }

  /// Updates an existing note by [id].
  Future<void> update({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    try {
      await _client.from(_table).update({
        'title': title,
        'content': content,
        'image_path': imagePath,
      }).eq('id', id);
    } catch (e) {
      throw DatabaseException('Failed to update note.', originalError: e);
    }
  }

  /// Deletes a note by [id].
  Future<void> delete(String id) async {
    try {
      await _client.from(_table).delete().eq('id', id);
    } catch (e) {
      throw DatabaseException('Failed to delete note.', originalError: e);
    }
  }
}

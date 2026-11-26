import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import '../database/database_helper.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;
  NoteService._internal();

  final _uuid = const Uuid();

  Future<List<Note>> loadNotes({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'notes',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'is_pinned DESC, updated_at DESC',
    );
    return rows.map((r) => Note.fromJson({
          ...r,
          'isPinned': r['is_pinned'] == 1,
          'tags': jsonDecode(r['tags'] as String? ?? '[]'),
          'createdAt': r['created_at'],
          'updatedAt': r['updated_at'],
          'profileId': r['profile_id'],
        })).toList();
  }

  Future<Note> addNote(Note note) async {
    final n = Note(
      id: note.id.isEmpty ? _uuid.v4() : note.id,
      title: note.title,
      content: note.content,
      color: note.color,
      isPinned: note.isPinned,
      tags: note.tags,
      profileId: note.profileId,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
    await _save(n);
    return n;
  }

  Future<void> updateNote(Note note) async => _save(note);

  Future<void> deleteNote(String id) async {
    await DatabaseHelper.instance.delete('notes', id);
  }

  Future<void> _save(Note n) async {
    await DatabaseHelper.instance.insert('notes', {
      'id': n.id,
      'profile_id': n.profileId,
      'title': n.title,
      'content': n.content,
      'color': n.color,
      'is_pinned': n.isPinned ? 1 : 0,
      'tags': jsonEncode(n.tags),
      'created_at': n.createdAt.toIso8601String(),
      'updated_at': n.updatedAt.toIso8601String(),
    });
  }

  // ─── Todo ─────────────────────────────────────────────────────────────────

  Future<List<TodoItem>> loadTodos({String profileId = 'default'}) async {
    final rows = await DatabaseHelper.instance.queryAll(
      'todos',
      where: 'profile_id = ?',
      whereArgs: [profileId],
      orderBy: 'sort_order ASC',
    );
    return rows.map((r) => TodoItem.fromJson({
          ...r,
          'isCompleted': r['is_completed'] == 1,
          'dueDate': r['due_date'],
          'sortOrder': r['sort_order'],
          'profileId': r['profile_id'],
        })).toList();
  }

  Future<TodoItem> addTodo(TodoItem item) async {
    final t = TodoItem(
      id: item.id.isEmpty ? _uuid.v4() : item.id,
      text: item.text,
      isCompleted: item.isCompleted,
      priority: item.priority,
      dueDate: item.dueDate,
      profileId: item.profileId,
      sortOrder: item.sortOrder,
    );
    await _saveTodo(t);
    return t;
  }

  Future<void> updateTodo(TodoItem item) async => _saveTodo(item);

  Future<void> deleteTodo(String id) async {
    await DatabaseHelper.instance.delete('todos', id);
  }

  Future<void> _saveTodo(TodoItem t) async {
    await DatabaseHelper.instance.insert('todos', {
      'id': t.id,
      'profile_id': t.profileId,
      'text': t.text,
      'is_completed': t.isCompleted ? 1 : 0,
      'priority': t.priority,
      'due_date': t.dueDate?.toIso8601String(),
      'sort_order': t.sortOrder,
    });
  }
}

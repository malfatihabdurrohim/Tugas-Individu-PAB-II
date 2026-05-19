import 'dart:async';

import '../models/course_models.dart';
import '../models/note_models.dart';

/// Minimal in-memory service used for development and tests.
/// Replace with real Firebase implementation when integrating Firebase.
class FirebaseService {
	// Courses
	final _coursesController = StreamController<List<CourseModel>>.broadcast();
	final List<CourseModel> _courses = [];

	// Notes
	final _notesController = StreamController<List<NoteModel>>.broadcast();
	final List<NoteModel> _notes = [];

	FirebaseService() {
		_coursesController.add(List.unmodifiable(_courses));
		_notesController.add(List.unmodifiable(_notes));
	}

	// Courses API
	Stream<List<CourseModel>> getCourses() => _coursesController.stream;

	Future<void> addCourse(CourseModel course) async {
		final newCourse = CourseModel(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			name: course.name,
			lecturer: course.lecturer,
		);
		_courses.add(newCourse);
		_coursesController.add(List.unmodifiable(_courses));
	}

	// Notes API
	Stream<List<NoteModel>> getNotes() => _notesController.stream;

	Future<void> addNote(NoteModel note) async {
		final newNote = NoteModel(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			courseId: note.courseId,
			courseName: note.courseName,
			title: note.title,
			content: note.content,
			timestamp: note.timestamp,
		);
		_notes.add(newNote);
		_notesController.add(List.unmodifiable(_notes));
	}

	Future<void> updateNote(String id, NoteModel note) async {
		final idx = _notes.indexWhere((n) => n.id == id);
		if (idx == -1) return;
		_notes[idx] = note;
		_notesController.add(List.unmodifiable(_notes));
	}

	Future<void> deleteNote(String id) async {
		_notes.removeWhere((n) => n.id == id);
		_notesController.add(List.unmodifiable(_notes));
	}

	void dispose() {
		_coursesController.close();
		_notesController.close();
	}
}

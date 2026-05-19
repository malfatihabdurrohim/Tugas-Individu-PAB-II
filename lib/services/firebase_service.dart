import 'dart:async';

import '../models/course_models.dart';

/// Minimal in-memory service used for development and tests.
/// Replace with real Firebase implementation when integrating Firebase.
class FirebaseService {
	final _controller = StreamController<List<CourseModel>>.broadcast();
	final List<CourseModel> _items = [];

	FirebaseService() {
		_controller.add(List.unmodifiable(_items));
	}

	Stream<List<CourseModel>> getCourses() => _controller.stream;

	Future<void> addCourse(CourseModel course) async {
		final newCourse = CourseModel(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			name: course.name,
			lecturer: course.lecturer,
		);
		_items.add(newCourse);
		_controller.add(List.unmodifiable(_items));
	}

	void dispose() {
		_controller.close();
	}
}

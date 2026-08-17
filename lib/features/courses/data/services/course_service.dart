import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Edvance/features/courses/data/model/course_enrollment_model.dart';
import 'package:Edvance/features/courses/data/model/course_model.dart';
import 'package:Edvance/features/enrollment/data/model/enrollment_model.dart';

class CourseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CourseEnrollmentModel>> getCoursesWithEnrollment(String userId) {
    return _firestore.collection('courses').snapshots().asyncMap((courseSnapshot) async {
      final enrollmentSnapshot = await _firestore
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();

      // Map enrollments by courseId
      final enrollmentMap = {
        for (var doc in enrollmentSnapshot.docs) doc['courseId']: EnrollmentModel.fromFirestore(doc.data()),
      };

      // Combine both
      return courseSnapshot.docs.map((doc) {
        final course = CourseModel.fromFirestore(doc);

        return CourseEnrollmentModel(course: course, enrollment: enrollmentMap[course.id]);
      }).toList();
    });
  }
}

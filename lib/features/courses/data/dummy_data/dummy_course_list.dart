// lib/features/home/data/mock_data.dart

import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/courses/data/model/lesson_model.dart';
import 'package:lms/features/courses/data/model/module_model.dart';
import 'package:lms/features/home/data/dummy_data/dummy_review_c1.dart';

final List<CourseModel> mockCourses = [
  CourseModel(
    instructorId: '800',
    id: '1',
    title: 'Graphic Design',
    description:
        'Lorem ipsum dolor sit amet consectetur. Nec eget accumsan molestie prin. Integer rhoncus vitae nisi natoque ac mus tellus scelerisque. Consectetur aliquet sit at diam. Augue eu mauris suspendisse adipiscing nibh. Nibh lorem id eu suspendisse nulla leo hendrerit. Erat tortor commodo quam fames et molestie.',
    instructorName: 'Syed Hasnain',
    thumbnailUrl: '',
    category: 'Design',
    rating: 4.5,
    totalRatings: 128,
    price: 72,

    totalDurationMinutes: 360,
    skills: ['Adobe', 'Adobe Photo Shop', 'Logo', 'Designing', 'Poster Design', 'Figma'],
    reviews: mockReviews,
    modules: [
      // Chapter 1
      ModuleModel(
        id: 'm1',
        title: 'What is Graphics Designing?',
        lessons: [
          LessonModel(
            id: 'l1',
            title: 'Introduction to Graphics Design',
            type: 'video',
            durationMinutes: 15,
            isFree: true,
          ),
          LessonModel(
            id: 'l2',
            title: 'Tools and Software Overview',
            type: 'video',
            durationMinutes: 20,
            isFree: false,
          ),
          LessonModel(
            id: 'l3',
            title: 'Design Principles Basics',
            type: 'text',
            durationMinutes: 10,
            isFree: true,
          ),
          LessonModel(
            id: 'l4',
            title: 'Color Theory Fundamentals',
            type: 'video',
            durationMinutes: 18,
            isFree: false,
          ),
        ],
      ),
      // Chapter 2
      ModuleModel(
        id: 'm2',
        title: 'What is Logo Designing?',
        lessons: [
          LessonModel(
            id: 'l5',
            title: 'Understanding Logo Design',
            type: 'video',
            durationMinutes: 12,
            isFree: false,
          ),
          LessonModel(
            id: 'l6',
            title: 'Typography in Logos',
            type: 'text',
            durationMinutes: 8,
            isFree: false,
          ),
        ],
      ),
      // Chapter 3
      ModuleModel(
        id: 'm3',
        title: 'What is Poster Designing?',
        lessons: [
          LessonModel(
            id: 'l7',
            title: 'Poster Layout Techniques',
            type: 'video',
            durationMinutes: 25,
            isFree: false,
          ),
          LessonModel(id: 'l8', title: 'Visual Hierarchy', type: 'video', durationMinutes: 15, isFree: false),
        ],
      ),
      // Chapter 4
      ModuleModel(
        id: 'm4',
        title: 'What is Picture Editing?',
        lessons: [
          LessonModel(
            id: 'l9',
            title: 'Photo Retouching Basics',
            type: 'video',
            durationMinutes: 20,
            isFree: false,
          ),
          LessonModel(
            id: 'l10',
            title: 'Advanced Editing Techniques',
            type: 'video',
            durationMinutes: 30,
            isFree: false,
          ),
        ],
      ),
    ],
  ),
  CourseModel(
    id: '2',
    instructorId: '801',
    title: 'Wireframing',
    description: 'Learn wireframing basics',
    instructorName: 'Shahzad Hassan',
    thumbnailUrl: '',
    category: 'UI/UX',
    rating: 4.8,
    totalRatings: 95,
    price: 65,

    totalDurationMinutes: 240,
    skills: ['Figma', 'Sketch', 'UI Design'],
    reviews: mockReviews,
    modules: [],
  ),
  CourseModel(
    id: '3',
    instructorId: '804',
    title: 'Website Design',
    description: 'Master website design',
    instructorName: 'Danish Hanif',
    thumbnailUrl: '',
    category: 'Development',
    rating: 4.6,
    totalRatings: 110,
    price: 80,

    totalDurationMinutes: 480,
    reviews: mockReviews,
    skills: ['HTML', 'CSS', 'Responsive Design'],
    modules: [],
  ),
  CourseModel(
    id: '4',
    instructorId: '805',
    title: 'Video Editing',
    description: 'Professional video editing',
    instructorName: 'Ammar Ijaz',
    thumbnailUrl: '',
    category: 'Media',
    rating: 4.7,
    totalRatings: 87,
    price: 70,

    totalDurationMinutes: 300,
    reviews: mockReviews,
    skills: ['Premiere Pro', 'After Effects', 'Color Grading'],
    modules: [],
  ),
];

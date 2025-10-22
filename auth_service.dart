import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'storage_service.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isTeacher => _currentUser?.type == UserType.teacher;
  bool get isStudent => _currentUser?.type == UserType.student;

  // Initialize - check if user is already logged in
  Future<void> init() async {
    // StorageService.getString is synchronous (returns String?). Do not await it.
    final storedUserId = StorageService.getString(AppConstants.keyCurrentUser);
    final storedUserType = StorageService.getString(AppConstants.keyUserType);

    if (storedUserId != null && storedUserType != null) {
      // Reconstruct a minimal User from stored pieces. In this app we only
      // persisted the user id and user type (teacher/student). Other fields
      // like name/email are not available in storage, so provide defaults.
      final userType =
          storedUserType == 'teacher' ? UserType.teacher : UserType.student;

      _currentUser = User(
        id: storedUserId,
        name: 'User',
        email: '',
        type: userType,
      );

      notifyListeners();
    }
  }

  // Teacher login
  Future<bool> loginTeacher(String employeeId, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (employeeId.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: employeeId,
        name: 'Prof. Johnson',
        email: 'johnson@university.edu',
        type: UserType.teacher,
      );

      await StorageService.setString(
        AppConstants.keyCurrentUser,
        _currentUser!.id,
      );
      await StorageService.setString(AppConstants.keyUserType, 'teacher');

      notifyListeners();
      return true;
    }

    return false;
  }

  // Student login
  Future<bool> loginStudent(String studentId, String password) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock validation
    if (studentId.isNotEmpty && password.isNotEmpty) {
      _currentUser = User(
        id: studentId,
        name: 'John Doe',
        email: 'john.doe@university.edu',
        type: UserType.student,
      );

      await StorageService.setString(
        AppConstants.keyCurrentUser,
        _currentUser!.id,
      );
      await StorageService.setString(AppConstants.keyUserType, 'student');

      notifyListeners();
      return true;
    }

    return false;
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    await StorageService.remove(AppConstants.keyCurrentUser);
    await StorageService.remove(AppConstants.keyUserType);
    notifyListeners();
  }
}

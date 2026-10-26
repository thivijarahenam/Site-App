import 'package:flutter/foundation.dart';

import '../data/mock_data.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  // App opens to Role Selection Landing Screen on launch
  AppUser? _user;

  final List<AppUser> _registeredUsers = [];
  final Map<String, String> _userPasswords = {};

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  UserRole? get role => _user?.role;

  /// Identifier can be either Email or Phone Number.
  String? login({
    required String email, // Also acts as identifier (email or phone)
    required String password,
    UserRole? roleFilter,
  }) {
    final cleanIdentifier = email.trim().toLowerCase();
    final cleanPhone = cleanIdentifier.replaceAll(RegExp(r'[\s\-]'), '');

    // Check custom registered users first
    for (final u in _registeredUsers) {
      final userPhone = u.phone.replaceAll(RegExp(r'[\s\-]'), '');
      if ((u.email.toLowerCase() == cleanIdentifier || userPhone == cleanPhone) &&
          (roleFilter == null || u.role == roleFilter)) {
        final storedPass = _userPasswords[u.id] ?? '123456';
        if (password != storedPass && password != DemoAccounts.password) {
          return 'Incorrect password. Please try again.';
        }
        _user = u;
        notifyListeners();
        return null;
      }
    }

    // Check demo accounts
    for (final demo in DemoAccounts.all) {
      final demoPhone = demo.phone.replaceAll(RegExp(r'[\s\-]'), '');
      if ((demo.email.toLowerCase() == cleanIdentifier || demoPhone == cleanPhone) &&
          (roleFilter == null || demo.role == roleFilter)) {
        if (password != DemoAccounts.password && password.isNotEmpty) {
          return 'Incorrect password. (Demo password is 123456)';
        }
        _user = demo;
        notifyListeners();
        return null;
      }
    }

    // If identifier empty or not found, try to match by role filter demo
    if (roleFilter != null && (cleanIdentifier.isEmpty || cleanIdentifier == 'demo')) {
      _user = DemoAccounts.accountFor(roleFilter);
      notifyListeners();
      return null;
    }

    return 'No account found with this phone/email for ${roleFilter?.label ?? 'this role'}.';
  }

  /// Register a newly created user (e.g. from stepper registration flow)
  void registerUser({
    required AppUser user,
    required String password,
  }) {
    _registeredUsers.add(user);
    _userPasswords[user.id] = password;
    _user = user;
    notifyListeners();
  }

  /// Update current user profile details
  void updateUser(AppUser updatedUser) {
    _user = updatedUser;
    final index = _registeredUsers.indexWhere((u) => u.id == updatedUser.id);
    if (index >= 0) {
      _registeredUsers[index] = updatedUser;
    }
    notifyListeners();
  }

  /// Direct login as a specific user
  void loginAs(AppUser user) {
    _user = user;
    notifyListeners();
  }

  /// Direct role switcher for easy demonstration of different roles
  void switchRole(UserRole role) {
    _user = DemoAccounts.accountFor(role);
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}

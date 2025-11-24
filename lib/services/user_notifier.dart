import 'package:flutter/foundation.dart';
import 'package:posyandu_app/data/models/response/auth/auth_response_model.dart';

class UserNotifier {
  static final ValueNotifier<User?> user = ValueNotifier<User?>(null);

  static void update(User? newUser) {
    user.value = newUser;
  }
}
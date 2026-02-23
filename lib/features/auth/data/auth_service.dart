// lib/features/auth/data/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Hàm Đăng ký - giờ sẽ ném lỗi ra ngoài
  Future<User?> signUpWithEmailPassword(String email, String password) async {
    // try-catch được chuyển ra ngoài UI để hiển thị thông báo
    User? currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      UserCredential userCredential = await currentUser.linkWithCredential(credential);
      return userCredential.user;
    } else {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    }
  }

  // Hàm Đăng nhập - giờ sẽ ném lỗi ra ngoài
  Future<User?> signInWithEmailPassword(String email, String password) async {
    // try-catch được chuyển ra ngoài UI để hiển thị thông báo
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Hàm Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
    await _auth.signInAnonymously();
  }
}
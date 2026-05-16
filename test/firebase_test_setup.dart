import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

bool _initialized = false;
bool _setupSucceeded = false;

bool get isFirebaseSetupSuccessful => _setupSucceeded;

Future<void> setupFirebaseForTests() async {
  if (_initialized) return;
  _initialized = true;
  TestWidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-sender-id',
        projectId: 'test-project',
      ),
    );
    _setupSucceeded = true;
  } catch (_) {
    _setupSucceeded = false;
  }
}

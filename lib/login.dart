
// Future<void> signInWithGoogleAndSendToServer() async {
//   final GoogleSignIn googleSignIn = GoogleSignIn();
//   final FirebaseAuth auth = FirebaseAuth.instance;

//   try {
//     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
//     if (googleUser == null) {
//       print('Google sign-in cancelled');
//       return;
//     }

//     final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

//     // Create Firebase credential
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth.accessToken,
//       idToken: googleAuth.idToken,
//     );

//     // Sign in with Firebase
//     final UserCredential userCredential =
//         await auth.signInWithCredential(credential);
//     final User? user = userCredential.user;

//     if (user == null) {
//       print("Firebase user is null");
//       return;
//     }

//     // Now get user details
//     final String? name = user.displayName;
//     final String? email = user.email;
//     final String? firebaseIdToken = await user.getIdToken();

//     print("Google user: $name, $email");

//     // Send to your backend
//     final response = await http.post(
//       Uri.parse('https://yourapi.com/api/google-login'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({
//         'name': name,
//         'email': email,
//         'firebase_token': firebaseIdToken, // optional
//       }),
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print("Logged in via server. Token: ${data['access_token']}");
//       // Save access_token / navigate
//     } else {
//       print("Server login failed: ${response.body}");
//     }
//   } catch (e) {
//     print("Google sign-in error: $e");
//   }
// }

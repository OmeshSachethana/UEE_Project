import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Google Sign In
  signInWithGoogle() async {
    //begin with interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn()
        .signIn(); //this opens a new page for select google account

    //obatin auth details from the request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    //create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //finally, lets sigm in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_screen.dart';
import 'singup_screen.dart';
import 'main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isPasswordObscured = true;

  // Function to toggle password visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Stack to layer the background image behind your login form
    return Scaffold(
      body: Stack(
        fit: StackFit
            .expand, // Ensure the background image covers the whole screen
        children: [
          // Background Image
          Opacity(
            opacity:
                0.9, // Adjust the opacity as needed, 1.0 is fully opaque, 0.0 is fully transparent
            child: Image.asset(
              'lib/images/FIEPAImage.jpg', // Assuming .jpg is a typo and you meant .png as previously mentioned
              fit: BoxFit.cover, // Cover the screen size
            ),
          ),
          Center(
            child: SingleChildScrollView(
              // Makes the content scrollable
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Image with shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 5,
                          blurRadius: 17,
                          offset: const Offset(0, 3), // Position of shadow
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(20.0), // Rounded corners
                      child: Image.asset('lib/images/LogoFipa.png', width: 300),
                    ),
                  ),
                  const SizedBox(height: 60),

                  Container(
                    width: 360, // Specify the width you want
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 209, 207, 207), // Background color of the field
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        fillColor: Colors
                            .transparent, // Make fillColor transparent so container color shows
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.email),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  Container(
                    width: 360, // Specify the width you want
                    height: 55,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                          255, 209, 207, 207), // Background color of the field
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText:
                          _isPasswordObscured, // Use the state variable here
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        filled: true,
                        fillColor: Colors
                            .transparent, // Make fillColor transparent so container color shows
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        labelStyle: const TextStyle(
                          // Specify label style here
                          fontWeight: FontWeight.bold,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            // Change the icon based on the state
                            _isPasswordObscured
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed:
                              _togglePasswordVisibility, // Toggle the password visibility
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 1, 138, 24),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                    ),
                    child:
                        const Text('Acessar', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(
                      height:
                          20), // Space between "Acessar" button and "Criar conta"
                  TextButton(
                    onPressed: () {
                      // Action for "Criar conta"
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupScreen()));
                    },
                    child: const Text(
                      "Criar conta!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 238, 241, 8),
                      ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          0), // Space between "Criar conta" and the new label
                  TextButton(
                    onPressed: () {
                      // Action for the new label, e.g., navigate to a "Forgot Password?" page
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotScreen()));
                    },
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(
                        fontSize: 18, // Adjust as per design requirements
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 252, 248,
                            250), // Ensuring it matches your app theme color
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Google Sign-in Button
                  ElevatedButton.icon(
                    onPressed: _enterWithGoogle,
                    icon: Image.asset('lib/images/google_logo.png',
                        height: 24, width: 24),
                    label: const Text('Entrar com Google',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
                      minimumSize: const Size(240, 50), // Button size
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(
                          color: Colors.grey.shade300), // Border color
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Google Sign-in Button
                  ElevatedButton.icon(
                    onPressed: () {
                      // Google sign-in logic
                    },
                    icon: Image.asset('lib/images/apple_logo.png',
                        height: 34, width: 34),
                    label: const Text('Entrar com Apple',
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white, // Text color
                      minimumSize: const Size(240, 50), // Button size
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(
                          color: Colors.grey.shade300), // Border color
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false, // User must not close the dialog manually
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Close the loading dialogr
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        // Close the loading dialog
        Navigator.pop(context);

        // Show login failed error
        showLoginError(context,
            'Credenciais incorretas. Tente novamente ou recupere sua senha.');
      }
    } catch (e) {
      // Close the loading dialog
      Navigator.pop(context);
      // Show an error message.
      showLoginError(
          context, 'Email ou senha inválidos. Por favor, tente novamente!');
    }
  }

  Future<void> _enterWithGoogle() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        );
      },
    );
    try {
      // Sign out any existing Google account
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Verifica se o usuário cancelou o login
      if (googleUser == null) {
        // Usuário cancelou o login, fecha o diálogo de carregamento
        Navigator.pop(context);
        return; // Sai do método para não prosseguir com o login
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Check if user is already registered
        final usersRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid);
        final docSnapshot = await usersRef.get();

        if (docSnapshot.exists) {
          // User is already registered
          Navigator.pop(context); // Dismiss the loading dialog
         Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
            return; 
        }

        // User is not registered, proceed to save their details
        await usersRef.set({
          'name': userCredential.user!.displayName ?? 'No Name',
          'email': userCredential.user!.email ?? 'No Email',
        });

        Navigator.pop(context); // Dismiss the loading dialog
        showLoginError(context, 'Registro de Usuário realizado com sucesso!',
            onSuccess: () {
         Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
        });
      }
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      showLoginError(context, 'Google Sign In Failed: $e');
    }
  }

  void showLoginError(BuildContext context, String message,
      {VoidCallback? onSuccess}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login de Usuário'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (onSuccess != null) {
                  onSuccess();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

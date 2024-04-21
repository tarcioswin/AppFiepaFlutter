// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_screen.dart';
import 'main_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'singup_screen.dart';

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
  bool _stayLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final stayLoggedIn = prefs.getBool('stayLoggedIn') ?? false;
    _stayLoggedIn = stayLoggedIn; // Update local _stayLoggedIn with shared pref value

    if (stayLoggedIn) {
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MainScreen()));
          });
        }
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.9,
            child: Image.asset(
              'lib/images/FIEPAImage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.8),
                          spreadRadius: 5,
                          blurRadius: 17,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.asset('lib/images/LogoFipa.png', width: 300),
                    ),
                  ),
                  const SizedBox(height: 60),
                  buildEmailTextField(),
                  const SizedBox(height: 20),
                  buildPasswordTextField(),
                  const SizedBox(height: 5),
                  SwitchListTile(
                    value: _stayLoggedIn,
                    onChanged: (bool value) {
                      setState(() {
                        _stayLoggedIn = value;
                      });
                    },
                    title: const Text(
                      'Permanecer conectado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 238, 241, 8),
                      ),
                    ),
                    activeColor: Colors.grey,
                    activeTrackColor: const Color.fromARGB(255, 1, 138, 24),
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () => _login(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color.fromARGB(255, 1, 138, 24),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100, vertical: 15),
                    ),
                    child: const Text('Acessar', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
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
                  const SizedBox(height: 0),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotScreen()));
                    },
                    child: const Text(
                      "Esqueceu a senha?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 252, 248, 250),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _enterWithGoogle,
                    icon: Image.asset('lib/images/google_logo.png', height: 24, width: 24),
                    label: const Text('Entrar com Google', style: TextStyle(fontSize: 18, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(240, 50),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Google sign-in logic
                    },
                    icon: Image.asset('lib/images/apple_logo.png', height: 34, width: 34),
                    label: const Text('Entrar com Apple', style: TextStyle(fontSize: 18, color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(240, 50),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                      side: BorderSide(color: Colors.grey.shade300),
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

  Widget buildEmailTextField() {
    return Container(
      width: 360,
      height: 50,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 209, 207, 207),
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
          fillColor: Colors.transparent,
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
    );
  }

  Widget buildPasswordTextField() {
    return Container(
      width: 360,
      height: 50,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 209, 207, 207),
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
        obscureText: _isPasswordObscured,
        decoration: InputDecoration(
          labelText: 'Senha',
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.lock),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordObscured ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: _togglePasswordVisibility,
          ),
        ),
      ),
    );
  }

  Future<void> _login(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: SizedBox(
            height: 50,
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('stayLoggedIn', _stayLoggedIn);

        Navigator.pop(context);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        Navigator.pop(context);
        showLoginError(context,
            'Credenciais incorretas. Tente novamente ou recupere sua senha.');
      }
    } catch (e) {
      Navigator.pop(context);
      showLoginError(
          context, 'Email ou senha inválidos. Por favor, tente novamente!');
    }
  }





Future<void> _enterWithGoogle() async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const AlertDialog(
        content: SizedBox(
          height: 50,
          child: Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        ),
      );
    },
  );

  try {
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      Navigator.pop(context);
      return;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _auth.signInWithCredential(credential);

    if (userCredential.user != null) {
      final prefs = await SharedPreferences.getInstance();
      // Ensure the stayLoggedIn is set when signing in with Google
      await prefs.setBool('stayLoggedIn', _stayLoggedIn);

      final usersRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid);
      final docSnapshot = await usersRef.get();

      if (!docSnapshot.exists) {
        await usersRef.set({
          'name': userCredential.user!.displayName ?? 'No Name',
          'email': userCredential.user!.email ?? 'No Email',
        });
      }

      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    }
  } catch (e) {
    Navigator.pop(context);
    showLoginError(context, 'Google Sign In Failed: $e');
  }
}



  void showLoginError(BuildContext context, String message, {VoidCallback? onSuccess}) {
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
                Navigator.of(context).pop();
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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart'; // Import the package
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _phoneController = MaskedTextController(
      mask: '(00)00000-0000'); // Update this mask as needed
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllerCheck =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _isPasswordObscured = true;
  bool _isPasswordCheckObscured = true;

  // Toggle for the first password field
  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordObscured = !_isPasswordObscured;
    });
  }

// Toggle for the password confirmation field
  void _togglePasswordCheckVisibility() {
    setState(() {
      _isPasswordCheckObscured = !_isPasswordCheckObscured;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _passwordControllerCheck.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Registrar", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.7,
            child: Image.asset(
              'lib/images/FIEPAImage.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 60.0), // Adjust the top padding as needed
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTextField(_nameController, 'Nome', Icons.person),
                  const SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email', Icons.email),
                  const SizedBox(height: 20),
                  _buildTextFieldNumber(
                      _phoneController, 'DDD + Celular', Icons.phone_android),
                  const SizedBox(height: 20),
                  _buildTextFieldPassword(
                    controller: _passwordController,
                    label: 'Digite a Senha',
                    icon: Icons.lock,
                    isObscured: _isPasswordObscured,
                    toggleVisibility: _togglePasswordVisibility,
                  ),
                  const SizedBox(height: 20),
                  _buildTextFieldPassword(
                    controller: _passwordControllerCheck,
                    label: 'Digite Novamente a Senha',
                    icon: Icons.lock,
                    isObscured: _isPasswordCheckObscured,
                    toggleVisibility: _togglePasswordCheckVisibility,
                  ),
                  const SizedBox(height: 30),
                  _buildButton(context, 'Registrar', _register),
                  const SizedBox(height: 40),
                  _buildButtonWithIcon(context, 'Registrar com Google',
                      'lib/images/google_logo.png', _registerWithGoogle),
                  const SizedBox(height: 20),
                  _buildButtonWithIcon(context, 'Registrar com Apple',
                      'lib/images/apple_logo.png', _registerWithApple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Container(
      width: 370,
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
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Make label text bold
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
        ),
        keyboardType: label == 'Email'
            ? TextInputType.emailAddress
            : TextInputType.text, // Conditional keyboardType for Email
      ),
    );
  }

  Widget _buildTextFieldNumber(
      MaskedTextController controller, String label, IconData icon) {
    return Container(
      width: 370,
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
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, // Make label text bold
          ),
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
        ),
      ),
    );
  }

  Widget _buildTextFieldPassword({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isObscured,
    required VoidCallback toggleVisibility,
  }) {
    return Container(
      width: 370,
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
        controller: controller,
        obscureText: isObscured,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon),
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          suffixIcon: IconButton(
            icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }

  Widget _buildButton(
      BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18)),
    );
  }

  Widget _buildButtonWithIcon(BuildContext context, String label,
      String iconPath, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(iconPath, height: 24, width: 24),
      label: Text(label,
          style: const TextStyle(fontSize: 18, color: Colors.black)),
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        minimumSize: const Size(240, 50),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void _register() async {
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


    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _passwordControllerCheck.text.trim().isEmpty) {
      // Dismiss the loading dialog
      Navigator.pop(context);
      showRegistrationError(context, 'Por favor, preencha todos os campos.');
      return;
    }

    // Check if email is in correct form
    RegExp emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      // Dismiss the loading dialog
      Navigator.pop(context);
      showRegistrationError(context, 'Por favor, insira um email válido.');
      return;
    }

    // Check for password minimum length
    if (_passwordController.text.trim().length < 6) {
      // Dismiss the loading dialog
      Navigator.pop(context);
      showRegistrationError(
          context, 'Por favor, insira uma senha com no mínimo 6 dígitos.');
      return;
    }

    // Check if the two passwords are equal
    if (_passwordController.text.trim() ==
        _passwordControllerCheck.text.trim()) {
      try {
        // Use Firebase Auth to create a new user with the email and password provided
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text
              .trim(), // Use the password from the controller
        );

        // Check if the user was successfully created
        if (userCredential.user != null) {
          // Use Firestore to save the user's name, email, and phone number
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
          });

          // Dismiss the loading dialog
          Navigator.pop(context);

          // Show success message
          showRegistrationError(context, 'Cadastro realizado com sucesso!', navigateBack: true);
        }
      } catch (e) {
        // Dismiss the loading dialog
        Navigator.pop(context);

        String errorMessage =
            'Falha ao realizar cadastro. Verifique seus dados e tente novamente!';

        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'Este email já está sendo usado por outra conta.';
              break;
            case 'weak-password':
              errorMessage =
                  'A senha fornecida é muito fraca. Por favor, insira uma senha mais forte.';
              break;
            // Add more cases for other error codes as needed
            default:
              // You can use the default error message or log the error code for debugging purposes
              if (kDebugMode) {
                print('Failed with error code: ${e.code}');
              }
          }
        }

        // Show an error message based on the specific error
        showRegistrationError(context, errorMessage);
      }
    } else {
      // Dismiss the loading dialog
      Navigator.pop(context);

      // If the passwords do not match, show an error message
      showRegistrationError(context,
          'As senhas não coincidem. Por favor, verifique e tente novamente!');
    }
  }

  Future<void> _registerWithGoogle() async {
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
            showRegistrationError(context, 'Usuário já registrado.',navigateBack: true);
            return;
          }

          // User is not registered, proceed to save their details
          await usersRef.set({
            'name': userCredential.user!.displayName ?? 'No Name',
            'email': userCredential.user!.email ?? 'No Email',
          });

          Navigator.pop(context); // Dismiss the loading dialog
          showRegistrationError(
              context, 'Registro de Usuário realizado com sucesso!', navigateBack: true);
        }
      
    } catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      showRegistrationError(context, 'Google Sign In Failed: $e');
    }
  }

void showRegistrationError(BuildContext context, String message, {bool navigateBack = false}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Registro de Usuário'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
              if (navigateBack) {
                // If navigateBack is true, pop again to go back to the login screen
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}


  void _registerWithApple() {
    // Implement your Apple registration logic here
  }
}

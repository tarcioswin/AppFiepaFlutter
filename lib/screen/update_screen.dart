import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UpdateScreenState createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final MaskedTextController _phoneController =
      MaskedTextController(mask: '(00) 00000-0000');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordControllerCheck =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isPasswordObscured = true;
  bool _isPasswordCheckObscured = true;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserData();
  }

  Future<void> _fetchCurrentUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? '';
        _emailController.text =
            user.email ?? ''; // Email directly from FirebaseAuth
        _phoneController.text = data['phone'] ?? '';
      }
    }
  }

   Future<void> _updateUserData() async {
    // Show loading dialog
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

    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': _nameController.text,
          'phone': _phoneController.text,
        });

        if (_passwordController.text.isNotEmpty && _passwordController.text == _passwordControllerCheck.text) {
          await user.updatePassword(_passwordController.text);
        }

        // Dismiss the loading dialog
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showRegistration(context, 'Perfil atualizado com sucesso!', navigateBack: true);
      } catch (e) {
        // Dismiss the loading dialog
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
        // ignore: use_build_context_synchronously
        showRegistration(context, 'Erro ao atualizar perfil: $e');
      }
    } else {
      // Dismiss the loading dialog
      Navigator.pop(context);
      showRegistration(context, 'Usuário não encontrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Atualizar Cadastro",
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 1, 138, 24),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(_nameController, 'Nome', Icons.person),
            const SizedBox(height: 10),
            _buildTextField(_emailController, 'Email', Icons.email),
            const SizedBox(height: 10),
            _buildTextField(_phoneController, 'Celular', Icons.phone),
            const SizedBox(height: 10),
            _buildPasswordField(
              controller: _passwordController,
              label: 'Nova Senha',
              toggleVisibility: () {
                setState(() => _isPasswordObscured = !_isPasswordObscured);
              },
              isObscured: _isPasswordObscured,
            ),
            const SizedBox(height: 10),
            _buildPasswordField(
              controller: _passwordControllerCheck,
              label: 'Confirmar Nova Senha',
              toggleVisibility: () {
                setState(
                    () => _isPasswordCheckObscured = !_isPasswordCheckObscured);
              },
              isObscured: _isPasswordCheckObscured,
            ),
            const SizedBox(height: 20),
            _buildButton(context, 'Atualizar', _updateUserData),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required VoidCallback toggleVisibility,
    required bool isObscured,
  }) {
    return TextField(
      controller: controller,
      obscureText: isObscured,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(isObscured ? Icons.visibility : Icons.visibility_off),
          onPressed: toggleVisibility,
        ),
      ),
    );
  }


  void showRegistration(BuildContext context, String message, {bool navigateBack = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Atualizar Cadastro'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                if (navigateBack) {
                  Navigator.of(context).pop(); // Go back to the previous screen
                }
              },
            ),
          ],
        );
      },
    );
  }

}

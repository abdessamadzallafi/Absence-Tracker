import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _user = TextEditingController(text: 'prof');
  final _pass = TextEditingController(text: '1234');
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await ref.read(authStateProvider.notifier).login(_user.text, _pass.text);
    setState(() => _loading = false);

    final st = ref.read(authStateProvider);
    if (!st.isLoggedIn && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Identifiants invalides')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final maxW = w > 520 ? 460.0 : w * 0.92;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text('Connexion Professeur',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _user,
                        decoration:
                            const InputDecoration(labelText: 'Nom utilisateur'),
                        validator: Validators.requiredText,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pass,
                        decoration:
                            const InputDecoration(labelText: 'Mot de passe'),
                        obscureText: true,
                        validator: Validators.requiredText,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _loading ? null : _submit,
                          child: _loading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Se connecter'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('Démo: prof / 1234',
                          style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_text_field.dart';
import 'onboarding_accessibility_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _handleController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _acceptTerms = true;

  void _submitRegister() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final handle = _handleController.text.trim().replaceAll('@', '');
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || handle.isEmpty || password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos. A senha deve ter no mínimo 8 caracteres.')),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('É necessário aceitar os Termos de Uso e Política de Privacidade.')),
      );
      return;
    }

    context.read<AuthBloc>().add(
          RegisterEvent(
            name: name,
            email: email,
            handle: handle,
            password: password,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro Inclusivo')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            SemanticsHelper.announce('Cadastro concluído com sucesso!');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OnboardingAccessibilityScreen()),
            );
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro no cadastro: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Criar Conta no DáPraIr?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça parte da nossa comunidade colaborativa de mobilidade urbana acessível.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                AccessibleTextField(
                  controller: _nameController,
                  label: 'Nome Completo',
                  hint: 'Maria Silva',
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _emailController,
                  label: 'E-mail',
                  hint: 'maria@exemplo.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _handleController,
                  label: 'Nome de Usuário (@handle)',
                  hint: 'maria_silva',
                ),
                const SizedBox(height: 16),
                AccessibleTextField(
                  controller: _passwordController,
                  label: 'Senha (mínimo 8 caracteres)',
                  hint: 'Digite uma senha segura',
                  obscureText: true,
                ),
                const SizedBox(height: 16),

                // LGPD Terms Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                    ),
                    Expanded(
                      child: Text(
                        'Concordo com os Termos de Uso e a Política de Privacidade',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                AccessibleButton(
                  label: 'Cadastrar e Continuar',
                  isLoading: state is AuthLoading,
                  onPressed: _submitRegister,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

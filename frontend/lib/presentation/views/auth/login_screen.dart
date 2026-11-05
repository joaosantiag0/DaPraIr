import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../components/accessible_button.dart';
import '../../components/accessible_text_field.dart';
import '../../components/responsive_container.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _submitLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha e-mail e senha para entrar')),
      );
      return;
    }

    context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar no DáPraIr?')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            SemanticsHelper.announce('Login realizado com sucesso. Bem-vindo ${state.user.name}');
            Navigator.pop(context, true);
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Falha ao autenticar: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ResponsiveContainer.narrow(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Acessar Conta',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Entre para publicar avaliações, conectar-se com amigos e salvar seus locais favoritos.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  AccessibleTextField(
                    controller: _emailController,
                    label: 'E-mail',
                    hint: 'exemplo@email.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  AccessibleTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    hint: 'Digite sua senha',
                    obscureText: true,
                  ),
                  const SizedBox(height: 28),
                  AccessibleButton(
                    label: 'Entrar',
                    isLoading: state is AuthLoading,
                    onPressed: _submitLogin,
                  ),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    label: 'Criar uma nova conta',
                    isSecondary: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

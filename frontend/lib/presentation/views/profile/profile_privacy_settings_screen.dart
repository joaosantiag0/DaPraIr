import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';

class ProfilePrivacySettingsScreen extends StatefulWidget {
  const ProfilePrivacySettingsScreen({super.key});

  @override
  State<ProfilePrivacySettingsScreen> createState() => _ProfilePrivacySettingsScreenState();
}

class _ProfilePrivacySettingsScreenState extends State<ProfilePrivacySettingsScreen> {
  String _visibility = 'PRIVATE';

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(LoadProfileEvent());
  }

  void _showAnonymizeConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão e Anonimização?'),
        content: const Text(
          'Conforme o Art. 18, VI da LGPD, todos os seus dados pessoais identificáveis (nome, e-mail, perfil de saúde) serão definitivamente apagados ou desvinculados. Suas avaliações públicas serão mantidas com autoria anônima para preservar a utilidade comunitária.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warningOrange),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ProfileBloc>().add(AnonymizeAccountEvent());
            },
            child: const Text('Anonimizar e Excluir Minha Conta', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade e Dados (LGPD)')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _visibility = state.profile.visibility;
            if (state.anonymizeSuccess) {
              SemanticsHelper.announce('Sua conta foi anonimizada e seus dados foram apagados.');
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pop(context);
            }
            if (state.exportedData != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pacote de dados pessoais exportado com sucesso!')),
              );
            }
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
                    'Gestão de Privacidade',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No DáPraIr?, você tem controle integral sobre quem visualiza suas informações de mobilidade e saúde.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Granular Visibility
                Text(
                  'Visibilidade das Preferências de Acessibilidade:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _visibility,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'PRIVATE', child: Text('Privado (Criptografado AES-256)')),
                    DropdownMenuItem(value: 'FRIENDS_ONLY', child: Text('Apenas Amigos Aceitos')),
                    DropdownMenuItem(value: 'PUBLIC', child: Text('Público para Toda a Comunidade')),
                  ],
                  onChanged: (val) {
                    if (val != null && state is ProfileLoaded) {
                      setState(() => _visibility = val);
                      context.read<ProfileBloc>().add(
                            UpdateProfileEvent(
                              disabilityTypes: state.profile.disabilityTypes,
                              assistanceNeeds: state.profile.assistanceNeeds,
                              visibility: val,
                              consentGranted: true,
                            ),
                          );
                    }
                  },
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // Portability Section
                Semantics(
                  header: true,
                  child: Text(
                    'Portabilidade de Dados (LGPD Art. 18, V)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Baixe uma cópia estruturada em formato aberto (JSON) de todos os seus dados cadastrais, consentimentos e histórico.',
                ),
                const SizedBox(height: 12),
                AccessibleButton(
                  label: 'Exportar Meus Dados em JSON',
                  icon: Icons.download,
                  isSecondary: true,
                  onPressed: () {
                    context.read<ProfileBloc>().add(ExportDataEvent());
                  },
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 16),

                // Right to be forgotten
                Semantics(
                  header: true,
                  child: Text(
                    'Direito ao Esquecimento (LGPD Art. 18, VI)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.warningOrange,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Solicite a exclusão de sua conta e a anonimização permanente de seus dados.',
                ),
                const SizedBox(height: 12),
                AccessibleButton(
                  label: 'Anonimizar e Excluir Minha Conta',
                  icon: Icons.delete_forever,
                  isSecondary: true,
                  onPressed: _showAnonymizeConfirmation,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/accessibility/semantics_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';

class ProfilePrivacySettingsScreen extends StatefulWidget {
  final bool isAuthenticated;
  final VoidCallback? onNavigateToLogin;

  const ProfilePrivacySettingsScreen({
    super.key,
    this.isAuthenticated = true,
    this.onNavigateToLogin,
  });

  @override
  State<ProfilePrivacySettingsScreen> createState() => _ProfilePrivacySettingsScreenState();
}

class _ProfilePrivacySettingsScreenState extends State<ProfilePrivacySettingsScreen> {
  String _visibility = 'PRIVATE';

  @override
  void initState() {
    super.initState();
    if (widget.isAuthenticated) {
      context.read<ProfileBloc>().add(LoadProfileEvent());
    }
  }

  @override
  void didUpdateWidget(covariant ProfilePrivacySettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isAuthenticated && widget.isAuthenticated) {
      context.read<ProfileBloc>().add(LoadProfileEvent());
    }
  }

  void _showAnonymizeConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warningOrange, size: 26),
            SizedBox(width: 8),
            Expanded(child: Text('Confirmar Exclusão e Anonimização?')),
          ],
        ),
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
    if (!widget.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacidade e Dados (LGPD)')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 56,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Privacidade e Governança LGPD',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Faça login na sua conta para gerenciar preferências de acessibilidade, portabilidade de dados (Art. 18, V) e exclusão/anonimização permanente.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
                const SizedBox(height: 28),
                AccessibleButton(
                  label: 'Entrar ou Cadastrar',
                  icon: Icons.login,
                  onPressed: () {
                    if (widget.onNavigateToLogin != null) {
                      widget.onNavigateToLogin!();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

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
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Pacote de dados pessoais exportado com sucesso!'),
                    ],
                  ),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Shield Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryBlue.withOpacity(0.15)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security_rounded, color: AppColors.primaryBlue, size: 26),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Governança & Segurança LGPD',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Seus dados sensíveis são criptografados com padrão militar AES-256.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                Semantics(
                  header: true,
                  child: Text(
                    'Gestão de Privacidade',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'No DáPraIr?, você tem controle integral sobre quem visualiza suas informações de mobilidade e saúde.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: 20),

                // Granular Visibility Section
                Text(
                  'Visibilidade das Preferências de Acessibilidade:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _visibility,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'PRIVATE',
                      child: Row(
                        children: [
                          Icon(Icons.lock_outline, size: 20, color: AppColors.primaryBlue),
                          SizedBox(width: 10),
                          Text('Privado (Criptografado AES-256)'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'FRIENDS_ONLY',
                      child: Row(
                        children: [
                          Icon(Icons.people_outline, size: 20, color: AppColors.primaryBlue),
                          SizedBox(width: 10),
                          Text('Apenas Amigos Aceitos'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'PUBLIC',
                      child: Row(
                        children: [
                          Icon(Icons.public, size: 20, color: AppColors.primaryBlue),
                          SizedBox(width: 10),
                          Text('Público para Toda a Comunidade'),
                        ],
                      ),
                    ),
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

                const SizedBox(height: 28),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 20),

                // Portability Section
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.file_download_outlined, color: AppColors.primaryBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Portabilidade de Dados (LGPD Art. 18, V)',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Baixe uma cópia estruturada em formato aberto (JSON) de todos os seus dados cadastrais, consentimentos e histórico.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: 'Exportar Meus Dados em JSON',
                          icon: Icons.download_rounded,
                          isSecondary: true,
                          onPressed: () {
                            context.read<ProfileBloc>().add(ExportDataEvent());
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Right to be forgotten (Danger Zone)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: AppColors.warningOrange.withOpacity(0.3), width: 1.2),
                  ),
                  color: AppColors.warningLight.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.warningLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.delete_forever_rounded, color: AppColors.warningOrange, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Semantics(
                                header: true,
                                child: Text(
                                  'Direito ao Esquecimento (LGPD Art. 18, VI)',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.warningOrange,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Solicite a exclusão de sua conta e a anonimização permanente de seus dados.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                        ),
                        const SizedBox(height: 16),
                        AccessibleButton(
                          label: 'Anonimizar e Excluir Minha Conta',
                          icon: Icons.delete_forever,
                          isSecondary: true,
                          onPressed: _showAnonymizeConfirmation,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}

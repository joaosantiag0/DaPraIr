import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/responsive_container.dart';
import 'account_data_governance_screen.dart';
import '../admin/admin_dashboard_view.dart';

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

  @override
  Widget build(BuildContext context) {
    if (!widget.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Privacidade e Dados')),
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
                  'Privacidade e Dados',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Faça login na sua conta para gerenciar preferências de acessibilidade, exportação de dados e exclusão permanente.',
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
      appBar: AppBar(title: const Text('Privacidade e Dados')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoaded) {
            _visibility = state.profile.visibility;
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ResponsiveContainer.medium(
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
                              'Privacidade e Segurança',
                              style: TextStyle(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Seus dados pessoais são armazenados com segurança.',
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
                          Text('Apenas Eu (Privado)'),
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
                const SizedBox(height: 16),

                // Admin / Moderator Panel Entry
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, authState) {
                    if (authState is Authenticated &&
                        (authState.user.role == 'ADMIN' || authState.user.role == 'MODERATOR')) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Card(
                          elevation: 0.5,
                          color: AppColors.primaryContainer.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: AppColors.primaryBlue, width: 1.2),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AdminDashboardView(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.admin_panel_settings,
                                      color: AppColors.primaryBlue,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Painel de Controle e Moderação',
                                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.primaryBlue,
                                              ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Gerenciar denúncias, conteúdos, usuários e auditoria',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: AppColors.primaryBlue),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),

                // Link to second screen (Account & Data Governance)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderLight, width: 1.2),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AccountDataGovernanceScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.manage_accounts_outlined,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gerenciamento de Dados e Conta',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Portabilidade de dados e exclusão de conta',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.textHint),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}

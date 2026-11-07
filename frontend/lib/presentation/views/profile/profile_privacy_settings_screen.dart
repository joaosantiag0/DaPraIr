import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../components/accessible_button.dart';
import '../../components/responsive_container.dart';
import 'account_data_governance_screen.dart';
import 'blocked_contacts_screen.dart';
import '../admin/admin_dashboard_view.dart';
import '../gamification/leaderboard_view.dart';

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
        appBar: AppBar(
          title: const Text('Privacidade e Dados'),
          actions: [
            if (kDebugMode)
              Semantics(
                button: true,
                label: 'Acessar Painel de Moderação e Administração (Dev)',
                child: IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: AppColors.primaryBlue),
                  tooltip: 'Painel de Administração (Dev)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardView(),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ResponsiveContainer.medium(
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
                const SizedBox(height: 24),
                AccessibleButton(
                  label: 'Entrar ou Cadastrar',
                  icon: Icons.login,
                  onPressed: () {
                    if (widget.onNavigateToLogin != null) {
                      widget.onNavigateToLogin!();
                    }
                  },
                ),
                const SizedBox(height: 32),
                _buildOpenSourceCreditsSection(context),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade e Dados'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, authState) {
              final isPrivileged = authState is Authenticated &&
                  (authState.user.role == 'ADMIN' || authState.user.role == 'MODERATOR');
              if (!isPrivileged) return const SizedBox.shrink();
              return Semantics(
                button: true,
                label: 'Acessar Painel de Moderação e Administração',
                child: IconButton(
                  icon: const Icon(Icons.admin_panel_settings, color: AppColors.primaryBlue),
                  tooltip: 'Painel de Administração',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminDashboardView(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
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
                    border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
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
                  initialValue: _visibility,
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
                _buildAdminPanelEntry(context),

                // Ranking & Gamification Entry
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
                          builder: (_) => const LeaderboardView(),
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
                              color: AppColors.underReviewLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.leaderboard_rounded,
                              color: AppColors.underReviewYellow,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ranking de Colaboradores',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Veja as pontuações, insígnias e o ranking da comunidade',
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
                const SizedBox(height: 14),

                // Link to Blocked Contacts screen
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
                          builder: (_) => const BlockedContactsScreen(),
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
                              Icons.block_outlined,
                              color: AppColors.warningOrange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contatos Bloqueados',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Gerencie pessoas bloqueadas e desbloqueie contatos',
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
                const SizedBox(height: 14),

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
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 20),

                // Open Source & Credits Section
                _buildOpenSourceCreditsSection(context),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
      ),
    );
  }

  Widget _buildOpenSourceCreditsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 1.2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.accentTeal,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Projeto Open Source',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Licença Aberta MIT • Comunidade',
                      style: TextStyle(
                        color: AppColors.accentTeal,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'O DáPraIr? é um projeto comunitário, gratuito e 100% de código aberto, dedicado a mapear, avaliar e compartilhar a acessibilidade física real no Brasil. Apoiamos o desenvolvimento transparente, colaborativo e auditável.',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _CreditTag(label: 'ABNT NBR 9050', icon: Icons.architecture),
              _CreditTag(label: 'W3C WCAG 2.1 AA/AAA', icon: Icons.accessibility_new),
              _CreditTag(label: 'LGPD Compliance', icon: Icons.privacy_tip_outlined),
              _CreditTag(label: 'Flutter & PostGIS', icon: Icons.code),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: AppColors.borderLight),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text('Ver Créditos'),
                  onPressed: () => _showCreditsDialog(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: const BorderSide(color: AppColors.borderLight),
                  ),
                  icon: const Icon(Icons.article_outlined, size: 18),
                  label: const Text('Licenças'),
                  onPressed: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'DáPraIr?',
                      applicationVersion: '1.0.0+1',
                      applicationIcon: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.accessible_forward, size: 48, color: AppColors.primaryBlue),
                      ),
                      applicationLegalese: 'Licenciado sob a Licença MIT.\nDesenvolvido com foco em acessibilidade universal.',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              icon: const Icon(Icons.open_in_new, size: 16, color: AppColors.primaryBlue),
              label: const Text(
                'Visitar repositório no GitHub',
                style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: () async {
                final uri = Uri.parse('https://github.com/joaosantiag0/DaPraIr');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreditsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.workspace_premium_outlined, color: AppColors.primaryBlue, size: 28),
            SizedBox(width: 10),
            Expanded(child: Text('Créditos & Referências')),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCreditCategory(
                  icon: Icons.person_outline,
                  title: 'Autoria & Comunidade',
                  description:
                      'Idealizado e desenvolvido por João Santiago e contribuidores da comunidade open source DáPraIr?.',
                ),
                const SizedBox(height: 14),
                _buildCreditCategory(
                  icon: Icons.accessible_forward,
                  title: 'Norma Técnica de Acessibilidade Física',
                  description:
                      'ABNT NBR 9050:2020 — Critérios padronizados de acessibilidade a edificações, mobiliário, espaços e equipamentos urbanos (7 critérios oficiais).',
                ),
                const SizedBox(height: 14),
                _buildCreditCategory(
                  icon: Icons.remove_red_eye_outlined,
                  title: 'Acessibilidade Digital',
                  description:
                      'W3C WCAG 2.1 (Níveis AA e AAA) — Alto contraste, leitores de tela semânticos, alvos de toque acessíveis (mínimo 48px) e suporte a foco/teclado.',
                ),
                const SizedBox(height: 14),
                _buildCreditCategory(
                  icon: Icons.security,
                  title: 'Privacidade & Proteção de Dados',
                  description:
                      'LGPD (Lei nº 13.709/2018) — Criptografia de dados sensíveis de saúde com AES-256-GCM, senhas em Argon2id e anonimização SHA-256.',
                ),
                const SizedBox(height: 14),
                _buildCreditCategory(
                  icon: Icons.layers_outlined,
                  title: 'Tecnologias & Bibliotecas Livres',
                  description:
                      'Construído com Flutter & Dart (Google), Fastify & TypeScript, PostgreSQL com extensão espacial PostGIS e Prisma ORM.',
                ),
                const SizedBox(height: 14),
                _buildCreditCategory(
                  icon: Icons.description_outlined,
                  title: 'Licenciamento Aberto',
                  description:
                      'Distribuído sob os termos da Licença MIT. Software livre para inspeção, auditoria de acessibilidade e contribuições comunitárias.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.open_in_new, size: 16),
            label: const Text('Repositório'),
            onPressed: () async {
              final uri = Uri.parse('https://github.com/joaosantiag0/DaPraIr');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminPanelEntry(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isPrivileged = authState is Authenticated &&
            (authState.user.role == 'ADMIN' || authState.user.role == 'MODERATOR');
        if (!isPrivileged) return const SizedBox.shrink();

        final roleLabel = (authState is Authenticated &&
                authState.user.role.isNotEmpty &&
                authState.user.role != 'USER')
            ? authState.user.role
            : 'ADMIN / MOD';

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 1,
            color: AppColors.primaryContainer.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
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
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Painel de Controle e Moderação',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  roleLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildCreditCategory({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CreditTag extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CreditTag({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryBlue),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

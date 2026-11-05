import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/accessibility/semantics_helper.dart';
import '../../core/theme/app_colors.dart';
import 'accessible_button.dart';

class CommunityRulesSheet extends StatelessWidget {
  const CommunityRulesSheet({super.key});

  static const String rulesAcknowledgedKey = 'has_seen_community_rules';

  static Future<void> show(BuildContext context) async {
    SemanticsHelper.announce('Abrindo regras da comunidade');
    return await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CommunityRulesSheet(),
    );
  }

  /// Checks if user has already acknowledged community rules.
  /// If not, displays the sheet and marks as acknowledged in SharedPreferences.
  /// Returns true if rules were shown (first time), false if already seen before.
  static Future<bool> ensureAcknowledged(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool(rulesAcknowledgedKey) ?? false;
      if (!hasSeen) {
        if (!context.mounted) return false;
        await show(context);
        final prefsAfter = await SharedPreferences.getInstance();
        await prefsAfter.setBool(rulesAcknowledgedKey, true);
        return true;
      }
    } catch (_) {}
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.90;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: 24 + bottomInset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Regras da Comunidade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Liberdade com respeito mútuo',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: 'Fechar regras da comunidade',
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Highlight Banner: Freedom of conversation
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF), // Soft blue tint
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primaryBlue, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Você pode conversar sobre o que quiser!',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sinta-se em casa para puxar papo, trocar ideias, tirar dúvidas e falar sobre seu cotidiano, interesses, lazer ou amizade. Lembramos que conteúdos com extremismo político e religioso devem ser evitados e poderão ser removidos pela moderação.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textPrimary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Incentive to Report Callout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB), // Warm amber tint
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.campaign_outlined, color: Color(0xFFB45309), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viu algo fora do padrão? Denuncie!',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF92400E),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Sua denúncia é anônima e essencial para mantermos a comunidade segura e acolhedora. Não hesite em denunciar qualquer conteúdo fora das regras.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78350F),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Scrollable Rules List
          Expanded(
            child: ListView(
              children: const [
                _RuleItem(
                  icon: Icons.favorite_outline_rounded,
                  iconColor: Color(0xFFE11D48),
                  title: '1. Respeito, Empatia e Inclusão',
                  description:
                      'Trate todos com dignidade. Não toleramos capacitismo, discriminação, ofensas, assédio ou qualquer forma de discurso de ódio.',
                ),
                _RuleItem(
                  icon: Icons.forum_outlined,
                  iconColor: Color(0xFF0284C7),
                  title: '2. Liberdade de Expressão Responsável',
                  description:
                      'Fale sobre temas que gosta: dicas de vida, experiências pessoais, acessibilidade, hobbies e descontrações. Opiniões são bem-vindas quando construtivas.',
                ),
                _RuleItem(
                  icon: Icons.warning_amber_rounded,
                  iconColor: Color(0xFFD97706),
                  title: '3. Conteúdos Evitáveis: Extremismo Político e Religioso',
                  description:
                      'Para preservar o foco no acolhimento mútuo e na inclusão de todos, evite extremismo político e religioso. Conteúdos com teor extremista, polarizador ou intolerante poderão ser moderados e removidos.',
                ),
                _RuleItem(
                  icon: Icons.shield_outlined,
                  iconColor: Color(0xFF16A34A),
                  title: '4. Denúncia Ativa e Ambiente Seguro',
                  description:
                      'Incentivamos você a denunciar qualquer conteúdo fora do padrão ou abusivo. Nossa moderação atua com rapidez para garantir a tranquilidade de todos.',
                ),
                _RuleItem(
                  icon: Icons.block_outlined,
                  iconColor: Color(0xFFEA580C),
                  title: '5. Sem Spam ou Golpes',
                  description:
                      'É proibido envio de propagandas invasivas, correntes, autopromoção abusiva ou links suspeitos.',
                ),
                _RuleItem(
                  icon: Icons.lock_outline_rounded,
                  iconColor: Color(0xFF7C3AED),
                  title: '6. Proteção à Privacidade',
                  description:
                      'Respeite a privacidade alheia. Nunca compartilhe dados sensíveis, documentos ou fotos de terceiros sem permissão.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Confirm button
          AccessibleButton(
            label: 'Entendido, vamos conversar!',
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setBool(CommunityRulesSheet.rulesAcknowledgedKey, true);
              } catch (_) {}
              if (context.mounted) {
                Navigator.pop(context);
                SemanticsHelper.announce('Regras compreendidas');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _RuleItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RuleItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

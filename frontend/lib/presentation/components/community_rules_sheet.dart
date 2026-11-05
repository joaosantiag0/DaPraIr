import 'package:flutter/material.dart';
import '../../core/accessibility/semantics_helper.dart';
import '../../core/theme/app_colors.dart';
import 'accessible_button.dart';

class CommunityRulesSheet extends StatelessWidget {
  const CommunityRulesSheet({super.key});

  static Future<void> show(BuildContext context) async {
    SemanticsHelper.announce('Abrindo regras da comunidade');
    return await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const CommunityRulesSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

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

          const SizedBox(height: 16),

          // Highlight Banner: Freedom of conversation
          Container(
            padding: const EdgeInsets.all(14),
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
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Sinta-se em casa para puxar papo, trocar ideias, tirar dúvidas e falar sobre seu cotidiano, interesses, lazer ou amizade. O único requisito é manter o respeito e seguir as regras abaixo:',
                        style: TextStyle(
                          fontSize: 12.5,
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

          const SizedBox(height: 16),

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
                  icon: Icons.shield_outlined,
                  iconColor: Color(0xFF16A34A),
                  title: '3. Ambiente Seguro e Colaborativo',
                  description:
                      'O DáPraIr? conta com moderação ativa. Conteúdos abusivos podem ser denunciados por qualquer membro e serão colocados em análise.',
                ),
                _RuleItem(
                  icon: Icons.block_outlined,
                  iconColor: Color(0xFFD97706),
                  title: '4. Sem Spam ou Golpes',
                  description:
                      'É proibido envio de propagandas invasivas, correntes, autopromoção abusiva ou links suspeitos.',
                ),
                _RuleItem(
                  icon: Icons.lock_outline_rounded,
                  iconColor: Color(0xFF7C3AED),
                  title: '5. Proteção à Privacidade',
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
            onPressed: () {
              Navigator.pop(context);
              SemanticsHelper.announce('Regras compreendidas');
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

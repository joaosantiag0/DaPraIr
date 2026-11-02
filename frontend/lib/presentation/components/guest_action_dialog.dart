import 'package:flutter/material.dart';
import 'accessible_button.dart';

class GuestActionDialog extends StatelessWidget {
  final String actionTitle;
  final VoidCallback onLoginPressed;

  const GuestActionDialog({
    super.key,
    required this.actionTitle,
    required this.onLoginPressed,
  });

  static Future<void> show({
    required BuildContext context,
    required String actionTitle,
    required VoidCallback onLoginPressed,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => GuestActionDialog(
        actionTitle: actionTitle,
        onLoginPressed: onLoginPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      scopesRoute: true,
      label: 'Diálogo de autenticação necessária',
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.lock_outline, color: Color(0xFF0D47A1), size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Entrar no DáPraIr?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Você está no Modo Convidado.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Para $actionTitle, conecte-se com sua conta para que suas contribuições de acessibilidade sejam validadas pela comunidade.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: AccessibleButton(
                  label: 'Continuar Visitando',
                  isSecondary: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AccessibleButton(
                  label: 'Fazer Login',
                  onPressed: () {
                    Navigator.pop(context);
                    onLoginPressed();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

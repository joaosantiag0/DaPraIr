import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';

class GamificationPrivacyView extends StatefulWidget {
  const GamificationPrivacyView({super.key});

  @override
  State<GamificationPrivacyView> createState() => _GamificationPrivacyViewState();
}

class _GamificationPrivacyViewState extends State<GamificationPrivacyView> {
  final TextEditingController _nicknameController = TextEditingController();
  bool _isRankingVisible = true;
  bool _useAnonymousNickname = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    context.read<GamificationBloc>().add(LoadGamificationProfile());
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacidade no Ranking (LGPD)'),
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listener: (context, state) {
          if (state.profile != null && !_initialized) {
            _isRankingVisible = state.profile!.isRankingVisible;
            _useAnonymousNickname = state.profile!.useAnonymousNickname;
            _nicknameController.text = state.profile!.customNickname ?? '';
            _initialized = true;
          }
        },
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.privacy_tip_outlined, color: Colors.blue, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Você tem total controle sobre sua visibilidade pública no ranking comunitário de acordo com a LGPD.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                title: const Text(
                  'Exibir meu perfil no Ranking Público',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Se desativado, você continuará acumulando seus pontos e medalhas de forma privada, mas não aparecerá para outros usuários na listagem.',
                ),
                value: _isRankingVisible,
                onChanged: (val) {
                  setState(() => _isRankingVisible = val);
                },
              ),
              const Divider(height: 32),
              SwitchListTile.adaptive(
                title: const Text(
                  'Modo Pseudônimo / Anônimo',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Substitui seu nome real e foto de perfil por um apelido ou pseudônimo neutro no ranking.',
                ),
                value: _useAnonymousNickname,
                onChanged: _isRankingVisible
                    ? (val) {
                        setState(() => _useAnonymousNickname = val);
                      }
                    : null,
              ),
              if (_useAnonymousNickname && _isRankingVisible) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Apelido Comunitário Opcional',
                      hintText: 'Ex: MapeadorNoturno',
                      helperText: 'Deixe vazio para usar "Membro Anônimo #ID"',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 50,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.save),
                label: const Text('Salvar Preferências'),
                onPressed: () {
                  context.read<GamificationBloc>().add(
                        UpdatePrivacySettings(
                          isRankingVisible: _isRankingVisible,
                          useAnonymousNickname: _useAnonymousNickname,
                          customNickname: _nicknameController.text.trim().isEmpty
                              ? null
                              : _nicknameController.text.trim(),
                        ),
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preferências de privacidade atualizadas!'),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

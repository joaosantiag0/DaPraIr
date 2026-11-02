import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DaPraIrApp());
}

class DaPraIrApp extends StatefulWidget {
  const DaPraIrApp({super.key});

  @override
  State<DaPraIrApp> createState() => _DaPraIrAppState();
}

class _DaPraIrAppState extends State<DaPraIrApp> {
  bool _isHighContrast = false;

  void toggleHighContrast() {
    setState(() {
      _isHighContrast = !_isHighContrast;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DáPraIr?',
      debugShowCheckedModeBanner: false,
      theme: _isHighContrast ? AppTheme.highContrastTheme : AppTheme.lightTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DáPraIr?'),
          actions: [
            IconButton(
              icon: Icon(_isHighContrast ? Icons.contrast : Icons.contrast_outlined),
              tooltip: _isHighContrast ? 'Desativar alto contraste' : 'Ativar alto contraste',
              onPressed: toggleHighContrast,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    'Bem-vindo ao DáPraIr?',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Plataforma social e avaliações comunitárias de acessibilidade física.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

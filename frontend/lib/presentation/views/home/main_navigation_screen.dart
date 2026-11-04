import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import 'feed_screen.dart';
import '../map_search/map_search_screen.dart';
import '../events/events_list_screen.dart';
import '../social/social_connections_screen.dart';
import '../profile/profile_privacy_settings_screen.dart';
import '../auth/login_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final VoidCallback? onToggleHighContrast;
  final bool isHighContrast;

  const MainNavigationScreen({
    super.key,
    this.onToggleHighContrast,
    this.isHighContrast = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onNavigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is Authenticated;

        final screens = [
          const FeedScreen(),
          MapSearchScreen(
            isAuthenticated: isAuthenticated,
            onNavigateToLogin: _onNavigateToLogin,
          ),
          const EventsListScreen(),
          SocialConnectionsScreen(
            isAuthenticated: isAuthenticated,
            onNavigateToLogin: _onNavigateToLogin,
          ),
          ProfilePrivacySettingsScreen(
            isAuthenticated: isAuthenticated,
            onNavigateToLogin: _onNavigateToLogin,
          ),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Semantics(
            container: true,
            label: 'Barra de navegação principal',
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Início',
                  tooltip: 'Ir para o feed comunitário',
                ),
                NavigationDestination(
                  icon: Icon(Icons.map_outlined),
                  selectedIcon: Icon(Icons.map),
                  label: 'Locais',
                  tooltip: 'Buscar e avaliar locais no mapa',
                ),
                NavigationDestination(
                  icon: Icon(Icons.event_outlined),
                  selectedIcon: Icon(Icons.event),
                  label: 'Eventos',
                  tooltip: 'Descobrir encontros inclusivos',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: 'Social',
                  tooltip: 'Comunidade, amigos e chat',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Perfil',
                  tooltip: 'Perfil e configurações',
                ),
              ],
            ),
          ),
          floatingActionButton: widget.onToggleHighContrast != null
              ? Semantics(
                  button: true,
                  label: widget.isHighContrast
                      ? 'Desativar tema de alto contraste'
                      : 'Ativar tema de alto contraste (WCAG AAA)',
                  child: FloatingActionButton.small(
                    heroTag: 'high_contrast_fab',
                    onPressed: widget.onToggleHighContrast,
                    tooltip: widget.isHighContrast ? 'Contraste normal' : 'Alto contraste',
                    child: Icon(
                      widget.isHighContrast ? Icons.contrast : Icons.contrast_outlined,
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}

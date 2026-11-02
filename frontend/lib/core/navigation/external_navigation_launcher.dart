import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

enum NavigationApp { googleMaps, waze, appleMaps }

class ExternalNavigationLauncher {
  /**
   * Launch external routing application for turn-by-turn navigation (FR-004)
   */
  static Future<bool> launchNavigation({
    required double latitude,
    required double longitude,
    required String destinationName,
    NavigationApp preferredApp = NavigationApp.googleMaps,
  }) async {
    Uri uri;

    switch (preferredApp) {
      case NavigationApp.googleMaps:
        uri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
        );
        break;
      case NavigationApp.waze:
        uri = Uri.parse(
          'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
        );
        break;
      case NavigationApp.appleMaps:
        uri = Uri.parse(
          'https://maps.apple.com/?daddr=$latitude,$longitude&q=${Uri.encodeComponent(destinationName)}',
        );
        break;
    }

    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback to web browser
      final webFallback = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );
      return await launchUrl(webFallback, mode: LaunchMode.platformDefault);
    }
  }

  /**
   * Shows an accessible modal sheet for the user to choose navigation app
   */
  static Future<void> showNavigationPicker({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String destinationName,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  'Como deseja navegar para $destinationName?',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.map, size: 32, color: Colors.blue),
                title: const Text('Google Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  launchNavigation(
                    latitude: latitude,
                    longitude: longitude,
                    destinationName: destinationName,
                    preferredApp: NavigationApp.googleMaps,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.navigation, size: 32, color: Colors.cyan),
                title: const Text('Waze', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  launchNavigation(
                    latitude: latitude,
                    longitude: longitude,
                    destinationName: destinationName,
                    preferredApp: NavigationApp.waze,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.apple, size: 32, color: Colors.black),
                title: const Text('Apple Maps', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  launchNavigation(
                    latitude: latitude,
                    longitude: longitude,
                    destinationName: destinationName,
                    preferredApp: NavigationApp.appleMaps,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

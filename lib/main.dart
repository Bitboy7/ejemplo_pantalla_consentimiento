import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar datos persistentes usando SharedPreferences
class DataManager {
  static const String _consentKey = 'user_consent_given';
  static const String _permissionsKey = 'permissions_status';

  /// Guarda si el usuario ha dado su consentimiento
  static Future<void> saveConsentStatus(bool consentGiven) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey, consentGiven);
  }

  /// Obtiene si el usuario ha dado su consentimiento
  static Future<bool> getConsentStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_consentKey) ?? false;
  }

  /// Guarda los estados de permisos
  static Future<void> savePermissionStatuses(
    Map<Permission, PermissionStatus> statuses,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, String> statusStrings = {};

    statuses.forEach((permission, status) {
      statusStrings[permission.toString()] = status.toString();
    });

    // Convertir a lista de strings para guardar
    final List<String> permissionsList = [];
    statusStrings.forEach((permission, status) {
      permissionsList.add('$permission:$status');
    });

    await prefs.setStringList(_permissionsKey, permissionsList);
  }

  /// Obtiene los estados de permisos guardados
  static Future<Map<String, String>> getSavedPermissionStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> permissionsList =
        prefs.getStringList(_permissionsKey) ?? [];

    final Map<String, String> statuses = {};
    for (String item in permissionsList) {
      final parts = item.split(':');
      if (parts.length == 2) {
        statuses[parts[0]] = parts[1];
      }
    }

    return statuses;
  }

  /// Limpia todos los datos guardados
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

// Punto de entrada de la aplicación: lanza ConsentApp.
void main() {
  runApp(const ConsentApp());
}

// Widget raíz de la app que configura tema y pantalla inicial.
class ConsentApp extends StatelessWidget {
  const ConsentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantalla de Consentimiento',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ConsentScreen(),
    );
  }
}

// Pantalla inicial que solicita el consentimiento del usuario.
// Al presionar "Acepto" se piden los permisos y se navega a PermissionsScreen.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  @override
  void initState() {
    super.initState();
    _checkExistingConsent();
  }

  /// Verifica si ya se dio consentimiento anteriormente
  Future<void> _checkExistingConsent() async {
    final consentGiven = await DataManager.getConsentStatus();
    if (consentGiven && mounted) {
      // Si ya se dio consentimiento, ir directamente a la pantalla de permisos
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PermissionsScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consentimiento')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Para continuar, necesitamos tu consentimiento para solicitar permisos de acceso. Por favor, acepta para continuar.',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Guardar que el usuario dio su consentimiento
                await DataManager.saveConsentStatus(true);

                // Al aceptar, solicitar los permisos y pasar los resultados a la pantalla
                final permissions = [
                  Permission.camera,
                  Permission.location,
                  Permission.photos,
                ];

                // request() sobre la lista retorna un Map<Permission, PermissionStatus>
                final statuses = await permissions.request();

                // Guardar los estados de permisos
                await DataManager.savePermissionStatuses(statuses);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PermissionsScreen(initialStatuses: statuses),
                  ),
                );
              },
              child: const Text('Acepto'),
            ),
          ],
        ),
      ),
    );
  }
}

// Pantalla que muestra el estado de los permisos y permite re-solicitarlos.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, this.initialStatuses});

  final Map<Permission, PermissionStatus>? initialStatuses;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  // Mapa local con los estados actuales de permisos.
  Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    // Si la pantalla recibió estados iniciales, úsalos; si no, chequea los permisos actuales
    if (widget.initialStatuses != null) {
      _statuses = Map.from(widget.initialStatuses!);
    } else {
      _loadSavedPermissions();
    }
  }

  /// Carga permisos guardados o verifica el estado actual
  Future<void> _loadSavedPermissions() async {
    final savedStatuses = await DataManager.getSavedPermissionStatuses();

    if (savedStatuses.isNotEmpty) {
      // Si hay datos guardados, mostrarlos primero (conversión omitida por ahora)
      // Después verificar el estado actual real
      await _checkPermissions();
    } else {
      // Si no hay datos guardados, verificar estado actual
      await _checkPermissions();
    }
  }

  // Verifica el estado actual de los permisos listados.
  Future<void> _checkPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.location,
      Permission.photos,
    ];
    final statuses = <Permission, PermissionStatus>{};
    for (final permission in permissions) {
      statuses[permission] = await permission.status;
    }

    // Guardar los estados actualizados
    await DataManager.savePermissionStatuses(statuses);

    setState(() {
      _statuses = statuses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos'),
        actions: [
          // Acción para re-solicitar todos los permisos
          IconButton(
            tooltip: 'Solicitar permisos',
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              final permissions = [
                Permission.camera,
                Permission.location,
                Permission.photos,
              ];
              final newStatuses = await permissions.request();
              // Guardar los nuevos estados
              await DataManager.savePermissionStatuses(newStatuses);
              setState(() {
                _statuses = newStatuses;
              });
            },
          ),
          // Menú para opciones adicionales
          PopupMenuButton<String>(
            tooltip: 'Opciones',
            onSelected: (value) async {
              switch (value) {
                case 'reset_consent':
                  await _resetConsent();
                  break;
                case 'clear_data':
                  await _clearAllData();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset_consent',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 8),
                    Text('Resetear consentimiento'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_data',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever),
                    SizedBox(width: 8),
                    Text('Limpiar todos los datos'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        // Muestra cada permiso con su estado y acción al pulsar
        children: _statuses.entries.map((entry) {
          return ListTile(
            title: Text(entry.key.toString()),
            subtitle: Text(entry.value.toString()),
            trailing: entry.value.isGranted
                ? const Icon(Icons.check, color: Colors.green)
                : entry.value.isPermanentlyDenied
                ? const Icon(Icons.settings, color: Colors.orange)
                : const Icon(Icons.close, color: Colors.red),
            onTap: () async {
              if (entry.value.isPermanentlyDenied) {
                // Si está permanentemente denegado, abrir ajustes para que el usuario cambie permisos.
                await openAppSettings();
              } else {
                // Si no, intentar solicitar el permiso directamente.
                final status = await entry.key.request();
                // Guardar el estado actualizado
                final updatedStatuses = Map<Permission, PermissionStatus>.from(
                  _statuses,
                );
                updatedStatuses[entry.key] = status;
                await DataManager.savePermissionStatuses(updatedStatuses);
                setState(() {
                  _statuses[entry.key] = status;
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  /// Resetea el consentimiento y regresa a la pantalla inicial
  Future<void> _resetConsent() async {
    await DataManager.saveConsentStatus(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConsentScreen()),
    );
  }

  /// Limpia todos los datos guardados y regresa a la pantalla inicial
  Future<void> _clearAllData() async {
    await DataManager.clearAllData();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ConsentScreen()),
    );
  }
}

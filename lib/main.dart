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

  /// Limpia solo los datos de permisos (mantiene consentimiento)
  static Future<void> clearPermissionsOnly() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionsKey);
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Consentimiento',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono decorativo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('🔐', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Título
              const Text(
                'Necesitamos tu permiso',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Descripción en tarjeta
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Para continuar, necesitamos tu consentimiento para solicitar permisos de acceso a la cámara, ubicación y fotos. Estos permisos nos permitirán brindarte la mejor experiencia.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // Botón mejorado
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.blue.withOpacity(0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Acepto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Texto informativo pequeño
              Text(
                'Al aceptar, confirmas que has leído y comprendes los permisos solicitados',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
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

  /// Crea un widget de icono de estado personalizado
  Widget _buildStatusIcon(PermissionStatus status) {
    if (status.isGranted) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '✓',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (status.isPermanentlyDenied) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.orange.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text('⚙', style: TextStyle(color: Colors.white, fontSize: 18)),
        ),
      );
    } else {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.red.shade600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            '✗',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

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

  /// Obtiene un nombre legible para el permiso
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Cámara';
      case Permission.location:
        return 'Ubicación';
      case Permission.photos:
        return 'Fotos';
      default:
        return permission.toString().split('.').last;
    }
  }

  /// Obtiene una descripción del estado del permiso
  String _getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Permite tomar fotos y grabar videos';
      case Permission.location:
        return 'Acceso a tu ubicación GPS';
      case Permission.photos:
        return 'Acceso a tus fotos y galería';
      default:
        return 'Permiso requerido para la aplicación';
    }
  }

  /// Obtiene un emoji representativo del permiso
  String _getPermissionEmoji(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return '📷';
      case Permission.location:
        return '📍';
      case Permission.photos:
        return '🖼️';
      default:
        return '🔐';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Permisos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        actions: [
          // Acción para re-solicitar todos los permisos
          IconButton(
            tooltip: 'Actualizar permisos',
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Text(
                  '⟲',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
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

              // Mostrar confirmación
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permisos actualizados'),
                  duration: Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
      body: _statuses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('⏳', style: TextStyle(fontSize: 50)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Cargando permisos...',
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                final entry = _statuses.entries.elementAt(index);
                final permission = entry.key;
                final status = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () async {
                          if (status.isPermanentlyDenied) {
                            // Mostrar diálogo antes de abrir ajustes
                            final shouldOpen = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Permiso denegado'),
                                content: Text(
                                  'El permiso de ${_getPermissionName(permission).toLowerCase()} está permanentemente denegado. ¿Deseas abrir la configuración de la app?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Abrir ajustes'),
                                  ),
                                ],
                              ),
                            );

                            if (shouldOpen == true) {
                              await openAppSettings();
                            }
                          } else {
                            // Si no, intentar solicitar el permiso directamente
                            final newStatus = await permission.request();
                            final updatedStatuses =
                                Map<Permission, PermissionStatus>.from(
                                  _statuses,
                                );
                            updatedStatuses[permission] = newStatus;
                            await DataManager.savePermissionStatuses(
                              updatedStatuses,
                            );
                            setState(() {
                              _statuses[permission] = newStatus;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Emoji del permiso
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: status.isGranted
                                      ? Colors.green.shade50
                                      : status.isPermanentlyDenied
                                      ? Colors.orange.shade50
                                      : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    _getPermissionEmoji(permission),
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Información del permiso
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _getPermissionName(permission),
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _getPermissionDescription(permission),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: status.isGranted
                                            ? Colors.green.shade100
                                            : status.isPermanentlyDenied
                                            ? Colors.orange.shade100
                                            : Colors.red.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.isGranted
                                            ? 'Concedido'
                                            : status.isPermanentlyDenied
                                            ? 'Denegado permanentemente'
                                            : 'Denegado',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: status.isGranted
                                              ? Colors.green.shade800
                                              : status.isPermanentlyDenied
                                              ? Colors.orange.shade800
                                              : Colors.red.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Icono de estado
                              _buildStatusIcon(status),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

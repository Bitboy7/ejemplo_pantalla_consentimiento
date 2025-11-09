import 'package:permission_handler/permission_handler.dart';

/// Configuración de permisos de la aplicación
class PermissionsConfig {
  // Lista de permisos que maneja esta aplicación
  static const allowedPermissions = [
    Permission.camera,
    Permission.location,
    Permission.photos,
  ];

  /// Obtiene un nombre legible para el permiso
  static String getPermissionName(Permission permission) {
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
  static String getPermissionDescription(Permission permission) {
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

  /// Filtra solo los permisos permitidos de un mapa
  static Map<Permission, PermissionStatus> filterAllowedPermissions(
    Map<Permission, PermissionStatus> allStatuses,
  ) {
    final statuses = <Permission, PermissionStatus>{};
    for (final permission in allowedPermissions) {
      if (allStatuses.containsKey(permission)) {
        statuses[permission] = allStatuses[permission]!;
      }
    }
    return statuses;
  }

  /// Verifica el estado actual de todos los permisos permitidos
  static Future<Map<Permission, PermissionStatus>> checkPermissions() async {
    final statuses = <Permission, PermissionStatus>{};
    for (final permission in allowedPermissions) {
      statuses[permission] = await permission.status;
    }
    return statuses;
  }

  /// Solicita todos los permisos permitidos
  static Future<Map<Permission, PermissionStatus>> requestPermissions() async {
    final allStatuses = await allowedPermissions.request();
    return filterAllowedPermissions(allStatuses);
  }
}

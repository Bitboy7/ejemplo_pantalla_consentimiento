import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widgets personalizados para la aplicación
class PermissionWidgets {
  /// Crea un widget de icono de estado personalizado
  static Widget buildStatusIcon(PermissionStatus status) {
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

  /// Obtiene un icono de Font Awesome para el permiso
  static Widget getPermissionIcon(
    Permission permission,
    PermissionStatus status,
  ) {
    IconData iconData;
    Color iconColor;

    // Determinar color según el estado
    if (status.isGranted) {
      iconColor = Colors.green.shade700;
    } else if (status.isPermanentlyDenied) {
      iconColor = Colors.orange.shade700;
    } else {
      iconColor = Colors.red.shade700;
    }

    // Determinar icono según el permiso
    switch (permission) {
      case Permission.camera:
        iconData = FontAwesomeIcons.camera;
        break;
      case Permission.location:
        iconData = FontAwesomeIcons.locationDot;
        break;
      case Permission.photos:
        iconData = FontAwesomeIcons.images;
        break;
      default:
        iconData = FontAwesomeIcons.lock;
    }

    return FaIcon(iconData, size: 32, color: iconColor);
  }

  /// Obtiene el color de fondo del badge según el estado
  static Color getBadgeColor(PermissionStatus status) {
    if (status.isGranted) {
      return Colors.green.shade100;
    } else if (status.isPermanentlyDenied) {
      return Colors.orange.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  /// Obtiene el color del texto del badge según el estado
  static Color getBadgeTextColor(PermissionStatus status) {
    if (status.isGranted) {
      return Colors.green.shade800;
    } else if (status.isPermanentlyDenied) {
      return Colors.orange.shade800;
    } else {
      return Colors.red.shade800;
    }
  }

  /// Obtiene el texto del badge según el estado
  static String getBadgeText(PermissionStatus status) {
    if (status.isGranted) {
      return 'Concedido';
    } else if (status.isPermanentlyDenied) {
      return 'Denegado permanentemente';
    } else {
      return 'Denegado';
    }
  }
}

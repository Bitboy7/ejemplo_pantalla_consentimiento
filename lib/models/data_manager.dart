import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Clase para manejar datos persistentes usando SharedPreferences
class DataManager {
  static const String _consentKey = 'user_consent_given';
  static const String _permissionsKey = 'permissions_status';
  static const String _termsAcceptedKey = 'terms_accepted';
  static const String _newsletterKey = 'accept_newsletter';
  static const String _offersKey = 'accept_offers';

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

  /// Guarda si el usuario aceptó los términos y condiciones
  static Future<void> saveTermsAccepted(bool accepted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_termsAcceptedKey, accepted);
  }

  /// Obtiene si el usuario aceptó los términos y condiciones
  static Future<bool> getTermsAccepted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_termsAcceptedKey) ?? false;
  }

  /// Guarda las preferencias de contacto
  static Future<void> saveContactPreferences({
    required bool newsletter,
    required bool offers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_newsletterKey, newsletter);
    await prefs.setBool(_offersKey, offers);
  }

  /// Obtiene si el usuario aceptó recibir newsletter
  static Future<bool> getNewsletterPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_newsletterKey) ?? false;
  }

  /// Obtiene si el usuario aceptó recibir ofertas
  static Future<bool> getOffersPreference() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_offersKey) ?? false;
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

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/data_manager.dart';
import '../models/permissions_config.dart';
import '../widgets/permission_widgets.dart';

/// Pantalla que muestra el estado de los permisos y permite re-solicitarlos.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key, this.initialStatuses});

  final Map<Permission, PermissionStatus>? initialStatuses;

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  Map<Permission, PermissionStatus> _statuses = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialStatuses != null) {
      _statuses = PermissionsConfig.filterAllowedPermissions(
        widget.initialStatuses!,
      );
    } else {
      _loadSavedPermissions();
    }
  }

  /// Carga permisos guardados o verifica el estado actual
  Future<void> _loadSavedPermissions() async {
    final savedStatuses = await DataManager.getSavedPermissionStatuses();
    if (savedStatuses.isNotEmpty) {
      await _checkPermissions();
    } else {
      await _checkPermissions();
    }
  }

  /// Verifica el estado actual de los permisos listados
  Future<void> _checkPermissions() async {
    final statuses = await PermissionsConfig.checkPermissions();
    await DataManager.savePermissionStatuses(statuses);
    setState(() {
      _statuses = statuses;
    });
  }

  /// Actualiza todos los permisos
  Future<void> _refreshPermissions() async {
    final newStatuses = await PermissionsConfig.requestPermissions();
    await DataManager.savePermissionStatuses(newStatuses);
    setState(() {
      _statuses = newStatuses;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permisos actualizados'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Maneja el tap en un permiso individual
  Future<void> _handlePermissionTap(
    Permission permission,
    PermissionStatus status,
  ) async {
    if (status.isPermanentlyDenied) {
      final shouldOpen = await _showSettingsDialog(permission);
      if (shouldOpen == true) {
        await openAppSettings();
      }
    } else {
      final newStatus = await permission.request();
      final updatedStatuses = Map<Permission, PermissionStatus>.from(_statuses);
      updatedStatuses[permission] = newStatus;
      await DataManager.savePermissionStatuses(updatedStatuses);
      setState(() {
        _statuses[permission] = newStatus;
      });
    }
  }

  /// Muestra un diálogo para abrir ajustes
  Future<bool?> _showSettingsDialog(Permission permission) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permiso denegado'),
        content: Text(
          'El permiso de ${PermissionsConfig.getPermissionName(permission).toLowerCase()} está permanentemente denegado. ¿Deseas abrir la configuración de la app?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Abrir ajustes'),
          ),
        ],
      ),
    );
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
            onPressed: _refreshPermissions,
          ),
        ],
      ),
      body: _statuses.isEmpty ? _buildLoadingState() : _buildPermissionsList(),
    );
  }

  /// Widget de estado de carga
  Widget _buildLoadingState() {
    return Center(
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
    );
  }

  /// Lista de permisos
  Widget _buildPermissionsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _statuses.length,
      itemBuilder: (context, index) {
        final entry = _statuses.entries.elementAt(index);
        final permission = entry.key;
        final status = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildPermissionCard(permission, status),
        );
      },
    );
  }

  /// Tarjeta individual de permiso
  Widget _buildPermissionCard(Permission permission, PermissionStatus status) {
    return Container(
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
          onTap: () => _handlePermissionTap(permission, status),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                PermissionWidgets.getPermissionIcon(permission, status),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        PermissionsConfig.getPermissionName(permission),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        PermissionsConfig.getPermissionDescription(permission),
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
                          color: PermissionWidgets.getBadgeColor(status),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          PermissionWidgets.getBadgeText(status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: PermissionWidgets.getBadgeTextColor(status),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                PermissionWidgets.buildStatusIcon(status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

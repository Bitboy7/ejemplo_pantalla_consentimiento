import 'package:flutter/material.dart';
import '../models/data_manager.dart';
import 'consent_screen.dart';

/// Pantalla de aceptación de términos y condiciones
class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
  bool _acceptedTerms = false;
  bool _acceptNewsletter = false;
  bool _acceptOffers = false;

  @override
  void initState() {
    super.initState();
    _checkExistingTerms();
  }

  /// Verifica si ya se aceptaron los términos anteriormente
  Future<void> _checkExistingTerms() async {
    final termsAccepted = await DataManager.getTermsAccepted();
    if (termsAccepted && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConsentScreen()),
      );
    }
  }

  /// Verifica si se puede continuar (términos obligatorios aceptados)
  bool get _canContinue => _acceptedTerms;

  /// Maneja el botón continuar
  Future<void> _handleContinue() async {
    if (!_canContinue) return;

    // Guardar que el usuario aceptó los términos
    await DataManager.saveTermsAccepted(true);

    // Guardar las preferencias de contacto
    await DataManager.saveContactPreferences(
      newsletter: _acceptNewsletter,
      offers: _acceptOffers,
    );

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConsentScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Términos',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icono decorativo
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('📋', style: TextStyle(fontSize: 40)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Sección obligatoria: Términos y condiciones
                    _buildSection(
                      title: 'Términos y condiciones',
                      isRequired: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Para utilizar nuestra aplicación, debes leer y aceptar nuestras políticas. Esto incluye el manejo de datos personales, políticas de privacidad y uso responsable de la aplicación.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCheckbox(
                            value: _acceptedTerms,
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value ?? false),
                            label:
                                'He leído y acepto los términos y condiciones',
                            isRequired: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sección opcional: Permisos de contacto
                    _buildSection(
                      title: 'Permisos de contacto',
                      isRequired: false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Deseas recibir información adicional?',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildCheckbox(
                            value: _acceptNewsletter,
                            onChanged: (value) => setState(
                              () => _acceptNewsletter = value ?? false,
                            ),
                            label:
                                'Acepto recibir un resumen semanal con novedades y contenidos',
                            isRequired: false,
                          ),
                          const SizedBox(height: 12),
                          _buildCheckbox(
                            value: _acceptOffers,
                            onChanged: (value) =>
                                setState(() => _acceptOffers = value ?? false),
                            label:
                                'Acepto recibir información sobre productos y ofertas especiales',
                            isRequired: false,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Botón continuar (fijo en la parte inferior)
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _canContinue ? _handleContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _canContinue
                            ? Colors.blue
                            : Colors.grey.shade300,
                        foregroundColor: Colors.white,
                        elevation: _canContinue ? 2 : 0,
                        shadowColor: Colors.blue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade500,
                      ),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  if (!_canContinue)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: Text(
                        'Debes aceptar los términos obligatorios para continuar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget para construir una sección con título
  Widget _buildSection({
    required String title,
    required bool isRequired,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              if (isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '*',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color.fromARGB(255, 11, 11, 11),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  /// Widget para construir un checkbox personalizado
  Widget _buildCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
    required bool isRequired,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: value ? Colors.blue : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
                color: value ? Colors.blue : Colors.white,
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  height: 1.5,
                  fontWeight: isRequired ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

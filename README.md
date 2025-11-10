# Pantalla de Consentimiento - Flutter

Aplicación Flutter modular que demuestra el manejo profesional de permisos con una pantalla de consentimiento previa, usando arquitectura organizada y componentes reutilizables.

## Características

- ✅ Pantalla de consentimiento con diseño Material
- ✅ Gestión completa de permisos con estados visuales
- ✅ Persistencia de datos con SharedPreferences
- ✅ Arquitectura modular

## Permisos Incluidos

- **📷 Cámara**: Acceso a la cámara del dispositivo
- **📍 Ubicación**: Acceso a la ubicación GPS
- **🖼️ Fotos**: Acceso a las imágenes del dispositivo (compatible con Android 13+)

## Instalación y Uso

1. **Clonar el repositorio**:

   ```bash
   git clone https://github.com/Bitboy7/ejemplo_pantalla_consentimiento.git
   cd pantalla_consentimiento
   ```

2. **Instalar dependencias**:

   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## Flujo de la Aplicación

1. **Pantalla de Consentimiento**: Diseño moderno con círculos concéntricos y emoji 🔐
2. **Solicitud de Permisos**: Al pulsar "Acepto", se solicitan automáticamente
3. **Pantalla de Permisos**: Cards con iconos Font Awesome y badges de estado
4. **Gestión de Estados**:
   - ✅ **Verde**: Permiso concedido
   - ❌ **Rojo**: Permiso denegado (tocar para volver a solicitar)
   - ⚙️ **Naranja**: Permanentemente denegado (tocar para abrir ajustes)

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                      # Punto de entrada (20 líneas)
├── models/
│   ├── data_manager.dart          # Gestión de SharedPreferences
│   └── permissions_config.dart    # Configuración de permisos
├── screens/
│   ├── consent_screen.dart        # Pantalla de consentimiento
│   └── permissions_screen.dart    # Pantalla de gestión de permisos
└── widgets/
    └── permission_widgets.dart    # Widgets reutilizables (iconos, badges)
android/
├── app/src/main/
    └── AndroidManifest.xml        # Declaración de permisos Android
pubspec.yaml                       # Dependencias del proyecto
```

## 📦 Dependencias

```yaml
dependencies:
  flutter:
    sdk: flutter
  permission_handler: ^11.3.1 # Manejo de permisos multiplataforma
  shared_preferences: ^2.3.2 # Persistencia de datos local
  font_awesome_flutter: ^10.7.0 # Iconos profesionales
```

## 🔧 Compatibilidad

- **Android**: API 21+ (Android 5.0 Lollipop o superior)
- **Flutter**: 3.19.x o superior
- **Dart**: >=3.9.0 <4.0.0
- **Permisos modernos**: Compatible con Android 13+ (API 33+)

## 💾 Persistencia de Datos

- Estado de consentimiento guardado con SharedPreferences
- Estados de permisos almacenados localmente
- Navegación automática si el consentimiento ya fue dado

## 📝 Licencia

Este es un proyecto de ejemplo para demostración educativa.

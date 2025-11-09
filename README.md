# Pantalla de Consentimiento - Flutter

Aplicación Flutter modular que demuestra el manejo profesional de permisos con una pantalla de consentimiento previa, usando arquitectura organizada y componentes reutilizables.

## ✨ Características

- ✅ Pantalla de consentimiento moderna con diseño Material
- ✅ Gestión completa de permisos con estados visuales
- ✅ Persistencia de datos con SharedPreferences
- ✅ Iconos profesionales con Font Awesome Flutter
- ✅ Arquitectura modular y escalable
- ✅ Manejo de permisos permanentemente denegados
- ✅ Compatibilidad con Android moderno (API 21+)

## 📱 Permisos Incluidos

- **📷 Cámara**: Acceso a la cámara del dispositivo
- **📍 Ubicación**: Acceso a la ubicación GPS
- **🖼️ Fotos**: Acceso a las imágenes del dispositivo (compatible con Android 13+)

## 🚀 Instalación y Uso

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

## 🎯 Flujo de la Aplicación

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

## 🎨 Funcionalidades Destacadas

### 💾 Persistencia de Datos

- Estado de consentimiento guardado con SharedPreferences
- Estados de permisos almacenados localmente
- Navegación automática si el consentimiento ya fue dado

### 🔄 Actualización de Permisos

- Botón de refresh (⟲) en la barra superior
- Re-solicitud de todos los permisos con un tap
- SnackBar de confirmación

### ⚙️ Permisos Permanentemente Denegados

- Diálogo de confirmación antes de abrir ajustes
- Apertura directa de la configuración de la app
- Indicador visual naranja con icono ⚙

### 🎯 Permisos Filtrados

- Evita permisos duplicados (como `locationWhenInUse`)
- Solo muestra los permisos definidos en la app
- Sistema de filtrado automático

### 🎨 Diseño Moderno

- Cards con sombras y bordes redondeados
- Badges de estado con colores temáticos
- Iconos Font Awesome con colores dinámicos según estado
- Emojis decorativos en estados de carga

## 🔨 Personalización

### Agregar Nuevos Permisos

**1. En `models/permissions_config.dart`:**

```dart
static const allowedPermissions = [
  Permission.camera,
  Permission.location,
  Permission.photos,
  Permission.microphone,  // Nuevo permiso
];
```

**2. Agregar nombre y descripción:**

```dart
static String getPermissionName(Permission permission) {
  switch (permission) {
    // ... otros casos
    case Permission.microphone:
      return 'Micrófono';
    // ...
  }
}
```

**3. Agregar icono en `widgets/permission_widgets.dart`:**

```dart
case Permission.microphone:
  iconData = FontAwesomeIcons.microphone;
  break;
```

**4. Declarar en `AndroidManifest.xml`:**

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
```

## 🐛 Troubleshooting

### Los iconos no aparecen

- **Solución**: Los iconos de Font Awesome están correctamente implementados. Si no se ven, ejecuta:
  ```bash
  flutter clean
  flutter pub get
  flutter run
  ```

### Permiso "locationWhenInUse" aparece duplicado

- **Solución**: Ya está solucionado con el sistema de filtrado en `PermissionsConfig.filterAllowedPermissions()`

### Los permisos aparecen como denegados

1. Verificar que están declarados en `AndroidManifest.xml`
2. Limpiar y reconstruir:
   ```bash
   flutter clean && flutter pub get
   ```
3. Desinstalar la app del emulador y volver a instalar

### Error de SDK version

- Verificar que `pubspec.yaml` tiene:
  ```yaml
  environment:
    sdk: ">=3.9.0 <4.0.0"
  ```

## 📝 Licencia

Este es un proyecto de ejemplo para demostración educativa.

## 👤 Autor

Bitboy7 - [GitHub](https://github.com/Bitboy7) 3. Reinstalar la app completamente

### Permiso de almacenamiento no funciona

- En Android 11+, `Permission.storage` está deprecated
- Usar `Permission.photos` o `Permission.videos` en su lugar
- Verificar que `READ_MEDIA_IMAGES` está en el AndroidManifest

## Licencia

Este proyecto es de código abierto para fines educativos y de demostración.

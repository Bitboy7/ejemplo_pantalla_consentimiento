# Ejemplo de pantalla de consentimiento - Flutter

Una pequeña app que demuestra el manejo de permisos con una pantalla previa.

## Características

- ✅ Pantalla de consentimiento inicial
- ✅ Solicitud automática de permisos al aceptar
- ✅ Visualización del estado de cada permiso
- ✅ Manejo de permisos permanentemente denegados
- ✅ Compatibilidad con Android moderno (API 30+)

## Permisos Incluidos

- **Cámara**: Para acceso a la cámara del dispositivo
- **Ubicación**: Para acceso a la ubicación GPS
- **Fotos**: Para acceso a las imágenes del dispositivo (compatible con Android 13+)

## Instalación y Uso

1. **Clonar o descargar el proyecto**

2. **Instalar dependencias**:

   ```bash
   flutter pub get
   ```

3. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

## Flujo de la Aplicación

1. **Pantalla de Consentimiento**: Se muestra al iniciar la app
2. **Solicitud de Permisos**: Al pulsar "Acepto", se solicitan automáticamente los permisos
3. **Pantalla de Permisos**: Muestra el estado actual de cada permiso
4. **Gestión de Estados**:
   - ✅ **Verde**: Permiso concedido
   - ❌ **Rojo**: Permiso denegado (tocar para volver a solicitar)
   - ⚙️ **Naranja**: Permanentemente denegado (tocar para abrir ajustes)

## Estructura del Proyecto

```
lib/
├── main.dart              # Aplicación principal con lógica de permisos
android/
├── app/src/main/
    └── AndroidManifest.xml # Declaración de permisos Android
pubspec.yaml               # Dependencias del proyecto
```

## Dependencias

- `flutter`: Framework principal
- `permission_handler: ^11.3.1`: Manejo de permisos multiplataforma

## Compatibilidad

- **Android**: API 21+ (Android 5.0+)
- **Permisos modernos**: Compatible con Android 13+ (API 33+)
- **Flutter**: 3.19.x o superior
- **Dart**: 3.9.0 o superior

## Funcionalidades Avanzadas

### Refresh de Permisos

- Botón de actualización en la barra superior para volver a solicitar todos los permisos

### Permisos Permanentemente Denegados

- Apertura directa de la pantalla de ajustes del sistema

### Permisos Modernos de Android

- Uso de `READ_MEDIA_IMAGES` y `READ_MEDIA_VIDEO` para Android 13+
- Fallback a `READ_EXTERNAL_STORAGE` para versiones anteriores

## Personalización

Para modificar los permisos solicitados, edita las listas en `lib/main.dart`:

```dart
final permissions = [
  Permission.camera,
  Permission.location,
  Permission.photos,
  // Añadir más permisos aquí
];
```

## Troubleshooting

### Los permisos aparecen como denegados

1. Verificar que los permisos están declarados en `AndroidManifest.xml`
2. Limpiar y reconstruir: `flutter clean && flutter pub get`
3. Reinstalar la app completamente

### Permiso de almacenamiento no funciona

- En Android 11+, `Permission.storage` está deprecated
- Usar `Permission.photos` o `Permission.videos` en su lugar
- Verificar que `READ_MEDIA_IMAGES` está en el AndroidManifest

## Licencia

Este proyecto es de código abierto para fines educativos y de demostración.

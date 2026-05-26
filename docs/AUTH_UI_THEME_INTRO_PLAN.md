# Auth UI, Theme Mode And Intro Plan

## Objetivo

Implementar una experiencia visual basada en los nuevos mocks de UI para MovieFinder, incluyendo:

- Tema claro y oscuro.
- Modo automatico basado en el sistema.
- Toggle manual para cambiar tema.
- Intro animada de la app.
- Logo `iM` recreado con widgets Flutter.
- Login y registro alineados visualmente a los mocks.

## Referencias De Diseno

Mocks ubicados en:

- `docs/mocks-ui/Intro.png`
- `docs/mocks-ui/Intro-2.png`
- `docs/mocks-ui/Login.png`
- `docs/mocks-ui/Login-1.png`
- `docs/mocks-ui/Register.png`
- `docs/mocks-ui/Register-1.png`

## Tema

Crear:

- `lib/core/theme/app_colors.dart`
- `lib/core/theme/app_theme.dart`
- `lib/core/theme/theme_controller.dart`

El tema debe soportar:

- `ThemeMode.system` como modo inicial.
- `ThemeMode.light`.
- `ThemeMode.dark`.
- Cambio manual desde un toggle.

Colores base:

- Verde principal: `#8CF241`.
- Fondo claro: `#FFFFFF`.
- Fondo oscuro: `#000000`.
- Texto claro: `#000000`.
- Texto oscuro: `#FFFFFF`.
- Texto secundario: `#9E9E9E`.
- Error: `#FF8A80`.

## Toggle De Tema

Crear:

- `lib/shared/widgets/theme_mode_toggle.dart`

Comportamiento recomendado:

- Ciclo de tres estados: sistema, claro, oscuro.
- Usar `AnimatedContainer` para el fondo.
- Usar `AnimatedSwitcher` para iconos/texto.
- Mostrar iconos:
  - Sistema: `Icons.brightness_auto`.
  - Claro: `Icons.light_mode`.
  - Oscuro: `Icons.dark_mode`.

## Logo iM Con Widgets

Crear:

- `lib/shared/widgets/movie_finder_logo.dart`

El logo debe recrearse con widgets Flutter, no con imagenes.

Propuesta tecnica:

- Usar `CustomPaint` para dibujar el simbolo `iM`.
- Crear un `CustomPainter` llamado `MovieFinderLogoPainter`.
- Dibujar el punto de la `i` como circulo.
- Dibujar el cuerpo de la `i` como poligono inclinado.
- Dibujar la letra `M` como combinacion de poligonos.
- Exponer propiedades:
  - `size`.
  - `color`.
  - `opacity`.
  - `showLabel`.
  - `labelColor`.

Uso esperado:

- En intro: logo grande, opacidad alta.
- En login/register: logo de fondo translucido.
- En home futuro: logo pequeno en header.

## Intro Animada

Crear:

- `lib/features/intro/presentation/pages/intro_page.dart`

Comportamiento:

- Mostrar `MovieFinderLogo`.
- Mostrar texto `MovieApp`.
- Respetar tema claro/oscuro.
- Esperar entre `1600ms` y `2000ms`.
- Llamar callback `onFinished`.

Animaciones:

- `FadeTransition` para aparicion del logo.
- `ScaleTransition` para entrada del logo.
- `SlideTransition` o `FadeTransition` para el texto.
- Duracion recomendada: `900ms`.
- Delay antes de navegar: `1600ms`.

## Auth UI Compartida

Crear widgets reutilizables:

- `lib/features/auth/presentation/widgets/auth_background_mark.dart`
- `lib/features/auth/presentation/widgets/auth_text_field.dart`
- `lib/features/auth/presentation/widgets/google_sign_in_button.dart`

`auth_background_mark.dart` debe usar `MovieFinderLogo` con baja opacidad.

`auth_text_field.dart` debe centralizar:

- Borde claro/oscuro.
- Hint gris.
- Error style.
- Padding.
- Radio de borde.
- Estilo segun tema.

`google_sign_in_button.dart` debe representar el boton de Google de los mocks.

## Register Page

Actualizar:

- `lib/features/auth/presentation/pages/register_page.dart`

Cambios:

- Usar `Theme.of(context)` y `ColorScheme`.
- Remover colores hardcodeados.
- Agregar `ThemeModeToggle`.
- Usar `AuthBackgroundMark`.
- Usar `AuthTextField`.
- Usar `GoogleSignInButton`.
- Ajustar textos al mock:
  - `Unete y encuentra tus peliculas!` con signos y acentos si se decide permitir Unicode.
  - `Sign up`.
  - `-Or sign in with-`.

## Login Page

Crear:

- `lib/features/auth/presentation/pages/login_page.dart`

Debe incluir:

- Titulo `Bienvenido!` con signos y acentos si se decide permitir Unicode.
- Subtitulo `Login to your Account`.
- Campo email.
- Campo password.
- Boton `Sign In`.
- Boton Google.
- Link a registro: `Don't have an account? Sign up`.
- `ThemeModeToggle`.

## Login Mock Completo

Si se implementa funcionalidad mock completa, agregar:

- `lib/features/auth/data/models/login_request_model.dart`
- `lib/features/auth/domain/usecases/login_user.dart`
- `lib/features/auth/presentation/controllers/login_controller.dart`

Modificar:

- `AuthDataSource`.
- `AuthMockDataSource`.
- `AuthRepository`.
- `AuthRepositoryImpl`.

Metodos nuevos:

- `login(LoginRequestModel request)`.
- `login({required String email, required String password})`.

Validaciones minimas:

- Email obligatorio.
- Password obligatoria.
- Email debe tener formato basico.
- Password debe tener longitud minima.

## Main Flow

Actualizar:

- `lib/main.dart`

Crear estado simple:

```dart
enum AppScreen {
  intro,
  login,
  register,
  home,
}
```

Flujo:

- `intro` al abrir app.
- `login` al finalizar intro.
- `register` desde link de login.
- `login` desde link de registro.
- `home` tras login o registro exitoso.

Usar `AnimatedSwitcher` para transiciones entre pantallas.

Transicion recomendada:

- Fade + slide vertical suave.
- Duracion: `250ms`.

## Verificacion

Ejecutar:

```powershell
flutter analyze
```

Opcional:

```powershell
flutter test
```

## Patch Reversible

Al terminar, generar patch:

```powershell
git diff > docs/feature-auth-ui-theme-intro.patch
```

Aplicar:

```powershell
git apply docs/feature-auth-ui-theme-intro.patch
```

Desaplicar:

```powershell
git apply -R docs/feature-auth-ui-theme-intro.patch
```

## Orden De Implementacion

1. Crear `MovieFinderLogo`.
2. Crear tema claro/oscuro.
3. Crear `ThemeController`.
4. Conectar tema en `main.dart`.
5. Crear `ThemeModeToggle`.
6. Crear `IntroPage`.
7. Crear widgets compartidos de auth.
8. Actualizar `RegisterPage`.
9. Crear `LoginPage`.
10. Agregar login mock completo.
11. Actualizar flujo en `main.dart`.
12. Ejecutar analisis.
13. Generar patch reversible.

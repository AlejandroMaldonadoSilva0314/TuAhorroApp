@echo off
setlocal enabledelayedexpansion

echo ==========================================
echo   TuAhorroApp - Setup GitHub
echo ==========================================
echo.

cd /d "C:\dev\lab_gastos"

REM Limpiar .git roto si existe
if exist ".git" (
    echo Limpiando repositorio anterior...
    rmdir /s /q .git
)

REM Crear .gitignore para Flutter
echo Creando .gitignore...
(
echo # Miscellaneous
echo *.class
echo *.log
echo *.pyc
echo *.swp
echo .DS_Store
echo .atom/
echo .buildlog/
echo .history
echo .svn/
echo migrate_working_dir/
echo.
echo # IntelliJ related
echo *.iml
echo *.ipr
echo *.iws
echo .idea/
echo.
echo # Flutter/Dart/Pub related
echo **/doc/api/
echo **/ios/Runner/GeneratedPluginRegistrant.*
echo .dart_tool/
echo .flutter-plugins
echo .flutter-plugins-dependencies
echo .pub-cache/
echo .pub/
echo /build/
echo.
echo # Android Studio build artifacts
echo /android/app/debug
echo /android/app/profile
echo /android/app/release
) > .gitignore

REM Inicializar Git
echo Inicializando repositorio Git...
git init -b main
git config user.email "jarvisalejandrochaparroperez@gmail.com"
git config user.name "Alejandro"

REM Primer commit
echo Haciendo commit inicial...
git add .
git commit -m "feat: initial commit - TuAhorroApp Flutter project"

echo.
echo ==========================================
echo Comprobando si gh (GitHub CLI) esta instalado...
echo ==========================================
gh --version >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [!] GitHub CLI no esta instalado.
    echo     Instala desde: https://cli.github.com
    echo     Luego ejecuta los siguientes comandos manualmente:
    echo.
    echo     gh auth login
    echo     gh repo create TuAhorroApp --public --source=. --remote=origin --push
    echo.
) else (
    echo GitHub CLI encontrado. Creando repositorio...
    echo.
    REM Verifica si ya estas autenticado
    gh auth status >nul 2>&1
    if %errorlevel% neq 0 (
        echo Necesitas autenticarte primero:
        gh auth login
    )
    gh repo create TuAhorroApp --public --source=. --remote=origin --push
    echo.
    echo ==========================================
    echo  Repositorio creado y subido exitosamente!
    echo  URL: https://github.com/tu_usuario/TuAhorroApp
    echo ==========================================
)

echo.
pause

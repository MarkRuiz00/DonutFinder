@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo.
echo === DonutFinder: generar JAR ===
echo.

where java >nul 2>&1
if errorlevel 1 (
    echo [ERROR] No encuentra "java" en el PATH.
    echo.
    echo 1) Instala JDK 21:
    echo    https://adoptium.net/temurin/releases/?version=21
    echo    Elige: Windows x64, JDK, .msi
    echo.
    echo 2) Al instalar, marca "Add to PATH" o reinicia el PC.
    echo.
    echo 3) Vuelve a ejecutar este archivo: build-jar.bat
    echo.
    echo   O lee: COMPILE-EN-LA-NUBE.txt  (compilar en GitHub, sin instalar Java)
    echo.
    pause
    exit /b 1
)

echo Java OK:
java -version
echo.

if not exist "gradlew.bat" (
    echo [ERROR] No esta gradlew.bat en esta carpeta.
    pause
    exit /b 1
)

call gradlew.bat build --no-daemon
if errorlevel 1 (
    echo.
    echo [ERROR] El build fallo. Copia el mensaje de arriba y pegalo si pides ayuda.
    pause
    exit /b 1
)

echo.
echo === LISTO ===
echo El JAR deberia estar aqui (abre la carpeta en el Explorador):
echo   %CD%\build\libs\
echo.
dir /b "build\libs\*.jar" 2>nul
if errorlevel 1 (
    echo [AVISO] No hay .jar en build\libs. Revisa errores arriba.
) else (
    echo.
    echo Copia el archivo que NO termina en -sources ni -dev (si hay varios).
)

echo.
pause

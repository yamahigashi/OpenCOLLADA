@echo off
REM Build script for COLLADAMaya plugin

setlocal

REM Set default Maya version if not specified
if "%1"=="" (
    set MAYA_VERSION=2024
) else (
    set MAYA_VERSION=%1
)

echo Building COLLADAMaya plugin for Maya %MAYA_VERSION%
echo ================================================

REM Set Maya environment variables
call set_maya_env.bat

REM Try to get Maya installation path from registry
set MAYA_INSTALL_BASE_PATH=
for /f "skip=2 tokens=2*" %%A ^
in ('reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Autodesk\Maya\%MAYA_VERSION%\Setup\InstallPath" /v "MAYA_INSTALL_LOCATION" 2^>nul') ^
do set "MAYALOC=%%B"

if defined MAYALOC (
    REM Extract Autodesk base directory from Maya location
    for %%i in ("%MAYALOC%\..") do set "MAYA_INSTALL_BASE_PATH=%%~fi"
    echo Found Maya %MAYA_VERSION% at: %MAYALOC%
    echo Using Autodesk base path: %MAYA_INSTALL_BASE_PATH%
) else (
    REM Fallback to environment variable or default path
    if defined MAYA_PATH%MAYA_VERSION%_X64 (
        call set "MAYALOC=%%MAYA_PATH%MAYA_VERSION%_X64%%"
        for %%i in ("%%MAYA_PATH%MAYA_VERSION%_X64%%\..") do set "MAYA_INSTALL_BASE_PATH=%%~fi"
        echo Using Maya path from environment variable
    ) else (
        echo WARNING: Could not find Maya %MAYA_VERSION% in registry or environment variables
        echo Trying default location: C:\Program Files\Autodesk
        set MAYA_INSTALL_BASE_PATH=C:\Program Files\Autodesk
    )
)

REM Check if Maya is actually installed
if not exist "%MAYA_INSTALL_BASE_PATH%\Maya%MAYA_VERSION%" (
    echo ERROR: Maya %MAYA_VERSION% not found at %MAYA_INSTALL_BASE_PATH%\Maya%MAYA_VERSION%
    echo Please install Maya %MAYA_VERSION% or specify the correct path.
    exit /b 1
)

REM Create build directory
set BUILD_DIR=build_maya%MAYA_VERSION%
if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

REM Configure with CMake
echo Configuring with CMake...
cmake -G "Visual Studio 17 2022" -A x64 ^
      -DBUILD_MAYA_PLUGIN=ON ^
      -DENABLE_DAE2MA_IMPORT=ON ^
      -DMAYA_VERSION=%MAYA_VERSION% ^
      -DMAYA_INSTALL_BASE_PATH="%MAYA_INSTALL_BASE_PATH%" ^
      -DUSE_STATIC=ON ^
      -DUSE_LIBXML=ON ^
      ..

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake configuration failed!
    exit /b 1
)

REM Build the plugin
echo Building plugin...
cmake --build . --config Release --target COLLADAMaya

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed!
    exit /b 1
)

echo.
echo ================================================
echo Build completed successfully!
echo Plugin installed to: %MAYA_INSTALL_BASE_PATH%\Maya%MAYA_VERSION%\bin\plug-ins\COLLADAMaya.mll
echo.
echo To use the plugin:
echo 1. Open Maya %MAYA_VERSION%
echo 2. Go to Window ^> Settings/Preferences ^> Plug-in Manager
echo 3. Find and load COLLADAMaya.mll
echo ================================================

cd ..
endlocal

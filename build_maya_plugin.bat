@echo off
REM Build script for COLLADAMaya plugin

setlocal enabledelayedexpansion

pushd %~dp0
set PFX=%cd%
call :deploy
goto :eof

REM If no argument is provided, build for all supported Maya versions
REM Otherwise, build for the specified version
if "%1"=="" (
    set MAYA_VERSION=2026
    call :build_for_maya %MAYA_VERSION%
    set MAYA_VERSION=2025
    call :build_for_maya %MAYA_VERSION%
    set MAYA_VERSION=2024
    call :build_for_maya %MAYA_VERSION%
    set MAYA_VERSION=2023
    call :build_for_maya %MAYA_VERSION%
    set MAYA_VERSION=2022
    call :build_for_maya %MAYA_VERSION%
    set MAYA_VERSION=2020
    call :build_for_maya %MAYA_VERSION%

) else (
    set MAYA_VERSION=%1
    call :build_for_maya %MAYA_VERSION%
)

goto :eof


REM --------------------------------------------------------------------------
:build_for_maya

echo Building COLLADAMaya plugin for Maya %MAYA_VERSION%
echo ================================================


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
      -DCMAKE_INSTALL_PREFIX="..\..\maya_module" ^
      ..

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: CMake configuration failed!
    cd ..
    exit /b 1
)

REM Build the plugin
echo Building plugin...
cmake --build . --config Release --target COLLADAMaya

if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Build failed!
    cd ..
    exit /b 1
)

REM Return to parent directory after successful build
cd ..
exit /b 0

REM --------------------------------------------------------------------------
:deploy
REM --------------------------------------------------------------------------
echo Deploying to Maya module folder
cd /d %PFX%\maya_module
set zipfile=COLLADAMaya_maya_module_win64_all_version.zip
set source1=COLLADAMaya
set source2=COLLADAMaya.mod
if exist %zipfile% del %zipfile%
echo Creating zip package %zipfile%...
PowerShell -Command "& {Compress-Archive -LiteralPath '%source1%', '%source2%' -DestinationPath '%zipfile%'}"

for %%v in (2026 2025 2024 2023 2022 2020) do (
    set mllpath=%PFX%\maya_module\COLLADAMaya\platforms\win64\%%v\plug-ins\COLLADAMaya.mll
    set scriptdir=%PFX%\maya_module\COLLADAMaya\platforms\win64\%%v\scripts
    echo Checking for COLLADAMaya.mll for Maya %%v at !mllpath!...
    if exist "!mllpath!" (
        echo Packaging COLLADAMaya plugin for Maya %%v...
        set zipfile=COLLADAMaya_maya_module_win64_maya%%v.zip
        if exist !zipfile! del !zipfile!
        set source1=!mllpath!
        set source2=!scriptdir!
        echo Creating zip package !zipfile! with:
        echo  - !source1!
        echo  - !source2!
        PowerShell -Command "& {Compress-Archive -LiteralPath '!source1!', '!source2!' -DestinationPath '!zipfile!'}"

    ) else (
        echo WARNING: COLLADAMaya.mll for Maya %%v not found, skipping...
    )
)
exit /b 0

REM --------------------------------------------------------------------------
:eof
echo Build process completed.
REM --------------------------------------------------------------------------

echo.
echo ================================================
echo Build completed successfully!
echo Plugin package created: %PFX%\maya_module\%zipfile%
echo.
echo You can extract the contents of the zip file to your Maya modules directory.
echo The default location is usually:
echo %USERPROFILE%\Documents\maya\modules
echo.
echo To use the plugin:
echo 1. Open Maya %MAYA_VERSION%
echo 2. Go to Window ^> Settings/Preferences ^> Plug-in Manager
echo 3. Find and load COLLADAMaya.mll
echo ================================================

cd ..
endlocal

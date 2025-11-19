@echo off
setlocal enabledelayedexpansion

set TEMP_CACHE=%TEMP%\dtx_test_cache
set DTX_CACHE_DIR=%TEMP_CACHE%

if exist "%TEMP_CACHE%" rmdir /s /q "%TEMP_CACHE%"
echo Using temp cache dir: %TEMP_CACHE%

REM Determine which binary to use based on DTX_VERSION
if "%DTX_VERSION%"=="" set DTX_VERSION=dev
if "%DTX_VERSION%"=="release" (
    echo Building release version...
    cargo build --release
    set "DTX_BIN=cargo run --release --"
    echo Testing with release build
) else if "%DTX_VERSION%"=="dev" (
    echo Building debug version...
    cargo build
    set "DTX_BIN=cargo run --"
    echo Testing with debug build
) else (
    echo Downloading version %DTX_VERSION%...
    curl -L -o dtx.exe "https://github.com/DiscreteTom/dtx/releases/download/%DTX_VERSION%/dtx-windows-x86_64.exe"
    if not exist target\debug mkdir target\debug
    move dtx.exe target\debug\dtx.exe
    set "DTX_BIN=target\debug\dtx.exe"
    echo Testing with downloaded version: %DTX_VERSION%
)

echo Testing direct binary download...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\2c5f1687\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing zip archive...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe.zip -e dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\75ed4879\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\75ed4879\dtx-test-fixture-windows-x86_64.exe.zip" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing tar.gz archive...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe.tar.gz -e dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\f5a74e81\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\f5a74e81\dtx-test-fixture-windows-x86_64.exe.tar.gz" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing nested zip archive...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe-nested.zip -e bin/dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\c8f7e1ac\bin\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\c8f7e1ac\dtx-test-fixture-windows-x86_64.exe-nested.zip" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing nested tar.gz archive...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe-nested.tar.gz -e bin/dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\4e9f06d2\bin\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-x86_64.exe\4e9f06d2\dtx-test-fixture-windows-x86_64.exe-nested.tar.gz" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe -n my-custom-name -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-custom-name\2c5f1687\my-custom-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with zip...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe.zip -n my-zip-name -e dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-zip-name\75ed4879\my-zip-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-zip-name\75ed4879\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with tar.gz...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe.tar.gz -n my-tar-name -e dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-tar-name\f5a74e81\my-tar-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-tar-name\f5a74e81\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with nested zip...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe-nested.zip -n my-nested-zip -e bin/dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-nested-zip\c8f7e1ac\bin\my-nested-zip.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-nested-zip\c8f7e1ac\bin\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with nested tar.gz...
%DTX_BIN% https://github.com/DiscreteTom/dtx-test-fixture/releases/download/v0.1.1/dtx-test-fixture-windows-x86_64.exe-nested.tar.gz -n my-nested-tar -e bin/dtx-test-fixture-windows-x86_64.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture 0.1.1" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-nested-tar\4e9f06d2\bin\my-nested-tar.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-nested-tar\4e9f06d2\bin\dtx-test-fixture-windows-x86_64.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

if exist "%TEMP_CACHE%" rmdir /s /q "%TEMP_CACHE%"

echo All integration tests passed!

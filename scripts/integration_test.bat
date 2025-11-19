@echo off
REM Integration test script for dtx
REM
REM Usage:
REM   scripts\integration_test.bat                                    - Build and test debug version
REM   set DTX_VERSION=release && scripts\integration_test.bat         - Build and test release version
REM   set DTX_VERSION=v1.0.0 && scripts\integration_test.bat          - Download and test specific version
REM   set DTX_BIN=target\release\dtx.exe && scripts\integration_test.bat  - Test specific binary
REM   set DTX_ARCH=aarch64 && set DTX_VERSION=v1.0.0 && scripts\integration_test.bat  - Download ARM version

setlocal enabledelayedexpansion

if "%DTX_VERSION%"=="" set DTX_VERSION=dev
if "%DTX_ARCH%"=="" set DTX_ARCH=x86_64

set FIXTURE_VERSION=v0.1.2
set TEMP_CACHE=%TEMP%\dtx_test_cache
set DTX_CACHE_DIR=%TEMP_CACHE%

REM Test fixture URLs
set URL_DIRECT=https://github.com/DiscreteTom/dtx-test-fixture/releases/download/%FIXTURE_VERSION%/dtx-test-fixture-windows-%DTX_ARCH%.exe
set URL_ZIP=%URL_DIRECT%.zip
set URL_TAR=%URL_DIRECT%.tar.gz
set URL_NESTED_ZIP=%URL_DIRECT%-nested.zip
set URL_NESTED_TAR=%URL_DIRECT%-nested.tar.gz

REM Compute URL hashes (first 8 chars of SHA256)
for /f %%i in ('echo %URL_DIRECT%^| certutil -hashstring -stdin SHA256 ^| findstr /v "hash CertUtil"') do set "HASH_DIRECT=%%i"
set HASH_DIRECT=%HASH_DIRECT:~0,8%
for /f %%i in ('echo %URL_ZIP%^| certutil -hashstring -stdin SHA256 ^| findstr /v "hash CertUtil"') do set "HASH_ZIP=%%i"
set HASH_ZIP=%HASH_ZIP:~0,8%
for /f %%i in ('echo %URL_TAR%^| certutil -hashstring -stdin SHA256 ^| findstr /v "hash CertUtil"') do set "HASH_TAR=%%i"
set HASH_TAR=%HASH_TAR:~0,8%
for /f %%i in ('echo %URL_NESTED_ZIP%^| certutil -hashstring -stdin SHA256 ^| findstr /v "hash CertUtil"') do set "HASH_NESTED_ZIP=%%i"
set HASH_NESTED_ZIP=%HASH_NESTED_ZIP:~0,8%
for /f %%i in ('echo %URL_NESTED_TAR%^| certutil -hashstring -stdin SHA256 ^| findstr /v "hash CertUtil"') do set "HASH_NESTED_TAR=%%i"
set HASH_NESTED_TAR=%HASH_NESTED_TAR:~0,8%

if exist "%TEMP_CACHE%" rmdir /s /q "%TEMP_CACHE%"
echo Using temp cache dir: %TEMP_CACHE%

REM Determine which binary to use
if not "%DTX_BIN%"=="" (
    echo Using provided DTX_BIN: %DTX_BIN%
) else (
    if "%DTX_VERSION%"=="release" (
        echo Building release version...
        cargo build --release
        set "DTX_BIN=target\release\dtx.exe"
        echo Testing with release build: %DTX_BIN%
    ) else if "%DTX_VERSION%"=="dev" (
        echo Building debug version...
        cargo build
        set "DTX_BIN=target\debug\dtx.exe"
        echo Testing with debug build: %DTX_BIN%
    ) else (
        echo Downloading version %DTX_VERSION% for %DTX_ARCH%...
        curl -L -o dtx.zip "https://github.com/DiscreteTom/dtx/releases/download/%DTX_VERSION%/dtx-windows-%DTX_ARCH%.exe.zip"
        tar -xf dtx.zip
        if not exist target\debug mkdir target\debug
        move dtx.exe target\debug\dtx.exe
        del dtx.zip
        set "DTX_BIN=target\debug\dtx.exe"
        echo Testing with downloaded version: %DTX_VERSION% (%DTX_ARCH%)
    )
)

echo Testing direct binary download...
set URL=%URL_DIRECT%
set HASH=%HASH_DIRECT%
%DTX_BIN% %URL% -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing zip archive...
set URL=%URL_ZIP%
set HASH=%HASH_ZIP%
%DTX_BIN% %URL% -e dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe.zip" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing tar.gz archive...
set URL=%URL_TAR%
set HASH=%HASH_TAR%
%DTX_BIN% %URL% -e dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe.tar.gz" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing nested zip archive...
set URL=%URL_NESTED_ZIP%
set HASH=%HASH_NESTED_ZIP%
%DTX_BIN% %URL% -e bin/dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\bin\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe-nested.zip" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing nested tar.gz archive...
set URL=%URL_NESTED_TAR%
set HASH=%HASH_NESTED_TAR%
%DTX_BIN% %URL% -e bin/dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\bin\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Binary not found in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\dtx-test-fixture-windows-%DTX_ARCH%.exe\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe-nested.tar.gz" (
    echo ERROR: Archive file should not be in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter...
set URL=%URL_DIRECT%
set HASH=%HASH_DIRECT%
%DTX_BIN% %URL% -n my-custom-name -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-custom-name\%HASH%\my-custom-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with zip...
set URL=%URL_ZIP%
set HASH=%HASH_ZIP%
%DTX_BIN% %URL% -n my-zip-name -e dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-zip-name\%HASH%\my-zip-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-zip-name\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with tar.gz...
set URL=%URL_TAR%
set HASH=%HASH_TAR%
%DTX_BIN% %URL% -n my-tar-name -e dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-tar-name\%HASH%\my-tar-name.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-tar-name\%HASH%\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with nested zip...
set URL=%URL_NESTED_ZIP%
set HASH=%HASH_NESTED_ZIP%
%DTX_BIN% %URL% -n my-nested-zip -e bin/dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-nested-zip\%HASH%\bin\my-nested-zip.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-nested-zip\%HASH%\bin\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

echo Testing --name parameter with nested tar.gz...
set URL=%URL_NESTED_TAR%
set HASH=%HASH_NESTED_TAR%
%DTX_BIN% %URL% -n my-nested-tar -e bin/dtx-test-fixture-windows-%DTX_ARCH%.exe -- --version 2>&1 | findstr /C:"dtx-test-fixture %FIXTURE_VERSION:~1%" >nul
if %ERRORLEVEL% neq 0 (
    echo ERROR: Version output incorrect
    exit /b 1
)
echo Checking cache...
if not exist "%TEMP_CACHE%\my-nested-tar\%HASH%\bin\my-nested-tar.exe" (
    echo ERROR: Binary not found with custom name in cache
    exit /b 1
)
if exist "%TEMP_CACHE%\my-nested-tar\%HASH%\bin\dtx-test-fixture-windows-%DTX_ARCH%.exe" (
    echo ERROR: Original entry name should not exist
    exit /b 1
)
echo √ Test passed
echo.

if exist "%TEMP_CACHE%" rmdir /s /q "%TEMP_CACHE%"

echo All integration tests passed!

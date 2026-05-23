# Local Development

This repo uses MSYS2 UCRT64 on Windows for local C development.

## Installed Toolchain

Expected tools:

- GCC
- CMake
- Ninja
- GNU Make
- CMocka
- pkgconf

The expected MSYS2 root is:

```text
C:\msys64
```

## Verify Tools

From PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev-env.ps1
```

If `powershell` is not on PATH, use the absolute path:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\dev-env.ps1
```

## Run Local CI

From PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\local-ci.ps1
```

Absolute path form:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\local-ci.ps1
```

This runs:

- CMake configure
- CMake build
- CTest
- Make clean
- Make tests

## Run One Command In The Dev Environment

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev-env.ps1 make test
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev-env.ps1 cmake --build build --parallel
```

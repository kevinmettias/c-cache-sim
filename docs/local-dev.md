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
- clang-format
- clang-tidy
- cppcheck
- gcov/lcov
- gdb
- bear
- pre-commit

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

## Format

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\format.ps1
```

## Static Analysis

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\analyze.ps1
```

This runs `clang-tidy` using CMake's `compile_commands.json`, then runs `cppcheck`.

## Coverage

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\coverage.ps1
```

Coverage uses GCC/Clang instrumentation and `lcov`.

## Compile Commands

CMake generates `build/compile_commands.json` by default. For non-CMake builds, use `bear`:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\dev-env.ps1 bear -- make test
```

## Pre-Commit

Install hooks after cloning:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\dev-env.ps1 pre-commit install
```

Run hooks manually:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\dev-env.ps1 pre-commit run --all-files
```

## Debugging

Build first, then launch `gdb` against the executable:

```powershell
C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy Bypass -File scripts\dev-env.ps1 gdb build/cache-sim.exe
```

## Valgrind

Valgrind is a Linux tool, not a good native Windows/MSYS2 tool. Use it in WSL, Linux, or CI once the executable and tests are meaningful.

## Run One Command In The Dev Environment

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev-env.ps1 make test
```

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev-env.ps1 cmake --build build --parallel
```

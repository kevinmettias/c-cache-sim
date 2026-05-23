param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $Command
)

$ErrorActionPreference = "Stop"

$msys_root = "C:\msys64"
$ucrt_bin = Join-Path $msys_root "ucrt64\bin"
$usr_bin = Join-Path $msys_root "usr\bin"
$pipx_bin = Join-Path $HOME ".local\bin"

$env:Path = "$pipx_bin;$ucrt_bin;$usr_bin;$env:Path"

if ($Command.Count -eq 0) {
    Write-Host "MSYS2 UCRT64 development environment"
    gcc --version
    cmake --version
    make --version
    pkg-config --modversion cmocka
    clang-format --version
    clang-tidy --version
    cppcheck --version
    gdb --version
    lcov --version
    bear --version
    pre-commit --version
    exit $LASTEXITCODE
}

$program = $Command[0]
$arguments = @()
if ($Command.Count -gt 1) {
    $arguments = $Command[1..($Command.Count - 1)]
}

& $program @arguments
exit $LASTEXITCODE

$ErrorActionPreference = "Stop"

$repo_root = Split-Path -Parent $PSScriptRoot
$dev_env = Join-Path $PSScriptRoot "dev-env.ps1"

function Invoke-Checked {
    param(
        [Parameter(Mandatory = $true)]
        [string[]] $Command
    )

    & $dev_env @Command
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed with exit code ${LASTEXITCODE}: $($Command -join ' ')"
    }
}

Push-Location $repo_root
try {
    Invoke-Checked -Command @(
        "cmake",
        "-S",
        ".",
        "-B",
        "build",
        "-G",
        "Ninja",
        "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    )

    $source_files = Get-ChildItem -Path src, tests -Recurse -File -Include *.c |
        ForEach-Object { $_.FullName }

    foreach ($source_file in $source_files) {
        Invoke-Checked -Command @("clang-tidy", $source_file, "-p", "build")
    }

    Invoke-Checked -Command @(
        "cppcheck",
        "--enable=warning,style,performance,portability",
        "--std=c11",
        "--inline-suppr",
        "--quiet",
        "--project=build/compile_commands.json"
    )
} finally {
    Pop-Location
}

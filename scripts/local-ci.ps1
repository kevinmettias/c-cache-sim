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
    Invoke-Checked -Command @("cmake", "-S", ".", "-B", "build", "-G", "Ninja")
    Invoke-Checked -Command @("cmake", "--build", "build", "--parallel")
    Invoke-Checked -Command @("ctest", "--test-dir", "build", "--output-on-failure")
    Invoke-Checked -Command @("make", "clean")
    Invoke-Checked -Command @("make", "test")
} finally {
    Pop-Location
}

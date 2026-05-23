$ErrorActionPreference = "Stop"

$repo_root = Split-Path -Parent $PSScriptRoot
$dev_env = Join-Path $PSScriptRoot "dev-env.ps1"
$coverage_dir = "build-coverage"

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
        $coverage_dir,
        "-G",
        "Ninja",
        "-DENABLE_COVERAGE=ON"
    )
    Invoke-Checked -Command @("cmake", "--build", $coverage_dir, "--parallel")
    Invoke-Checked -Command @("ctest", "--test-dir", $coverage_dir, "--output-on-failure")
    Invoke-Checked -Command @("lcov", "--capture", "--directory", $coverage_dir, "--output-file", "$coverage_dir/coverage.info")
    Invoke-Checked -Command @("lcov", "--summary", "$coverage_dir/coverage.info")
} finally {
    Pop-Location
}

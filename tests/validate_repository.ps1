$ErrorActionPreference = 'Stop'

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$readmePath = Join-Path $repositoryRoot 'README.md'
$readme = Get-Content -LiteralPath $readmePath -Raw
$errors = [System.Collections.Generic.List[string]]::new()

if ($readme -match '(?m)^(<<<<<<<|=======|>>>>>>>)') {
    $errors.Add('README.md contains unresolved Git conflict markers.')
}

if ($readme -match 'dashboard/index\.html' -and
    -not (Test-Path -LiteralPath (Join-Path $repositoryRoot 'dashboard\index.html'))) {
    $errors.Add('README.md documents dashboard/index.html, but that file does not exist.')
}

$workflowPath = Join-Path $repositoryRoot 'workflow\africa-crisis-intelligence-workflow.json'
try {
    Get-Content -LiteralPath $workflowPath -Raw | ConvertFrom-Json | Out-Null
}
catch {
    $errors.Add("Workflow JSON is invalid: $($_.Exception.Message)")
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ -ErrorAction Continue }
    exit 1
}

Write-Output 'Repository validation passed.'

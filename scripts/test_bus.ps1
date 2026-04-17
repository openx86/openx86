param(
    [string] $OutDir = "build",
    [switch] $ContinueOnFail
)

$runner = Join-Path $PSScriptRoot "run_tb_group.ps1"
$params = @{
    Name = "bus"
    PathPrefixes = @("tb/integration")
    NameRegex = "^bus.*_tb\.sv$"
    OutDir = $OutDir
}
if ($ContinueOnFail) { $params.ContinueOnFail = $true }

& $runner @params
exit $LASTEXITCODE

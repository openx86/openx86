param(
    [string] $OutDir = "build",
    [switch] $ContinueOnFail
)

$runner = Join-Path $PSScriptRoot "run_tb_group.ps1"
$params = @{
    Name = "soc"
    PathPrefixes = @("tb/top")
    NameRegex = ".*_tb\.sv$"
    OutDir = $OutDir
}
if ($ContinueOnFail) { $params.ContinueOnFail = $true }

& $runner @params
exit $LASTEXITCODE

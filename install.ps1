[CmdletBinding()]
param(
    [string]$Workspace = "",
    [string]$ConfigFile = "",
    [string]$CopilotRoot = "",
    [string]$VscodePrompts = ""
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildRoot = Join-Path $scriptRoot ".build\copilot"

if ([string]::IsNullOrWhiteSpace($ConfigFile)) {
    $ConfigFile = Join-Path $scriptRoot "config.env"
}
if (-not (Test-Path -LiteralPath $ConfigFile)) {
    $ConfigFile = Join-Path $scriptRoot "config.example.env"
}

$config = @{
    REASONING_MODEL = ""
    REASONING_LIMIT = ""
    CONTEXT_MODEL = ""
    CONTEXT_LIMIT = ""
}

foreach ($line in Get-Content -LiteralPath $ConfigFile) {
    if ($line -match '^\s*(#|$)') {
        continue
    }
    if ($line -match '^\s*([A-Z_]+)\s*=\s*(.*)\s*$') {
        $key = $Matches[1]
        if ($config.ContainsKey($key)) {
            $config[$key] = $Matches[2].Trim().Trim('"').Trim("'")
        }
    }
}

foreach ($key in $config.Keys) {
    if ([string]::IsNullOrWhiteSpace($config[$key])) {
        throw "Missing $key in $ConfigFile"
    }
}

Remove-Item -LiteralPath $buildRoot -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null

function Copy-Template {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $content = Get-Content -LiteralPath $Source -Raw
    foreach ($key in $config.Keys) {
        $content = $content.Replace("{{$key}}", $config[$key])
    }
    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    [IO.File]::WriteAllText($Destination, $content, [Text.UTF8Encoding]::new($false))
}

function Install-File {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    $parent = Split-Path -Parent $Destination
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
}

$vscodeSource = Join-Path $scriptRoot "adapters\vscode"
$agentBuild = Join-Path $buildRoot "agents"
$promptBuild = Join-Path $buildRoot "prompts"
$skillBuild = Join-Path $buildRoot "skills\studio"
New-Item -ItemType Directory -Path $agentBuild,$promptBuild,$skillBuild -Force | Out-Null

foreach ($file in Get-ChildItem -LiteralPath (Join-Path $vscodeSource "agents") -Filter "*.agent.md") {
    Copy-Template $file.FullName (Join-Path $agentBuild $file.Name)
}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $vscodeSource "prompts") -Filter "*.prompt.md") {
    Copy-Template $file.FullName (Join-Path $promptBuild $file.Name)
}
Copy-Template (Join-Path $vscodeSource "skills\studio\SKILL.md") (Join-Path $skillBuild "SKILL.md")

if ([string]::IsNullOrWhiteSpace($CopilotRoot)) {
    $CopilotRoot = Join-Path $HOME ".copilot"
}
if ([string]::IsNullOrWhiteSpace($VscodePrompts)) {
    $VscodePrompts = Join-Path $env:APPDATA "Code\User\prompts"
}

$copilotRoot = $CopilotRoot
$agentsTarget = Join-Path $copilotRoot "agents"
$skillsTarget = Join-Path $copilotRoot "skills\studio"
$promptsTarget = $VscodePrompts

foreach ($file in Get-ChildItem -LiteralPath $agentBuild -Filter "*.agent.md") {
    Install-File $file.FullName (Join-Path $agentsTarget $file.Name)
}
foreach ($file in Get-ChildItem -LiteralPath $promptBuild -Filter "*.prompt.md") {
    Install-File $file.FullName (Join-Path $promptsTarget $file.Name)
}
Install-File (Join-Path $skillBuild "SKILL.md") (Join-Path $skillsTarget "SKILL.md")

if (-not [string]::IsNullOrWhiteSpace($Workspace)) {
    $workspaceRoot = (Resolve-Path -LiteralPath $Workspace).Path
    foreach ($file in Get-ChildItem -LiteralPath $agentBuild -Filter "*.agent.md") {
        Install-File $file.FullName (Join-Path $workspaceRoot ".github\agents\$($file.Name)")
    }
    foreach ($file in Get-ChildItem -LiteralPath $promptBuild -Filter "*.prompt.md") {
        Install-File $file.FullName (Join-Path $workspaceRoot ".github\prompts\$($file.Name)")
    }
    Install-File (Join-Path $skillBuild "SKILL.md") (Join-Path $workspaceRoot ".github\skills\studio\SKILL.md")
    Write-Output "Installed workspace Copilot files in $workspaceRoot\.github"
}

Write-Output "Installed Copilot agents in $agentsTarget"
Write-Output "Installed VS Code prompts in $promptsTarget"
Write-Output "Installed Copilot skills in $skillsTarget"

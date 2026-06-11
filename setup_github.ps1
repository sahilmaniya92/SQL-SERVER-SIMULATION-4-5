# Simulation 4-5 — Push to GitHub
# https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5

param(
    [string]$RepoUrl = "https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5.git"
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) {
    git init
    git branch -M main
}

$hasCommits = git rev-parse HEAD 2>$null
if (-not $hasCommits) {
    git add .
    git commit -m "Initial commit: Simulation 4-5 team project structure and planning docs"
}

git remote remove origin 2>$null
git remote add origin $RepoUrl
git branch -M main
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "Pushed: https://github.com/sahilmaniya92/SQL-SERVER-SIMULATION-4-5" -ForegroundColor Green
} else {
    Write-Host "Run: gh auth login" -ForegroundColor Yellow
    Write-Host "Then: git push -u origin main" -ForegroundColor Yellow
}

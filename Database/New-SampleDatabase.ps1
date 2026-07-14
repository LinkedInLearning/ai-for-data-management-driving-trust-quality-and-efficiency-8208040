#Requires -Modules dbatools
<#
.SYNOPSIS
    Creates the AI for Data Management course sample database.
.DESCRIPTION
    Creates the database, applies the schema, and imports all CSV sample data.
    Run from the assets\ folder, or pass -AssetPath to point elsewhere.
.PARAMETER SqlInstance
    The SQL Server instance to connect to.
.PARAMETER Database
    Name of the database to create. Defaults to 'AIDatMgmt'.
.PARAMETER AssetPath
    Path to the assets folder containing schema.sql and the CSV files.
    Defaults to the folder this script lives in.
.EXAMPLE
    .\New-SampleDatabase.ps1 -SqlInstance localhost
.EXAMPLE
    .\New-SampleDatabase.ps1 -SqlInstance sql01 -Database CourseDemo
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    $SqlInstance,

    [string]$Database = 'AIDataMgmt',

    [string]$AssetPath = $PSScriptRoot
)

$schemaFile = Join-Path $AssetPath 'schema.sql'

# CSV import order matters — respect FK dependencies
$csvImportOrder = @(
    'warehouses',
    'suppliers',
    'products',
    'customers',
    'orders',
    'order_items',
    'inventory',
    'pipeline_runs',
    'data_quality_checks',
    'daily_order_volume'
)

# ── 1. Create database ────────────────────────────────────────────────────────
Write-Host "Creating database '$Database' on $SqlInstance..." -ForegroundColor Cyan

New-DbaDatabase -SqlInstance $SqlInstance -Name $Database -ErrorAction Stop
Write-Host "  Database created." -ForegroundColor Green

# ── 2. Apply schema ───────────────────────────────────────────────────────────
Write-Host "Applying schema from $schemaFile..." -ForegroundColor Cyan

Invoke-DbaQuery -SqlInstance $SqlInstance -Database $Database `
    -File $schemaFile -ErrorAction Stop

Write-Host "  Schema applied." -ForegroundColor Green

# ── 3. Import CSVs ────────────────────────────────────────────────────────────
Write-Host "Importing sample data..." -ForegroundColor Cyan

foreach ($table in $csvImportOrder) {
    $csvFile = Join-Path $AssetPath "$table.csv"

    if (-not (Test-Path $csvFile)) {
        Write-Warning "  Skipping $table — $csvFile not found."
        continue
    }

    Import-DbaCsv -Path $csvFile `
        -SqlInstance $SqlInstance `
        -Database $Database `
        -Table $table `
        -AutoCreateTable:$false `
        -ErrorAction Stop

    Write-Host "  Imported $table" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done. Connect to [$SqlInstance].[$Database] to get started." -ForegroundColor Cyan

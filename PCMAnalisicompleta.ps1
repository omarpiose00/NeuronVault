# ===================== SCRIPT CON ESCLUSIONE node_modules e nodes =====================
# Definisci i percorsi
$projectRoot = "C:\Users\omarp\NeuronVault"
$outputDir   = "$projectRoot\ANALISI AI"
$outputFile  = "$outputDir\neuronvault_ai_analysis.txt"

# Crea la cartella di output se non esiste
if (!(Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Pulisce eventuale file precedente
if (Test-Path $outputFile) {
    Remove-Item $outputFile
}

# Estensioni dei file da includere
$extensions = @("*.dart", "*.js", "*.ts", "*.json", "*.yaml", "*.yml")

# Directory da cui estrarre i file
$directories = @("assets", "lib", "test")

# Aggiunge pubspec.yaml manualmente
$pubspecPath = Join-Path $projectRoot "pubspec.yaml"
if (Test-Path $pubspecPath) {
    Add-Content -Path $outputFile -Value "`n==== FILE: pubspec.yaml ====`n"
    Get-Content $pubspecPath | Add-Content -Path $outputFile
}

# Cicla tutte le directory e raccoglie i file (escludendo node_modules e nodes)
foreach ($dir in $directories) {
    $fullPath = Join-Path $projectRoot $dir
    foreach ($ext in $extensions) {
        Get-ChildItem -Path $fullPath -Recurse -Include $ext -File |
        Where-Object {
            # Esclude percorsi che contengono \node_modules\ o \nodes\
            $_.FullName -notmatch '\\(?:node_modules|nodes)\\'
        } | ForEach-Object {
            Add-Content -Path $outputFile -Value "`n==== FILE: $($_.FullName) ====`n"
            Get-Content $_.FullName | Add-Content -Path $outputFile
        }
    }
}

Write-Host "✅ Tutti i file sono stati raccolti in: $outputFile"
# =============================================================================

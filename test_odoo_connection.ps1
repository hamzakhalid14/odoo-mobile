# Script pour tester la connexion Odoo
$odooUrl = 'http://localhost:8070'

Write-Host "`n=== TEST CONNEXION ODOO ===" -ForegroundColor Cyan

# Test 1: Vérifier que Odoo répond
Write-Host "`n1️⃣ Test de santé Odoo..." -ForegroundColor Yellow
try {
    $health = Invoke-RestMethod -Uri "$odooUrl/web/health" -Method Get
    Write-Host "✅ Odoo est accessible: $($health.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Erreur: $_" -ForegroundColor Red
    exit
}

# Test 2: Lister les bases de données disponibles
Write-Host "`n2️⃣ Liste des bases de données..." -ForegroundColor Yellow
$dbListBody = @{
    jsonrpc = '2.0'
    method = 'call'
    params = @{}
    id = 1
} | ConvertTo-Json -Depth 10

try {
    $dbList = Invoke-RestMethod -Uri "$odooUrl/web/database/list" -Method Post -Body $dbListBody -ContentType 'application/json'
    Write-Host "📦 Bases disponibles: $($dbList.result -join ', ')" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Impossible de lister les bases: $_" -ForegroundColor Yellow
}

# Test 3: Tester plusieurs combinaisons
Write-Host "`n3️⃣ Test d'authentification..." -ForegroundColor Yellow

$testCombos = @(
    @{db='odoo15'; user='admin'; pass='Hamza123-'},
    @{db='odoo15'; user='admin'; pass='admin'},
    @{db='postgres'; user='admin'; pass='Hamza123-'}
)

foreach ($combo in $testCombos) {
    Write-Host "`n   Testing: DB=$($combo.db), User=$($combo.user)" -ForegroundColor Cyan
    
    $authBody = @{
        jsonrpc = '2.0'
        method = 'call'
        params = @{
            service = 'common'
            method = 'authenticate'
            args = @($combo.db, $combo.user, $combo.pass, @{})
        }
        id = 1
    } | ConvertTo-Json -Depth 10
    
    try {
        $authResult = Invoke-RestMethod -Uri "$odooUrl/jsonrpc" -Method Post -Body $authBody -ContentType 'application/json'
        
        if ($authResult.result -and $authResult.result -ne $false) {
            Write-Host "   ✅ SUCCÈS ! UID = $($authResult.result)" -ForegroundColor Green
            Write-Host "`n🎉 IDENTIFIANTS CORRECTS:" -ForegroundColor Green
            Write-Host "   Database: $($combo.db)" -ForegroundColor White
            Write-Host "   Username: $($combo.user)" -ForegroundColor White
            Write-Host "   Password: $($combo.pass)" -ForegroundColor White
            exit
        } else {
            Write-Host "   ❌ Échec: $($authResult.result)" -ForegroundColor Red
        }
    } catch {
        Write-Host "   ❌ Erreur: $_" -ForegroundColor Red
    }
}

Write-Host "`n⚠️  Aucune combinaison n'a fonctionné." -ForegroundColor Yellow
Write-Host "Vérifiez votre configuration Odoo." -ForegroundColor Yellow

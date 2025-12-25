# Script de diagnostic et correction SSH pour Windows
# À exécuter en tant qu'administrateur sur le serveur (192.168.1.28)

Write-Host "=== Diagnostic et correction SSH ===" -ForegroundColor Cyan
Write-Host ""

$userName = "supdeco_user"
$userProfile = "C:\Users\$userName"
$sshDir = "$userProfile\.ssh"
$authorizedKeysFile = "$sshDir\authorized_keys"
$publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIq3+y8A/5daakCCELAK8HWVeC7XRM3/OEc9o/6w+AVV deploy@mon-laravel"

# 1. Vérifier si l'utilisateur existe
Write-Host "1. Vérification de l'utilisateur..." -ForegroundColor Yellow
$user = Get-LocalUser -Name $userName -ErrorAction SilentlyContinue
if (-not $user) {
    Write-Host "   ERREUR: L'utilisateur $userName n'existe pas!" -ForegroundColor Red
    exit 1
}
Write-Host "   ✓ Utilisateur $userName existe" -ForegroundColor Green

# 2. Créer le dossier .ssh si nécessaire
Write-Host "2. Vérification du dossier .ssh..." -ForegroundColor Yellow
if (-not (Test-Path $sshDir)) {
    Write-Host "   Création du dossier .ssh..." -ForegroundColor Gray
    New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
}
Write-Host "   ✓ Dossier .ssh existe" -ForegroundColor Green

# 3. Créer/Corriger le fichier authorized_keys
Write-Host "3. Configuration du fichier authorized_keys..." -ForegroundColor Yellow
if (Test-Path $authorizedKeysFile) {
    $currentContent = Get-Content $authorizedKeysFile -Raw
    if ($currentContent -notlike "*$publicKey*") {
        Write-Host "   Ajout de la clé publique..." -ForegroundColor Gray
        Set-Content -Path $authorizedKeysFile -Value $publicKey -Force
    } else {
        Write-Host "   La clé est déjà présente" -ForegroundColor Gray
    }
} else {
    Write-Host "   Création du fichier authorized_keys..." -ForegroundColor Gray
    Set-Content -Path $authorizedKeysFile -Value $publicKey -Force
}
Write-Host "   ✓ Fichier authorized_keys configuré" -ForegroundColor Green

# 4. Corriger les permissions du dossier .ssh
Write-Host "4. Correction des permissions du dossier .ssh..." -ForegroundColor Yellow
try {
    # Prendre possession
    takeown /f $sshDir /r /d y 2>&1 | Out-Null
    
    # Supprimer l'héritage
    icacls $sshDir /inheritance:r 2>&1 | Out-Null
    
    # Donner les permissions
    icacls $sshDir /grant "${userName}:(OI)(CI)(F)" 2>&1 | Out-Null
    icacls $sshDir /grant "SYSTEM:(OI)(CI)(F)" 2>&1 | Out-Null
    
    Write-Host "   ✓ Permissions du dossier .ssh corrigées" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Erreur lors de la correction des permissions: $_" -ForegroundColor Yellow
}

# 5. Corriger les permissions du fichier authorized_keys
Write-Host "5. Correction des permissions du fichier authorized_keys..." -ForegroundColor Yellow
try {
    # Prendre possession
    takeown /f $authorizedKeysFile 2>&1 | Out-Null
    
    # Supprimer l'héritage
    icacls $authorizedKeysFile /inheritance:r 2>&1 | Out-Null
    
    # Donner les permissions (lecture seule pour l'utilisateur)
    icacls $authorizedKeysFile /grant "${userName}:(R)" 2>&1 | Out-Null
    icacls $authorizedKeysFile /grant "SYSTEM:(R)" 2>&1 | Out-Null
    
    Write-Host "   ✓ Permissions du fichier authorized_keys corrigées" -ForegroundColor Green
} catch {
    Write-Host "   ⚠ Erreur lors de la correction des permissions: $_" -ForegroundColor Yellow
}

# 6. Vérifier la configuration OpenSSH
Write-Host "6. Vérification de la configuration OpenSSH..." -ForegroundColor Yellow
$sshdConfig = "C:\ProgramData\ssh\sshd_config"
if (Test-Path $sshdConfig) {
    $configContent = Get-Content $sshdConfig -Raw
    if ($configContent -notmatch "AuthorizedKeysFile") {
        Write-Host "   ⚠ AuthorizedKeysFile non configuré dans sshd_config" -ForegroundColor Yellow
        Write-Host "   Ajout de la configuration..." -ForegroundColor Gray
        
        # Ajouter la configuration si elle n'existe pas
        Add-Content -Path $sshdConfig -Value "`nAuthorizedKeysFile .ssh/authorized_keys" -Force
        Write-Host "   ✓ Configuration ajoutée, redémarrage du service SSH..." -ForegroundColor Green
        Restart-Service sshd
    } else {
        Write-Host "   ✓ AuthorizedKeysFile est configuré" -ForegroundColor Green
    }
} else {
    Write-Host "   ⚠ Fichier sshd_config non trouvé" -ForegroundColor Yellow
}

# 7. Vérifier que le service SSH est démarré
Write-Host "7. Vérification du service SSH..." -ForegroundColor Yellow
$sshService = Get-Service -Name sshd -ErrorAction SilentlyContinue
if ($sshService) {
    if ($sshService.Status -ne "Running") {
        Write-Host "   Démarrage du service SSH..." -ForegroundColor Gray
        Start-Service sshd
    }
    Write-Host "   ✓ Service SSH est démarré" -ForegroundColor Green
} else {
    Write-Host "   ERREUR: Service SSH non trouvé!" -ForegroundColor Red
}

# 8. Afficher les permissions finales
Write-Host "`n8. Vérification finale des permissions..." -ForegroundColor Yellow
Write-Host "`nPermissions du dossier .ssh:" -ForegroundColor Cyan
icacls $sshDir
Write-Host "`nPermissions du fichier authorized_keys:" -ForegroundColor Cyan
icacls $authorizedKeysFile
Write-Host "`nContenu du fichier authorized_keys:" -ForegroundColor Cyan
Get-Content $authorizedKeysFile

Write-Host "`n=== Diagnostic terminé ===" -ForegroundColor Cyan
Write-Host "Essayez maintenant de vous connecter depuis votre machine:" -ForegroundColor Yellow
Write-Host "ssh -i `"`$env:USERPROFILE\.ssh\github_actions_supdeco`" supdeco_user@192.168.1.28" -ForegroundColor White


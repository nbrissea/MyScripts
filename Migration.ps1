#==========================================================================
# NOM			: Migration.PS1
# SOCIETE		: U-IRIS-GIE
# VERSIONS		: 1.0 - 17/01/2017 - Creation du Script - FCH
#				Adaptation du script de Bascule à la migration de fichier01 et Ulis01 - FCH
#			1.1 - 19/01/2017 - Remplacement de la fonction CheckUSB par CheckUsbMigration et ajout de l'envoi WebServices - FCH
#				Suppression de la fonction CheckVMsOnBase (propre au base01,base02,base04) - FCH
#			1.21 - 30/01/2017 - ReAdaptation de la Véerification des pre-requis USB (Identique à la bascule) et Ajout d'un Numero de version - FCH
#			1.22 - 07/02/2017 - Deblocage de tous les boutons - FCH
#			1.23 - 08/02/2017 - Ajout des tests de connexions Powershell Winrm dans les pre-requis -FCH
#			1.24 - 10/02/2017 - Modificiation sur exportation des Vms / ajout d'un bouton d'envoi de fin de Phase WebServices - FCH
#			1.25 - 02/03/2017 - Passage en 1.25 suite modification des boucles d'attentes demarrage, arret et winrm dans tous les scripts - FCH
#			1.26 - 08/03/2017 - Passage en 1.26 suite modification de la phase de deblocage final de Phase 2 - FCH
#			1.27 - 15/03/2017 - Passage en 1.27 ajout étapes Export/Import quota VMFICHIER - SRA
#			1.28 - 28/03/2017 - Passage en 1.28 - Diverses corrections suite recette - FCH/SRA
#				Déplacement des boutons de retour arrière en fin - FCH
#				Ajout de la desactivation de l'accès au bouton de retour arrière si la phase 2 de mogration à été jouée -FCH
#			1.29 - 04/04/2017 - Passage en 1.29 suite Pilote Migration Nantes petit port - FCH
#			1.30 - 15/05/2017 - Passage en 1.30 suite Pilote Migration Mareuil et Carquefou - FCH
#			1.31 - 12/06/2017 - Passage en 1.31 - Optimisation + Agrandissement fenêtre de suivi pour les étapes ULIS - FCH
#			1.32 - 26/06/2017 - Passage en 1.32 - Correction import DNS TECH11 - FCH
#			1.33 - 03/08/2017 - Passage en 1.33 - Suite dernier correctif - FCH
#			1.34 - 22/08/2017 - Passage en 1.34 - Suite dernier correctif - SRA
#			1.35 - 23/08/2017 - Passage en 1.35 - Suite dernier correctif Desactivation compte computer - DCO
#			1.36 - 04/09/2017 - Passage en 1.36 - Suite dernier correctif MAJ Paramétrage EAI + Suppression répertoire UlisPourLocosa sur ULIS11 avant migration
#			1.37 - 06/09/2017 - Passage en 1.37 - Suite Correction test existence répertoire ULISPourLocosa - et changement ordre des étapes pour quota - FCH
#			1.38 - 19/09/2017 - Passage en 1.38 - Suite Correction pour intégration paramétrage spécifique compta sur EAI + redirection U32 EAI + DNS TECH11
#			1.39 - 27/09/2017 - Passage en 1.39 - Suite Correction pour intégration paramétrage spécifique compta sur EAI + DNS TECH11 - DCO
#			1.40 - 11/10/2017 - Passage en 1.40 - Modification record TECH11 et FICHIER11 - DCO
#			1.41 - 12/10/2017 - Passage en 1.41 - Correction record CNAME ULIS11 - DCO
#			1.42 - 22/11/2017 - Passage en 1.42 - Traitement Reprise EAI CATL + Post Bascule UGC - MBE
#			1.43 - 27/11/2017 - Passage en 1.43 - Corrections EAI U33 + BBBO - MBE
#			1.44 - 28/11/2017 - Passage en 1.44 - Suite Correction Pre requis - Recuperation des Vms du Base12 - SRA
#			1.45 - 07/12/2017 - Passage en 1.45 - Correction arret service U_Automate - SRA
#			1.46 - 21/12/2017 - Passage en 1.46 - Corrections EAI CNP - MBE
#			1.47 - 05/02/2018 - Passage en 1.47 - Corrections EAI U32 SUNO + CATL_BOBADS - MBE
#  			1.48 - 07/02/2018 - Passage en 1.48 - Correction StopShare - FCH
#			1.49 - 06/03/2018 - Passage en 1.49 - Corrections EAI CATL_BOBADS - MBE
#			1.50 - 13/03/2018 - Passage en 1.50 - Corrections EAI Reprise Paramétrage - MBE
#			1.51 - 26/03/2018 - Passage en 1.51 - Ajout Event ID pour sonde hyps-bck-errs - DCO
#			1.52 - 11/04/2018 - Passage en 1.52 - Suppression dossier ccu_Direction sur FICHIER11 avant migration sinon les droits ne sont pas repris - DCO
#			1.53 - 18/04/2018 - Passage en 1.53 - Correction migration ULIS sur le traitement des fichiers FILEAS.ini (problème de traitement de '+' dans les valeurs) et OUTMGSIN.INI (on ne le supprime plus mais on applique ULIS11)
#			2.00 - 30/11/2023 - Migration USBv2
#           2.01 - 25/07/2024 - Enregistrement du hash password dans fichier pour utilisation dans scripts de migration /rollback
#
# DESCRIPTION	: MIGRATION/ROLLBACK/BLOCK/DEBLOCK  - Menu general
# ARGUMENTS		: -
#==========================================================================
#							CODE COMMUN
#==========================================================================

## Version à modifier à chaque changement
$version = "2"

# Chargement des modules PowerShell
$ErrorActionPreference = "Stop"
try {
    foreach ($module in @("Tools", "Registry")) {
        if (Get-Module $module) {
            Remove-Module $module
        }
        Import-Module ".\Modules\${module}.psm1"
    }
}
catch {
	Write-Host ("/!\\ Erreur lors du chargement des modules ")
	exit 1
}

# Permet de positionner une Box en premier plan (MsgBox ou Inputbox)
[Void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$activateWindow = {
        $null = [reflection.assembly]::loadwithpartialname("microsoft.visualbasic")
        $isWindowFound = $false
        while(-not $isWindowFound) {
            try {
                [microsoft.visualbasic.interaction]::AppActivate($args[0])
                $isWindowFound = $true
            }
            catch {
                sleep -Milliseconds 100
            }
        }
    }

# Clear Console
Clear

# Minimize Console
$showWindowAsync = Add-Type –memberDefinition @”
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
“@ -name “Win32ShowWindowAsync” -namespace Win32Functions –passThru

function Show-PowerShell() {
	[void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 10)
}

function Hide-PowerShell() {
	[void]$showWindowAsync::ShowWindowAsync((Get-Process –id $pid).MainWindowHandle, 2)
}

Hide-PowerShell

#################################################
#VARIABLE VM FICHIER ET ULIS
#################################################

$CCU = $env:CodecarteU
$varFichier= $CCU+"FICHIER11"
$varFICHIER21= $CCU+"FICHIER21"
$varUlis= $CCU+"ULIS11"
$varULIS21=$CCU+"ULIS21"
$varTech=$CCU+"TECH11"
$varTech21=$CCU+"TECH21"
$varBASE21=$CCU+"BASE21"
$varBASE22=$CCU+"BASE22"
$Basedest= $CCU+"BASE21"

## Formatage de la date
$date                  = $(Get-Date -format yyyyMMddHHmm)
$start_time            = (Get-date)
$sep_log               = "---------------------------------------------------"

# Recuperation des credential du technicien pour mapper et ajouter au cluster destination
$domainNameCred = (Get-WmiObject WIN32_ComputerSystem).Domain.ToLower()
$credential = Get-Credential -UserName "$($domainNameCred)\$env:username" -Message "Compte Admin PDV-U"
$credential | Test-Cred
$credential.Password | ConvertFrom-SecureString -key (1..16) | Out-File -FilePath "c:\outils_usb\migration\password.enc"
if ($global:ExitCode -eq 1){exit}

## Function decriture d'une entete de fichier de log ( en fonction du nom du log)
Function LogHeaderWrite ($logfile) {
	# Ecriture de l'entete du fichier
	$sep_log  | set-content $logfile -Encoding Unicode
	"Date                : $start_time" | add-content $logfile
	"Lance par           : $env:username" | add-content $logfile
	"Hostname            : $env:Computername" | add-content $logfile
	$sep_log | add-content $logfile
}

## Declaration du chemin courant
$global:path = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition
$global:path+="\"

## Variables pour Web Services
$confiniFile = $global:path+"config.ini"
$strconfiginifile  = Get-IniContent "$($confiniFile)"

$webserverIP   = $strconfiginifile["WebServices"]["webserverIP"]
$port          = $strconfiginifile["WebServices"]["Port"]

## Chemin du log pour les WebServices

$global:strPathLogWebServices = $global:path+"logs\$($Basedest)_WEBSERVICES.LOG"

LogHeaderWrite $global:strPathLogWebServices

### Rceuperation des informations du point de vente
$PDVS = WB_Get_PDVs $webserverip $port

#################################################
#region Import the Assemblies
#################################################
[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
#endregion

#################################################
# CONFIGURATION DE L'INFO BULLE
#################################################
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.ReshowDelay = 0
$ToolTip.InitialDelay = 0
$ToolTip.IsBalloon = $true

#################################################
# Label Formulaire Commun
#################################################

$label_menu = New-Object System.Windows.Forms.Label
$label_menu.BackColor = [System.Drawing.Color]::FromArgb(0,255,255,255)
$label_menu.DataBindings.DefaultDataSourceUpdateMode = 0
$label_menu.Font = New-Object System.Drawing.Font("Lucida Console",14.25,0,3,0)
$label_menu.ForeColor = [System.Drawing.Color]::FromArgb(255,255,255,255)
$label_menu.Image =  [System.Convert]::FromBase64String( "/9j/4AAQSkZJRgABAQEAYABgAAD/4QAiRXhpZgAATU0AKgAAAAgAAQESAAMAAAABAAEAAAAAAAD/2wBDAAIBAQIBAQICAgICAgICAwUDAwMDAwYEBAMFBwY
HBwcGBwcICQsJCAgKCAcHCg0KCgsMDAwMBwkODw0MDgsMDAz/2wBDAQICAgMDAwYDAwYMCAcIDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDAwMDA
wMDAwMDAwMDAwMDAwMDAz/wAARCABnAeoDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9A
QIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqD
hIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQA
AAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKj
U2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2
Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD9/PwNH4GufHxR8Nd9e0UD3vYv/iqZJ8U/Dca5Gv6EF9Wv4x/WtPq1X+VmH1in/MjocgJ1AJo2
5HHeuX1D4s+GdPs5ribXtHSC3++wvE4+vNfKH7Qn/BZvwD8JNSOjeGtP1DxtrxOBb2A4311YbK8TXfuQfrsvvdkeTmfEmXYFL6xVSb2W7foldn2sAP4gDQR
xgAY+lfmyP23P2wfjkd/gn4O6b4e0yUZhmvoXkc/9tJnjT/yHUeo/FH9vuxG8+FNA/wC2FpaSf+1q61klRfFUin6o8T/Xig9YUKsl3UXb8bP8D9Kix6nmkz
uZeMCvy4H/AAV4+PvwAuEt/ip8IoRaf8trnyZtMJ/H94lfTX7L/wDwVt+FX7TE9tp41K48La/dLxY6rtiz/uSfcesq2TYmEeayku8XdG+C43yvEVPYyk6cu
0k0/TXT8T6ux9KMfSuf/wCFleHv+g1pH/gbF/8AF0z/AIWb4d/6GDRf/A2L/wCKrz1Qrfyn1SxFLfmR0u8+ho3n0Nc1/wALN8O/9DBov/gbF/8AFUn/AAs/
w7/0MGjf+BkX/wAVTWHq/wAr+5/5D+sUv5jpt59DRvPoa5n/AIWf4d/6GDRv/AyL/wCKo/4Wf4d/6GDRv/AyL/4qj6vV/lf3P/IPrFL+Y6befQ0bz6GuZ/4
Wf4d/6GDRv/AyL/4qj/hZ/h3/AKGDRv8AwMi/+Ko+r1f5X9z/AMg+sUv5jpt59DRvPoa5n/hZ/h3/AKGDRv8AwMi/+Ko/4Wf4d/6GDRv/AAMi/wDiqPq9X+
V/c/8AIPrFL+Y6befQ0bz6GuZ/4Wf4d/6GDRv/AAMi/wDiqP8AhZ/h3/oYNG/8DIv/AIqj6vV/lf3P/IPrFL+Y6befQ0bz6GuZ/wCFn+Hf+hg0b/wMi/8Ai
qP+Fn+Hf+hg0b/wMi/+Ko+r1f5X9z/yD6xS/mOm3n0NG8+hrmf+Fn+Hf+hg0b/wMi/+Ko/4Wf4d/wChg0b/AMDIv/iqPq9X+V/c/wDIPrFL+Y6befQ0bz6G
uZ/4Wf4d/wChg0b/AMDIv/iqP+Fn+Hf+hg0b/wADIv8A4qj6vV/lf3P/ACD6xS/mOm3n0NG8+hrmf+Fn+Hf+hg0b/wADIv8A4qj/AIWf4d/6GDRv/AyL/wC
Ko+r1f5X9z/yD6xS/mOm3n0NG8+hrmf8AhZ/h3/oYNG/8DIv/AIqj/hZ/h3/oYNG/8DIv/iqPq9X+V/c/8g+sUv5jpt59DRvPoa5n/hZ/h3/oYNG/8DIv/i
qP+Fn+Hf8AoYNG/wDAyL/4qj6vV/lf3P8AyD6xS/mOm3n0NG8+hrmf+Fn+Hf8AoYNG/wDAyL/4qj/hZ/h3/oYNG/8AAyL/AOKo+r1f5X9z/wAg+sUv5jpt5
9DRvPoa5n/hZ/h3/oYNG/8AAyL/AOKo/wCFn+Hf+hg0b/wMi/8AiqPq9X+V/c/8g+sUv5jpt59DRvPoa5n/AIWf4d/6GDRv/AyL/wCKo/4Wf4d/6GDRv/Ay
L/4qj6vV/lf3P/IPrFL+Y6befQ0bz6GuZ/4Wf4d/6GDRv/AyL/4qj/hZ/h3/AKGDRv8AwMi/+Ko+r1f5X9z/AMg+sUv5jpt59DRvPoa5n/hZ/h3/AKGDRv8
AwMi/+Ko/4Wf4d/6GDRv/AAMi/wDiqPq9X+V/c/8AIPrFL+Y6befQ0bz6GuZ/4Wf4d/6GDRv/AAMi/wDiqP8AhZ/h3/oYNG/8DIv/AIqj6vV/lf3P/IPrFL
+Y6befQ0bz6GuZ/wCFn+Hf+hg0b/wMi/8AiqP+Fn+Hf+hg0b/wMi/+Ko+r1f5X9z/yD6xS/mOm3n0NG8+hrmf+Fn+Hf+hg0b/wMi/+Ko/4Wf4d/wChg0b/A
MDIv/iqPq9X+V/c/wDIPrFL+Y6befQ0bz6GuZ/4Wf4d/wChg0b/AMDIv/iqP+Fn+Hf+hg0b/wADIv8A4qj6vV/lf3P/ACD6xS/mOm3n0NG8+hrmf+Fn+Hf+
hg0b/wADIv8A4qj/AIWf4d/6GDRv/AyL/wCKo+r1f5X9z/yD6xS/mOm3n0NG8+hrmf8AhZ/h3/oYNG/8DIv/AIqj/hZ/h3/oYNG/8DIv/iqPq9X+V/c/8g+
sUv5jpt59DRvPoa5n/hZ/h3/oYNG/8DIv/iqP+Fn+Hf8AoYNG/wDAyL/4qj6vV/lf3P8AyD6xS/mOm3n0NG8+hrmf+Fn+Hf8AoYNG/wDAyL/4qj/hZ/h3/o
YNG/8AAyL/AOKo+r1f5X9z/wAg+sUv5jpt59DRvPoa5n/hZ/h3/oYNG/8AAyL/AOKo/wCFn+Hf+hg0b/wMi/8AiqPq9X+V/c/8g+sUv5jpt59DRuPoa5n/A
IWf4d/6GDRv/AyL/wCKo/4Wf4d/6GDRv/AyL/4ql9Xrfyv7n/kH1il/Mfk4Pg54YJ/5Amjf+AEP+Aph+EXhizUyTaLoohzwy2UQYfiQB+ldGj76tfDf4N33
7VHxdtfh/YNNZ6V5H2/xFfQn/jxst/yQJ/tzyf8AouSv6czHG08Fh5VqiXLFXf8AwPM/lnEVsRUqwwmEvKpN2S7eb8kc98Af2T9e/bL8Q3Vv4Jt9P8D+ALO
fyL7xHBYp519J/wAtILb+/wD9dK/RH9m/9g/4b/sxad/xTPh23/tRzmbVL3/Sb2eT++ZH5/KvSfBPgnR/hb4Ns9G0e1t9L0jSoBDbwQjy4oY1q4fG2kjg6n
ZA+nnLX8+53xLXx1Vtyaj0Selj934V4EpYGkqtSPtar+KTV3fy3sjWFsFHygCnEDAyATWdYa5aamCIbqC6P90Opq+zBFyxAAr5+M7n28qDg+RxsZet+HLTx
DZvaX1pb3VtIOYp4FkiP4V8Oftr/wDBFLwj8XLW68QfDdbfwn4oY+d9h/5ht6f9z/li/wDtpX3CfGukbj/xM7LP/XdaW38TabqZKwX1pIR/dlWurCZjVw8r
0pWf4P1PIznhXD5hQcMVRuu7TuvNO10z8I/BN9/wrH4n3XgH4neG9PtdUs5/s/n31innf8Df+NP9uva/+FPeFv8AoC6P/wCAMP8A8RX2V/wVF/YIsf2tfhN
catotvBb+O/D0Bm0u4Uf8faJ8/wBmfjvzs96/Pr9mT4qXHiDw/wD2fqH/ACFdI/0efz/9d5n+3X6/wzxJGrFKei2a7N7NeTeh/O+dZZichxqwtaTlSnrGT/
J+aO7/AOFOeF/+gLo//gDDR/wp7wt/0BdH/wDAGH/4it/z/ajz/av0aOvQSqS/mMD/AIU94W/6Auj/APgDD/8AEUf8Kc8L/wDQF0f/AMAYa3/P9qPP9qas9
rfcL2j7swP+FPeFv+gLo/8A4Aw//EUf8Ke8Lf8AQF0f/wAAYf8A4it/z/ajz/ahLyHzy6yMD/hTnhf/AKAuj/8AgDD/APEn+Qo/4U94W/6Auj/+AMP/AMRW
/wCf7Uef7U7PsvuFzz/mZgH4OeF/+gLo+f8Arxh/+JH9fpR/wp7wt/0BdH/8AYf/AIit/wA/2o8/2os+y+4OeX8xgf8ACnvC3/QF0f8A8AYf/iKP+FOeF/8
AoC6P/wCAMNb/AJ/tR5/tSa62H7R/zGB/wp7wt/0BdH/8AYf/AIij/hT3hb/oC6P/AOAMP/xFb/n+1Hn+1NK3QFOX8xg/8Kc8L/8AQF0c/wDbjD/8SaT/AI
U94W/6Auj/APgDD/8AEVv+f7Uef7UuXrYPaS/mMD/hT3hb/oC6P/4Aw/8AxFL/AMKc8L/9AXRx/wBuMP8A8SK3vP8Aajz/AGp20tYam+sjA/4U54X/AOgLo
/8A4Aw/4H+VH/CnvC3/AEBdH/8AAGH/AOIrf8/2o8/2pcvkTzz/AJmYB+Dnhf8A6Auj/wDgDD/8SP50D4OeF/8AoC6P/wCAMP8A8Sf51v8An+1Hn+1FvIfP
LpIwP+FPeFv+gLo//gDD/wDEUf8ACnPC/P8AxJdG/wDAGH/AVv8An+1Hn+1O2lrB7R/zGD/wpzwv/wBAXRz/ANuMP/xJpP8AhT3hb/oC6P8A+AMP/wARW/5
/tR5/tSS62F7Sf8zMH/hTnhf/AKAujj/txh/+JFJ/wp7wt/0BdH/8AYf/AIit/wA/2o8/2otfoPnl0kYH/CnvC3/QF0f/AMAYf/iKB8HPC/8A0BdH/wDAGH
/4k/zrf8/2o8/2ptX6BzvpIwP+FPeFv+gLo/8A4Aw//EUf8Kc8L/8AQF0f/wAAYf8A4n+lb/n+1Hn+1Pl02Dnf8xgf8Ke8Lf8AQF0f/wAAYf8A4ij/AIU54
X/6Auj/APgDDW/5/tR5/tSt/ViVVf8AMzA/4U94W/6Auj/+AMP/AMRR/wAKe8Lf9AXR/wDwBh/+Irf8/wBqPP8Aakl5FKcusjA/4U54X/6Auj/+AMP/AMSf
5Cj/AIU94W/6Auj/APgDD/8AEVv+f7Uef7U7PsvuFzz/AJmYB+Dnhf8A6Auj5/68Yf8A4kf1+lH/AAp7wt/0BdH/APAGH/4it/z/AGo8/wBqLPsvuDnl/MY
H/CnvC3/QF0f/AMAYf/iKP+FOeF/+gLo//gDDW/5/tR5/tSa62H7R/wAxgf8ACnvC3/QF0f8A8AYf/iKP+FPeFv8AoC6P/wCAMP8A8RW/5/tR5/tTSt0BTl
1kYP8Awpzwv/0BdHP/AG4w/wDxJpP+FPeFv+gLo/8A4Aw//EVv+f7Uef7UrdbBzy/mMD/hT3hb/oC6P/4Aw/8AxFL/AMKc8L/9AXRx/wBuMP8A8SK3vP8Aa
jz/AGp20tYam+sjA/4U54X/AOgLo/8A4Aw/4H+VH/CnvC3/AEBdH/8AAGH/AOIrf8/2o8/2pcvkTzy/mZgH4OeF/wDoC6P/AOAMP/xI/nR/wpzwv/0BdH/8
AYa3/P8Aajz/AGovboHPL+Yowz9K+3f+CZ/wfXwB8CF166A/tbxxP/a057i2+5bJ/wB+xn/gb18EXk51Dwdqv/gP/wB97E/9nr9cvh9ocPh3wJpdhDj7PZ2
cVuB7KmK/MfEnGSjRpYeO0m2/loj3vC7BxxOcYjGT3hFJeTer/A4b9tuRo/2TPiJjvoN4P/IL1/OdpviPUDp9p/xMtQ/7/vX9Fv7ch/4xE+I/voN7/wCiJK
/nJ07/AJB1pX8vcZznCdPl7P8AM/1X+ijhKFfB411qal70d/Rn2h/wQ28Qai37e9nbDUtQa1vNEu/OhnmY+cUZPLNfrf8Ati31zpf7MXj24s5/s11BoV2yT
f3T5D8/pX5Bf8EM13f8FBdJ9P7Ev/8A0OKv13/bXYL+yl8Qu2NBuv8A0TJXpcMyk8tk5d5fkfAePeGpUuP6FOnFJNU9EtPiZ/OfpviPUPsFqP7S1D/Uf893
r7C/4Ih6tf33/BQLSTcXd3dH+xr0fv52l7rXxdp//HjZf9cI6+yf+CGf/KQbSe3/ABJr3/2lXxeS1akswpxv9pH9YeKOW4SHBmMqQpJP2T6f3T9zWAYbT1I
r8e/2+fg1/wAM5/8ABQu6uLG3W10H4iQfb4cN5eLn/lps/wC2n/odfsJ37Eivz2/4LoeD0/4tF4gQf6Va69JYf9s3Tf8A+yV+/wCQV3TxPJ0kmv1X4o/xy8
TstjicnlVt71NqS+9J/LU8P02+/tDT+K9s/ZU+DOhfECDxF4l8WPMfDXhO38+4hhLK1yxDNtypBwAh4UgkleRXzxps+NQr2v8AZZ/aXt/gXfatYazpja14Z
8RQiC/tkwZBgMNyhiFbKsylSRnI5GMH9vxVTF4jJebCX9o0tnZ2ur2b62vbzPynhqrQeIpTxfwdb6rZ2uuqva/keiD9rz4a2N8ttb/BvQZdMiYRpNMIDctE
OAzKYW+fbyQXPP8AEetZH7RXwT8Lj4X6R8RPARuYvD+qyCC5sJ3LtZPgjqxLD5lYMCzckFTtIxuv8B/gV8Y/tEnhPx9J4YvpnhWKzv5P3MJbA2Ik+ySVjg8
rKwDH0IFcH+0Z+zx4+/Z38KmzudXutU8EzXIEbWt1KLVXLkqZYCcI5wDkblzxuJr5/Lp4KGLpRwk50al/ejU5vfVtVrdX10sz7TGU8XLD1JYiEatKz5ZQ5f
dfR6WdtNbnWfCv9nB9X/ZP8W67P4X1S58UNLHHpW61lMskBMDb4o8fNuBf5wDwDg4zXg2pWlzo9/NZ3lvPaXVs5jmhmjMckTA4Ksp5BB7Gvqf4NftAeLIf2
G/Futpqu3UvDF3FY6bMLaH/AEeEC2UJt2bWwHYZYE89a5f9kIWt1B48+MHiqH+2L3w+GuIQY1USXLgyO4AAVWyUAIGF3k8YGOnAZxjcL9br4lKSjO0Um2+Z
8qUVdWUdVr0d9DmxOV4XEUsJRw7cZSi220krJttuzu2rO3dWPGbr4S+K7PSX1OXwv4ih05IvNe6k06ZYFjxneXK7duOc5xWFbrJeXEcMMbyyysEREXczseA
AB1J9K9e0v/gov8RbfxkdQur2wudME25tLFpHHBsI5RZAvmDHYlzyBncMg9F+1Z4B0fRPjZ4A8V6Dbm00/wAbSQXrRKu1PNEkRLAfw7lkQkeuT3r2KOcY+j
XVDMKcYuopOLi21eKu4u9rO3VaM8urlWEqUJ1sFUlLktzKSSum7XVm9L9HqeNwfDHxTc61PpsfhrX5NStoxJLaLp0zTxoejMm3cFORgkYOaxpLa4h1BrSS3
mS6SQwtCyESK4OCpXruzxjrmvq/9t39prX/AIIfFG30jwjLbaTPd2sd/qVz9mjlku3OY0QmQMAqpGOgByevXMf7K2ka94o8GeMfiza6Ha+I/Huq3skOlQyy
COGHO0MymR12qNxGN27ZFtDDcc+dT4oxkcDHMMTTioTSUVzWbk3bVtWUd3e7slqd9XhzDvGfUKFSTnFvmdrpRSu7Wd21otup83a78MPFPhbTHvtT8NeINNs
oiFa4utOmiiUk4ALMoHJ4rnXbzEZfSvsfwRq37S2n+LYZ9e0O01rRJ5Nl3ZSS6ciiJmG7YUdW3Bcgbiw55Brw/wDay+Ac/g/9oy80Xwpo97eW97AmpwWVjb
vcPAj7g4CoCQocNjsAVFdWU8Te1xDwuKlTvyuSlCScbK109mn17PXsc+Z8OqnQ+sYaM9Gk1KNnrs1umujW6Z5V5/tX0Bd+DdIH7AVrrSaVpx1p9T8o3otk+
0lfPYbd+N2MYGM14pf/AAW8a6VYzXV14R8U21tboZZZZdKuEjiQDJZmKYAA5JPSvp34R/FO2+D/AOwHY6/LY2+p3trqEo06G4QmJbkzyBHYeiDc3Y5UYIOC
J4mx6lSoTwclN+0jomtXro30v5+o+HcC1WqwxUeVOnLVrbzt1t5HzP4g+GniTwfZfbtX8Pa5pVnK6xrNd2EsEZY5IXcygZIB49jWL5/tX0Z+zL+2p4k+IHx
Jg8L+OJrPxDonicmxKS2cMfkswIUYRVDKxIVgwPYgjBBf8Ev2btH0L9rTxhZ6pGbrQfAitfRROpkVg2HhD/3tqEnHcoM5Gav/AFir4R1aWZQSlCPOuVtqSv
ayurp3aWvfsZ/2DSxMYTwE3JSkotSSTi7Xvo7NNJvueJaZ8KvFetaTHf2fhjxFeWEqGRLmDTZpInUZyQ4XBAwec9qw7C2uNVvoba2t5rq6uHEccMSF5JXJw
FVRySTwAK9f8Uf8FFviFqPjWW/0u9tNP0hZw0GmtZxSRmMHhZHI8wlh94q68k7dvGNr9s3S9J+I3wp8H/FbTbJdNvfEf+i6lFH9x5QrYJ4GSGjkXdj5gF9K
0o5vmFOrThjqUYqq7RabfLKzajJO267dRVcqwNSFR4OpKUqau00kmk0m1ZvZ9zw/xN4R1bwfeww6xpeo6TO6+akd5bPA7pkjcA4BIyCM+xqfQPBOu+K7Ge7
0vRdX1O2tf9dLa2ckscPGfmZQQvHPPavo34czWn7eHwG/4RnULm3tvH/hFVa1vJs5uISQAzEAsVYAK+M4ZVbviuc/ay+ImmfBvwFZfB7wnOWisFWTXbxRta
5lOG2Eg9ScMw7YRc8EVz0eIsTUrLL1TtXUmpLXlUVrzeaaastHc1nkFCNH697T9zy3T0u5bctu6d7vsfP4lzTUfy12msyWf903PY0/7Rn8q+0UT5Q0vP8Aa
jz/AGrM88+tHnn1o5QNENtct/exTvP9qy4rj5P+BGl88+tHKFzRdvMRl9Kd5/tWW9xh4/8Ae/xpfPPrRygafn+1Hn+1Znnn1o88+tHKBp+f7Uef7VmeefWj
zz60coGn5/tQZN4x61meefWmTT/J+I/nRy9wNRJNqgdcDFO8/wBqzWn+ak88+tHKBolvn3deMU7z/asuO4OZPqP5Uvnn1o5Quafn+1Hn+1Znnn1o88+tHKB
p+f7U128xGX0rO88+tI9xh4/97/GjlA1PP9qPP9qzPPPrR559aOUDRDbXLf3sU7z/AGrLiuPk/wCBGl88+tHKBp+f7Uef7VmeefWjzz60coGizbmVv7pp3n
+1Za3H71v90fzpfPPrRyhc0xLmofs1UJZ/3Tc9jTxdcDgU1FE2aOahv/8AikPEH/P1Zz/aP++HR/8A2Sv2N8Fasmv+ENNuo8D7TZxTj/gacV+MGg31vp/xA
utHuM/ZdXg+z1+lH/BMz4wL8UP2Y9L0y62HXPBUp0DUB/ekhwEk/wCBx7H/ABr8k8SsLJqnWW0W0/nqj7DwwxcMNmuIws9PaJSj520f3HbftxMB+yR8RMjJ
OgXf/oh6/nJ07/kHWlf0u/G/wAnxS+Evifw2SSuuabPZ9enmI6f+zV/Nx4u8Bax8NNeuvC+vW9xa6ppM/wBgvIJ/+WEiV/MnGlNuVOfSzXzuf6nfRMx9CNL
G4VyXO3GVr62s1dLd2e9j6t/4IZTj/h4NpOSBjRb/AP8AQoq/XH9tm5SP9k34gmQ/KNBu8/8Afp6/n2+D/wAXPEHwH+Jem+LfDNx9k13S5dsE4/eQ/wC2jp
/Gle+ftMf8Fcfin+1N8JLrwVf2+g6DpmrfuL37IXM17GeqfP8AcSuPJc+w+FwMsPUvzNu3ndH0fin4P51xBxfh83wTj7GKgpNuzjyybbs9XdPS3U+U9N/5B
1r/ANcK+yf+CG3/ACkI0jPT+xr3/wBpV8gV9+/8EA/gDqXiP4+a78RJrSY6X4es3srec9JbiU5dE/4DivHyGlKpmEHHo7/JH6n4yY+hg+DMbGvJR5qbivNt
WSXm2z9jhjJGOlfAf/BcvXGNh8ItItj/AKVeeI2n/wC2aR8198kgAk8AV+UP/BRL4r2/xt/buOn284udM+GNh9ibH/P7N87/APslfveR0nLEqfSKb/Rfmf4
5+JWYRoZNOm371RqK++7/AAR5rZ33/FYfZ/8AphX1Z+yf4G8M/H/4F+K/BT22j2fjdH+16Zfz2yee0fyEKJMb9oZCrYJwsmcHkV8deA77+0NQutR/5/J67D
StfvNB1KC9sbq5sry2cSRT28jRyxMOjKy4IPuK/fqGSVcRlMKMJ+znHllF9mtVddV0a7H47k2LWBnB1IKaStKL6pqz9Hroz0HxH+zH8RvC+sTWNz4K8RyzQ
Y3Pa2Ml1C2QCNskQZG69icHg4IIr3rU9H1X9n79gHW9F8cSxw6jr92i6NpU0wkltlMkROACduCGkIHCkjOGYivGNN/b5+LOlWENrF4vnMdvGsamWxtppCAM
Dc7xFmPqzEk9SSa83+IPxN134k6u+p6/qt9q965x5l1MZPLUuW2oOiICxIVQFGeAKwqZNm+NnTjmDpxhCSl7t3JtO6SulZN763toe9SzTLMEp1cGpuUouKU
rKKurO9m27dFZH01+zzoGoeLv2A/iLpmlWlzqOoyaopjtbZDJLKF+ysdqjk8KxwOTil/Yysl8XfDj4kfCnU3bRde1WLzbSC8iMcglCkMGVhnKMsZK43YJI6
HHz/8AC39oHxd8Er27l8L63caWbwBZk8uOaOTHIJSRWXcOzYyASM4JrK8RfE/W/FPjmbxNd6jN/b08y3D3kAFtIJRjDr5YUKwwOVA5561FbhfGVJYmlzxUK
klUjJXcozXLa6ta2ne5WH4gw9KnhqnK3OneLTtZxd763unZ9rHeaN+yP8SNS8df2A/hLWLWf7QYWuZoGWzjAwS/nY8sqMHlWOegySBXsP7YniLTtO+LXwv8
Eaddx3beDRb29yVA/du0kKhTjo22MMR23ivHLn9uv4q6loc2mSeMb5bfasO+KCCKfaAP+WyxiQNx94NuPrXmlr4iurTWY9RWeQ30U4uVmf52MgbduO7OTnn
nOa3p5LmWKxEa+YygvZqXKoXd3JWbba0suiMamaZfRw9SlgVJuo1dysrJO9lZu92t3Y9//wCCkUuz9pi4J5P9m23/AKCa7j9kvV9R+Kf7J/ifwT4b1ufRvG
GmXP22xMN0bWSWMlGwHUhsFg6E9AWXPBr5d+JHxX134u+JjrHiK/Oo6i8awtMYY4iVX7o2xqq8fSs/w54v1HwfrEOo6Tf3mm39vny7i1laKVMjBwy4OCCQR
3BxTnwxUqZNRwEmlUp8rTtePNHuna6ez8mP/WKnDNp46nFuE7pp6OzVnqr2fVanvfg3wL+0D4t8axaK198SNMJm8ua8vL67htYVDYZ/MLbXA6gISW/hzWR8
XfGfif8AZp/aDmj0nx/f+JdesLYWVxqlzCJmi3ZdrcCZphhfl5zwxYYGDnF1v9u/4seINHlsrjxjdRwTjYxt7W3tpRzn5ZI41denVWBryWa+Z542ZmZ3kGS
Tkk0ZZkGKdZzx8KSjytcsI3Ur7ttpO3ktNRY/OMLGly4OVRzumpSlblt2SbTd+r7HsniD9t74neKtBvdM1DxMbix1GF7e4i/s61XzI3BVhlYgRkE8gg17T8
PPhPe/Gn/gnfYaRpLQNq8eoy3VlbyOqfa3SWXKKWIAYoXI/wB3nAyR8Z/afeuu079oDxdo3gWy8N2et3FnpGn3f222igSOOSGbJbesqqJAcsf4sc1pm3DPN
SpwyyMKcozjLayfKnuktd/LTqZ5ZxA41ZSx8pVIuLja93r2benqex/sd/sveLLj4x6brev6Jqnh/RfDc/266uNRha0DFNzIEEgBYbgCSOAoOSMjPe/AX44a
L8RP2vviJazXccOm+OYmsrKVgAs5jURIBnjLx7yAepwOpAr518d/thfEb4q+GZNJ1vxRd3OnPIRJDDDDaiYAEbXMSKXXn7rEjODjIBrzxL1onVlYqynII4I
Ncc+GMZjnVq5jOMZSjyxULtJXUr66tt9Ox008/wANg406eAjJpSU5OVk27NWVrpKzevc9b8VfshfEXw147l0KPwrrGouJxDDd2tsz2c6k4V/O+4ikYJ3sNv
8AFjBr1L9sgW3wf/Zy8AfDR7qC41qxf+0L6OL5vKJEnX2LyuB6hM8V5RpX7c/xV0fQl02HxhfG2SMxhpYIJpwDnrK8ZkJ5+8WyOMHgV59bfEDVofGEevyXs
t5q6Sif7VehbtnkHRnEoYORx94HoK2hk+bYirSnj5Q5aT5ko83vSs0nK60SvsrkTzTLaFOp9SjLmqqzva0U2m0rPV6dbH1j8M7az/YK+BY8Ya1YxXXj7xYB
FYWEx2NbQjDbW7qACGfHOTGnBGawv2zfhtpfxM8E6d8YvB0QbTtXRV1mBFAa2lJ2+YwHRt3yP/tbTzuJr52+Jnxn8R/GXxQNT8TanJql7FbJCkjRpEqIGJC
qqKqjkk8Dkmr/AMP/ANoPxZ8LvDep6Pouqi30rWDm8tJrSC6gnyu05SZHHK8HGMgDOcDHPS4Yx1OrHMo1E8S5e9q+RwenKtG0kkrO25vLiHCSpPL3B/V+Wy
0XMpLXn3tq9Gr7HNXFzst5G9FJqRpSDWdPd5iY8cgngU77UWVT6qD+lfcqkfHORe8/2o8/2qj9p96PtPvT9mHMXIZ90e7/AGmH5E07z/as+G73Rn2dhTvtP
vS9loHNfUuPPmSNOfmYj9DTvP8Aas97vbJF7uBTvtPvT9kHMXvP9qPP9qo/afej7T70ezDmL3n+1Hn+1UftPvR9p96PZhzF7z/amzXG1V/3lH6iqf2n3qO4
u9kWenI/nQ6Wge0tqaXnbeM/d4o8/wBqpvc/O31pv2n3o9mHMXIp9zSY/hbH6A07z/as+K7y0o5+Vh/Knfafen7MOa+pe8/2o8/2qj9p96PtPvS9mHMXvP8
AamvPmSNOfmYj9DVP7T7017vbJF7uBS9kHNY0PP8Aajz/AGqj9p96PtPvT9mHMXIZ90e7/aYfkTTvP9qz4bvdGfZ2FO+0+9L2Wgc19S95/tR5/tVH7T70fa
fen7MOYuLNmZx/dVT/ADp3n+1Z6Xf79lP9wH9ad9p96Xsg5i3cXOy3kb0Umpto9KzJrrELYx0NWoLjdChx1UH9KcafcfOmeF/ELxVrGo6f/aFvc/6VZ/6RB
Xvf7EH7bVv8A/ijZeODlPCviwx6V4xsR/zCrhP9Tdf+Pv8A9s6+e5p64m81XUPhB4gutY0+2+12t5/o99Y/8sb6OnxdwvTxuFlaO61/z9UcmAxlalXhiKEu
WcHdN7Pun5NaH9GWg6/aeJdLttQsLmG6tbqETwyRH91KjYIevnf9tL/gl/8ADz9sorqGq20mj+JlH7rWdN2xTkY4SX/nqnsa/P8A/wCCfX/BUq4/Zls00i4
N34q+Fw/5YD/kJ+GPbZ/Glfq38Dv2kfA/7Rfhr+1vBfiLTNftcfN9nmHmwn+66ffT8RX8nZ9w1Uw05UcTDmh36M/qLgTxJqwqwxWArOjiI7pOzXe3dP5ruf
mN41/4N4fHOnXwbQfiFot3aet5YSRzfkj7Kw7f/g3u+LRGD4s8Ij/t2n/xr9mFYNyCCKUn2r4iXC2Xt3UWvmz+iaP0iONIU+T6wpebjG/32R+YfwS/4N59K
tL62uvHnjW+1VV/19lpsX2WGY+m9v3myv0P+FPwm8P/AAR8EWmgeGdOt9N0yzG2KGAcCuqmlEa5ZgoHfpXyF+2N/wAFYfAf7O/2jQPDNxbeNPHZ/cwaVpje
dHBJ/wBNnTp/uda9zKMhpwlyYSnq935ebeyPy3j7xYzPMqfts/xbcY/DF2Sv5RWjfyOu/wCChv7aVh+x/wDCOaa1Nvd+L9dH2bRbEtzNI3Hmt/sR1+Q/jbx
XcfC/w/8A2P8AaftfjTxHPJf6rP8A8tvMf77vUnxy/aS1i+8f3fjDxxqX/CRfErV/+PGxg/1Ohx/wJ/sVwvgnSrjUNQutY1i5+2areV+9cC8Fyqzi5L3U7y
fRtbJeR/InE2fVM3xKxNRONOHwxe7835npvhvxVqHh/wAP2tvn/wAgJV3/AIWJqH/Pz/6BXJ/b6Pt9f0LDL6EYqPKtD5GWIm3dtnW/8LG1D/n6t6R/iPqCr
zcb/wDZ2hs/ga5P7fR9vqvqdP8AlQvaT7s60/ETUAf+Pjb7YQYpP+Fi6hn/AI+ofxrk/t9H2+msHT/lQe1m+rOsHxG1DLfvhx/EEXn8TR/wsTUBx9qT/gW3
+lcn9vo+30fU6f8AKg9tO27Os/4WLqGf+PqP/gNH/CxNQPP2oceu2uT+30fb6X1Kj2QlVn3Z1n/CxdQ2j/Sofw60N8RtQyv77zMnGNgb+dcn9vo+30fU6fS
KD2k77s6z/hYmof8APz/6BS/8LG1D/n6t65L7fR9vp/U6PZAqs31Z1i/EXUGBxNt5xnYq7v8AGj/hYWof8/S/+O1yf2+j7fSWCp9Yor20+7Os/wCFiagOPt
Sf8C2/0o/4WNqH/P1F/wAB61yf2+j7fR9To9kL2k+7Os/4WNqBcjzs8Z3bF4/E0f8ACxNR/wCfpf8AgW3H6Vyf2+j7fTWDp/yoPbTta7Osb4jagFP+kQt7K
Mk/hQfiLqGP9fs46bUXH4Vyf2+j7fR9Tp/yoFVmurOs/wCFi6gOftUf/Asf0o/4WLqH/P0v/Aelcn9vo+30vqVHsg9pPuzrF+IuoMDibbzjOxV3f40f8LF1
Ac/ao/8AgWP6Vyf2+j7fQsFT6xQe1l3Z1jfEbUNy/vo5NxxhUDfzo/4WJqH/AD8/+gVyf2+lS/ywHTJ9KPqdP+VAq07bs6z/AIWNqH/P1b0n/Cw9QH/L1/6
D/WuaN0D/ABAf8BX/AAo+0Du2cewoWCpbqIvbS7nS/wDCxdQ/5+4f+BYz+lH/AAsXUD/y9L/wHGP1rm/tQ/vDn/ZH+FJ9pAH3zx7AUfU6a+yCqy3udN/wsb
UP+fq3pH+I+oKvNxv/ANnaGz+BrmDeg9XkP/AjR9rXuzH6sTTWDp/yoXtpfzM6g/ETUAf+Pjb7YQYpP+Fi6hn/AI+ofxrmPto/vuP+BGj7WOm5yP8AeNL6l
T/lKdaVtzpx8RtQy374cfxBF5/E0f8ACxNQHH2pP+Bbf6VzAvFBB64ORnml+3f7b/8AfRoWDp/yoSry/mOm/wCFi6hn/j6j/wCA0f8ACxNQPP2oceu2uY+2
D++//fRoF6qjAJHOeDjNJ4Kn/KCqy/mOn/4WLqG0f6VD+HWhviNqGV/feZk4xsDfzrmft3+2/wD30aQ3oPV5D/wI1SwVP+VB7WW6kdP/AMLE1D/n5/8AQKX
/AIWNqH/P1b1y/wBrXoWcj/eJoF4qnIJBxjIPNDwdP+UHVfVs6dfiLqDA4m284zsVd3+NH/CwtQ/5+l/8drmDeg9Xc/8AAjQbtSMFmYehYkflS+p0/wCQr2
8v5jp/+FiagOPtSf8AAtv9KP8AhY2of8/UX/Aetcz9uHQMwHoDgUhvAeruf+BGhYKn/KT7WX8x0/8AwsbUC5HnZ4zu2Lx+Jo/4WJqP/P0v/AtuP0rmPta92
Y/iTQL1VGASOc8HGaHg6f8AKNVpWtzHTt8RtQCn/SIW9lGSfwpy/EXUNo/+MJXLG8B6u5/4Eai+30LB0v5UCrS6SbMj+1PpUU051CsP7fS/2p9K9aVNSVmW
omB4k+HNxp+o/wBoaPc3Fpd/9MKyPDfxq8UfB/xAdQt/7Q0nVbP/AJftKne1mrtv7U+lRXn2e/8A+PjrXymb8IYTGJu1mz0qON2jNXts9mvRrVM9k+G//Bd
j4veEbJID4007Viv/AEHNK6f77p5ddjP/AMHA/wAXrpeNc+GNp/vWUx/9qV8lal8P9H1D/l1qv/wqTR/UV8JW8KaEp3jGP3I9ijn1eEFGOIqR8r3/ADTf4n
rPxq/4KfeN/jfYXVv4o+KHiC6tbv8A5hWhwfZYf/HPL/8AIleTWfxV1jUf9H8L6b/wj1ref6++/wBbeT/8D/gq9p3gfT9PH/HtW1DPb6ef9Hr2sr8N8NQad
S1uy2+Z52JxsJvnlepLvJttffp+Bm+CPAFv4f8A9IuP9Luv+e89dl9vrE/tT6Uf2p9K/Q8Jl9LDw9nSVkeXWqTqy5pM6D+1PpR/an0rn/7U+lH9qfSuvlMu
U6D+1PpR/an0rn/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1PpR/an0rn/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1Pp
R/an0rn/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1PpR/an0rn/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1PpR/an0rn
/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1PpR/an0rn/7U+lH9qfSjlDlOg/tT6Uf2p9K5/8AtT6Uf2p9KOUOU6D+1PpSpqe51BIAJrnv7
U+lLHqmZFGQOaOQOU6j7Wn940fa0/vGsL+0R/eo/tEf3qj2S7E8hu/a0/vGg3iYPzE1hf2iP71IdRGD81CpLsHIbf25Pej7cnvWD/aQ9TR/aQ9TT9kuw+U3
vtye9H25PesH+0h6mj+0h6mhUl2DlN77cnvR9uT3rB/tIepo/tIepodJdg5Te+3J70fbk96wf7SHqaP7SHqaFTXYOU3vtye9H25PesH+0h6mj+0h6mj2S7B
ym99uT3o+3J71g/2kPU0f2kPU0Kkuwcpvfbk96Ptye9YP9pD1NH9pD1NHs12DlN77cnvR9uT3rB/tIepo/tIepo9kuwcpvfbk96Ptye9YP9pD1NH9pD1NCp
rsHKb325Peof7U+lY/9pD1NV/7U+lVGjB/EhpqO7Xz/wCGMr7fR9voorY2D7fR9voooAPt9H2+iigA+30fb6KKAD7fR9voooAPt9H2+iigA+30fb6KKAD7f
R9voooAPt9H2+iigA+30fb6KKAD7fR9voooAPt9H2+iigA+30fb6KKAD7fR9voooAPt9H2+iigA+30fb6KKAD7fR9voooAPt9H2+iigA+30LfjIzwKKKAJP
t0f99vyo+3R/32/KiiiwrB9uj/vt+VH26P8AvsfwooosFhPtsfqf1o+2x+p/WiiiwWD7bH6n9aPtsfqf1ooosFg+2x+p/Wj7bH6n9aKKLBYPtsfqf1o+2x+
p/WiiiwWD7bH6n9aPtsfqf1ooosFg+2x+p/Wj7bH6n9aKKLBYPtsfqf1o+2x+p/WiiiwWD7bH6n9aT7eno1FFFgsH29PRqPt6ejUUUWCwfb09Gpv2+iihBY
//2Q==")
$label_menu.ImageAlign = 64
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 0
$System_Drawing_Point.Y = 0

$label_menu.Location = $System_Drawing_Point
$label_menu.Name = "label_menu"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 103
$System_Drawing_Size.Width = 494
$label_menu.Size = $System_Drawing_Size
$label_menu.TabIndex = 1
$label_menu.Text = "$($CCU) - $($PDVS.Site) "
$label_menu.TextAlign = 1024

# Ajout de l'info Bulle sur le label Image menu
$ToolTip.SetToolTip($label_menu, "A propos")

# Affichage d'un main sur le label_menu
$label_menu.Cursor = "Hand"

#################################################
# OBJET IMAGE : Logo U dans A Propos
#################################################
$pictureBoxlogo2 = New-Object System.Windows.Forms.PictureBox

# Pour coder une image en base64, il suffit de récupérer le résultat de la commande suivante dans une variable
# [convert]::ToBase64String((get-content "c:\temp\capture.png" -encoding byte))

 $pictureboxLogo2.BackgroundImageLayout = 'None'

 $pictureboxLogo2.Image =  [System.Convert]::FromBase64String( "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
YwgL88xWsAAAAASUVORK5CYII=")
$pictureboxLogo2.Location = '2, 2'
$pictureboxLogo2.Name = "pictureboxLogo2"
$pictureboxLogo2.Size = '60, 60'
$pictureboxLogo2.SizeMode = 'StretchImage'
$pictureboxLogo2.TabIndex = 5
$pictureboxLogo2.TabStop = $False

#################################################
# CONFIGURATION DE LA WINDOWS FORM A PROPOS
#################################################

$Apropos = New-Object Windows.Forms.Form
$Apropos.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$Apropos.MaximizeBox = $False
$Apropos.MinimizeBox = $False
$Apropos.Text = "A Propos de ..."
$Apropos.Size = New-Object System.Drawing.Size(350,160)

#################################################
# AJOUT DES COMPOSANTS A PROPOS FORM
#################################################
$label_apropos1 = New-Object System.Windows.Forms.Label
$label_apropos1.AutoSize = $true
$label_apropos1.Location = New-Object System.Drawing.Point(70,20)
$label_apropos1.Size = New-Object System.Drawing.Size(100,20)
$label_apropos1.Text = "U-StoreBoxV2 - Migration
Script développé par U-GIE-IRIS
Powershell v4
Version: $version
Juin 2024
Email : udsi_infrastructure_pdv_serveurs@systeme-u.fr
Tel :
"

## Si Click sur Label Menu

$label_menu.add_Click({
    $Apropos.ShowDialog()
})

## Ajout des elements au formulaire Apropos
$Apropos.Controls.Add($label_apropos1)
$Apropos.Controls.Add($pictureboxLogo2)

#label4 - Veuillez patienter
$label4 = New-Object System.Windows.Forms.Label
$label4.DataBindings.DefaultDataSourceUpdateMode = 0
$label4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",15.75,1,3,0)
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 26
$System_Drawing_Point.Y = 19
$label4.Location = $System_Drawing_Point
$label4.Name = "label4"
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Height = 47
$System_Drawing_Size.Width = 226
$label4.Size = $System_Drawing_Size
$label4.TabIndex = 0
$label4.Text = "Veuillez patienter ..."

#################################################
# CONFIGURATION DE LA WINDOWS FORM VEUILLEZ PATIENTER
#################################################
$form4 = New-Object System.Windows.Forms.Form
$form4.Name = "form4"
$form4.DataBindings.DefaultDataSourceUpdateMode = 0
$form4.MaximizeBox = $False
$form4.MinimizeBox = $False
$form4.ControlBox = $False
$form4.FormBorderStyle = 3
$form4.AutoSize = $true
$form4.AutoSizeMode = "GrowAndShrink"
$form4.WindowState = "Normal"
$form4.StartPosition = "CenterScreen"
$form4.SizeGripStyle = "Hide"

#Ajout label dans formulaire Veuillez patienter
$form4.Controls.Add($label4)

#################################################
# OBJET IMAGE : Logo U GIE IRIS pour le Form
#################################################

# Pour coder une image en base64, il suffit de récupérer le résultat de la commande suivante dans une variable
# [convert]::ToBase64String((get-content "c:\temp\gieiris.png" -encoding byte))

$pictureBoxlogo1 = New-Object System.Windows.Forms.PictureBox
$pictureboxLogo1.BackgroundImageLayout = 'None'
$pictureboxLogo1.Image =  [System.Convert]::FromBase64String( "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
8B6oRutvgunNkAAAAASUVORK5CYII=")
$pictureboxLogo1.Location = '700, 5'
$pictureboxLogo1.Name = "pictureboxLogo1"
$pictureboxLogo1.Size = '120, 40'
$pictureboxLogo1.SizeMode = 'StretchImage'
$pictureboxLogo1.TabIndex = 5
$pictureboxLogo1.TabStop = $False
$pictureboxLogo1.add_Click($pictureboxLogo1_OnClick)

## Fonction d ecriture dans fichier de log
Function LogWrite ($text){
	$text | add-content $global:logname
}

## Function de test si fin de phase2, Disable des boutons de retour arrière
 Function TestKeyPhase2 {
	$keyPhase = "U-DEBLOCK-PHASE2"
	if (FTestPathRegistry "HKLM:\SOFTWARE\$keyPhase"){
		# Statut de la Phase
		$Statut = FLireRegistry "HKLM:\SOFTWARE\$keyPhase\DEBLOCK" "Statut"

		if ($Statut -ne "INI")
		{
			$button2_10.Enabled = $False
			$button2_11.Enabled = $False
			$form2.refresh()
		}
	}
}

#################################################
###Fonction Formulaire Phase 2 ###
#################################################
Function formPhase2{
	#################################################
	###ACTION BOUTON###
	#################################################

	#BOUTON PHASE2 - MIGRATION

	$button2_1_OnClick=
	{
		## Vérification des Pre-requis USB - Attention différent de la bascule car les VMs à migrer sont sur le base21 !!
		## Vérifie la présence des VMs FICHIER21,TECH21,ULIS21
		## Recuperation des VMs à migrer FICHIER11 et ULIS11 sur BASE21 puis envoi de la creation des serveur + Activity vers le serveur WebServices
		checkUsbMigration
	}

	$button2_2_OnClick=
	{
		### controle des pre-requis FICHIER11
		suivi -VMsource $varfichier  -VMDest $varFICHIER21 -BaseDest $Basedest -Block
	}

	$button2_3_OnClick=
	{
		# Migration  FICHIER11
		suivi -VMSource $varfichier -VMDest $varFICHIER21 -BaseDest $Basedest -migration
	}

	$button2_4_OnClick=
	{
		## Deblocage de la FICHIER21
		suivi -VMSource $varfichier -VMDest $varFICHIER21 -BaseDest $Basedest -DeBlock
	}

	$button2_13_OnClick=
	{
		## controle des pre-requis TECH11
		suivi -VMsource $varTech  -VMDest $varTECH21 -BaseDest $Basedest -Block
	}

	$button2_14_OnClick=
	{
		## Migration  TECH11
		suivi -VMSource $varTech -VMDest $varTECH21 -BaseDest $Basedest -migration
	}

	$button2_15_OnClick=
	{
		## Deblocage de la TECH21
		suivi -VMSource $varTech -VMDest $varTECH21 -BaseDest $Basedest -DeBlock
	}

	$button2_6_OnClick=
	{
		## Verification des pre-requis Migration ULIS et blocage
		suivi -VMSource $varulis -VMDest $varulis21 -BaseDest $Basedest -Block
	}

	$button2_7_OnClick=
	{
		## Migration ULIS
		suivi -VMSource $varulis -VMDest $varulis21 -BaseDest $Basedest -migration
	}

	$button2_8_OnClick=
	{
		## Deblocage ULIS21
		suivi -VMSource $varulis -VMDest $varulis21 -BaseDest $Basedest -DeBlock
	}

	$button2_9_OnClick=
	{
		## Deblocage de la Phase 2
		suivi -VMSource "PHASE2" -BaseDest $Basedest -Deblock

		#################################################
		### Verification de l'accès à la Phase 2
		#################################################
		TestKeyPhase2
	}

	$button2_10_OnClick=
	{
		## Retour arrière Migration FICHIER11
		suivi -VMSource $varfichier -VMDest $varFICHIER21 -BaseDest $Basedest -rollback
	}

		$button2_16_OnClick=
	{
		## Retour arrière Migration TECH11
		suivi -VMSource $varTech -VMDest $varTECH21 -BaseDest $Basedest -rollback
	}

	$button2_11_OnClick=
	{
		## Retour arrière Migration ULIS
		suivi -VMSource $varulis -VMDest $varulis21 -BaseDest $Basedest -rollback
	}

	$button2_12_OnClick=
	{
		# Quitter
		$form2.Close()
	}


    #################################################
    ###BOUTON###
    #################################################

    ### BOUTON FORMULAIRE 2 - PHASE 2 - MIGRATION

    #Bouton 2_1 - Vérification prérequis USB - Controle de la presence de toutes les Vms
    $button2_1 = New-Object System.Windows.Forms.Button
    $button2_1.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 115
    $button2_1.Location = $System_Drawing_Point
    $button2_1.Name = "button2_1"
    $button2_1.Enabled = $true
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_1.Size = $System_Drawing_Size
    $button2_1.TabIndex = 0
	$button2_1.Text = "     0. Vérification prérequis USB"
	$button2_1.TextAlign = 16
	$button2_1.UseVisualStyleBackColor = $True
	$button2_1.add_Click($button2_1_OnClick)
	$button2_1.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
	$button2_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
	$ToolTip.SetToolTip($button2_1, "Vérification prérequis USB : présence FICHIER21, ULIS21, TECH21, FICHIER11 et ULIS11")

    #Bouton 2_2 - Vérification des pre-requis Migration Fichier11
    $button2_2 = New-Object System.Windows.Forms.Button
    $button2_2.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 155
    $button2_2.Location = $System_Drawing_Point
    $button2_2.Name = "button2_2"
    $button2_2.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_2.Size = $System_Drawing_Size
    $button2_2.TabIndex = 0
    $button2_2.Text = "     1. Prérequis à la Migration FICHIER11"
    $button2_2.TextAlign = 16
    $button2_2.UseVisualStyleBackColor = $True
    $button2_2.add_Click($button2_2_OnClick)
    $button2_2.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_2, "Pré-requis à la Migration FICHIER11")

    #Bouton 2_3 - Migration FICHIER11
    $button2_3 = New-Object System.Windows.Forms.Button
    $button2_3.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 195
    $button2_3.Location = $System_Drawing_Point
    $button2_3.Name = "button2_3"
    $button2_3.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_3.Size = $System_Drawing_Size
    $button2_3.TabIndex = 0
    $button2_3.Text = "     2. Migration FICHIER11"
    $button2_3.TextAlign = 16
    $button2_3.UseVisualStyleBackColor = $True
    $button2_3.add_Click($button2_3_OnClick)
    $button2_3.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_3, "Migration FICHIER11")

    #Bouton 2_4 - Deblocage FICHIER21
    $button2_4 = New-Object System.Windows.Forms.Button
    $button2_4.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 235
    $button2_4.Location = $System_Drawing_Point
    $button2_4.Name = "button2_4"
    $button2_4.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_4.Size = $System_Drawing_Size
    $button2_4.TabIndex = 0
    $button2_4.Text = "     3. Deblocage FICHIER21"
    $button2_4.TextAlign = 16
    $button2_4.UseVisualStyleBackColor = $True
    $button2_4.add_Click($button2_4_OnClick)
    $button2_4.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_4, "Deblocage FICHIER21")

	#Bouton 2_13 - Vérification des pre-requis Migration Tech11
    $button2_13 = New-Object System.Windows.Forms.Button
    $button2_13.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_13.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 275
    $button2_13.Location = $System_Drawing_Point
    $button2_13.Name = "button2_13"
    $button2_13.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_13.Size = $System_Drawing_Size
    $button2_13.TabIndex = 0
    $button2_13.Text = "     4. Prérequis à la Migration TECH11"
    $button2_13.TextAlign = 16
    $button2_13.UseVisualStyleBackColor = $True
    $button2_13.add_Click($button2_13_OnClick)
    $button2_13.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_13.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_13, "Pré-requis à la Migration TECH11")

    #Bouton 2_14 - Migration TECH11
    $button2_14 = New-Object System.Windows.Forms.Button
    $button2_14.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_14.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 315
    $button2_14.Location = $System_Drawing_Point
    $button2_14.Name = "button2_14"
    $button2_14.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_14.Size = $System_Drawing_Size
    $button2_14.TabIndex = 0
    $button2_14.Text = "     5. Migration TECH11"
    $button2_14.TextAlign = 16
    $button2_14.UseVisualStyleBackColor = $True
    $button2_14.add_Click($button2_14_OnClick)
    $button2_14.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_14.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_14, "Migration TECH11")

    #Bouton 2_15 - Deblocage TECH21
    $button2_15 = New-Object System.Windows.Forms.Button
    $button2_15.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_15.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 355
    $button2_15.Location = $System_Drawing_Point
    $button2_15.Name = "button2_15"
    $button2_15.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_15.Size = $System_Drawing_Size
    $button2_15.TabIndex = 0
    $button2_15.Text = "     6. Deblocage TECH21"
    $button2_15.TextAlign = 16
    $button2_15.UseVisualStyleBackColor = $True
    $button2_15.add_Click($button2_15_OnClick)
    $button2_15.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_15.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_15, "Deblocage TECH21")

    #Bouton 2_6 - Vérification des pre-requis Migration ULIS11
    $button2_6 = New-Object System.Windows.Forms.Button
    $button2_6.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_6.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 395
    $button2_6.Location = $System_Drawing_Point
    $button2_6.Name = "button2_6"
    $button2_6.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_6.Size = $System_Drawing_Size
    $button2_6.TabIndex = 0
    $button2_6.Text = "     7. Prérequis à la Migration ULIS11"
    $button2_6.TextAlign = 16
    $button2_6.UseVisualStyleBackColor = $True
    $button2_6.add_Click($button2_6_OnClick)
    $button2_6.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_6.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_6, "Pré-requis à la Migration ULIS11")

    #Bouton 2_7 - Migration ULIS
    $button2_7 = New-Object System.Windows.Forms.Button
    $button2_7.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_7.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 435
    $button2_7.Location = $System_Drawing_Point
    $button2_7.Name = "button2_7"
    $button2_7.Enabled = $true
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_7.Size = $System_Drawing_Size
    $button2_7.TabIndex = 0
    $button2_7.Text = "     8. Migration ULIS11"
    $button2_7.TextAlign = 16
    $button2_7.UseVisualStyleBackColor = $True
    $button2_7.add_Click($button2_7_OnClick)
    $button2_7.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_7.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_7, "Migration ULIS11")

    #Bouton 2_8 -  Deblocage ULIS21
    $button2_8 = New-Object System.Windows.Forms.Button
    $button2_8.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_8.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 475
    $button2_8.Location = $System_Drawing_Point
    $button2_8.Name = "button2_8"
    $button2_8.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_8.Size = $System_Drawing_Size
    $button2_8.TabIndex = 0
    $button2_8.Text =  "     9. Deblocage ULIS21"
    $button2_8.TextAlign = 16
    $button2_8.UseVisualStyleBackColor = $True
    $button2_8.add_Click($button2_8_OnClick)
    $button2_8.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_8.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_8, "Deblocage ULIS21")

    #Bouton 2_9 -  Deblocage Fin de Phase 2
    $button2_9 = New-Object System.Windows.Forms.Button
    $button2_9.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_9.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 515
    $button2_9.Location = $System_Drawing_Point
    $button2_9.Name = "button2_9"
    $button2_9.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_9.Size = $System_Drawing_Size
    $button2_9.TabIndex = 0
    $button2_9.Text = "     10. Deblocage Fin de Phase de Migration"
    $button2_9.TextAlign = 16
    $button2_9.UseVisualStyleBackColor = $True
    $button2_9.add_Click($button2_9_OnClick)
    $button2_9.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_9.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_9, "Deblocage Fin de Phase de Migration")

    #Bouton 2_10 - Retour arrière Migration FICHIER11
    $button2_10 = New-Object System.Windows.Forms.Button
    $button2_10.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_10.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 555
    $button2_10.Location = $System_Drawing_Point
    $button2_10.Name = "button2_10"
    $button2_10.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_10.Size = $System_Drawing_Size
    $button2_10.TabIndex = 0
    $button2_10.Text =  "     11. Retour arrière Migration FICHIER11"
    $button2_10.TextAlign = 16
    $button2_10.UseVisualStyleBackColor = $True
    $button2_10.add_Click($button2_10_OnClick)
    $button2_10.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_10.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_10, "Retour arrière Migration FICHIER11")

	#Bouton 2_16 - Retour arrière Migration TECH11
    $button2_16 = New-Object System.Windows.Forms.Button
    $button2_16.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_16.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 595
    $button2_16.Location = $System_Drawing_Point
    $button2_10.Name = "button2_16"
    $button2_10.Enabled = $True
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_16.Size = $System_Drawing_Size
    $button2_16.TabIndex = 0
    $button2_16.Text =  "     12. Retour arrière Migration TECH11"
    $button2_16.TextAlign = 16
    $button2_16.UseVisualStyleBackColor = $True
    $button2_16.add_Click($button2_16_OnClick)
    $button2_16.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_16.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_16, "Retour arrière Migration TECH11")

    #Bouton 2_11 - Retour arrière Migration ULIS11
    $button2_11 = New-Object System.Windows.Forms.Button
    $button2_11.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_11.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 635
    $button2_11.Location = $System_Drawing_Point
    $button2_11.Name = "button2_11"
    $button2_11.Enabled = $true
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_11.Size = $System_Drawing_Size
    $button2_11.TabIndex = 0
    $button2_11.Text = "     13. Retour arrière Migration ULIS11"
    $button2_11.TextAlign = 16
    $button2_11.UseVisualStyleBackColor = $True
    $button2_11.add_Click($button2_11_OnClick)
    $button2_11.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_11.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_11, "Retour arrière Migration ULIS11")

    #Bouton 2_12 - Quitter
    $button2_12 = New-Object System.Windows.Forms.Button
    $button2_12.DataBindings.DefaultDataSourceUpdateMode = 0
    $button2_12.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",11,0,3,1)
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 80
    $System_Drawing_Point.Y = 675
    $button2_12.Location = $System_Drawing_Point
    $button2_12.Name = "button2_12"
    $button2_12.Enabled = $true
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Height = 35
    $System_Drawing_Size.Width = 350
    $button2_12.Size = $System_Drawing_Size
    $button2_12.TabIndex = 0
    $button2_12.Text = "     14. Quitter"
    $button2_12.TextAlign = 16
    $button2_12.UseVisualStyleBackColor = $True
    $button2_12.add_Click($button2_12_OnClick)
    $button2_12.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
    $button2_12.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $ToolTip.SetToolTip($button2_12, "Quitter")

    ## Label 2 - N° de version
    $label2 = New-Object System.Windows.Forms.Label
    $label2.TabIndex = 6
    $label2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",8,0,3,0)
    $System_Drawing_Size = New-Object System.Drawing.Size
    $System_Drawing_Size.Width = 28
    $System_Drawing_Size.Height = 16
    $label2.Size = $System_Drawing_Size
    $label2.Text = $version
    $System_Drawing_Point = New-Object System.Drawing.Point
    $System_Drawing_Point.X = 460
    $System_Drawing_Point.Y = 690
    $label2.Location = $System_Drawing_Point
    $label2.DataBindings.DefaultDataSourceUpdateMode = 0
    $label2.Name = "label2"

    #################################################
    ###FORMULAIRE PHASE 2 ###
    #################################################
    $form2 = New-Object System.Windows.Forms.Form
    $System_Drawing_Size = New-Object System.Drawing.Size
    $form2.Text = "Menu General - MIGRATION"
    $form2.Name = "form2"
    $form2.DataBindings.DefaultDataSourceUpdateMode = 0

    $form2.MinimizeBox = $False
    $Form2.MaximizeBox = $False
    $form2.ControlBox = $false
    $form2.AutoSize = $true
    $Form2.AutoSizeMode = "GrowAndShrink"
    $form2.WindowState = "Normal"
    $Form2.StartPosition = "CenterScreen"
    $Form2.SizeGripStyle = "Hide"
    $Form2.BackColor = "white"

    #################################################
    ### Verification de l'accès à la Phase 2
    #################################################
    TestKeyPhase2

    #################################################
    ###Ajout object dans formulaire
    #################################################

    #Formulaire phase 2 / Migration

    $form2.Controls.Add($button2_1)
    $form2.Controls.Add($button2_2)
    $form2.Controls.Add($button2_3)
    $form2.Controls.Add($button2_4)
    $form2.Controls.Add($button2_6)
    $form2.Controls.Add($button2_7)
    $form2.Controls.Add($button2_8)
    $form2.Controls.Add($button2_9)
    $form2.Controls.Add($button2_10)
    $form2.Controls.Add($button2_11)
    $form2.Controls.Add($button2_12)
	$form2.Controls.Add($button2_13)
	$form2.Controls.Add($button2_14)
	$form2.Controls.Add($button2_15)
	$form2.Controls.Add($button2_16)
    $form2.Controls.Add($label_menu)
    $form2.Controls.Add($label2)

    $form2.ShowDialog()| Out-Null
}

#################################################
###Fonction Check USB MIGRATION ###
#################################################

## Fonction verifiant prerequis demarrage Migration

#################################################
###Fonction Check des Vms
#################################################
Function checkUsbMigration{
	$ErrorActionPreference = "Continue"

	## Formatage de la date
	$date                  = $(Get-Date -format yyyyMMddHHmm)
	$start_time            = (Get-date)
	$sep_log               = "---------------------------------------------------"

	$hostname = $env:computername.ToLower()

	# Popup permettant d'avoir des messages en premier plan
	$msgbox = new-object -comobject wscript.shell

	Function Get-VMsOnBasesUSB {
		Clear-host

		## Affiche le message Veuillez patienter ...
		$form4.Show()
		$form4.refresh()

		## Initialisation des tableaux
		$tab_vms_tmp=@() # Tableau de construction temporaire
		$tab_vms = @() # Tableau des Vms definitif utilisé pour l'affichage dans une dataGridView
		$tab_WB=@() # Tableau des Vms pour envoi vers WebServices

		## Traitement pour UStoreBox

		## Recuperation des Vms du BASE21

		Write-host "Recuperation des Vms du BASE21 ..."
		$AllVMsBASE21 = Get-Vm -computername $varbase21 | Where-Object { ($_.Name -like "*FICHIER21*") -or ($_.Name -like "*TECH21*") -or ($_.Name -like "*ULIS21*") -or ($_.Name -like "*FICHIER11*") -or ($_.Name -like "*TECH11*") -or ($_.Name -like "*ULIS11*") } 

		Foreach ($VM in $AllVMsBASE21) {
			### Pour chaque VM presente (ULIS21, TECH21, FICHIER21 , FICHIER11, ULIS11, TECH11)
			$checkPing = Test-Connection $VM.name -quiet -ErrorAction SilentlyContinue
			if ($checkPing -eq $true) {$ping ="OK"} Else {$Ping="KO"}
			Write-Host "Connexion $($VM.name) : $($Ping)"

			Try {$Session = New-PSsession $VM.name -ErrorAction Stop;$winrm="OK";Remove-PSSession –session $Session} Catch {$winrm="KO"}
			Write-Host "Connexion WinRM $($VM.name) : $($winrm)"

			$tab_vms_tmp+=new-object psobject -property @{VMNameSrc=$VM.name;BaseNameSrc=$varbase21;State=$VM.State;Ping=$Ping;WinRM=$Winrm}
		}  ## Fin ForEach

<#		## Recuperation des Vms du BASE22

		Write-host "Recuperation des Vms du BASE22 ..."
		$AllVMsBASE22 = Get-Vm -computername $varbase22 | Where-Object {($_.Name -like "*MONA11*") -or ($_.Name -like "*MONA01*")}

		Foreach ($VM in $AllVMsBASE22) {
			### Pour chaque VM presente (MONA11, MONA01)
			$checkPing = Test-Connection $VM.name -Quiet -ErrorAction SilentlyContinue
			if ($checkPing -eq $True) {$ping ="OK"} Else {$Ping="KO"}
			Write-Host "Connexion $($VM.name) : $($Ping)"

			Try {$Session = New-PSsession $VM.name -ErrorAction Stop;$winrm="OK";Remove-PSSession –session $Session} Catch {$winrm="KO"}
			Write-Host "Connexion WinRM $($VM.name) : $($winrm)"

			$tab_vms_tmp+=new-object psobject -property @{VMNameSrc=$VM.name;BaseNameSrc=$varbase22;State=$VM.State;Ping=$Ping;WinRM=$Winrm}
		}  ## Fin ForEach
#>

		## Traitement du tableau des VMs
		Write-Host "Creation des serveurs à basculer vers WebServices sur $($webserverIP):$($port)"

		Foreach ($ligne in $tab_vms_tmp) {
			## Envoi du tableau  vers un WebService Serveur et Activity uniquement
			if (($ligne.VMNameSrc -eq $varUlis) -or ($ligne.VMNameSrc -eq $varfichier) -or ($ligne.VMNameSrc -eq $varTech)) {
				if ($ligne.VMNameSrc -eq $varUlis) {$VMKey ="ULIS11"}
				if ($ligne.VMNameSrc -eq $varfichier) {$VMKey ="FICHIER11"}
				if ($ligne.VMNameSrc -eq $varTech) { $VMKey = "TECH11" }

				$activity = "MIGRATION"

				if (!(WB_Get $webserverIP $port $VMkey $activity)) {
					Write-host "Creation de $($CCU)$($vmkey)"
					WB_Create $webserverIP $port $VMKey $activity
				}
				Else
				{
					Write-host "$($CCU)$($vmkey) déjà présent"
				}
			}
		}

		## Ferme le formulaire Veuillez patienter...
		$form4.hide()

		## Mon tableau temporaire est complet mais non trié

		## Tri du tableau

		$tab_vms= $tab_vms_tmp | sort VMNameSrc,@{expression={if ($_.VMNameSrc -like "*FICHIER*") {$grade=1} else {if ($_.VMNameSrc -like "*ULIS*") {$grade=2} else {if ($_.VMNameSrc -like "*PSS*") {$grade=3} else {if ($_.VMNameSrc -like "*MOTEUR*") {$grade=4} else {if ($_.VMNameSrc -like "*MONA*") {$grade=5} else {$grade=6}}}}}; Add-Member noteproperty "Grade" $grade -InputObject $_}} | Sort-Object Grade | Select VMNameSrc,BaseNameSrc,State, Ping, WinRm

		## Test des Valeurs si null, si une et plusieurs VM
		$nbVMs = 0

		$array = New-Object System.Collections.ArrayList
		$Script:list_vms = $tab_vms | Select VMNameSrc,BaseNameSrc, State, Ping, WinRM

		$nbvms  = @($Script:list_vms).Count

			if ($nbVMs -ne 0) {
				## Si une valeur dans le tableau
				if ($nbVMs -eq 1)
				{
					$array.Add($Script:list_vms)
				}
				Else
				{
					$array.Addrange($Script:list_vms) ## pour plusieurs valeurs
				}
				## Modification
				$DataGridViewformUSB.DataSource = $array
				## Resize des colonnes en fonction du contenu
				$DataGridViewformUSB.Columns[1].AutoSizeMode = 4
				$DataGridViewformUSB.Columns[2].AutoSizeMode = 4
				$DataGridViewformUSB.Columns[3].AutoSizeMode = 6
				$DataGridViewformUSB.Columns[4].AutoSizeMode = 6
				## Desactivation des colonnes afin d'éviter les modificaitons, seul l'action est autorisé !!!
				$DataGridViewformUSB.Columns[0].ReadOnly = $True
				$DataGridViewformUSB.Columns[1].ReadOnly = $True
				$DataGridViewformUSB.Columns[2].ReadOnly = $True
				$DataGridViewformUSB.Columns[3].ReadOnly = $True
				$DataGridViewformUSB.Columns[4].ReadOnly = $True

				$nb = $DataGridViewformUSB.Rows.Count ## Nombre de lignes de la GridView

				## Parcours du tableau
				for($ind = 0; $ind -lt $nb; $ind++){ # Debut Boucle For
					## Colorisation de la colonne en fonction de l'état
					if ($DataGridViewformUSB.Item(2,$ind).Value -eq "Running") {$DataGridViewformUSB.Item(2,$ind).Style.backcolor = "Green" }
					if ($DataGridViewformUSB.Item(2,$ind).Value -eq "Off") {$DataGridViewformUSB.Item(2,$ind).Style.backcolor = "Red" }
					if ($DataGridViewformUSB.Item(2,$ind).Value -eq "Suspended") {$DataGridViewformUSB.Item(2,$ind).Style.backcolor = "darkcyan" }
					if ($DataGridViewformUSB.Item(3,$ind).Value -eq "OK") {$DataGridViewformUSB.Item(3,$ind).Style.backcolor = "Green" }
					if ($DataGridViewformUSB.Item(3,$ind).Value -eq "KO") {$DataGridViewformUSB.Item(3,$ind).Style.backcolor = "Red" }
					if ($DataGridViewformUSB.Item(4,$ind).Value -eq "OK") {$DataGridViewformUSB.Item(4,$ind).Style.backcolor = "Green" }
					if ($DataGridViewformUSB.Item(4,$ind).Value -eq "KO") {$DataGridViewformUSB.Item(4,$ind).Style.backcolor = "Red" }
				} # Fin Boucle For
			}
			## Fin du test Null
			$formUSB.refresh()
		}

		function GenerateFormListVmUSB {
			## Formulaire

			#region Import the Assemblies
			[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
			[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
			#endregion

			#################################################
			# CONFIGURATION DE LA WINDOWS FORM PRINCIPALE
			#################################################

			$formUSB = New-Object System.Windows.Forms.Form
			# Choix du titre
			$formUSB.Text = "Vérification prérequis USB"

			# Configuration de la Form
			$formUSB.Name = "formUSB"
			$formUSB.DataBindings.DefaultDataSourceUpdateMode = 0
			$formUSB.MinimizeBox = $False
			$formUSB.MaximizeBox = $False
			$formUSB.ControlBox = $false
			$formUSB.AutoSize = $true
			$formUSB.AutoSizeMode = "GrowAndShrink"
			$formUSB.WindowState = "Normal"
			$formUSB.StartPosition = "CenterScreen"
			$formUSB.SizeGripStyle = "Hide"
			$formUSB.BackColor = "white"
			$System_Drawing_Size = New-Object System.Drawing.Size
			$System_Drawing_Size.Height = 216
			$System_Drawing_Size.Width = 413
			$formUSB.ClientSize = $System_Drawing_Size

			#################################################
			# GESTION DES EVENEMENTS
			#################################################

			$button_formUSB_1_OnClick=
			{
				## Bouton Retour
				$formUSB.Close()
			}

			#################################################
			# AJOUT DES COMPOSANTS MAIN FORM PRINCIPAL
			#################################################
			$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

			## Label 1_1 - Libelle Liste des Vms
			$label_formUSB_1 = New-Object System.Windows.Forms.Label
			$label_formUSB_1.TabIndex = 4
			$System_Drawing_Size = New-Object System.Drawing.Size
			$System_Drawing_Size.Width = 155
			$System_Drawing_Size.Height = 23
			$label_formUSB_1.Size = $System_Drawing_Size
			$label_formUSB_1.Text = "Liste des VMs"
			$label_formUSB_1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,2,3,0)
			$label_formUSB_1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,102,204)
			$System_Drawing_Point = New-Object System.Drawing.Point
			$System_Drawing_Point.X = 13
			$System_Drawing_Point.Y = 13
			$label_formUSB_1.Location = $System_Drawing_Point
			$label_formUSB_1.DataBindings.DefaultDataSourceUpdateMode = 0
			$label_formUSB_1.Name = "label_formUSB_1"

			## Button 1 -  Retour
			$button_formUSB_1 = New-Object System.Windows.Forms.Button
			$button_formUSB_1.TabIndex = 2
			$button_formUSB_1.Name = "button_formUSB_1"
			$System_Drawing_Size = New-Object System.Drawing.Size
			$System_Drawing_Size.Width = 75
			$System_Drawing_Size.Height = 23
			$button_formUSB_1.Size = $System_Drawing_Size
			$button_formUSB_1.UseVisualStyleBackColor = $True
			$button_formUSB_1.Text = "Retour"
			$System_Drawing_Point = New-Object System.Drawing.Point
			$System_Drawing_Point.X = 5
			$System_Drawing_Point.Y = 255
			$button_formUSB_1.Location = $System_Drawing_Point
			$button_formUSB_1.DataBindings.DefaultDataSourceUpdateMode = 0
			$button_formUSB_1.add_Click($button_formUSB_1_OnClick)
			$button_formUSB_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
			$button_formUSB_1.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
			$ToolTip.SetToolTip($button_formUSB_1, "Retour")

			# DataGridViewformUSB
			$dataGridViewformUSB = New-Object System.Windows.Forms.DataGridView
			$System_Drawing_Size = New-Object System.Drawing.Size
			$System_Drawing_Size.Width = 368
			$System_Drawing_Size.Height = 200
			$dataGridViewformUSB.Size = $System_Drawing_Size
			$dataGridViewformUSB.DataBindings.DefaultDataSourceUpdateMode = 0

			$dataGridViewformUSB.Name = "dataGridViewformUSB"
			$dataGridViewformUSB.DataMember = ""
			$dataGridViewformUSB.TabIndex = 0
			$dataGridViewformUSB.MultiSelect = $False
			$dataGridViewformUSB.RowHeadersWidthSizeMode = 2
			$dataGridViewformUSB.AllowUserToResizeRows = $False
			$dataGridViewformUSB.AllowUserToResizeColumns = $False
			$DataGridViewformUSB.RowHeadersWidthSizeMode = 2
			$DataGridViewformUSB.ColumnHeadersHeightSizeMode = 2

			$System_Drawing_Point = New-Object System.Drawing.Point
			$System_Drawing_Point.X = 05
			$System_Drawing_Point.Y = 48
			$dataGridViewformUSB.Location = $System_Drawing_Point

			#################################################
			# INSERTION DES COMPOSANTS MAIN FORM PRINCIPAL
			#################################################
			$formUSB.Controls.Add($label_formUSB_1)
			$formUSB.Controls.Add($button_formUSB_1)
			$formUSB.Controls.Add($DataGridViewformUSB)

			#################################################
			# Action sur bouton
			#################################################
			$OnLoadForm_UpdateGrid=
			{
				## Chargement des Vms sur le base
				Get-VMsOnBasesUSB
			}

			#Save the initial state of the form
			$InitialFormWindowState = $formUSB.WindowState

			#Add Form event
			$formUSB.add_Load($OnLoadForm_UpdateGrid)

			#Show the Form

			$formUSB.ShowDialog()| Out-Null

		} #End Function

		### Script Principal

		GenerateFormListVmUSB

		#################################################
		# END
		#################################################
	}

	#################################################
	# Fonction SUIVI###
	#################################################

	function suivi{
		[CmdletBinding(DefaultParameterSetName="None")]
		param (
			[parameter(Mandatory=$false)][String]$VMsource = $null,
			[parameter(Mandatory=$false)][String]$VMDest = $null,
			[parameter(Mandatory=$false)][String]$BaseSource = $null,
			[parameter(Mandatory=$false)][String]$BaseDest = $null,
			[Parameter(ParameterSetName="Settings")]
			[switch]$migration,
			[Parameter(ParameterSetName="Settings")]
			[switch]$rollback,
			[Parameter(ParameterSetName="Settings")]
			[switch]$block,
			[Parameter(ParameterSetName="Settings")]
			[switch]$deblock,
			[Parameter(ParameterSetName="Settings")]
			[switch]$modif
		)

		$ErrorActionPreference = "Continue"

		[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
		[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

		# Création de la clé

		# Préparation des Ruches accueilant les clés de registres de Migration
		if ($VMSource -like "*MONA01") {$VMkey = "MONA01"}
		if ($VMSource -like "*ULIS11") {$VMkey = "ULIS11"}
		if ($VMSource -like "*ULIS21") {$VMkey = "ULIS21"}
		if ($VMSource -like "*TECH11") {$VMkey = "TECH11"}
		if ($VMSource -like "*TECH21") {$VMkey = "TECH21"}
		if ($VMSource -like "*PSS01") {$VMkey = "PSS01"}
		if ($VMSource -like "*MOTEUR01") {$VMkey = "MOTEUR01"}
		if ($VMSource -like "*FICHIER11") {$VMkey = "FICHIER11"}
		if ($VMSource -like "*FICHIER21") {$VMkey = "FICHIER21"}
		if ($VMSource -like "*ULIS21") {$VMkey = "ULIS21"}
		if ($VMSource -like "*PHASE2") {$VMkey = "PHASE2"}
		if ($BaseSource -like "*BASE21") {$BasekeySrc = "BASE21"}
		if ($BaseSource -like "*BASE22") {$BasekeySrc = "BASE22"}
		if ($Basedest -like "*BASE21") {$Basekeydest = "BASE21"}
		if ($Basedest -like "*BASE22") {$Basekeydest = "BASE22"}

		switch ($PSCmdlet.ParameterSetName) {

			None {
				write-host "Lecture seule" -ForegroundColor Red
				Erreur "Pas de paramètres !!!"
			}
			Settings {
				if ($migration) {$activity = "MIGRATION"}
				if ($rollback) {$activity = "ROLLBACK"}
				if ($block) {$activity = "BLOCK"}
				if ($deblock) {$activity = "DEBLOCK"}
				if ($modif) {$go="YES"} Else {$go="NO"}
			}
		}

		## Constantes et variables
		$StrPathKeySI       = "HKLM:\SOFTWARE\U-$($activity)-$($VMkey)\$($activity)"
		$StrPathKey         = "HKLM:\SOFTWARE\U-$($activity)-$($VMkey)"
		$StrFollowkeyPath   = "HKLM:\SOFTWARE\U-$($activity)-$($VMkey)\$($activity)\Follow"

		## Formatage de la date
		$date                  = $(Get-Date -format yyyyMMddHHmm)
		$start_time            = (Get-date)
		$sep_log               = "---------------------------------------------------"

		$hostname = $env:computername.ToLower()

		## Récupération du code ccu à partir du nom de la vm
		$CCU = $VMSource.Substring(0,5)

		$StrpathKeyIpf = $StrPathKeySI

		#Declaration des fichiers de log
		$StrPathLog = $global:path+"logs\$($VMSource)_$($activity)_SUIVI.LOG"
		$StrPathLogetapes = $global:path+"logs\$($VMSource)_$($activity)_ETAPES.LOG" # Fichier de log d execution des étapes

		# Declaration du fichier des étapes
		$strFichier    = "$($global:path)$($activity)_$($VMkey).IPF"

		#*******************************************************************************
		#                              Trace du Moteur
		#*******************************************************************************
		# Trace dans un fichier de log et a l ecran
		#*******************************************************************************

		function Trace ($message){
			"$date|$message" | add-content $StrPathLog
		}

		#*******************************************************************************
		#                           EcrireFichierRegistry
		#*******************************************************************************
		# Instruction d ecriture des valeurs du fichier dans la base de registre
		# Executer uniquement si premiere fois
		# En entree :
		#
		#        - strFichier : Fichier a traiter
		#*******************************************************************************
		Function EcrireFichierRegistry ($strFichier) {
			if (!(FTestPathRegistry  $StrpathKey)) {New-Item -Path $StrpathKey | Out-null}
			if (!(FTestPathRegistry  $StrPathKeySI)) {New-Item -Path $StrPathKeySI | Out-null}

			$StrpathKeyIpf = $StrPathKeySI

			# Si ce traitement n a pas deja ete fait

			if (!(FTestKeyRegistry $StrpathKeyIpf "Statut")) {
				# Ecriture de l entete du fichier de log des etapes (Attention bien precise UNIcode)
				$sep_log  | set-content $StrPathLogetapes -Encoding Unicode
				"Date                : $start_time" | add-content $StrPathLogetapes
				"Lance par           : $env:username" | add-content $StrPathLogetapes
				"Hostname            : $Hostname" | add-content $StrPathLogetapes
				$sep_log | add-content $StrPathLogetapes

				Trace "Ecriture du fichier $($strFichier) dans la base de registre"

				# Traitement du Moteur.ipf et remplacement des arguments Variable suivants :
				# {VMSOURCE} ; {BASESOURCE} ; {VMDEST} ; {BASEDEST}
				$content = Get-Content $StrFichier | foreach {$_ -replace "{VMSOURCE}", $VMsource}
				Set-Content -Path $StrFichier -Value $content
				$content = Get-Content $StrFichier | foreach {$_ -replace "{BASESOURCE}", $BaseSource}
				Set-Content -Path $StrFichier -Value $content
				$content = Get-Content $StrFichier | foreach {$_ -replace "{VMDEST}", $VMDest}
				Set-Content -Path $StrFichier -Value $content
				$content = Get-Content $StrFichier | foreach {$_ -replace "{BASEDEST}", $BaseDest}
				Set-Content -Path $StrFichier -Value $content

				# Ouverture du fichier IPF
				Trace "Lecture du fichier $($strFichier)"
				$Moteur_IPF = get-content $StrFichier

				# Ecriture des cles principales en registre
				New-ItemProperty -Path $StrpathKeyIpf -Name "Statut" -Value "INI" | Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "EtapeEnCours" -Value "" | Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "DateDebut" -Value (Get-date -format {dd/MM/yyyy HH:mm:ss})| Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "DateFin" -Value "" | Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "Path" -Value $($global:path) | Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "Version" -Value $($version) | Out-null
				New-ItemProperty -Path $StrpathKeyIpf -Name "Fichier" -Value $($strFichier) | Out-null

				New-Item -Path $StrFollowkeyPath | Out-null
				New-ItemProperty -Path $StrFollowkeyPath -Name "Return-ID" -Value "X" | Out-null
				New-ItemProperty -Path $StrFollowkeyPath -Name "ReturnDescription" -Value "X"	| Out-null
				New-ItemProperty -Path $StrFollowkeyPath -Name "Return" -Value "X"	| Out-null

				$IntNbrLn=1 # Nombre d etapes

				ForEach ($ligne in $Moteur_IPF) {
					if (($ligne -ne "") -and ($ligne.substring(0,1) -ne "#")){

					# Je recupere les valeurs de la ligne si la ligne est renseignee et si elle ne comporte pas de # pour les commentaires
					$split        = $ligne -split ";"
					$statut       = $split[0]
					$etapeid      = $split[1]
					$commande     = $split[2]
					$description  = $split[3]
					$reboot       = $split[4]

					# Inscription en base de registre pour chaque etape
					if ($statut.toupper() -eq "PA") {
						# Si la ligne comporte un point d arret : PA
						Trace "Ecriture de l etape $($IntNbrLn) : #point d arret#"
						$strpathKeyIpfEtape = $StrpathKeyIpf+"\"+$IntNbrLn
						New-Item -Path $strpathKeyIpfEtape | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "StatutEtape" -Value "PAR" | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "ID" -Value $etapeid  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetourId" -Value "PA"| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetour" -value "PntArret"| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetourDescription" -value "Arret force du moteur"	| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "DateCreation" -value (Get-date)| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Script" -value $commande | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Libelle" -value $description | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Reboot" -value  $reboot  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CptReboot" -value 0| Out-null
					}
					Else
					{
						# Sinon Etape normale NI
						Trace "Ecriture de l etape $($IntNbrLn) : $($etapeid)"
						$strpathKeyIpfEtape = $StrpathKeyIpf+"\"+$IntNbrLn
						New-Item -Path $strpathKeyIpfEtape| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "StatutEtape" -Value "INI"| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "ID" -Value $etapeid  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetourId" -Value "X"| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetour" -value "INI"| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CodeRetourDescription" -value "INI"	| Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "DateCreation" -value (Get-date)  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Script" -value $commande  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Libelle" -value $description | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "Reboot" -value  $reboot  | Out-null
						New-ItemProperty -Path $strpathKeyIpfEtape -Name "CptReboot" -value 0| Out-null
					}
					$IntNbrLn++
				}
			}

			If ($IntNbrLn -gt 0) {
				$IntNbrLn = $IntNbrLn -1 # Nombre de lignes -1 du fait que l on est demarre a 1
				New-ItemProperty -Path $StrpathKeyIpf -Name "NbrLine" -Value "$($IntNbrLn)"| Out-null
				Trace "Traitement du fichier $($strFichier) dans la base de registre termine"
			}
			Else
			{
				Trace "Traitement du fichier $($strFichier) : Pas de lignes a traiter dans le fichier"
				exit
			}

			## Envoi vers un WebService ->> 11/10/2016 Plus de creation du fait que cree lors de la phase de verificaitoon
			## Si le WeService Server/Activity existe et différent d'un retour arriere, je met à jour la date de demarrage et le nombre d'étapes
			if ($activity -eq "MIGRATION" ){
				if ((WB_Get $webserverIP $port $VMKey $activity)) {
					WB_Update $webserverIP $port $VMKey $activity  -SW_nbetapes -SW_StartDate
				}
			}
		}
	}

	Function Get-etapes {
		# Creation d un tableau regroupant les cles de registres du moteur
		if ((FTestKeyRegistry $StrpathKeyIpf "Statut")) {
			# Si moteur present
			$IntNbrLnTr = FLireRegistry $StrpathKeyIpf "NbrLine"
			$tab_etapes=@()
			for($ind = 1; $ind -le $IntNbrLnTr; $ind++){ # Debut Boucle For
				# On recupere l ID, le libelle, et le statut de l etape
				$StrpathKeyIpfInd = $($StrpathKeyIpf)+"\"+$($ind)
				$strStatutEtape = FLireRegistry $StrpathKeyIpfInd "StatutEtape"
				$etapeid = FLireRegistry  $StrpathKeyIpfInd "ID"
				$description = FLireRegistry $StrpathKeyIpfInd  "Libelle"
				$tab_etapes+=new-object psobject -property @{No=$ind;ID=$etapeid;Libelle=$description;Statut=$strStatutEtape}
			}
			$array = New-Object System.Collections.ArrayList
			$Script:list_etapes = $tab_etapes| Select No,ID,Libelle,Statut | sort -Property No
			$nbetapes= ($tab_etapes).count

			## Si une valeur dans le tableau
			if ($nbetapes -eq 1)  {
				$array.Add($Script:list_etapes)
			}
			Else
			{
				$array.Addrange($Script:list_etapes) ## pour plusieurs valeurs
			}

			if ($modif) { ## Valeur  True
				## Modification
				$dataGridView1.DataSource = $array
				## Resize des colonnes en fonction du contenu
				$dataGridView1.Columns[2].AutoSizeMode = 4
				$dataGridView1.Columns[1].AutoSizeMode = 4
			}

			if (!$modif) { ## Valeur False
				## Lecture Seule
				$dataGridView1.DataSource = $array
				## Resize des colonnes en fonction du contenu
				$dataGridView1.Columns[2].AutoSizeMode = 4
				$dataGridView1.Columns[1].AutoSizeMode = 4
				## Couleur des cellules en fonction du resultat FIN=VERT - WAR=ORANGE - ERR=ROUGE - PAR = POINT D ARRET - RUN = JAUNE
				$nb = $DataGridView1.Rows.Count ## Nombre de lignes de la GridView
				# Je parcours la colonne 3
				for($ind = 0; $ind -le $nb-1; $ind++){ # Debut Boucle
		 			if ($datagridview1.Item(3,$ind).Value -eq "FIN") {$datagridview1.Item(3,$ind).Style.backcolor = "Green" }
					if ($datagridview1.Item(3,$ind).Value -eq "PAR") {$datagridview1.Item(3,$ind).Style.backcolor = "Blue" }
					if ($datagridview1.Item(3,$ind).Value -eq "WAR") {$datagridview1.Item(3,$ind).Style.backcolor = "Orange" }
					if ($datagridview1.Item(3,$ind).Value -eq "ERR") {$datagridview1.Item(3,$ind).Style.backcolor = "Red" }
					if ($datagridview1.Item(3,$ind).Value -eq "RUN") {$datagridview1.Item(3,$ind).Style.backcolor = "Yellow" }
					if ($datagridview1.Item(3,$ind).Value -eq "REC") {$datagridview1.Item(3,$ind).Style.backcolor = "darkcyan"}
				} # Fin Boucle For
			}
			$formSuivi.refresh()
		}
		Else
		{
			# Pas de registre
			Exit
		}
	}

	function GenerateFormRead {
		# Formulaire en mode Lecture seule
		[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
		[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null

		#################################################
		# CONFIGURATION DE LA WINDOWS FORM PRINCIPALE
		#################################################
		$formSuivi = New-Object System.Windows.Forms.Form
		# Choix du titre
		if ($activity -eq "MIGRATION") {$formSuivi.Text = "$($activity) de $($VMSource)"}
		if ($activity -eq "ROLLBACK") {$formSuivi.Text = "RETOUR ARRIERE"}
		if ($activity -eq "BLOCK") {$formSuivi.Text = "BLOCAGE $($VMSource)"}
		if ($activity -eq "DEBLOCK") {$formSuivi.Text = "DEBLOCAGE $($VMSource)"}

		# Configuration de la Form
		$formSuivi.Name = "formSuivi"
		$formSuivi.DataBindings.DefaultDataSourceUpdateMode = 0
		$formSuivi.MinimizeBox = $False
		$formSuivi.MaximizeBox = $False
		$formSuivi.ControlBox = $false
		$formSuivi.AutoSize = $true
		$formSuivi.AutoSizeMode = "GrowAndShrink"
		$formSuivi.WindowState = "Normal"
		$formSuivi.StartPosition = "CenterScreen"
		$formSuivi.SizeGripStyle = "Hide"
		$formSuivi.BackColor = "white"

		#################################################
		# CONFIGURATION DU TIMER
		#################################################
		$timer1 = New-Object System.Windows.Forms.Timer

		#################################################
		# GESTION DES EVENEMENTS
		#################################################
		$handler_timer1_Tick=
		{
			## Actualisation de la GridView
			Get-Etapes
		}

		#################################################
		# GESTION DES EVENEMENTS
		#################################################
		$buttonSuiviR_2_OnClick=
		{
			## Bouton retour
			$timer1.Enabled = $false

			if($form2){
				$form2.Controls.remove($label_menu)
				$form2.Controls.Add($label_menu)
			}
			#  if((FLireRegistry "HKLM:\SOFTWARE\U-ROLLBACK-PHASE2\ROLLBACK\" "Statut") -eq "FIN"){
			#    Write-Host "Suppression cle HKLM:\SOFTWARE\U-ROLLBACK-PHASE2\"
			#    Remove-Item -Path "HKLM:\SOFTWARE\U-ROLLBACK-PHASE2" -Recurse
			#  }
			
			$formSuivi.Close()
		}

		$buttonSuiviR_1_OnClick=
		{
			#### A passer en parametre le nom de la VM, ainsi que switch migration
			if ($activity -eq "MIGRATION") {Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "$($global:path)etapes.ps1 -migration -VMSource $VMsource"}
			if ($activity -eq "ROLLBACK") {Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "$($global:path)etapes.ps1 -rollback -VMSource $VMsource"}
			if ($activity -eq "BLOCK") {Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "$($global:path)etapes.ps1 -block -VMSource $VMsource"}
			if ($activity -eq "DEBLOCK") {Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -ArgumentList "$($global:path)etapes.ps1 -deblock -VMSource $VMsource"}
		}

		$buttonSuiviR_3_OnClick=
		{
			## Bouton Log Moteur
			## Ouverture de la log moteur dans Notepad
			Start-Executable "Notepad.exe" "$($StrPathLog)"
		}

		$buttonSuiviR_4_OnClick=
		{
			## Bouton Log Etapes
			## Ouverture de la log etpes dans Notepad
			Start-Executable "Notepad.exe" "$($StrPathLogetapes)"
		}
		
		#################################################
		# AJOUT DES COMPOSANTS MAIN FORM
		#################################################
		$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

		## labelSuiviR_1 - Libelle Liste des étapes
		$labelSuiviR_1 = New-Object System.Windows.Forms.Label
		$labelSuiviR_1.TabIndex = 4
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 155
		$System_Drawing_Size.Height = 23
		$labelSuiviR_1.Size = $System_Drawing_Size
		$labelSuiviR_1.Text = "Liste des etapes"
		$labelSuiviR_1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,2,3,0)
		$labelSuiviR_1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,102,204)
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 13
		$System_Drawing_Point.Y = 13
		$labelSuiviR_1.Location = $System_Drawing_Point
		$labelSuiviR_1.DataBindings.DefaultDataSourceUpdateMode = 0
		$labelSuiviR_1.Name = "labelSuiviR_1"

		## buttonSuiviR_1  - Démarrer
		$buttonSuiviR_1 = New-Object System.Windows.Forms.Button
		$buttonSuiviR_1.TabIndex = 3
		$buttonSuiviR_1.Name = "buttonSuiviR_1"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviR_1.Size = $System_Drawing_Size
		$buttonSuiviR_1.UseVisualStyleBackColor = $True
		$buttonSuiviR_1.Text = "Démarrer"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 5
		#$System_Drawing_Point.Y = 462
		$System_Drawing_Point.Y = 515
		$buttonSuiviR_1.Location = $System_Drawing_Point
		$buttonSuiviR_1.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviR_1.add_Click($buttonSuiviR_1_OnClick)
		$buttonSuiviR_1.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$buttonSuiviR_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$ToolTip.SetToolTip($buttonSuiviR_1, "Démarrer")

		## buttonSuiviR_2  - Retour
		$buttonSuiviR_2 = New-Object System.Windows.Forms.Button
		$buttonSuiviR_2.TabIndex = 3
		$buttonSuiviR_2.Name = "buttonSuiviR_2"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviR_2.Size = $System_Drawing_Size
		$buttonSuiviR_2.UseVisualStyleBackColor = $True
		$buttonSuiviR_2.Text = "Retour"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 245
		#$System_Drawing_Point.Y = 462
		$System_Drawing_Point.Y = 515
		$buttonSuiviR_2.Location = $System_Drawing_Point
		$buttonSuiviR_2.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviR_2.add_Click($buttonSuiviR_2_OnClick)
		$buttonSuiviR_2.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$buttonSuiviR_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$ToolTip.SetToolTip($buttonSuiviR_2, "Retour")

		## buttonSuiviR_3 - Moteur Log
		$buttonSuiviR_3 = New-Object System.Windows.Forms.Button
		$buttonSuiviR_3.TabIndex = 1
		$buttonSuiviR_3.Name = "buttonSuiviR_3"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviR_3.Size = $System_Drawing_Size
		$buttonSuiviR_3.UseVisualStyleBackColor = $True
		$buttonSuiviR_3.Text = "Log Moteur"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 85
		#$System_Drawing_Point.Y = 462
		$System_Drawing_Point.Y = 515
		$buttonSuiviR_3.Location = $System_Drawing_Point
		$buttonSuiviR_3.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviR_3.add_Click($buttonSuiviR_3_OnClick)
		$buttonSuiviR_3.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$buttonSuiviR_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$ToolTip.SetToolTip($buttonSuiviR_3, "Visualisation log Moteur")

		## buttonSuiviR_4 - Etapes Logs
		$buttonSuiviR_4 = New-Object System.Windows.Forms.Button
		$buttonSuiviR_4.TabIndex = 2
		$buttonSuiviR_4.Name = "buttonSuiviR_4"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviR_4.Size = $System_Drawing_Size
		$buttonSuiviR_4.UseVisualStyleBackColor = $True
		$buttonSuiviR_4.Text = "Log Etapes"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 165
		#$System_Drawing_Point.Y = 462
		$System_Drawing_Point.Y = 515
		$buttonSuiviR_4.Location = $System_Drawing_Point
		$buttonSuiviR_4.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviR_4.add_Click($buttonSuiviR_4_OnClick)
		$buttonSuiviR_4.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$buttonSuiviR_4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$ToolTip.SetToolTip($buttonSuiviR_4, "Visualisation log Etapes")

		# DataGridView1 : Donnees du registre
		$dataGridView1 = New-Object System.Windows.Forms.DataGridView
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 840
		#$System_Drawing_Size.Height = 408
		$System_Drawing_Size.Height = 461
		$dataGridView1.Size = $System_Drawing_Size
		$dataGridView1.DataBindings.DefaultDataSourceUpdateMode = 0
		$dataGridView1.Name = "dataGrid1View1"
		$dataGridView1.DataMember = ""
		$dataGridView1.TabIndex = 0
		$dataGridView1.MultiSelect = $False
		$dataGridView1.RowHeadersWidthSizeMode = 2
		$dataGridView1.AllowUserToResizeRows = $False
		$dataGridView1.AllowUserToResizeColumns = $False
		$DataGridView1.RowHeadersWidthSizeMode = 2
		$DataGridView1.ColumnHeadersHeightSizeMode = 2
		$dataGridView1.ReadOnly = $True
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 05
		$System_Drawing_Point.Y = 48
		$dataGridView1.Location = $System_Drawing_Point

		## Timer
		$timer1.Enabled = $True
		$timer1.Interval = 3000 ## en Milisecondes
		$timer1.add_Tick($handler_timer1_Tick)

		#################################################
		# INSERTION DES COMPOSANTS MAIN FORM
		#################################################

		$formSuivi.Controls.Add($labelSuiviR_1)
		$formSuivi.Controls.Add($buttonSuiviR_1)
		$formSuivi.Controls.Add($buttonSuiviR_2)
		$formSuivi.Controls.Add($buttonSuiviR_3)
		$formSuivi.Controls.Add($buttonSuiviR_4)
		$formSuivi.Controls.Add($dataGridView1)
		$formSuivi.Controls.Add($pictureboxLogo1)

		$OnLoadForm_UpdateGrid=
		{
			## Chargement des etapes dans la Grid en fonction du mode lecture ou modification (type)
			Get-Etapes
		}

		#Save the initial state of the form
		$InitialFormWindowState = $formSuivi.WindowState

		#Add Form event
		$formSuivi.add_Load($OnLoadForm_UpdateGrid)

		#Show the Form
		$formSuivi.ShowDialog()| Out-Null
	}

	function GenerateFormWrite {
		## Formulaire en mode Modification
		#region Import the Assemblies
		[reflection.assembly]::loadwithpartialname("System.Windows.Forms") | Out-Null
		[reflection.assembly]::loadwithpartialname("System.Drawing") | Out-Null
		#endregion

		#################################################
		# CONFIGURATION DE LA WINDOWS FORM PRINCIPALE
		#################################################

		$formSuivi = New-Object System.Windows.Forms.Form
		# Choix du titre
		if ($activity -eq "MIGRATION") {$formSuivi.Text = "$($activity) de $($VMSource)"}
		if ($activity -eq "ROLLBACK") {$formSuivi.Text = "RETOUR ARRIERE de $($VMSource) "}
		if ($activity -eq "BLOCK") {$formSuivi.Text = "BLOCAGE $($VMSource)"}
		if ($activity -eq "DEBLOCK") {$formSuivi.Text = "DEBLOCAGE $($VMSource)"}

		# Configuration de la Form
		$formSuivi.Name = "formSuivi"
		$formSuivi.DataBindings.DefaultDataSourceUpdateMode = 0
		$formSuivi.MinimizeBox = $False
		$formSuivi.MaximizeBox = $False
		$formSuivi.ControlBox = $false
		$formSuivi.AutoSize = $true
		$formSuivi.AutoSizeMode = "GrowAndShrink"
		$formSuivi.WindowState = "Normal"
		$formSuivi.StartPosition = "CenterScreen"
		$formSuivi.SizeGripStyle = "Hide"
		$formSuivi.BackColor = "white"

		#################################################
		# GESTION DES EVENEMENTS
		#################################################

		$buttonSuiviW_3_OnClick=
		{
			## Bouton Retour
			$formSuivi.Close()
		}

		$buttonSuiviW_1_OnClick=
		{
			## Bouton :  Actualiser
			Get-Etapes
		}

		$buttonSuiviW_2_OnClick=
		{
			## Bouton :  Modification du Statut d un etape
			#Recuperation de la valeur du combox
			$init = $listeSuiviW_1.Text

			#Recuperation de l index de la ligne selecionnee
			$selectedRow = $dataGridView1.CurrentCell.RowIndex

			#On Modifie le champ Staut de la ligne Selectionnee
			$Script:list_etapes[$selectedRow].Statut = $init

			#On fait un Refresh du DataGrid1
			$DataGridView1.Refresh()
		}

		$buttonSuiviW_4_OnClick=
		{
			## Bouton - Sauvegarder informations en registre

			## Recuperation de toutes les informations dans le DatagGrid

			## Nombre de lignes de la dataGrid
			$nb = $DataGridView1.Rows.Count ## Nombre de lignes de la GridView

			## Parcours du tableau

			for($ind = 0; $ind -lt $nb; $ind++){ # Debut Boucle For
				# Je recupere le statut
				$statut = $dataGridview1.Item(3,$ind).value
				# Je modifie le registre (meme si non modifie)
				$StrpathKeyIpfInd = $($StrpathKeyIpf)+"\"+$($ind+1)
				FModifyRegistry $StrpathKeyIpfInd "StatutEtape" $statut
			} # Fin Boucle For

			$DataGridView1.Refresh()
		}

		$buttonSuiviW_5_OnClick=
		{
			## Bouton Log Moteur
			## Ouverture de la log moteur dans Notepad
			Start-Executable "Notepad.exe" "$($StrPathLog)"
		}

		$buttonSuiviW_6_OnClick=
		{
			## Bouton Log Etapes
			## Ouverture de la log etpes dans Notepad
			Start-Executable "Notepad.exe" "$($StrPathLogetapes)"
		}

		#################################################
		# AJOUT DES COMPOSANTS MAIN FORM
		#################################################
		$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

		## labelSuiviW_1 - Libelle Liste des étapes
		$labelSuiviW_1 = New-Object System.Windows.Forms.Label
		$labelSuiviW_1.TabIndex = 4
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 155
		$System_Drawing_Size.Height = 23
		$labelSuiviW_1.Size = $System_Drawing_Size
		$labelSuiviW_1.Text = "Liste des etapes"
		$labelSuiviW_1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",9.75,2,3,0)
		$labelSuiviW_1.ForeColor = [System.Drawing.Color]::FromArgb(255,0,102,204)
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 13
		$System_Drawing_Point.Y = 13
		$labelSuiviW_1.Location = $System_Drawing_Point
		$labelSuiviW_1.DataBindings.DefaultDataSourceUpdateMode = 0
		$labelSuiviW_1.Name = "labelSuiviW_1"

		## labelSuiviW_3 - Libelle Statut pour choix liste
		$labelSuiviW_3 = New-Object System.Windows.Forms.Label
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 40
		$System_Drawing_Size.Height = 15
		$labelSuiviW_3.Size = $System_Drawing_Size
		$labelSuiviW_3.Text = "Statut : "
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 5
		$System_Drawing_Point.Y = 467
		$labelSuiviW_3.Location = $System_Drawing_Point
		$labelSuiviW_3.DataBindings.DefaultDataSourceUpdateMode = 0
		$labelSuiviW_3.Name = "labelSuiviW_3"

		# listeSuiviW_1 : Liste deroulante (ComboBox)
		$listeSuiviW_1 = New-Object System.Windows.Forms.Combobox
		$listeSuiviW_1.Location = New-Object Drawing.Point 52,462
		$listeSuiviW_1.Size = New-Object System.Drawing.Size(75,23)
		$listeSuiviW_1.DropDownStyle = "DropDownList"
		$listeSuiviW_1.Items.AddRange(("INI","PAR","FIN"))
		$listeSuiviW_1.SelectedIndex = 0
		$listeSuiviW_1.tabindex = 1

		## buttonSuiviW_1 - Actualiser la DataGrid
		$buttonSuiviW_1 = New-Object System.Windows.Forms.Button
		$buttonSuiviW_1.TabIndex = 3
		$buttonSuiviW_1.Name = "buttonSuiviW_1"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_1.Size = $System_Drawing_Size
		$buttonSuiviW_1.UseVisualStyleBackColor = $True
		$buttonSuiviW_1.Text = "Actualiser"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 212
		$System_Drawing_Point.Y = 462
		$buttonSuiviW_1.Location = $System_Drawing_Point
		$buttonSuiviW_1.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_1.add_Click($buttonSuiviW_1_OnClick)
		$buttonSuiviW_1.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_1.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_1, "Actualiser la liste")

		## buttonSuiviW_2 -  Modification du Statut
		$buttonSuiviW_2 = New-Object System.Windows.Forms.Button # Modifier
		$buttonSuiviW_2.TabIndex = 2
		$buttonSuiviW_2.Name = "buttonSuiviW_2"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_2.Size = $System_Drawing_Size
		$buttonSuiviW_2.UseVisualStyleBackColor = $True
		$buttonSuiviW_2.Text = "Modifier"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 132 # col
		$System_Drawing_Point.Y = 462  # row
		$buttonSuiviW_2.Location = $System_Drawing_Point
		$buttonSuiviW_2.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_2.add_Click($buttonSuiviW_2_OnClick)
		$buttonSuiviW_2.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_2.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_2, "Modifie le Statut")

		## buttonSuiviW_3  - Retour
		$buttonSuiviW_3 = New-Object System.Windows.Forms.Button
		$buttonSuiviW_3.TabIndex = 7
		$buttonSuiviW_3.Name = "buttonSuiviW_3"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_3.Size = $System_Drawing_Size
		$buttonSuiviW_3.UseVisualStyleBackColor = $True
		$buttonSuiviW_3.Text = "Retour"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 535
		$System_Drawing_Point.Y = 462
		$buttonSuiviW_3.Location = $System_Drawing_Point
		$buttonSuiviW_3.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_3.add_Click($buttonSuiviW_3_OnClick)
		$buttonSuiviW_3.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_3.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_3, "Retour")

		## buttonSuiviW_4 - Sauvegarder
		$buttonSuiviW_4 = New-Object System.Windows.Forms.Button
		$buttonSuiviW_4.TabIndex = 4
		$buttonSuiviW_4.Name = "buttonSuiviW_4"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 80
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_4.Size = $System_Drawing_Size
		$buttonSuiviW_4.UseVisualStyleBackColor = $True
		$buttonSuiviW_4.Text = "Sauvegarder"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 292
		$System_Drawing_Point.Y = 462
		$buttonSuiviW_4.Location = $System_Drawing_Point
		$buttonSuiviW_4.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_4.add_Click($buttonSuiviW_4_OnClick)
		$buttonSuiviW_4.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_4.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_4, "Sauvegarder")

		## buttonSuiviW_5 - Moteur Log
		$buttonSuiviW_5 = New-Object System.Windows.Forms.Button
		$buttonSuiviW_5.TabIndex = 5
		$buttonSuiviW_5.Name = "buttonSuiviW_5"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_5.Size = $System_Drawing_Size
		$buttonSuiviW_5.UseVisualStyleBackColor = $True
		$buttonSuiviW_5.Text = "Log Moteur"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 375
		$System_Drawing_Point.Y = 462
		$buttonSuiviW_5.Location = $System_Drawing_Point
		$buttonSuiviW_5.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_5.add_Click($buttonSuiviW_5_OnClick)
		$buttonSuiviW_5.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_5.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_5, "Visualisation log Moteur")

		## buttonSuiviW_6 - Etapes Logs
		$buttonSuiviW_6 = New-Object System.Windows.Forms.Button
		$buttonSuiviW_6.TabIndex = 6
		$buttonSuiviW_6.Name = "buttonSuiviW_6"
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 75
		$System_Drawing_Size.Height = 23
		$buttonSuiviW_6.Size = $System_Drawing_Size
		$buttonSuiviW_6.UseVisualStyleBackColor = $True
		$buttonSuiviW_6.Text = "Log Etapes"
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 455
		$System_Drawing_Point.Y = 462
		$buttonSuiviW_6.Location = $System_Drawing_Point
		$buttonSuiviW_6.DataBindings.DefaultDataSourceUpdateMode = 0
		$buttonSuiviW_6.add_Click($buttonSuiviW_6_OnClick)
		$buttonSuiviW_6.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
		$buttonSuiviW_6.Cursor = "Hand" ## Affiche une Main lors du passage sur le bouton
		$ToolTip.SetToolTip($buttonSuiviW_6, "Visualisation log Etapes")

		# DataGridView1 : Donnees du registre
		$dataGridView1 = New-Object System.Windows.Forms.DataGridView
		$System_Drawing_Size = New-Object System.Drawing.Size
		$System_Drawing_Size.Width = 840
		$System_Drawing_Size.Height = 408
		$dataGridView1.Size = $System_Drawing_Size
		$dataGridView1.DataBindings.DefaultDataSourceUpdateMode = 0
		$dataGridView1.Name = "dataGrid1View1"
		$dataGridView1.DataMember = ""
		$dataGridView1.TabIndex = 0
		$dataGridView1.MultiSelect = $False
		$dataGridView1.RowHeadersWidthSizeMode = 2
		$dataGridView1.AllowUserToResizeRows = $False
		$dataGridView1.AllowUserToResizeColumns = $False
		$DataGridView1.RowHeadersWidthSizeMode = 2
		$DataGridView1.ColumnHeadersHeightSizeMode = 2
		$dataGridView1.ReadOnly = $True
		$System_Drawing_Point = New-Object System.Drawing.Point
		$System_Drawing_Point.X = 05
		$System_Drawing_Point.Y = 48
		$dataGridView1.Location = $System_Drawing_Point

		#################################################
		# INSERTION DES COMPOSANTS MAIN FORM
		#################################################
		$formSuivi.Controls.Add($labelSuiviW_1)
		$formSuivi.Controls.Add($labelSuiviW_3)
		$formSuivi.controls.add($listeSuiviW_1)
		$formSuivi.Controls.Add($buttonSuiviW_2)
		$formSuivi.Controls.Add($buttonSuiviW_1)
		$formSuivi.Controls.Add($buttonSuiviW_4)
		$formSuivi.Controls.Add($buttonSuiviW_5)
		$formSuivi.Controls.Add($buttonSuiviW_6)
		$formSuivi.Controls.Add($buttonSuiviW_3)
		$formSuivi.Controls.Add($dataGridView1)
		$formSuivi.Controls.Add($pictureboxLogo1)

		$OnLoadForm_UpdateGrid=
		{
			## Chargement des etapes dans la Grid en fonction du mode lecture ou modification (type)
			Get-Etapes
		}

		#Save the initial state of the form
		$InitialFormWindowState = $formSuivi.WindowState

		#Add Form event
		$formSuivi.add_Load($OnLoadForm_UpdateGrid)

		#Show the Form
		$formSuivi.ShowDialog()| Out-Null

	} #End Function

	### Script Principal
	if (!(test-path ($StrPathLog))) {
		# Ecriture de l entete de fichier
		Trace $sep_log
		Trace "Version             : $version"
		Trace "Date                : $start_time"
		Trace "Lance par           : $env:username"
		Trace "Hostname            : $hostname"
		Trace $sep_log
	}

	## Affichage des formulaires

	## Si appuie Sur F1 - Mode Modification
	Start-Sleep -Seconds 1;if (Test-KeyPress -Keys F1) {$go="YES"}

	if ($go -eq "NO") {
		## Mode lecture
		EcrireFichierRegistry $strFichier
		GenerateFormRead
	}
	Else
	{
		## Mode Modification
		EcrireFichierRegistry $strFichier
		GenerateFormWrite
	}

	#################################################
	# END
	#################################################
}

formPhase2

## Restitution de la Console
Show-PowerShell
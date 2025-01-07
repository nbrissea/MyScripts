##########################################################################
# Titre : récupére les informations de début et fin d'activité journalière
#
# Auteur : Nicolas Brisseau
#
# Arguments : -
##########################################################################

# 
Get-WinEvent -FilterHashTable @{LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; id = (22,24) } | sort-object -property Timecreated

# ==========================================================
# Get-IPConfig.ps1
# Auteur : Nicolas Brisseau
# Description : Module script permettant de présenter les informations IP d'un ordinateur du réseau
# ==========================================================

function Get-IPConfig{
  param ( 
    [String]$RemoteComputer='localhost',
    
    $OnlyConnectedNetworkAdapters=$true
  )
  if ($RemoteComputer -ne 'localhost'){
    $id = Read-Host 'credentials (domain/user)'
    $pwd = Read-Host 'password' -AsSecureString
    $cred = New-Object System.Management.Automation.PSCredential -ArgumentList ($id, $pwd)
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $RemoteComputer -Credential $cred | Where-Object { $_.IPEnabled -eq $OnlyConnectedNetworkAdapters } | Format-List @{ Label = "Computer Name"; Expression = { $_.__SERVER } }, IPEnabled, Description, MACAddress, IPAddress, IPSubnet, DefaultIPGateway, DHCPEnabled, DHCPServer, @{ Label = "DHCP Lease Expires"; Expression = { [dateTime]$_.DHCPLeaseExpires } }, @{ Label = "DHCP Lease Obtained"; Expression = { [dateTime]$_.DHCPLeaseObtained }}
  }
  Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $RemoteComputer | Where-Object { $_.IPEnabled -eq $OnlyConnectedNetworkAdapters } | Format-List @{ Label="Computer Name"; Expression= { $_.__SERVER }}, IPEnabled, Description, MACAddress, IPAddress, IPSubnet, DefaultIPGateway, DHCPEnabled, DHCPServer, @{ Label="DHCP Lease Expires"; Expression= { [dateTime]$_.DHCPLeaseExpires }}, @{ Label="DHCP Lease Obtained"; Expression= { [dateTime]$_.DHCPLeaseObtained }}
} 

#########################################################################
# Author:   Michał Zbyl                                                 #
# E-mail:   kafej666@gmail.com                                          #
# LinkedIn: https://www.linkedin.com/in/mzbyl/                          #
#########################################################################
$ErrorActionPreference= 'silentlycontinue'
clear-variable logObj, result, LogOnEvents, log

Add-Type -Path "C:\Audyt\MySQL.Data.dll"

$l = 'root'
$p = 'P@ssw0rd'

$SQLServer = "localhost"
$SQLDBName = "Audyt"
$h = $env:computername
$log = $env:UserName

$logObj = ''; 
$result = '';
$LogOnEvents = '';

if ($log) {
    $LogOnEvents = Get-WinEvent -filterHashtable @{Path='C:\Windows\System32\winevt\Logs\Security.evtx'; Id=4624; Level=0}  |  Where-Object{ $_.Properties[8].Value -eq 10 -AND $_.Properties[18].Value -ne $null -AND $_.Properties[5].value -eq $env:UserName} | Select-Object -First 1
    $Ip = $LogOnEvents.Properties[18].value
    $logObj = $Ip
    $result = $result + $logObj

    if ($result -notlike "192.168.100.*") {
        $result | Out-File \\fs01\IT\Raporty\Logon\$env:UserName\OstatniRDS.txt
        $Command             = New-Object MySql.Data.MySqlClient.MySqlCommand
        $conn                = New-Object MySql.Data.MySqlClient.MySqlConnection("server=$SQLServer;user id=$l;password=$p;database=$SQLDBName")
        $Command.CommandText = "INSERT INTO user (Login,AdresIPterminala,hostname) VALUES('$log','$result','$h')"
        $Command.Connection  = $conn
    
        $Command.Connection.Open()
        [int]$i = $Command.ExecuteNonQuery()
        $Command.Connection.Close()   
    }
}
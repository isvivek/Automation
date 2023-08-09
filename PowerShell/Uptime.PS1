# Script to Check Windows Servers Uptime
$Servers = "srv1","srv2"

$TodaysDate = Get-Date
ForEach ($Server in $Servers)
{
	$ServerBoottime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $server).LastBootUpTime
	$ServerUptime = $TodaysDate - $ServerBoottime
	Write-Output "$server Uptime : $($ServerUptime.Days) Days, $($ServerUptime.Hours) Hours, $($ServerUptime.Minutes) Minutes"
}	
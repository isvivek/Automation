# Script to Check VM Hardware & Tools Version
# Created by is_vivek@yahoo.co.in
# Created on 13-Jan-2017

$outfile = "C:\Users\isvivek\Script\windowsvmversion.csv"

If (Test-Path $outfile)
{
	Remove-Item $outfile 
}

$clusters = "Cluster-01" , "Cluster-02" , "Cluster-03" 

foreach ( $cluster in $clusters)
{
$vms = Get-Cluster $cluster | Get-VM
foreach ( $vm in $vms )
{
$vm |Where-Object {$_.PowerState -eq "PoweredOn"}| Get-View |
 Select Name,
 @{Name="HardwareVersion"; Expression={$_.Config.Version}},
 @{Name="ToolsStatus"; Expression={$_.Guest.ToolsStatus}},
 @{Name="ToolsVersion"; Expression={$_.Guest.ToolsVersionStatus}} | Export-Csv -NoTypeInformation -Path $outfile -Append
}
}

$totalvm = Import-Csv $outfile | Where-Object {$_.Name -like "*"} | Measure-Object | Select-Object -expand count
$toolsok = Import-Csv $outfile | Where-Object {$_.ToolsVersion -like "guestToolsCurrent"} | Measure-Object | Select-Object -expand count
$toolsold = $totalvm - $toolsok
$vmver11 = Import-Csv $outfile | Where-Object {$_.HardwareVersion -like "vmx-11"} | Measure-Object | Select-Object -expand count
$vmverold = $totalvm - $vmver11

$body = "Dear Team" 
$body += "<br>"
$body += "<br> Please find the summary of VM Hardware and VMTools version <br>" 
$body += "<br> Total No of Windows VM (Production Clusters) : $totalvm <br>"
$body += "<br> VMTools Version Status <br>"
$body += "<br> VMs running on Current VMtools Version : $toolsok"
$body += "<br> VMs running on Older VMtools Version : $toolsold <br>"
$body += "<br> VM Hardware Version Status<br>"
$body += "<br> VMs running on Hardware Version 11 : $vmver11"
$body += "<br> VMs running on Older Hardware Version : $vmverold <br>"
$body += "<br>"
$body += "<br> Regards :: Vivek I S <br>" 


$EmailFrom = "is_vivek@yahoo.co.in"
$EmailTo = "is_vivek@yahoo.co.in" 
$EmailSubject = "VM Hardware and Tools Version"
$SMTPServer = "relay.isvivek.com"

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject  -SmtpServer $SMTPServer -BodyAsHtml $body -attachment $outfile
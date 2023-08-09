# Script to fetch the HotAdd status of all the VMs
# is_vivek@yahoo.co.in
# 20-April-2017


Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server x.x.x.x

# Exclusion list defined
$exclusion = "D:\VRA-ScheduleJobs\DailyMonitoring\Exclusion.csv"

# Remove any old files if exits
$outfile = "D:\VRA-ScheduleJobs\DailyMonitoring\Final-Hotadd-VM.CSV"
If (Test-Path $outfile)
{
	Remove-Item $outfile 
}

$hotadd = "D:\VRA-ScheduleJobs\DailyMonitoring\Hotadd-VM.CSV"
If (Test-Path $outfile)
{
	Remove-Item $outfile 
}


# Capture the Hot Add Status
#$VMs = Get-VM | Get-View
$VMs =  Get-View -viewtype virtualmachine
$Output = ForEach ($VM in $VMs)
{`
"" | Select @{N="Name";E={$VM.Name}},
@{N="MemoryHotAdd";E={$VM.Config.MemoryHotAddEnabled}},
@{N="CPUHotAdd";E={$VM.Config.CpuHotAddEnabled}},
@{n='Cluster';e={$VM.Summary.Config.VmPathName | %{ $_.Split(' ')[0]; } | %{ $_.Split('-')[0]; } | %{$_ -replace “\[”,” ”}}},
@{N='OS';e={$vm.Summary.Guest.GuestFullName}}
} 
$Output | Export-Csv -Path $hotadd -NoTypeInformation

# Exclude the exclusion list from the output
$arrIgnore = Import-Csv $exclusion
$objAll = Import-Csv $hotadd

foreach($objIgnore in $arrIgnore)
{
     $objAll = $objAll | where {$_.Name -ne $objIgnore.Name}
}
$objAll | Export-Csv -Path $outfile -NoTypeInformation

$pending = Import-Csv $outfile | Where-Object {$_.CPUHotAdd -eq "false"} |Measure-Object | Select-Object -expand count
$Windows = Import-Csv $outfile | Where-Object {$_.CPUHotAdd -eq "false" -and $_.Cluster -Match "Sample1|Sample2"} |Measure-Object | Select-Object -expand count
$Linux = Import-Csv $outfile | Where-Object {$_.CPUHotAdd -eq "false" -and $_.Cluster -Match "Sample3|Sample4"} |Measure-Object | Select-Object -expand count
$tot = $Windows + $Linux

# Mail Alert
$body = "Dear Team" 
$body += "<br>"
$body += "<br> Please find the summary of VM Hotadd status <br>" 
$body += "<br> Total No of VMs Pending : $tot <br>"
$body += "<br> Total No of Windows VMs Pending : $Windows <br>"
$body += "<br> Total No of Linux VMs Pending : $Linux <br>"
$body += "<br>"
$body += "<br> Note : Please refer the attachment for detailed info."
$body += "<br>"
$body += "<br> Regards :: vRA Team <br>"

$EmailFrom = "is_vivek@yahoo.co.in"
$EmailTo = "is_vivek@yahoo.co.in" 
$EmailCc = "is_vivek@yahoo.co.in"
$EmailSubject = "VM Hot Add Status"
$SMTPServer = "webmail.isvivek.com"

Send-MailMessage -From $EmailFrom -To $EmailTo -Cc $EmailCc -Subject $EmailSubject  -SmtpServer $SMTPServer -BodyAsHtml $body -attachment $outfile

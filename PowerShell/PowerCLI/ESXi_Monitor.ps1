# Script to Trigger Mail on VSphere Resource Utilization
# Created by is_vivek@yahoo.co.in
# Created on 16-Nov-2016

Add-PSSnapin VMware.VimAutomation.Core

Connect-VIServer -Server x.x.x.x

$outfile = "D:\VRA-ScheduleJobs\DailyStatusmail\utilization.csv"

If (Test-Path $outfile)
{
	Remove-Item $outfile 
}

$mailbody = "D:\VRA-ScheduleJobs\DailyStatusmail\mailbody.csv"

If (Test-Path $mailbody)
{
	Remove-Item $mailbody 
}

Get-VMHost | 

Select-Object Name, 
    @{N='Cluster';E={Get-Cluster -VMHost $_}},
    @{N='Total_CPU';E={ $script:capacity = [math]::Round($_.CpuTotalMhz/1000,2) ; $script:capacity }},
    @{N='Used_CPU';E={ $script:used = [math]::Round($_.CpuUsageMhz/1000,2) ; $script:used}},
    @{N='CPU_Free';E={ $script:freecpu = [int](100 - $script:used/$script:capacity*100) ; $script:freecpu}},

    @{N='Total_Memory';E={ $script:mcapacity = [math]::Round($_.MemoryTotalGB,2) ; $script:mcapacity}},
    @{N='Used_Memory';E={ $script:mused = [math]::Round($_.MemoryUsageGB,2) ; $script:mused}},
	@{N='Memory_Free';E={ $script:freemem =[int](100 - $script:mused/$script:mcapacity*100) ; $script:freemem}} | Export-Csv -NoTypeInformation -Path $outfile
	

$Count = (Import-Csv $outfile | Where-Object {$_.CPU_Free -as [int] -LE "10" -or $_.Memory_Free -as [int] -LE "10"} | Measure-Object | Select-Object -expand count)

If ( $Count -ge 1 )
{

Import-Csv $outfile| Where { $_ -notmatch "server" } | Where { $_ -notmatch "scrbesxderue001" } | Where-Object {$_.CPU_Free -as [int] -LE "10" -or $_.Memory_Free -as [int] -LE "10"} |select Name,Cluster,CPU_Free,Memory_Free| Export-Csv -NoTypeInformation -Path $mailbody

$body= (Import-Csv $mailbody | Out-String)
$body = $body -replace '\n(\S+)\s+(\S+)\s+(\S+)\s+(\S+)', '<tr><td style = "border: 1px solid black; padding: 5px;text-align:center;">$1</td><td style = "border: 1px solid black; padding: 5px;text-align:center;">$2</td><td style = "border: 1px solid black; padding: 5px;text-align:center;">$3</td><td style = "border: 1px solid black; padding: 5px;text-align:center;">$4</td></tr>'
$body = '<body><br/>Hi Team<br/><br/>Please find the ESXi host CPU/Memory free percentage (%) available per host with cluster information<br/><br/><table style = "border: 1px solid black; border-collapse: collapse;">' + $body + '</table><br/>Note: This is an auto generated email, please dont reply to it.<br/><br/>Regards :: VMWare Team <br/></body>'

$EmailFrom = "donotreply@isvivek.com"
$EmailTo = "isvivek@isvivek.com"
$EmailSubject = "VSphere Health Alert"
$SMTPServer = "smtp.isvivek.com"

Send-MailMessage -From $EmailFrom -To $EmailTo -Subject $EmailSubject  -SmtpServer $SMTPServer -BodyAsHtml $body

}
Add-PSSnapin VMware.VimAutomation.Core
Connect-VIServer -Server x.x.x.x
$outdir = "C:\Users\isvivek\Script"
$hosts = Get-VMHost 
foreach ( $hos in $hosts)
{
$hos | Get-ScsiLun | Get-ScsiLunPath | `
Select @{N="ESXi";E={(Get-View -Id ($_.ScsiLunId.Split('/')[0])).Name}},Name,SCsiLunId | ft ESXi , Name , SCsiLunId -Wrap –AutoSize| Out-File "C:\Users\vis019\Desktop\Script\lun.txt" -Append
}
Import-Csv $outdir\lun.txt -delimiter "," -Header Host , LUNID , NAAID | Export-Csv -NoTypeInformation -Path $outdir\lun.csv
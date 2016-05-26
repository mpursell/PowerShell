#Script to drop multiple VMs to the domain
#Script assumes machines are powered on and joined to the domain
#Will leave VMs powered off
#Script requires VMWare PowerCli to be installed.
#Michael Pursell 2013


#set your credentials for the guest OS
$credUser = "<local admin user>"
$credPassword = "<password>"

#wmic command to drop from the domain
$domainLeave = "wmic.exe computersystem where Name=""%COMPUTERNAME%"" call unjoindomainorworkgroup"

get-content "path to vms.txt"|
foreach-object{

	Invoke-VMScript -VM $_ -ScriptType bat -ScriptText $domainLeave -GuestUser $_\$credUser -GuestPassword $credPassword
	Start-Sleep -s 3
	shutdown-vmguest $_ -Confirm:$false |out-null
	write-host $_ -foregroundcolor yellow
	
}

Write-Host "Domain disjoin Complete"

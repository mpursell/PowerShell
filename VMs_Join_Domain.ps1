#Script to join multiple VMs to the domain
#Script assumes machines are powered off and dropped from the domain 
#Script requires VMWare PowerCli to be installed and that a VMs.txt file exists with a list of VM names, no extra whitespace.
#Mike Pursell 2013


#set domain creds
$credUser = "<domain username>"
$credPassword = "<password>"


#wmic command to join domain
$domainJoin = "wmic.exe computersystem where Name=""%COMPUTERNAME%"" call joindomainorworkgroup AccountOU=""<OU1>`;OU=<OU2>`;OU=<OU3>`;DC=<dom1>`;DC=<dom2>"" FJoinOptions=1 Name=""<FQDN>"" Password=""$credPassword"" Username = ""$credUser"""



#Start the VMs

get-content "<path to VMs.txt>"|
foreach-object{
	start-vm $_ -Confirm:$false	
}

#Give the VMs a a chance to get back upc
Write-Host "Sleeping for 2 minutes while VMs power up..."
Start-Sleep -s 180

get-content "<path to VMs.txt>"|
foreach-object{
	
	
	Invoke-VMScript -VM $_ -ScriptType bat -ScriptText $domainJoin -GuestUser $_\<local admin user> -GuestPassword <local admin password>
	Start-Sleep -s 10
	shutdown-vmguest $_ -Confirm:$false
}

Write-Host "Sleeping for 2 minutes while VMs power down..."
Start-Sleep -s 180

get-content "<path to VMs.txt>"|
foreach-object{
	start-vm $_ -Confirm:$false
}

Write-Host "Domain join Complete - Finished"


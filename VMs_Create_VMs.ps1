#Creates VMs from a CSV file.  Requires PowerCLI
#Mike Pursell 2013

$vmlist = Import-CSV <path to csv>

  foreach ($item in $vmlist) {

    $linenum += 1

    $template = $item.template
    $datastore = $item.datastore
    $cluster = $item.cluster
    $custspec = $item.custspec
    $vmname = $item.vmname
    $ipaddr = $item.ipaddress
    $subnet = $item.subnet
    $gateway = $item.gateway
    $pdns = $item.pdns
    $sdns = $item.sdns
    $vlan = $item.vlan
    $folder = "<folder>"
   

        Get-OSCustomizationSpec $custspec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $ipaddr -SubnetMask $subnet -DefaultGateway $gateway -DNS $pdns,$sdns –ErrorAction Stop
        
	New-VM -Name $vmname -Template $template -Datastore $datastore -ResourcePool $cluster -location $folder -ErrorAction stop 
        
	Set-VM $vmname -OSCustomizationSpec $custspec -Confirm:$false -ErrorAction Stop
        
        Get-VM -Name $vmname | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $vlan -Confirm:$false –ErrorAction Stop
        
	Start-VM -VM $vmname –ErrorAction Stop
}

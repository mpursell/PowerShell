# The following functions are intended for use as a Powershell module to manage tenant VMs
# in a Horizon DaaS setup, without having to connect to the vCentre server through vSphere.

# The module requires PowerCLi V5 to be installed on the local server. 

function Get-GoldVM(){
<#

    .SYNOPSIS
    Function to get VMs from the vCenter server

    .DESCRIPTION
    Connects to the vCenter server and queries for any VMs.  If a full or partial name
    is specified, it will return only those that match.

    .PARAMETER User
    vCenter username

    .PARAMETER Password
    vCenter password

    .PARAMETER Name
    Full or partial VMName, not mandatory

    .PARAMETER Output
    If the Output switch is set, the function will return the list of VM objects.
    Do not use this parameter if you intend to pipe the output to other gold vm functions.
    They rely on a custom object that is only created if the output flag is not set. 

    .EXAMPLE
    Get-GoldVM -User domain\user -Password password -Name vmname -output

    .EXAMPLE
    Get-GoldVM -User domain\user -Password password -Name vmname 

    .EXAMPLE
    Get-GoldVM -User domain\user -Password password 

    .EXAMPLE
    Get-GoldVM -User domain\user -Password password -Name vmname | Restart-GoldVM

    .INPUTS
    

    .OUTPUTS
    Outputs either the VM objects (if the Output flag is set), or custom PS objects if not.

#>
  
    [CmdletBinding()]

        param(


            [Parameter(Mandatory=$false, ValueFromPipeline=$true)][string[]]$Name,
            [Parameter(Mandatory=$true)][string]$User,
            [Parameter(Mandatory=$true)][string]$Password,
            [Parameter(Mandatory=$false)][switch]$Output
           
            )
    BEGIN{
    
        
    
        # Adds the base cmdlets
        Add-PSSnapin VMware.VimAutomation.Core


        # set the address of the tenant vSphere box
        $VIServerAddress = "<server address>"

        Connect-VIServer $VIServerAddress -Protocol Https -User $User -Password $Password | Out-Null
    }

    PROCESS{

        
        
        if($Name){

            foreach ($VMName in $Name){

                
                
                if($Output){

                    # if the output flag is set, just return the VM objects as normal

                    Get-VM | Where {$_.Name -like "*$VMName*"}

                }

                else{
                    
                    # if the output flag isn't set
                    # null the output since we're writing a custom object to the pipeline at the end of this function

                    Get-VM | Where {$_.Name -like "*$VMName*"} | Out-Null
                }
                
            }
        }
        else{
            
            # same thing here, check if the output flag is set and modify the cmdlet output accordingly

            if($Output){
                
                Get-VM | Where {$_.Name -like "GVM*"}

            }
            else{
                
                Get-VM | Where {$_.Name -like "GVM*"} | Out-Null

            }
            

        }

    }

    END{

        foreach($VMName in $Name){

            if(!$Output){

                # if the output flag isn't set, assume that we don't want the cmdlet to return the usual list of objects
                # setup a custom object with props that we can pipe to the other functions in this module

                $VMObject = New-Object -TypeName PSCustomObject -Property @{"Name" = $VMName; "User"=$User; "Password"=$Password}
                Write-Output $VMObject

            }

        }
        
    }
}


function Restart-GoldVM(){

<#

    .SYNOPSIS
    Function to restart specified VMs

    .DESCRIPTION
    Restarts the given Gold VMs.  Will take VM name and connection details from the console, 
    or piped in via the Get-GoldVM function

    .PARAMETER User
    vCenter username

    .PARAMETER Password
    vCenter password

    .PARAMETER Name
    Full VMName

    .EXAMPLE
    Restart-GoldVM -User <domain\user> -Password <password> -Name <vm name>

    .EXAMPLE
    Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Restart-GoldVM 

    .INPUTS
    Accepts command line or piped input. 

    .OUTPUTS
    Outputs the restarted VM objects.
#>

        [CmdletBinding()]

        param(


            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string[]]$Name,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$User,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$Password
            
           
            )
    BEGIN{

        # check if the snap in is already loaded.  It will be if we're piping from Get-GoldVMs
        if (!(Get-PSSnapin -Name VMware.VimAutomation.Core)){
    
            # Adds the base cmdlets
            Add-PSSnapin VMware.VimAutomation.Core

        }


        $VIServerAddress = "<server address>"

        

        Connect-VIServer $VIServerAddress -Protocol Https -User $User -Password $Password -ErrorAction SilentlyContinue | Out-Null
    }


    PROCESS{

        foreach ($VM in $Name){

            Restart-VM -VM $VM -Confirm:$false
 
            
        }

    }


}

function Move-GoldVMToBuildNetwork(){

<#

    .SYNOPSIS
    Function to move specified VMs to the build / deployment network so they can be 
    re-imaged.

    .DESCRIPTION
    Moves the specified VMs to the given build network.  Accepts command line input, 
    or input piped from Get-GoldVM.

    .PARAMETER User
    vCenter username

    .PARAMETER Password
    vCenter password

    .PARAMETER Name
    Full VMName

    .EXAMPLE
    Move-GoldVMToBuildNetwork -User <domain\user> -Password <password> -Name <vm name>

    .EXAMPLE
    Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Move-GoldVMToBuildNetwork 

    .INPUTS
    Accepts command line input, or input piped from Get-GoldVM. 

    .OUTPUTS
    Outputs the reconfigured VM objects.
#>
        [CmdletBinding()]

        param(


            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string[]]$Name,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$User,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$Password
           
            )
    BEGIN{
    
       if (!(Get-PSSnapin -Name VMware.VimAutomation.Core)){
    
            # Adds the base cmdlets
            Add-PSSnapin VMware.VimAutomation.Core

        }

        # set the address of the tenant vSphere box
        $VIServerAddress = "<server address>"

        Connect-VIServer $VIServerAddress -Protocol Https -User $User -Password $Password -ErrorAction SilentlyContinue | Out-Null
    }

    PROCESS{

        $buildNetwork = "<network>"

        foreach($VM in $Name){

            $networkAdapter = Get-NetworkAdapter -VM $VM

        }

        Set-NetworkAdapter -NetworkAdapter $networkAdapter -NetworkName $buildNetwork -Connected $true -Confirm:$false


    }

}


function Move-GoldVMToClientNetwork(){
<#

    .SYNOPSIS
    Function to move specified VMs to the client network so they can be 
    picked up by the DaaS portal.

    .DESCRIPTION
    Moves the specified VMs to the givenclient  network.  Accepts command line input, 
    or input piped from Get-GoldVM.

    .PARAMETER User
    vCenter username

    .PARAMETER Password
    vCenter password

    .PARAMETER Name
    Full VMName

    .Parameter ClientNetwork
    Client network name

    .EXAMPLE
    Move-GoldVMToClientNetwork -User <domain\user> -Password <password> -Name <vm name> -ClientNetwork <network>

    .EXAMPLE
    Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Move-GoldVMToClientNetwork -ClientNetwork <network>

    .INPUTS
    Accepts command line input, or input piped from Get-GoldVM. 

    .OUTPUTS
    Outputs the reconfigured VM objects.
#>

        [CmdletBinding()]

        param(


            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string[]]$Name,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)][string]$User,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName)][string]$Password,
            [Parameter(Mandatory=$true)][string]$ClientNetwork
           
            )
    BEGIN{
    
        # check if the snap in is already loaded.  It will be if we're piping from Get-GoldVMs
        if (!(Get-PSSnapin -Name VMware.VimAutomation.Core)){
    
            # Adds the base cmdlets
            Add-PSSnapin VMware.VimAutomation.Core

        }


        # set the address of the tenant vSphere box
        $VIServerAddress = "<server address>"
        
        Connect-VIServer $VIServerAddress -Protocol Https -User $User -Password $Password -ErrorAction SilentlyContinue| Out-Null
    }

    PROCESS{

        

        foreach($VM in $Name){

            $networkAdapter = Get-NetworkAdapter -VM $VM

        }

        Set-NetworkAdapter -NetworkAdapter $networkAdapter -NetworkName $clientNetwork -Connected $true -Confirm:$false


    }

}


function Rebuild-GoldVM(){
<#

    .SYNOPSIS
    Function to rebuild specified tenant VMs

    .DESCRIPTION
    Invokes a PowerShell script on the tenant VMs that triggers an MDT task sequence

    .PARAMETER User
    vCenter username

    .PARAMETER Password
    vCenter password

    .PARAMETER Name
    Full VMName

    .EXAMPLE
    Rebuild-GoldVM -User <domain\user> -Password <password> -Name <name>

    .EXAMPLE
    Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Rebuild-GoldVM

    .INPUTS
    Accepts command line input, or input piped from Get-GoldVM. 

    .OUTPUTS
    None.
#>

    [CmdletBinding()]

        param(


            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string[]]$Name,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$User,
            [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)][string]$Password
            
           
            )
    BEGIN{
    
        # check if the snap in is already loaded.  It will be if we're piping from Get-GoldVMs
        if (!(Get-PSSnapin -Name VMware.VimAutomation.Core)){
    
            # Adds the base cmdlets
            Add-PSSnapin VMware.VimAutomation.Core

        }

        # set the address of the tenant vSphere box
        $VIServerAddress = "<server address>"

        Connect-VIServer $VIServerAddress -Protocol Https -User $User -Password $Password -ErrorAction SilentlyContinue| Out-Null
    }

    PROCESS{

        foreach($VM in $Name){

            # NB because the task sequence inevitably requires a restart, VMWare tools will stop responding
            # at some point during the script invocation, which will always throw an exception.

            try{

                Invoke-VMScript -VM $VM -ScriptText "C:\Windows\Temp\TaskSequence.ps1" -GuestUser Administrator -GuestPassword M1cr0s0ft 

            }
            catch [NotSpecified]{
            
                Write-Host "Lost contact with guest OS, probably due to restart in task sequence.  Check MDT for build progress" -ForegroundColor Green
                
            }

        }

    }

}


### TEST FUNCTION CALLS ###

#Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Restart-GoldVM
#Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Move-GoldVMToBuildNetwork
#Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Move-GoldVMToClientNetwork -ClientNetwork <network>
#Get-GoldVM -User <domain\user> -Password <password> -Name <name> | Rebuild-GoldVM
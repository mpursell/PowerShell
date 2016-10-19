function Get-RegStubPaths($registryPath){

    # set our reg location and enumerate all the child keys of that key
    Set-Location $registryPath 

    $list = Get-ChildItem

    Foreach($key in $list){

        # get the properties for all the keys we're iterating over

        $props = Get-ItemProperty $key.PSPath

        # iterate over each of the properties in the properties list for each reg key
        Foreach($prop in $props){

            # if we get a hit on a property name of StubPath, do stuff

            If($prop -match "StubPath"){
            
                $propPath = $prop.PSPath
                $childPath = $prop.PSChildName
                $stubvalue = $prop.StubPath

                 # writes out the stub path to console
                #$prop

                
                try{

                    Set-ItemProperty -Path "$registrypath\$childpath" -Name StubPath -Value "" -ErrorAction Stop -Force
                    Write-Log "Success... Removed $registrypath\$childpath\StubPath\$stubvalue"

                }catch{
                    
                    $errorMessage = $_.Exception.Message
                    Write-Log "Failure... Failed to remove $propPath\StubPath: $errorMessage"

                }
                

            }

        }


    }

}

function Disable-UAC{

    try{

        New-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force -ErrorAction Stop | Out-Null
        Write-Log "Success... Disable UAC"

    }catch{

        $errorMessage = $_.Exception.Message
        Write-Log "Failed... Exception thrown in Disable-UAC: $errorMessage"
    }
    
}

function Disable-WindowsFirewall{
    
    try{

        Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False -ErrorAction Stop | Out-Null
        Write-Log "Success... Disable-WindowsFirewall"

    }catch{
        
        $errorMessage = $_.Execption.Message
        Write-Log "Failed... Exception thrown in Disable-WindowsFirewall: $errorMessage"

    }
}

function Install-DesktopExperience{

    $checkFeature = Get-WindowsFeature -Name Desktop-Experience
    
    if($checkFeature.InstallState -notmatch "Installed"){
    
        try{

            Install-WindowsFeature Desktop-Experience -ErrorAction Stop | Out-Null
            Write-Log "Success... Install-DesktopExperience"

        }catch{

            $errorMessage = $_.ExceptionMessage
            Write-Log "Failure... Exception thrown in Install-DesktopExperience: $errorMessage"
        }
    } 
    
}

function Prevent-OutlookIndexing{

    try{

        New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Name PreventIndexingOutlook -PropertyType DWord -Value 1 -ErrorAction Stop | Out-Null
        Write-Log "Success... Prevent-OutlookIndexing"

    }catch{
        $errorMessage = $_.Exception.Message
        Write-Log "Failure... Exception thrown in Prevent-OutlookIndexing; $errorMessage"

    }
}




function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "Run-Optimisations.log"
    $fullpath = "$path\$logfile"
    $date = Get-Date

    # check if the log file exists, if it does, append content, if not create
    # a new file and add content to it.
    if (Test-Path $fullpath){
        
        Add-Content -Path $fullpath -Value "`n$date:: $text"

    }elseif (!(Test-Path $fullpath)){
        
        New-Item -ItemType File -Path $fullpath | Out-Null
        Add-Content -Path $fullpath -Value "`n$date:: $text"
    }

}

Get-RegStubPaths "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\"
Get-RegStubPaths "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Active Setup\Installed Components\"
Disable-UAC
Disable-WindowsFirewall
Install-DesktopExperience
Prevent-OutlookIndexing




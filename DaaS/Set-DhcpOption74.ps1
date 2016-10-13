# script to set option 74 settings in the DaaS agent MonitorAgent.ini file
# .EXAMPLE 
#     ./Set-Dhcp 10.0.0.0 10.0.0.1

param(
    
    [string]$firstip,
    [string]$secondip

)

function Set-DhcpOption74{

    $inipath = "C:\Program Files (x86)\VMware\VMware DaaS Agent\Service\MonitorAgent.ini" 

    # check the ini file is there
    if(!(Test-Path $inipath)){

        Write-Log "Failure... Ini file could not be found"
        return 1

    }else{

        # args should be empty if the correct number of params have been specified
        # so check it, if it has anything there, return 1 and write a failure to the log
        if($args){

            Write-Log "Failure... Too many arguments specified"
            return 1
        }
    
        # if we've got a second ip specified we know we have to add both ip addresses.
        if ($secondip){
        
                # get the content of the ini file and do the replacements

                try{

                    (Get-Content $inipath).Replace(";standby_address=<uncomment and add comma separated standby address list>","standby_address=$firstip,$secondip") | Out-File $inipath
                    (Get-Content $inipath).Replace("auto_discover=1","auto_discover=0") | Out-File $inipath

                    Write-Log "Success... $inipath modified with: $firstip, $secondip"
                    return 0

                }catch{

                    $ExceptionMessage = $_.Exception.Message
                    Write-Log "Failure... Check $inipath configuration.  Exception thrown: $ExceptionMessage"

                }

        }else{

                # if there's no second ip specified we can just add the first ip in.
                
                try{

                    (Get-Content $inipath).Replace(";standby_address=<uncomment and add comma separated standby address list>","standby_address=$firstip")| Out-File $inipath
                    (Get-Content $inipath).Replace("auto_discover=1","auto_discover=0")| Out-File $inipath

                    Write-Log "Success... $inipath modified with: $firstip"
                    return 0

                }catch{

                    $ExceptionMessage = $_.Exception.Message
                    Write-Log "Failure... Check $inipath configuration. Execption thrown: $ExceptionMessage"
                }
            }

    }

}


function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "set-dhcp.log"
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

Set-DhcpOption74 $args
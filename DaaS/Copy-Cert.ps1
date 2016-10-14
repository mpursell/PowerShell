# script to copy tenant SSL cert obtained from DaaS portal to tenant Gold VM
# during build / task sequence
#
# .EXAMPLE
#    Copy-Cert %deployroot%\certdir\

param(

    [string]$certpath

)

function Copy-Cert{

    $cert = "cacert.pem"

    try{

        Copy-Item -Path $certpath\$cert -Destination "C:\Program Files (x86)\VMware\VMware DaaS Agent\cert\"

    
    }catch{

        $ExecptionMessage = $_.Exception.Message
        Write-Log "Exception thrown: $ExceptionMessage"

    }
    
}



function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "copy-cert.log"
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

Copy-Cert
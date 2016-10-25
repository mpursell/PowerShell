<#
    
    Script to remove logs over 100kb

#>

function Clear-Logfiles($LogPath){


    $filelist = Get-childitem $LogPath

    foreach ($file in $filelist){

        if($file.Name.Contains(".log")){

            if($file.Length -gt 100000){

                $fileLength = [math]::round($file.Length / 1000)

                try{

                    Remove-Item $LogPath\$file -Force -ErrorAction SilentlyContinue| Out-Null
                    Write-Log "Sucess... Removed $file because it was $fileLength kB long"
           
                }catch{

                    $exceptionMessage = $_.Exception.Message
                    Write-Log("Failure... Failed to remove $file of $fileLength kB length: $exceptionMessage")
                }

            }
        }
    }
}

function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "Clear-Logfiles.log"
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

Clear-Logfiles "C:\windows\temp"
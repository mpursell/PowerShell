function Write-Log($text){

        $path = "<path to log file>"
        $logfile = "<logfile name>"
        $fullpath = "$path\$logfile"
        $date = Get-Date

        # check if the log file exists, if it does, append content, if not create
        # a new file and add content to it.
        if (Test-Path $fullpath){
        
            Add-Content -Path $fullpath -Value "$date:: $text"

        }elseif (!(Test-Path $fullpath)){
        
            New-Item -ItemType File -Path $fullpath | Out-Null
            Add-Content -Path $fullpath -Value "$date:: $text"
        }

    }
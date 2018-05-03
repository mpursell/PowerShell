<#

    Script to disable named scheduled tasks.  
    Add any required tasks to the $tasks array of arrays ('task name', 'task path'). 

#>


function Disable-Tasks{

    # list of lists to hold the task name, task path
    $tasks = (("ServerManager", "Microsoft\Windows\Server Manager"),("",""))
  
    # get the length of the array and set a counter var
    $arrayLength = $tasks.Length
    $i = 0
    
    # while the counter is less than the length of the $tasks array
    while ($i -le $arrayLength){

        # get the first and second entry in each list of lists
        $taskName = $tasks[$i][0]
        $taskPath = $tasks[$i][1]

        try{

            # sanity check to make sure that task name is actually populated with something
            # other than an empty string

            if($taskName -ne ""){

                Disable-ScheduledTask -TaskName $taskName  -TaskPath $taskPath  -ErrorAction Stop | out-Null
                Write-Log "Success... Disabled $taskName"

            }else{

                # quit the script if the task name is empty
                exit
            }

        }catch{

            $exceptionMessage = $_.Exception.Message
            Write-Log "Failure... Failed to disable $taskName : $exceptionMessage"
        }

        # increment the counter var
        $i++
    
    }
}

function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "DisableTasks.log"
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

Write-Log "*********************************************************"
Write-Log "************** Disabling ServerManager ******************"
Write-Log "*********************************************************"
Write-Log ""

Disable-Tasks


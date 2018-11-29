function Get-LogTimeDifferentials{

# Parses the time differential between log entries to try and identify the longest spells
# Accepts "Hours" "Minutes" or "Seconds" as the TimeUnit
# TimeLimit is the least amount of time you are interested in parsing - i.e everything that takes longer
# to process that the TimeLimit will be displayed. 
    
    [CmdletBinding()]
    param(

        [Parameter(ValueFromPipeLine=$true)][string]$path,
        [Parameter(ValueFromPipeLine=$true)][string]$TimeUnit,
        [Parameter(ValueFromPipeLine=$true)][int32]$TimeLimit

        )

# Gather an array of arrays that contain (datetime object - info)


    $log = get-content $Path
    $logList = New-Object System.Collections.ArrayList
    $counter = 0
    [DateTime]$previousDate = Get-Date
    [String]$info = "Start"

    foreach($entry in $log){

        $entry = $entry.split('.')

   
        $timestamp = $entry[0]
        $info = $entry[1]

       
    

        try{
    
            $date = [DateTime]::Parse($timestamp) 
            

        }catch{
        
            continue
            }
    
   


        $logObject = New-Object -TypeName PSCustomObject -Property @{"Date" = $date; "Info" = $info}

        $logList.Add($logObject)| out-null
    
    }

# iterate over the array of arrays and find the timespan between the previous datetime entry and the current
# datetime log entry.  If the result is over the specified TimeLimit, display the log time, info, and diff in TimeUnits

    foreach($item in $logList){

        $currentDate = $item.date
        $info = $item.info
    

       if($counter -eq 0){
        
            $previousDate = $currentDate
            $previousDate
            $counter ++

        }else{
        
            [TimeSpan]$diff = New-TimeSpan -Start $previousDate -End $currentDate

            $diffTime = $diff.$timeUnit

            $diffObject = New-Object -TypeName PSCustomObject -Property @{"Date" = $previousDate; "Info" = $previousinfo; "Diff" = $diffTime}

            if($diffObject.Diff -gt $TimeLimit){
        
                $diffobject | Export-Csv -Path c:\users\sa_pursellm\desktop\flexengine.csv -Append
            } 

        

        }
        
        $previousDate = $currentDate
        $previousInfo = $info
        

    }

}



Get-LogTimeDifferentials -Path "C:\Users\sa_pursellm\Desktop\logs\flexengine(eha_adamsk).log" -timeUnit Seconds -timeLimit 30
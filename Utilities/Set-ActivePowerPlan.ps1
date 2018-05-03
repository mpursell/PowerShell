# Script to set the active powerplan
# M Pursell 17.11.16
#
# NOTE: takes the powerplan name as a param



# name can be either "Balanced" "High Performance" or "Power Saver"
param([string]$powerPlanName)

function Set-ActivePowerPlan{

    # get the power plan back from wmi and set it to active

    try{
    
        $powerplan = Get-WmiObject -NS root\cimv2\power -Class win32_PowerPlan | where{$_.elementName -eq $powerPlanName}
        Write-Log "Success...Retrieved $powerPlanName Power Plan"
    
    }catch{
        
        $exception = $_.Exception.Message
        Write-Log "Failure... Failed to retrieve $powerPlanName Power Plan: $exception"
    }
   
    try{
    
        $powerplan.Activate()
        Write-Log "Success... Activated $powerPlanName Power Plan"
    
    }catch{

        $exception = $_.Exception.Message
        Write-Log "Failure... Failed to activate $powerPlanName : $exception"
    }
}


function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "PowerPlan.log"
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
Write-Log "*************** Setting Power Plan **********************"
Write-Log "*********************************************************"
Write-Log ""

Set-ActivePowerPlan
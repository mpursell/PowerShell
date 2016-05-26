$MPErrorLogPreference = "C:\users\sa_pursellm\desktop\ErrorLog.txt"

Function Get-MPSystemInfo{

    <#
    .SYNOPSIS
    Queries critical computer information from a single machine.
    .DESCRIPTION
    Queries OS and hardware information from a single computer.  This
    utilises WMI, so the appropriate ports must be open, and you must
    be a local administrator on the target machine.
    .PARAMETER ComputerName
    The name of the computer to query. Accepts multiple values
    and accepts pipeline input
    .PARAMETER IPAddress
    The IP address of the computer to query.  Accepts multiple values,
    but does not accept pipeline input.
    .PARAMETER ShowProgress
    Displays a progress bar with the current operation and percent complete.
    Percentage will be inaccurate when receiving input from the pipeline. 
    .EXAMPLE
    Get-MPSystemInfo -ComputerName XXXXX
    Query single computer by name.
    .EXAMPLE
    Get-MPSystemInfo -ComputerName XXXX | Format-Table *
    This will display the information in a table.
    .EXAMPLE
    Get-MPSystemInfo -IPAddress 10.0.0.0
    Query computer by IP address.
    .EXAMPLE
    Get-MPSystemInfo -IPAddress 10.0.0.0,10.0.0.1,10.0.0.2
    Query multiple computers by IP address. 
    #>

    [CmdletBinding()]
    param(
        # sets up a -ComputerName parameter for the script with a default fall back value of "localhost"
        [Parameter(Mandatory=$True,
            ValueFromPipeline=$True, 
            ValueFromPipelineByPropertyName=$True,
            ParameterSetName='computername',
            HelpMessage='Computer name to query via WMI')]
        [Alias('hostname')]
        [ValidateLength(1,15)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$True,
                    ParameterSetName='ip',
                    HelpMessage='IP address to query via WMI')]
        [ValidatePattern('\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}')]
        [string[]]$IPAddress,


        [Parameter()]
        [string]$ErrorLogPath = $MPErrorLogPreference,

        [switch]$ShowProgress
    )

    # BEGIN, PROCESS and END required for pipeline support, function will just run against the last object 
    # in the pipeline otherwise. 

    # BEGIN executes first, used for opening log files, DB connections etc
    BEGIN{
        # if block to catch the case if the ipaddress parameter is specified. 
        # if it is, make sure $computername contains the $ipaddress.
        if($PSBoundParameters.ContainsKey('ipaddress')){
            $ComputerName = $IPAddress
        }

        #$each_computer = (100 / ($ComputerName.count) -as [int])
        #$current_complete = 0

    }

    PROCESS{
    # foreach to account for more than one computername
    foreach($computer in $ComputerName){

            if($computer -eq '127.0.0.1'){
                Write-Warning "Connecting to local computer via loopback address"
            }

            if($ShowProgress){Write-Progress -Activity "Working on $computer" -PercentComplete $current_complete}
            
            write-Verbose "Querying WMI for $computer"
            # wmi queries

            if($ShowProgress){Write-Progress -Activity "Working on $computer" -CurrentOperation "Operating System" -PercentComplete $current_complete}

            try{

                $everything_ok = $True
                $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $Computer -ErrorAction Stop -ErrorVariable myerr

            }catch{

                $everything_ok = $false
                Write-Warning "Logging computer name to $ErrorLogPath"
                Write-Warning "The error was $myerr"
                $computer | Out-File $ErrorLogPath -Append

            }

            if($everything_ok){
                if($ShowProgress){Write-Progress -Activity "Working on $computer" -CurrentOperation "Computer System" -PercentComplete $current_complete}
                $cs = Get-WmiObject -Class win32_computersystem -ComputerName $Computer


                Write-Verbose "Building ouptut..."
                if($ShowProgress){Write-Progress -Activity "Working on $computer" -CurrentOperation "Creating Output" -PercentComplete $current_complete}
                # combine the desired properties from the two wmi queries into a hash table
                $props = @{'ComputerName' = $Computer;
                            'OSVersion' = $os.version;
                            'OSBuild' = $os.buildnumber;
                            'SPVersion' = $os.servicepackmajorversion;
                            'Model' = $cs.model;
                            'Manufacturer' = $cs.manufacturer;
                            'RAM' = $cs.TotalPhysicalMemory / 1GB -as [int];
                            'Sockets' = $cs.NumberOfProcessors;
                            'Cores' = $cs.NumberOfLogicalProcessors
                            }

                # create a custom object that uses the hash table to provide the keys and values for the object's properties
                $obj = New-Object -TypeName PSObject -Property $props

                Write-Verbose "Outputting to pipeline"

                $obj.PSObject.Typenames.Insert(0,'MP.SystemInfo')
                Write-Output $obj

                Write-Verbose "Done with $computer"
                
            }

            #$current_complete += $each_computer
            if($ShowProgress){Write-Progress -Activity "Working on $computer" -PercentComplete $current_complete}
        }
    }
    # END executes last, put in cleanup like dropping DB connections etc.import
    END{
        if($ShowProgress){Write-Progress -Activity "Done" -Completed}
    
    }
}

# This means that only the exported functions and variables are available to users
# when the module is loaded.  functions and variables are still accessible internally in the module. 
Export-ModuleMember -Function Get-MPSystemInfo -Variable MPErrorLogPreference
  
#Get-MPSystemInfo -ComputerName $env:COMPUTERNAME, localhost
#$env:COMPUTERNAME, 'localhost' | Get-MPSystemInfo
#import-csv C:\users\sa_pursellm\Desktop\computers.csv | Get-MPSystemInfo
#Get-MPSystemInfo -IPAddress '192.168.1.52', '127.0.0.1','192.168.0.6', '127.0.0.1','192.168.0.6', '127.0.0.1','192.168.0.6', '127.0.0.1' -Verbose -showprogress
#help Get-MPSystemInfo -full
#'localhost' | Get-MPSystemInfo

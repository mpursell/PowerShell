
Function Get-MDTAppName{

<#
    .SYNOPSIS
    CmdLet to display the name of an MDT application for a given GUID

    .DESCRIPTION
    Takes a Path and GUID input and displays the name of the application.  The script
    will look for the Applications.XML in the \Control\Applications folder in the 
    specified deployment share and return the results based on that.  Enter any of the alphnumeric 
    guid string to search the xml. 

    .PARAMETER Path
    Path to the root of the deployment share, shortened to either Win7 or Win8.  If neither is specified
    it will default to the Win7 path \\0.0.0.0\DeployShare1$

    .PARAMETER Guid
    Partial or complete guid of the application

    .EXAMPLE
    Get-MDTAppNameFromGUID -Path Win7 -Guid 'r92f' 

    .INPUTS
    Accepts pipeline input for the Guid parameter

    .OUTPUTS
    Formatted list of Name, Source Folder and Guid

#>

    [CmdletBinding()]

    param(
    
        [Parameter(Mandatory=$True)]
        [string]$Path,

        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [string]$Guid
    )

    if($Path -eq "Win7"){

        $realPath = "\\0.0.0.0\DeployShare1$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"

    } elseif($Path -eq "Win8"){
        
        $realPath = "\\0.0.0.0\DeployShare2$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"

    } else{

        $realPath = "\\0.0.0.0\DeployShare1$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"
    }

    try{
        
        Write-Verbose "Getting the xml file"
        $Search = [xml]$xml = Get-Content -Path $realPath -ErrorAction Stop

    } catch{

        Write-Warning "Check your path is correct.  Path is currently: $realPath"
        Write-Verbose "Exiting script"
        Break

    }

    Write-Verbose "Getting the Name, Source and Guid from the xml nodes applications.application"

    foreach($result in $Search){

    #$xml.applications.application | where {$_.guid -like "*$Guid*"} | Select-Object Name, source, guid

    $properties = @{'Name' = $xml.applications.application | where {$_.guid -like "*$Guid*"} | Select-Object -ExpandProperty Name;
                    'Source' = $xml.applications.application | where {$_.guid -like "*$Guid*"} | Select-Object -ExpandProperty Source;
                    'GUID' = $xml.applications.application | where {$_.guid -like "*$Guid*"} | Select-Object -ExpandProperty GUID}

    $object = New-Object -TypeName PSCustomObject -Property $properties


    Write-Verbose 'Writing custom object to pipeline'
    Write-output $object 
    }
              
}


Function Get-MDTAppGuid{


<#
    .SYNOPSIS
    CmdLet to get the GUID of an MDT application for a given application name

    .DESCRIPTION
    Takes a Path and name input and displays the guid of the application.  The script
    will look for the Applications.XML in the \Control\Applications folder in the 
    specified deployment share and return the results based on that.  Enter any of the alphnumeric 
    name string to search the xml. 

    .PARAMETER Path
    Path to the root of the deployment share, shortened to either Win7 or Win8.  If neither is specified
    it will default to the Win7 path \\0.0.0.0\DeployShare1$

    .PARAMETER name
    Partial or complete name of the application

    .EXAMPLE
    Get-MDTAppGuidFromName -Path Win7 -Name 'Microsoft*' 

    .INPUTS
    Accepts pipeline input for the Name parameter

    .OUTPUTS
    Formatted list of Name, Source Folder and Guid

#>

[CmdletBinding()]

    param(
    
        [Parameter(Mandatory=$True)]
        [string]$Path,

        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [string]$Name
    )

    if($Path -eq "Win7"){

        $realPath = "\\0.0.0.0\DeployShare1$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"

    } elseif($Path -eq "Win8"){
        
        $realPath = "\\0.0.0.0\DeployShare2$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"

    } else{

        $realPath = "\\0.0.0.0\DeployShare1$\Control\Applications.xml"
        Write-Verbose "Path set to $realPath"
    }

    try{
        
        Write-Verbose "Getting the xml file"
        [xml]$xml = Get-Content -Path $realPath -ErrorAction Stop

    } catch{

        Write-Warning "Check your path is correct.  Path is currently: $realPath"
        Write-Verbose "Exiting script"
        Break

    }

    Write-Verbose "Getting the Name, Source and Guid from the xml nodes applications.application"
    
    

    $Search = $xml.applications.application | where {$_.name -like "*$Name*"}

    foreach($result in $Search){
        $properties = @{'Name' = $result.name;
                    'Source' = $result.Source;
                    'GUID' = $result.guid}

        $object = New-Object -TypeName PSCustomObject -Property $properties

        Write-Verbose 'Writing custom object to pipeline'
        Write-output $object

    }
              
}




Function Get-MDTAppLocation{

<#
    .SYNOPSIS
    Cmdlet to find the location of apps in MDT Task Sequences and SQL

    .DESCRIPTION
    Takes a Path and Guid as parameters.  Searches the ts.xml files in 
    the \Control\ folder and sub-folders for the app guid and returns the location
    of the xml file.  Designed to sit at the end of the pipeline, Get-MDTAppGuidFromName
    can be piped into this cmdlet. 

    .PARAMETER Path
    Accepts input as a parameter, or from the pipeline

    .PARAMETER Guid
    Accepts input as a parameter, or from the pipeline

    .EXAMPLE
    Get-MDTAppLocation -Path \\server\share -Guid '{567*'

    .EXAMPLE
    Get-MDTAppGuidFromName -Path \\server\share -Name 'Microsoft*' | Get-MDTAppLocation

    .INPUTS
    Accepts pipeline input

    .OUTPUTS
    List of locations.  Designed to sit at the end of the pipeline, so
    DOES NOT output objects that can be piped. 

#>

    [CmdletBinding()]

        param(
    
            [Parameter(Mandatory=$True,
                       ValueFromPipeline=$True, 
                       ValueFromPipelineByPropertyName=$True)]
            [string]$Path,

            [Parameter(ValueFromPipeline=$True,
                        ValueFromPipelineByPropertyName=$True)]
            [string[]]$Guid
        )

    if($Path -eq "Win7"){

        $realPath = "\\0.0.0.0\DeployShare1$\Control\"
        Write-Verbose "Path set to $realPath"

    } elseif($Path -eq "Win8"){
        
        $realPath = "\\0.0.0.0\DeployShare2$\Control\"
        Write-Verbose "Path set to $realPath"

    } else{

        $realPath = "\\0.0.0.0\DeployShare1$\Control\"
        Write-Verbose "Path set to $realPath"
    }


    if($Guid){

        foreach($id in $guid){
        
            $tsSearch = Get-ChildItem -path $realPath -Recurse -Filter *.xml | select-string -Pattern "$id" | 
            select filename, path | where{$_.filename -ne "ApplicationGroups.xml"  -and $_.filename -ne "Applications.xml"  -and $_.filename -ne "Applications - copy.xml"}
        
            if($tsSearch){

                $tsSearch
            }else{

                Write-Warning "Application not found in task sequences"
            }

        }

    }else{

        Write-Warning "Either enter a GUID as a parameter, or pipe in an object that has a GUID property"
    }

}

Function Get-MDTSupportedModel{

<#
    .SYNOPSIS
    Cmdlet to see a model is supported

    .DESCRIPTION
    Takes a full or partial variant code and path or name and searches the path's
    DriverGroups.xml for the model.  Returns a list of names which are folder names
    in MDT's Deployment Workbench structure. 

    .PARAMETER Path
    Accepts input as a parameter, or from the pipeline

    .PARAMETER Variant
    Accepts input as a parameter, or from the pipeline

    .EXAMPLE
    Get-MDTSupportedModel -Path \\server\share -Variant 'HP'

    .INPUTS
    Accepts pipeline input

    .OUTPUTS
    List of names.  Designed to sit at the end of the pipeline, so
    DOES NOT output objects that can be piped. 

#>
    
    [CmdletBinding()]

        param(
    
            [Parameter(Mandatory=$True,
                       ValueFromPipeline=$True, 
                       ValueFromPipelineByPropertyName=$True)]
            [string]$Path,

            [Parameter(Mandatory=$True,
                        ValueFromPipeline=$True,
                        ValueFromPipelineByPropertyName=$True)]
            [string[]]$Variants

            
        )

    if($Path -eq "Win7"){

        $realPath = "\\0.0.0.0\DeployShare1$\Control\"
        Write-Verbose "Path set to $realPath"

    } elseif($Path -eq "Win8"){
        
        $realPath = "\\0.0.0.0\DeployShare2$\Control\"
        Write-Verbose "Path set to $realPath"

    } else{

        $realPath = "$Path\Control\"
        Write-Verbose "Path set to $realPath"
    }


    [xml]$xml = get-content "$realPath\DriverGroups.xml"

    foreach($Variant in $Variants){
     
        # removing a whole bunch of exceptions from the list.  These occur because the xml picks up the folder structure from MDT, we don't need
        # any of the top level folder names, we're just interested in the specific driver group folders that deliver drivers to variants / models.

        $result = $xml.groups.group | select -ExpandProperty name | where{$_ -like "*$Variant*" -and $_ -ne 'default' -and $_ -ne 'hidden' -and $_ -ne 'NFC' -and $_ -ne 'x64' -and $_ -ne 'WinPE' -and $_ -ne 'x64\10' -and $_ -ne 'x64\8' -and
                                                                    $_ -ne 'x64\10\Lenovo' -and $_ -ne 'x64\8\Lenovo' -and $_ -ne 'x64\10\VMware, Inc.' -and $_ -ne 'x64\8\VMware, Inc.'-and $_ -ne 'x64\8\Dell Inc.' -and
                                                                    $_ -ne 'x64\10\Microsoft Corporation' -and $_ -ne 'x64\8\Microsoft Corporation' -and $_ -ne 'x64\8\Hewlett-Packard' -and $_ -ne 'x64\10\Hewlett-Packard' -and
                                                                    $_ -ne 'NIC' -and $_ -ne 'NIC\7x64' -and $_ -ne 'NIC\7x86' -and $_ -ne 'NIC\XP' -and $_ -ne 'temp' -and $_ -ne 'x64\2008R2' -and $_ -ne 'x64\7' -and $_ -ne 'x86\7' -and
                                                                    $_ -ne 'x64\7\Acer, inc.' -and $_ -ne 'x64\7\Dell Inc.' -and $_ -ne 'x64\7\Lenovo' -and $_ -ne 'x64\7\Hewlett-Packard' -and $_ -ne 'x64\7\Microsoft Corporation' -and 
                                                                    $_ -ne 'x64\7\Viglen' -and $_ -ne 'x64\PE3' -and $_ -ne 'x86' -and $_ -ne 'x86\7\Dell Inc.' -and $_ -ne 'x86\7\Hewlett-Packard' -and $_ -ne 'x64\7\VMware, Inc' -and
                                                                    $_ -ne 'x64\7\Viglen\test' -and $_ -ne 'x86\XP' -and $_ -ne 'x86\PE3'-and $_ -ne 'x86\XP\Dell Inc.' -and $_ -ne 'x86\XP\Hewlett-Packard' -and $_ -ne 'x86\XP\HP Compaq' -and
                                                                    $_ -ne 'x86\XP\Lenovo' -and $_ -ne 'x86\XP\Toshiba'-and $_ -ne 'x86\XP\VMware, Inc.' -and $_ -ne 'x64\7\VMware, Inc.'-and $_ -ne 'x86\7\Lenovo' -and 
                                                                    $_ -ne 'x86\7\VMware, Inc.'-and $_ -ne 'x86\XP\Dell Computer Corporation'}
                                               

        if($result){
            
            Write-Host ""
            $result
            Write-Host ""

        }else{

            Write-Warning "No matching models found for $Variant at $realPath DriverGroups.xml"
        }
   
        
    }
}



Function Get-MDTComputers{


<#
    .SYNOPSIS
    Cmdlet to check a computer, or list of computers' OU against a "Correct OU."  Requires
    AD module for PowerShell (RSAT installed).

    .DESCRIPTION
    Takes a domain name, list of computers and correct OU DN.  Function will check the list
    of computers and match their DN to the correct OU's DN.  It will produce a tally at the end
    of how many computers it has found, and how many are in the correct / wrong OU.

    .PARAMETER Domain
    Accepts input as a parameter.  Domain name in the format example.co.uk

    .PARAMETER ComputerList
    Accepts input as a parameter or from the pipeline. 

    .PARAMETER CorrectOU
    Accepts input as a parameter.  OU DN in the format Desktops,Computers.  Domain name NOT required 

    .EXAMPLE
    Get-MDTComputers -Domain example.co.uk -ComputerList (Get-Content C:\Users\sa_pursellm\Desktop\computers.txt) -CorrectOU 'Desktops,Computers'

    .EXAMPLE
    Get-MDTComputers -Domain example.co.uk testpc -CorrectOU 'Desktops,Computers'

    .INPUTS
    Accepts pipeline input for certain parameters.

    .OUTPUTS
    List of computers and computer counts.  Designed to sit at the end of the pipeline or as standalone function, so
    DOES NOT output objects that can be piped. 

#>

    [CmdLetBinding()]

    param([Parameter(Mandatory=$True)]
            [string]$Domain,

            [Parameter(Mandatory=$True,
                        ValueFromPipeLine=$True,
                        ValueFromPipeLineByPropertyName=$True)]
            [string[]]$ComputerList,

            [Parameter(Mandatory=$True)]
            [string]$CorrectOU
            

    )

     # couple of counter variables to produce a tally at the end
     $correctCount = 0
     $wrongCount = 0
     $notFound = 0

     # create the Searchbase DN from the domain, so split example.co.uk and
     # rejoin as dc=example,dc=co,dc=uk
     $searchBase = $domain.split(".")| % {$_.replace($_, "dc=$_")}
     $searchBase = $searchBase -join(",")

     # same idea with the OU DN prefix
     $OU = $CorrectOU.Split(",")| % {$_.replace($_, "ou=$_")}
     $OU = $OU -join(",")

     # join the OU DN prefix and the domain DN to create the full OU DN
     $CorrectOU = "$OU,$searchBase"


    foreach($computer in $ComputerList){

   

        $compObject = Get-ADComputer -Filter * -Searchbase $searchBase -Server $Domain | where{$_.Name -match "$computer"}

        if($compObject){

            if($compObject.DistinguishedName -eq "CN=$computer,$correctOU"){
                Write-Host "Found $computer in" $compObject.DistinguishedName -ForegroundColor Green
                $found = $true
                $correctCount += 1

            }else{

                Write-Host "Found $computer in" $compObject.DistinguishedName -ForegroundColor Yellow
                $found = $true
                $wrongCount += 1
            }

        } else{

            Write-Host "Couldn't find $computer" -ForegroundColor Yellow
            $found =$false
            $notFound += 1
        }

    }

    # Output our computer counts
    $fullCount = $correctCount + $wrongCount

    Write-Host "Found $fullCount computers" -ForegroundColor Green

    Write-Host "$correctCount in the correct OU" -ForegroundColor Green

    if($wrongCount -gt 0){

        Write-Host "$wrongCount in the wrong OU" -ForegroundColor Yellow

    }else{

            Write-Host "$wrongCount in the wrong OU" -ForegroundColor Green

    }

    if($notFound -gt 0){

        Write-Host "$notFound not found" -ForegroundColor Yellow

    }else{

            Write-Host "All computers found" -ForegroundColor Green

    }

    Write-Host "Finished" -BackgroundColor Green

}

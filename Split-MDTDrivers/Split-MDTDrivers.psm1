Function Split-MDTDrivers
{

    <#
    .SYNOPSIS
    CmdLet to lookup drivers in MDT xml files and split the drivers out to a destination folder, by model name

    .DESCRIPTION
    Takes a deployment share path and a driver destination path.  Uses the \Control\DriverGroups.xml to create 
    a list of tuples in the form ((name, guid),(name, guid) etc.).  It creates a hash table of the @{guid = $source}
    from the Control\Drivers.xml.  It then iterates over the tuple list, looks up the key (guid) in the hash table 
    and returns the source path.  It then creates a list 0f 3-tuples in the form ((guid, Name, source),(guid, Name, source) etc.)

    Once we have the list of 3-tuples, we setup a new PSDrive to the Destination path, check the PSDrive to see if 
    DestinationPath + Name exists.  If not, create the folder.  If the folder has been created or already exists, 
    copy the driver file from the deploymentSharePath + Source to the driverDestination + Name path.  Removes the 
    PSDrive after the list of 3-tuples has been iterated over. 

    .PARAMETER DriverDestinationPath
    Local or network path to copy the drivers to, without the trailing slash

    .PARAMETER DeploymentSharePath
    Path to the deployment share to be parsed, without the trailing slash. 

    .PARAMETER Models
    Accepts a comma seperated list of model numbers.  Letter case matters. Checks if the driver name CONTAINS the
    model name, so T540 will capture T540p, T540, T540s etc. 

    .EXAMPLE
    Split-MDTDrivers -DeploymentSharePath \\server\deploymentshare$ -DriverDestinationPath C:\users\%username%\Documents\DriverTest

    .INPUTS
    Accepts NO pipeline input

    .OUTPUTS
    Outputs the list of folders created

    #>

    [CmdletBinding()]

        param(
    
            [Parameter(Mandatory=$True)]
            [string]$DriverDestinationPath,

            [Parameter(Mandatory=$True)]
            [string]$DeploymentSharePath,

            [Parameter(Mandatory=$false)]
            [string[]]$Models
        )

    Write-Verbose "Setting DriverGroups.xml path to: $DeploymentSharePath\Control\drivergroups.xml"
    Write-Verbose "Setting Driver.xml path to: $DeploymentSharePath\Control\drivers.xml"

    [xml]$dg = Get-Content -Path "$DeploymentSharePath\Control\drivergroups.xml"
    [xml]$drivers = Get-Content -Path "$DeploymentSharePath\Control\drivers.xml"

    New-PSDrive -Name X -PSProvider FileSystem -Root $deploymentSharePath

    Write-Verbose "Looking up guids in hashtable"

    foreach($entry in getFinalTupleList)
    {
    
        foreach($model in $Models)
        {
            if($entry.Item2.Name.Contains($model))
            {


                #remove the leading .\ from the out-of-box-drivers path
                $source = "X:\" + $entry.Item3.TrimStart(".\")

                # split the string at the backslashes, then remove the last [-1] string from the string
                # so dir\folder\file.inf becomes dir\folder.
                # this is because we want to copy everything in the driver folder not just the inf file
                $source = $source.TrimEnd($source.split('\')[-1])

                $Destination = "$DriverDestinationPath\" + $entry.item2.Name

                $checkDestination = Test-Path $Destination

                # create a new model folder if one doesn't already exist
                if($checkDestination -eq $false)
                {
                    New-Item -ItemType Directory -Path $Destination
                }

                # copy all files from the source path into the model folder
                Copy-Item -Path "$source\*.*" -Destination $Destination


            }

        }
            
        
    }

    Remove-PSDrive -Name X

}


function nameGuidList()
    {

    $nameGuidTupleList = @()

    # get the nodes
    foreach($nodes in $dg.groups.group | Select-Object -Property Name, Member)
    {
        # iterate over each node
        foreach($node in $nodes)
        {
            # get the node name so we can compare it to a string
            $nodeName = $node | Select-Object Name

        
            # list of the guids in the "member" property of the node
            $guidList = $node.Member


            foreach($guid in $guidList)
            {
          
                # create a tuple of - e.g. [\x64\7\lenovo\thinkpad x250\w6472td, {3cvfjs-3389v-etc.}]
                # and add it to the list nameGuid
                $nameTuple = [System.Tuple]::Create($nodename, $guid)
           
                $nameGuidTupleList += ($nameTuple)          

            }

            
        }
    }
    return $nameGuidTupleList

}

function driverSourceList()
{
    $driversList = @()

    foreach($driver in $drivers.drivers.driver)
    {
        # create a tuple of (guid, source) and add it to a list
        $driverTuple = [System.Tuple]::Create($driver.Guid, $driver.Source)
           
        $driversList += ($driverTuple)
        

    }
    return $driversList
}

function driverSourceHash()
{
    $driversHash = @{}

    foreach($driver in $drivers.drivers.driver)
    {
        # create a hash of (guid = source)
        $driversHash.Add($driver.Guid.ToString(), $driver.Source.ToString()) 

    }
    return $driversHash
}


function getFinalTupleList()
# uses the hash table from drivers.xml and looks up the key from the
# tuple list created from drivergroups.xml

{

    $hash = driverSourceHash
    $finalTupleList = @()

    foreach($nameGuidPair in nameGuidList)
    {

    
        # create a 3-tuple that contains(guid, modelname, path to driver)
        $guidNameLocation = [System.Tuple]::Create($nameGuidPair.Item2, $nameGuidPair.Item1, $hash.($nameGuidPair.Item2))
        $finalTupleList += ($guidNameLocation)
    
    }

    return $finalTupleList
}




### TEST FUNCTION CALLS ###
#Split-MDTDrivers -DeploymentSharePath \\127.0.0.1\deploy$ -DriverDestinationPath C:\users\env:username\Documents\DriverTest
#nameGuidList
#driverSourceList
#driverSourceHash



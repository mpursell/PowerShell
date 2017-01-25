Module is a small suite of functions to allow automation, or low manual effort / speed to complete regular MDT support tasks. 

**Get-MDTAppName**

	.SYNOPSIS
    CmdLet to display the name of an MDT application for a given GUID

    .DESCRIPTION
    Takes a Path and GUID input and displays the name of the application.  The script
    will look for the Applications.XML in the \Control\Applications folder in the 
    specified deployment share and return the results based on that.  Enter any of the alphnumeric 
    guid string to search the xml. 

    .PARAMETER Path
    Path to the root of the deployment share

    .PARAMETER Guid
    Partial or complete guid of the application

    .EXAMPLE
    Get-MDTAppNameFromGUID -Path \\server\DeploymentShare -Guid 'r92f' 

    .INPUTS
    Accepts pipeline input for the Guid parameter

    .OUTPUTS
    Formatted list of Name, Source Folder and Guid
	
**Get-MDTAppGuid**

    .SYNOPSIS
    CmdLet to get the GUID of an MDT application for a given application name

    .DESCRIPTION
    Takes a Path and name input and displays the guid of the application.  The script
    will look for the Applications.XML in the \Control\Applications folder in the 
    specified deployment share and return the results based on that.  Enter any of the alphnumeric 
    name string to search the xml. 

    .PARAMETER Path
    Path to the root of the deployment share

    .PARAMETER name
    Partial or complete name of the application

    .EXAMPLE
    Get-MDTAppGuidFromName -Path \\server\DeploymentShare -Name 'Microsoft*' 

    .INPUTS
    Accepts pipeline input for the Name parameter

    .OUTPUTS
    Formatted list of Name, Source Folder and Guid


	
**Get-MDTAppLocation**

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
	
	
**Get-MDTSupportedModel**

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
	
	
**Get-MDTComputers**

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
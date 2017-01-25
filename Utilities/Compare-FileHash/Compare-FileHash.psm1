function Compare-FileHash(){

    <#
    .SYNOPSIS
    CmdLet to compare file hashes
    

    .DESCRIPTION
    Takes a Path parameter (to generate the current hash), and a BaseLineHash parameter.  The 
    BaseLineHash parameter assumes you've generated a hash object from Get-FileHash as a baseline
    and that same algorithm has been used to hash the file.  The third parameter, Algorithm allows
    you to specify the hash algorithm.  

    .PARAMETER Path
    Path to file you want to take a has of

    .PARAMETER BaseLineHash
    Takes a existing hash object created from Get-FileHash

    .PARAMETER Algorithm
    Allows you to choose which algorithm you want to create the new file hash with.
    Must match the algorithm used to create your baseline hash

    .EXAMPLE
    Compare-FileHash -Path C:\test.txt -BaselineHash $hash -Algorithm MD5

    .INPUTS
    Accepts pipeline input for the Path parameter

    .OUTPUTS
    Console output of "True" or "False"



#>
    [CmdletBinding()]

    param(
    
        
        [string]$Path,

        [Parameter(Mandatory=$True,
                    ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]

        [string]$BaseLineHash,
            [Parameter(Mandatory=$True)]

        [string]$Algorithm
      
    )

    $currentHash = Get-FileHash -Path $Path -Algorithm $Algorithm

    if($baselineHash -eq $currentHash)
    {
        Write-Host "True"

    }else{

        Write-Host "False"
    }

}






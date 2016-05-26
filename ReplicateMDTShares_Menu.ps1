<#
    Script to provide a list of MDT linked deployment shares and offer the user
    options to replicate content to the individual shares, or to replicate all content 
    to all shares.

    Author: Michael Pursell
    Date: 15 July 2015
    Notes: Requires at least PowerShell version 3.0
#>

Clear

#requires -version 3 
$ModulePath = "C:\Program Files\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1" 
Import-Module $ModulePath -ErrorAction SilentlyContinue| Out-Null


# Check that we can import the MDT module and that we have some linked shares to enumerate
Function CheckEnvironment()
{
    # Suppressing the usual PowerShell error ouput in favour of our own
    Import-Module $ModulePath -ErrorAction SilentlyContinue| Out-Null 
    if (!$?) 
    { 
        Write-Host "`nThe MDT Deployment Share Replication Script failed to load the MDT Powershell module located at $ModulePath. No replication will occur." -ForegroundColor Red -BackgroundColor White

        return $false
    } 
 
    Restore-MDTPersistentDrive -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | Out-Null 
    $sharedDrives = Get-MDTPersistentDrive 
    if (!$?) 
    { 
        Write-Host "'nFailed to enumerate Deployment Shares. No replication will occur.  Is MDT installed on this server?" -ForegroundColor Red -BackgroundColor White   

        return $false
    } 

    else
    {
       return $true
    }
}


Function BuildList()
<#
    Function creates and returns an array of deployment shares $replicationList
#>

{
    # Array that will be built dynamically by the list of MDT shares
    $replicationList = @()

    Restore-MDTPersistentDrive -WarningAction SilentlyContinue| Out-Null

    # build the replicationList

    $MDTDrives = Get-MDTPersistentDrive 

    $shareList = @()
    
     foreach ($drive in $MDTDrives)
     {
       foreach ($linkedShare in get-childitem -ErrorAction SilentlyContinue "$($drive.Name):\Linked Deployment Shares" )
        {
        
            $shareList += "$($linkedShare.PSDrive):\Linked Deployment Shares\$($linkedShare.PSChildName)"
            
        }

        
     }

     <# the double foreach loop above produces 2 sets of results;
      this foreach loop removes the duplicate entries by only adding 
      shares with DS001 in the array item to the replicationList that 
      will be used to build the menu.
      
      Nasty fix - because the code isn't working as expected.  This "fix"
      shouldn't be needed. 
      
      #>

      foreach ($item in $shareList)
      {
          if($item.contains("DS001")) 
          {
            $replicationList +=$item
          }

      }

      return $replicationList 
    
}


Function Menu()
{

    # Set an initial value for the menu numbering and an empty hash table for the menu items
    $menuNumber = 1
    $selection = @{100 = 'All'}

    # Get the replicationList array from BuildList
    foreach ($option in BuildList)

    {
        <# 
        enumerate the shares presented in the replicationList array and add them 
        to the hash table in the format (1 = firstShare, 2 = secondShare) etc.
        #>

        $selection += @{$menuNumber = $option}
    
        # increment the menu number so we get a new number assigned to each menu option
        $menuNumber += 1
    }

    # Output the replication menu
    Write-Host "***Replication Menu***  `n`nPlease choose which share you'd like to replicate:"

    <# 
    This sorts the hash table into numerical order for the menu, and hides 
    the default PS table headings of Name and Value
    #>

    $selection.GetEnumerator() | Sort-Object Name |format-table -HideTableHeaders

    # Prompt the user for a selection
    [int32]$choice = Read-Host "Enter a choice: "
    

    

        Try
        {
            # if the menu choice matches a hash table key, prompt and then replicate 
            # the chosen share

            if ($selection.Keys -contains $choice)
            {
                Write-Host "You have chosen to replicate" $selection[$choice]
                $confirm = Read-Host "Is this correct (Y/N)? "

                if ($confirm -eq "Y" -or "y")
                {
                    Update-MDTLinkedDS -path $selection[$choice]
                } 

                else
                {
                    Break
                }
             }
                
            # If the user chooses 100, replicate to all linked shares. 
            ElseIf($choice -eq 100)
            {
                foreach($item in BuildList)
                {
                    Update-MDTLinkedDS -path $item

                }
            }
                    
            
        
            # if an invalid user choice is submitted, throw an exception
            else
            {
                throw "Invalid menu choice.  Exiting"
            }

            }
            Catch
            {
                $_.Exception.Message

            }

        
Write-Host "Replication Finished" -ForegroundColor Green       
        
}    



# As long as we pass the environment checks, continue. 
if (CheckEnvironment -eq $true)
{
    Menu
    #BuildlIst
}
else
{
    Write-Host "Exiting..."
    break
}



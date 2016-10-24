<#
    Script to download DAT files from McAfee FTP server and copy to folder
    for use in automated MDT builds. 

#>

function Get-DATFiles{

    # set the ftp server url and call the function to get the files 
    # on the ftp server.

    $folderPath="ftp://ftp.mcafee.com/commonupdater/"
    $files=Get-FTPDir $folderPath

    
    # ftp file list is returned as one long string with only the 
    # length available as a property - so do a regex that finds 
    # all substrings that match avvdat-****.zip
    $DATList = @()
    $files.ToString() | Select-String -Pattern '(avvdat\W\d\d\d\d\W\w\w\w)' -AllMatches | 
    
        foreach{
            $_.Matches
        }|
    
        ForEach-Object{
        
           $DATList += $_.Value
        
        } | Out-Null


    # get the list of matches and call the function to 
    # download the matched files
    foreach($DAT in $DATList){

        
        Download-DATFiles $DAT $folderPath
    }

}

function Get-FtpDir ($url) {

    # get the list of files available on  the ftp server

    $request = [Net.WebRequest]::Create($url)
    $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
    #if ($credentials) { $request.Credentials = $credentials }
    $response = $request.GetResponse()
    $reader = New-Object IO.StreamReader $response.GetResponseStream() 
	$reader.ReadToEnd()
	$reader.Close()
	$response.Close()
}


function Download-DATFiles($DATFile, $folderPath){

    $source = $folderpath + $DATFile

    # make sure that IE is set to open zip files automatically from Downloads page
    $ie = New-Object -ComObject InternetExplorer.Application
    $ie.Navigate($source)
    $ie.Visible = $true 
    
    Start-Sleep -Seconds 60
    
    # IE will automatically cache the zip files if IE is setup correctly,
    # so we need a copy-item to copy the zipped files from temp cache
    # to permanent location 
    Copy-Item -Path "C:\Users\mike\AppData\Local\Microsoft\Windows\INetCache\IE\XV0F1EOW\$DATFile"  -Destination "C:\users\mike\Documents\test\"
        
    

}

function Extract-ZIPFile($file, $destination)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)

    foreach($item in $zip.items())
    {

        $shell.Namespace($destination).copyhere($item)
    
    }
}


Get-DATFiles




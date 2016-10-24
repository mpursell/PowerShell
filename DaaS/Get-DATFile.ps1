<#
    Script to download DAT files from McAfee FTP server and copy to folder
    for use in automated MDT builds. 

#>

function Get-DATFiles{

    $folderPath="ftp://ftp.mcafee.com/commonupdater/"
    $files=Get-FTPDir $folderPath

    
    $DATList = @()


    $files.ToString() | Select-String -Pattern '(avvdat\W\d\d\d\d\W\w\w\w)' -AllMatches | 
    
        foreach{
            $_.Matches
        }|
    
        ForEach-Object{
        
           $DATList += $_.Value
        
        } | Out-Null


    foreach($DAT in $DATList){

        
        Download-DATFiles $DAT $folderPath
    }

}

function Get-FtpDir ($url) {
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

<#
        $source = $folderpath + $DATFile
        $destination = "C:\Users\mike\Documents\Test\"
        $username = ""
        $password = ""

        $WebClient = New-Object System.Net.WebClient
        $WebClient.Credentials = New-Object System.Net.NetworkCredential($username, $password)
        
	    $WebClient.DownloadFile($source, $destination)
       
#>

    $source = $folderpath + $DATFile

    # make sure that IE is set to open zip files automatically from Downloads page
    $ie = New-Object -ComObject InternetExplorer.Application
    $ie.Navigate($source)
    $ie.Visible = $true 
    
    Start-Sleep -Seconds 60
    
    Copy-Item -Path "C:\Users\mike\AppData\Local\Microsoft\Windows\INetCache\IE\XV0F1EOW\$DATFile"  -Destination "C:\users\mike\Documents\test\"
        
    

}


Get-DATFiles




<#
    Script to download DAT files from McAfee FTP server and copy to folder
    for use in automated MDT builds. 

#>


# set some global variables

$FtpServer = "ftp://ftp.mcafee.com/commonupdater/"
$ZipStagingLocation = "C:\Users\$env:USERNAME\Desktop"
$ExtractDir = "C:\Users\$env:USERNAME\Desktop\DAT\"

function Get-DATFiles{

    # set the ftp server url and call the function to list the files 
    # on the ftp server.

   

        $files = Get-FTPDir $FtpServer
    
  
    
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

        
        Download-DATFiles $DAT $FtpServer
    }

}

function Get-FTPDir ($url) {

    # get the list of files available on  the ftp server

    try{

        $request = [Net.WebRequest]::Create($url)
        $request.Method = [System.Net.WebRequestMethods+FTP]::ListDirectory
        #if ($credentials) { $request.Credentials = $credentials }
        $response = $request.GetResponse()
        $reader = New-Object IO.StreamReader $response.GetResponseStream() 
	    $reader.ReadToEnd()
	    $reader.Close()
	    $response.Close()

        Write-Log "Success... Retrieved list of files from $FtpServer"
    
    }catch{
        
        $ExceptionMessage = $_.Exception.Message
        Write-Log "Failure... Error Getting FTP directory (Get-FTPDir); $ExceptionMessage"
    }
}


function Download-DATFiles($DATFile, $FtpServer){

    $source = $FtpServer + $DATFile

    try{

        $WebClient = $webclient = New-Object System.Net.WebClient
        $webclient.DownloadFile($source, "$ZipStagingLocation\$DATfile")
        Write-Log "Success... DAT file downloaded from $source to $ZipStagingLocation\$DATFile"
        $DownloadCheck = $true

    }catch{
    
        $ExceptionMessage = $_.Exception.Message
        Write-Log "Failure... Error Downloading files (Download-DATFiles); $ExceptionMessage"
        $DownloadCheck = $false
        
        
    }


    # clean the DAT extraction folder
    try{

        Get-ChildItem $ExtractDir | Remove-Item -Force -ErrorAction Stop
        Write-Log "Success... Cleaned $ExtractDir"

    }catch{

        $ExceptionMessage = $_.Exception.Message
        Write-Log "Failure... Error deleting old DAT files from $ExtractDir; $ExceptionMessage"

    }

    # if we haven't downloaded anything, we want to quit

    if ($DownloadCheck -eq $true){

        # Extract the DAT file
        Extract-ZIPFile "$ZipStagingLocation\$DATFile"
    
    }else{
        
        Write-Log "Failure... Exiting owing to failed download check"
        exit
    }
        
}

function Extract-ZIPFile($file)
{
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace($file)
    

    foreach($item in $zip.items())
    {
        try{

            $shell.Namespace($ExtractDir).copyhere($item)
            Write-Log "Success... Unzipped $file to $ExtractDir"

        }catch{

            $ExceptionMessage = $_.Exception.Message
            Write-Log "Failure... Error extracting zip archive $file; $ExceptionMessage"
        }
    
    }
}

function Write-Log($text){

    $path = "C:\Windows\Temp\"
    $logfile = "Get-DATFiles.log"
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


Get-DATFiles





function Get-Downloads{

    # requires a .csv in the format name,url where name is a convenient name for the application / file
    # and url is the path to download the application / file

    [CmdletBinding()]

    param(
    # Parameter help description
    [Parameter(Mandatory=$true)][string] $RootDownloadDirectory,
    [Parameter(Mandatory=$true)][string] $CSVFile
    )


    Write-Host "Starting bulk download using " -ForegroundColor Green -NoNewline
    Write-Host "$CSVFile" -ForegroundColor Yellow
   

    # check for root folder existence, and create if it doesn't exist
    If((Test-Path -Path $RootDownloadDirectory) -eq $false){

        Write-Host "Root Folder does not exist, creating..." -ForegroundColor Green
        
        try{
            New-Item -Path $RootDownloadDirectory -ItemType Directory -Force -Confirm:$false | Out-Null
            Write-Host "Creating root folder at:" -NoNewline -ForegroundColor Green
            Write-Host "$RootDownloadDirectory" -NoNewline -ForegroundColor Yellow
            Write-Host "... Success" -ForegroundColor Green
        }catch{

            Write-Host "Creating root folder at: " -ForegroundColor Red -NoNewline
            Write-Host "$RootDownloadDirectory" -ForegroundColor Yellow -NoNewline
            Write-Host "... Failed" -ForegroundColor Red
        }
    }else{

        Write-Host "Root Folder already exists, using existing folder..." -ForegroundColor Green
    }

    # import the csv file with name,url
    $downloads = Import-Csv -Path $CSVFile 

    [int]$total = $downloads.Count
    [int]$counter = 0

    
    foreach($item in $downloads){

        $name = $item.name
        $uri = $item.url

        # split the url string to get the file extension
        $fileExtension = $uri.split(".") | Select-Object -Last 1

        # call new-folders function to create the new folders
        try{

            New-folders $RootDownloadDirectory $name 
            Write-Host "Creating folder " -ForegroundColor Green -NoNewline
            Write-Host "$RootDownloadDirectory\$name " -ForegroundColor Yellow -NoNewline
            Write-Host " ...Success" -ForegroundColor Green

        }catch{

            Write-Host "Creating folder " -ForegroundColor Red -NoNewline
            Write-Host "$RootDownloadDirectory\$name" -ForegroundColor Yellow -NoNewline
            Write-Host " ...Failed" -ForegroundColor Red
            
        }

        # download the file, and set the out file to the new path, and rename the file to the name
        # in the csv, and add on the file extension we split above
        $fullpath = "$RootDownloadDirectory\$name\$name.$fileExtension"

        try{
            
            Invoke-WebRequest -Uri $uri -OutFile "$fullpath" | Out-Null
            Write-Host "Downloading " -ForegroundColor Green -NoNewline
            Write-Host "$name.$fileExtension" -ForegroundColor Yellow -NoNewline
            Write-Host " ...Success" -ForegroundColor Green
        }catch{

            Write-Host "Downloading " -ForegroundColor Red -NoNewline
            Write-Host "$name.$fileExtension" -ForegroundColor Yellow -NoNewline
            Write-Host " ...Failed" -ForegroundColor Red
        }

        $counter = ++$counter
        $completed = ($counter/$total) * 100

        $ProgressPreference = continue
        Write-Progress -Activity "Downloading Files" -PercentComplete $completed 
        
        }
        
}



function New-Folders($root, $folder){

    $path = "$root\$folder"
    $folder = New-Item -Path $path -ItemType Directory -Force -Confirm:$false | Out-Null

}

Get-Downloads -RootDownloadDirectory "C:\users\sa_pursellm\desktop\Download Test" -CSVFile "C:\Users\sa_pursellm\desktop\downloads.csv"


Function Get-YoutubePlaylist{

<#
    .SYNOPSIS
    CmdLet to get and optionally download all videos from a YouTube playlist

    .DESCRIPTION
    

    .PARAMETER PlaylistID
    The YouTube playlist ID

    .PARAMETER Download
    Switch to download the playlist videos.  Requires Youtube-dl.exe, and the path to
    the executable to be specified in the script

    .PARAMETER ApiKey
    Personal Google API key for Youtube.com

    .EXAMPLE
    Get-YoutubePlaylist -PlayListID PL2103FD9F9D0615B7

    .EXAMPLE

    Get-YoutubePlaylist -PlayListID PL2103FD9F9D0615B7 -Download
    

#>

    [CmdletBinding()]

    param(
        
        [Parameter(Mandatory=$True)]
        [string] $PlayListID,

        [Parameter()]
        [switch] $Download,

        [Parameter(Mandatory=$True)]
        [string] $apiKey
    
    )

    
    
    $youtubeDl = "C:\Users\sa_pursellm\Downloads\youtube-dl.exe"

    Write-Debug "Api key set to $apiKey"
    Write-Debug "YoutubeDl location set to $youtubeDl"

    Write-Debug "Making initial GET request"
    $initialRequest = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&key=$apiKey"

    $resultCount = $initialrequest.pageInfo.totalResults
    $resultsPerPage = $initialrequest.pageInfo.resultsPerPage

    $pages = $resultCount / $resultsPerPage

    Write-Debug "ResultCount is $resultCount"
    Write-Debug "ResultsPerPage are $resultsPerPage"
    Write-Debug "Number of pages to query is $pages"

    $counter = 0

  

    while($counter -le $pages){

        if($counter -eq 0){

            Write-Debug "Making first request, counter is at $counter"
            $request = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=$playlistId&key=$apiKey"
    
        }else{
    
            $request = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/playlistItems?pageToken=$nextPageToken&part=snippet&playlistId=$playlistId&key=$apiKey"
            Write-Debug "Making reqeust.  Next page token is $nextPageToken"

        }

        $nextPageToken = $request.nextPageToken

        foreach($item in $request.items){


            $videoId = $item.snippet.resourceId.videoId
            $title = $item.snippet.title
            $youtubeUrl = "https://www.youtube.com/watch?v=$videoId"

            Write-Host $title -ForegroundColor Yellow
            Write-Host $youtubeUrl -ForegroundColor Green 

            Write-Debug "Calling youtubeDl:  $youtubeDl $youtubeUrl"

            if($Download){

                try{

                    Invoke-Expression "$youtubeDL $youtubeUrl"

                }catch{

                    Write-Warning "Problem running youtube-dl.  Please check the path to the executable is correct"

                }

            }else{

                Continue
            }
        }

        $counter += 1
        $progess = ($counter / $resultCount) * 100

        if($Download){
            
            Write-Progress "Downloading Playlist" -PercentComplete $progess

        } else{

            Continue
        }
    
    }

}
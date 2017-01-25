function Search-Youtube{


<#
    .SYNOPSIS
    Function to get and (optionally) download all videos returned from a YouTube keyword search

    .DESCRIPTION
    Requires a YouTube API key to be passed as a param.  It will use the search terms to create
    an API query and return the search results: starting at the page specified as a param, and for 
    the total number of pages specified as a param.  If nothing is specified, the search will begin
    at page 0 and return a total of 100 YouTube search pages.

    .PARAMETER SearchTerm
    Keywords for YouTube search

    .PARAMETER StartPage
    Of all the returned search pages from YouTube, this param specifies which
    page to start from when returning results

    .PARAMETER TotalPages
    The total number of search pages you would like to be returned (a subset
    of the total number of pages returned by the API search).  Recommended to keep the 
    difference between this and StartPage relatively small to allow viewing a small subset
    of search results. 

    .PARAMETER ApiKey
    Personal Google API key for Youtube.com
    
    .PARAMETER AudioOnly
    Allows downloading of audio only.  See params for audio format and audio quality. Requires 
    either ffmpeg (https://ffmpeg.org/download.html#build-windows) or avprobe to be installed.

    .PARAMETER AudioFormat
    Specifies the audio format if AudioOnly is selected.  Depends upon available codecs

    .PARAMETER AudioQuality
    Specifies the quality of the audio 1(low) to 9(high)

    .INPUTS
    Accepts the ApiKey string from the pipeline

    .OUTPUTS
    Outputs the selected videos as PSCustomObjects to the pipeline.
    Properties are $obj.Title, $obj.Description, and $obj.url


    .EXAMPLE
    Search-Youtube -ApiKey "<api key>" -StartPage 0 -TotalPages 3 -SearchTerm "BBC Radio Drama"

    .EXAMPLE
    Search-Youtube -ApiKey "<api key>" -StartPage 0 -TotalPages 3 -SearchTerm "BBC Radio Drama" -AudioOnly -AudioFormat mp3 -AudioQuality 5
    
#>

    [CmdletBinding()]
    param(

        [Parameter(Mandatory=$true, ValueFromPipeLine=$true)][string]$ApiKey,
        [Parameter(Mandatory=$true)][string]$SearchTerm,
        [Parameter(Mandatory=$false)][int32]$StartPage,
        [Parameter(Mandatory=$false)][int32]$TotalPages,
        [Parameter(Mandatory=$false)][switch]$AudioOnly,
        [Parameter(Mandatory=$false)][string]$AudioFormat,
        [Parameter(Mandatory=$false)][int32]$AudioQuality
        
        )


    BEGIN{

        # set some reasonable defaults if no params entered


        if(!$StartPage){

            $counter = 0
        }

        if(!$TotalPages){

            $TotalPages = 100
        }

        if($StartPage -gt $TotalPages){


        }

        # replace any spaces in the search term with "+" in order
        # to craft the API request correctly

        $SearchTerm.Replace(" ", "+") | Out-Null

        # list to hold our items for download
         
        [pscustomobject]$downloadList = @()

    }

    PROCESS{
        $initialrequest = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/search?part=snippet&q=$SearchTerm&type=video&key=$ApiKey"



        # find the number of pages required by dividing the total number of results
        # by the number of results per page

        $resultCount = $initialrequest.pageInfo.totalResults
        $resultsPerPage = $initialrequest.pageInfo.resultsPerPage

        $pages = $resultCount / $resultsPerPage



        # set a counter for the loop iterations
        # while the number of iterations is less than the number of 
        # required pages, we know we need to get the next page token
        # and find some more results

        $counter = $StartPage
    

        $nextPageToken = $initialrequest.nextPageToken


        while($counter -le $TotalPages){

                if($counter -eq 0){

                    # Write-Host "Making first request, counter is at $counter"
                    $request = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/search?part=snippet&q=$SearchTerm&type=video&key=$ApiKey"
                    $nextPageToken=$request.nextPageToken
    
                }else{
    
                    $request = Invoke-RestMethod -Method GET -Uri "https://www.googleapis.com/youtube/v3/search?pageToken=$nextPageToken&part=snippet&q=$SearchTerm&type=video&key=$ApiKey"
            
                    # Write-Host "Making reqeust.  Next page token is $nextPageToken"

                }

                foreach($item in $request.items){

                    # grab the video id and build the YouTube URL

                    $videoid = $item.id.videoId
                    $youtubeUrl = "https://www.youtube.com/watch?v=$videoId"

                
                    # create custom object with properties we'll need

                    $video = New-Object PSObject -Property @{Title = $item.snippet.title;
                                                            Description = $item.snippet.description;
                                                            URL = $youtubeUrl}
            
                    # nasty hack to make sure first title appears before first prompt
                    # not sure why just outputting the $object | select prop1 prop2 doesn't do this

                    Write-Host ""
                    Write-Host "Title                  Description"
                    Write-Host "-----                  -----------"
                    Write-Host $video.title $video.Description

                    #####
                    
                    $prompt = Read-Host -Prompt "Add to Download list? Y/N: "

                    if(($prompt -eq "N") -or ($prompt -eq "No")){
                        
                        continue
                    }

                    elseif(($prompt -eq "Y") -or ($prompt -eq "Yes")){
                        
                        $downloadList += $video
                    }

            
                }


                

                $nextPageToken=$request.nextPageToken

                Write-Debug "YouTube Search Page: $counter \\ Next Page Token: $nextPageToken"

                $counter+=1
        
        }

    }

    END{
    
        # output the download list for review

        Write-Host ""
        Write-Host ""
        Write-Host ""
        Write-Host "**** Download List ***"
        Write-Host ""
        foreach($vid in $downloadList){

            $vid.title
            Write-Output $vid
                            
        }

        Write-Host ""
        Write-Host "**********************"
        Write-Host ""

        $listCheck = Read-Host -Prompt "Is this list correct Y/N?"

        # if the list is correct, start downloading, else quit

        if($listCheck -eq "N"){

            Write-Host "List incorrect?  Exiting..."
        
        }elseif($listCheck -eq "Y"){

            $youtubeDl = "C:\Users\$env:username\Downloads\youtube-dl.exe"

            foreach($vid in $downloadList){

                $url = $vid.url
    
                try{
        
                    # if the AudioOnly switch is set, tell youtube-dl to extract the audio

                    if($audioOnly){
            
                        Invoke-Expression "$youtubeDL $url -x --audio-format $audioFormat --audio-quality $audioQuality"
                    
                    # otherwise just download the video

                    }else{

                        Invoke-Expression "$youtubeDL $url"
                    }

                }catch{

                    $exception = $_.Exception.Message
                    Write-Warning "Problem running youtube-dl.  Please check the path to the executable is correct: $exception"

                }

            }
        }
    
    }

}




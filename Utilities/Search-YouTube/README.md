	SYNOPSIS
    Function to get and optionally download all videos returned from a YouTube search

    DESCRIPTION
    Requires a YouTube API key to be passed as a param.  It will use the search terms to create
    an API query and return the search results: starting at the page specified as a param, and for 
    the total number of pages specified as a param.  If nothing is specified, the search will begin
    at page 0 and return a total of 100 YouTube search pages.

    PARAMETER ApiKey
    Personal Google API key for Youtube.com

    PARAMETER SearchTerm
    Keywords for YouTube search

    PARAMETER StartPage
    Of all the returned search pages from YouTube, this param specifies which
    page to start from when returning results

    PARAMETER TotalPages
    The total number of search pages you would like to be returned (a subset
    of the total number of pages returned by the API search).  Recommended to keep the 
    difference between this and StartPage relatively small to allow viewing a small subset
    of search results. 

    PARAMETER AudioOnly
    Allows downloading of audio only.  See params for audio format and audio quality. Requires 
    either ffmpeg (https://ffmpeg.org/download.html#build-windows) or avprobe to be installed.

    PARAMETER AudioFormat
    Specifies the audio format if AudioOnly is selected.  Depends upon available codecs

    PARAMETER AudioQuality
    Specifies the quality of the audio 1(low) to 9(high)

    INPUTS
    Accepts the ApiKey string from the pipeline

    OUTPUTS
    Outputs the selected videos as PSCustomObjects to the pipeline.
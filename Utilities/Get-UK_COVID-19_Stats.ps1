
function Get-DaysInLockdown{

    [DateTime]$start = "23 March 2020"
    [DateTime]$today = Get-Date 

    $daysInLockdown = $today - $start

    $daysView = $daysInLockdown | Select-Object  -ExpandProperty Days 
    
    return $daysView   

}

function Get-UKCases{

    # uses daily data from a Johns Hopkins public API
    
    $headers=@{}
    $headers.Add("x-rapidapi-host", "covid-19-coronavirus-statistics.p.rapidapi.com")
    $headers.Add("x-rapidapi-key", "56135d0f0dmshe43ede3f1c57ba4p16ac9fjsnf43b7663248c")

    # get the api results.  If there's an issue try testing the net connection.
    try{
        $response = Invoke-RestMethod -Uri 'https://covid-19-coronavirus-statistics.p.rapidapi.com/v1/stats?country=United Kingdom' -Method GET -Headers $headers
    
    }catch{

        $connection = Test-NetConnection -InformationLevel Quiet

        if ( $connection -eq "True"){

            Write-Host "Internet connection is up, but API for COVID-19 stats cannot be reached" -ForegroundColor Red

        }else{

            Write-Host "API for COVID-19 stats cannot be reached, Internet connection may be down" -ForegroundColor Red

        }

    }


    $stats = $response.data.covid19Stats | where-object {$_.province -eq ""}

    $args = @{
        "cases" = $stats.confirmed;
        "deaths" = $stats.deaths;
        "recovered" = $stats.recovered;
    }

    $UKStats = New-Object -TypeName PSObject -ArgumentList $args

    return $UKStats

}

function Show-Chart{

    $cases = (Get-UKCases).cases
    $deaths = (Get-UkCases).deaths
    $recovered = (Get-UKCases).recovered

    # to keep chart length sensible, increase the divisor *10
    if($cases -lt 15000){

        $divisor = 100

    }else{

        $divisor = 1000
    }

    # round up so that we always show a plot point if the number is > 0
    [int]$casesConverted = [Math]::Round([Math]::Ceiling($cases / $divisor))
    [int]$deathsConverted = [Math]::Round([Math]::Ceiling($deaths / $divisor))
    [int]$recoveredConverted = [Math]::Round([Math]::Ceiling($recovered / $divisor))

    [string]$casesPlot = "C" * $casesConverted
    [string]$deathsPlot = "D" * $deathsConverted
    [string]$recoveredPlot = "R" * $recoveredConverted

    $args = @{

        "plottedCases" = $casesPlot;
        "plottedDeaths" = $deathsPlot;
        "plottedRecovered" = $recoveredPlot
    }

    $plottedStats = New-Object -TypeName PSObject -ArgumentList $args

    return $plottedStats

}

#region write preamble
Clear-Host
Write-Host
Write-Host "Fetching the UK coronavirus stats..."
Write-Host
#endregion

#region gather the numbers

[int]$lockdownDays = Get-DaysInLockdown
[int]$cases = (Get-UKCases).cases
[int]$deaths = (Get-UkCases).deaths
[int]$recovered = (Get-UKCases).recovered

[string]$casesGraph = (Show-Chart).plottedCases
[string]$deathsGraph = (Show-Chart).plottedDeaths
[string]$recoveredGraph = (Show-Chart).plottedRecovered

#endregion

#region write the output

Clear-Host
Write-Host "****************************************************" 
Write-Host "************* UK COVID-19 Stats ********************" 
Write-Host "****************************************************" 
Write-Host
Write-Host "Number of days in lockdown: $lockdownDays" -ForegroundColor Cyan
Write-Host
Write-Host "Number of cases: $cases" -ForegroundColor Yellow
Write-Host "Number of deaths: $deaths" -ForegroundColor Red
Write-Host "Number of recovered cases: $recovered" -ForegroundColor Green

Write-Host
Write-Host "$casesGraph" -ForegroundColor Yellow
Write-Host "$deathsGraph" -ForegroundColor Red
Write-Host "$recoveredGraph" -ForegroundColor Green
Write-Host

#endregion


    



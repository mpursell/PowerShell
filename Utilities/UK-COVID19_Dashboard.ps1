
function Get-DaysInLockdown{

    [DateTime]$start = "23 March 2020"
    [DateTime]$today = Get-Date 

    $daysInLockdown = $today - $start

    $daysView = $daysInLockdown | Select-Object  -ExpandProperty Days 
    
    return $daysView   

}

function Get-Cases{

    $headers=@{}
    $headers.Add("x-rapidapi-host", "covid-193.p.rapidapi.com")
    $headers.Add("x-rapidapi-key", "56135d0f0dmshe43ede3f1c57ba4p16ac9fjsnf43b7663248c")
    

    # get the api results.  If there's an issue try testing the net connection.
    try{
        
            $response = Invoke-RestMethod -Uri 'https://covid-193.p.rapidapi.com/statistics?country=UK' -Method GET -Headers $headers
        
    }catch{

        $connection = Test-NetConnection -InformationLevel Quiet

        if ( $connection -eq "True"){

            Write-Host "Internet connection is up, but API for COVID-19 stats cannot be reached" -ForegroundColor Red

        }else{

            Write-Host "API for COVID-19 stats cannot be reached, Internet connection may be down" -ForegroundColor Red

        }

    }

        $args = @{
            "new" = $response.response.cases.new;
            "active" = $response.response.cases.active;
            "critical" = $response.response.cases.critical;
            "recovered" = $response.response.cases.recovered;
            "total" = $response.response.cases.total;
            "deaths" = $response.response.deaths.total;
            "newDeaths" = $response.response.deaths.new;
        }

    $Stats = New-Object -TypeName PSObject -ArgumentList $args

    return $Stats
}

function Show-Chart{

    
    [int]$cases = (Get-Cases).total
    [int]$newCases = (Get-Cases).new
    [int]$deaths = (Get-Cases).deaths
    [int]$recovered = (Get-Cases).recovered
    

    # to keep chart length sensible, increase the divisor *10
    if($cases -lt 15000){

        $divisor = 100

    }else{

        $divisor = 1000
    }

    # round up so that we always show a plot point if the number is > 0
    [int]$casesConverted = [Math]::Round([Math]::Ceiling($cases / $divisor))
    [int]$newCasesConverted = [Math]::Round([Math]::Ceiling($newCases / $divisor))
    [int]$deathsConverted = [Math]::Round([Math]::Ceiling($deaths / $divisor))
    [int]$recoveredConverted = [Math]::Round([Math]::Ceiling($recovered / $divisor))

    [string]$casesPlot = "c" * $casesConverted
    [string]$newCasesPlot = "n" * $newCasesConverted
    [string]$deathsPlot = "d" * $deathsConverted
    [string]$recoveredPlot = "r" * $recoveredConverted

    $args = @{

        "plottedCases" = $casesPlot;
        "plottednewCases" = $newCasesPlot;
        "plottedDeaths" = $deathsPlot;
        "plottedRecovered" = $recoveredPlot;
        "divisor" = $divisor
    }

    $plottedStats = New-Object -TypeName PSObject -ArgumentList $args

    return $plottedStats

}

function Show-COVIDCases{

    param(
        [switch]$WindowsChart
    )

    #region write preamble
    Clear-Host
    Write-Host
    Write-Host "Fetching coronavirus stats..."
    Write-Host
    #endregion

    #region gather the numbers

    [int]$lockdownDays = Get-DaysInLockdown
    [int]$cases = (Get-Cases).total
    [int]$newCases = (Get-Cases).new
    [int]$deaths = (Get-Cases).deaths
    [int]$recovered = (Get-Cases).recovered

    [int]$divisor = (Show-Chart).divisor

    [string]$casesGraph = (Show-Chart).plottedCases
    [string]$newCasesGraph = (Show-Chart).plottednewCases
    [string]$deathsGraph = (Show-Chart).plottedDeaths
    [string]$recoveredGraph = (Show-Chart).plottedRecovered

    #endregion

    
    #region write the output
    if($WindowsChart){

        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        [void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")

        # create chart object
        $Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart
        $Chart.Width = 500
        $Chart.Height = 400
        $Chart.Left = 40
        $Chart.Top = 30

        # create a chartarea to draw on and add to chart
        $ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
        $Chart.ChartAreas.Add($ChartArea)

        # add data to chart
        $data = @{"New Cases"=$newCases;"Total Cases"=$cases; "Deaths"=$deaths;"Recoveries"=$recovered}
        [void]$Chart.Series.Add("Data")
        $Chart.Series["Data"].Points.DataBindXY($data.Keys, $data.Values)

        # display the chart on a form
        $Chart.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor
        [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left
        $Form = New-Object Windows.Forms.Form
        $Form.Text = "COVID-19 Chart"
        $Form.Width = 600
        $Form.Height = 600
        $Form.controls.add($Chart)
        $Form.Add_Shown({$Form.Activate()})
        $Form.ShowDialog()

        [void]$Chart.Titles.Add("COVID-19 Cases, deaths & recoveries")

        # change chart area colour
        $Chart.BackColor = [System.Drawing.Color]::Transparent
        


    }else{


        

        Clear-Host
        Write-Host "****************************************************" 
        Write-Host "*****       UK COVID-19 Stats              *********" 
        Write-Host "*****  Chart scale is 1:$divisor (rounded up)      *****"
        Write-Host "****************************************************" 
        Write-Host
        Write-Host "Number of days in lockdown: $lockdownDays" -ForegroundColor Cyan
        Write-Host
        Write-Host "Number of cases: $cases" -ForegroundColor Yellow
        Write-Host "Number of new cases: $newCases" -ForegroundColor DarkCyan
        Write-Host "Number of deaths: $deaths" -ForegroundColor Red
        Write-Host "Number of recovered cases: $recovered" -ForegroundColor Green

        Write-Host


        Write-Host "$casesGraph" -ForegroundColor Yellow
        Write-Host "$newCasesGraph" -ForegroundColor DarkCyan
        Write-Host "$deathsGraph" -ForegroundColor Red 
        Write-Host "$recoveredGraph" -ForegroundColor Green
        Write-Host

    
    }
    #endregion
}

#Show-COVIDCases -WindowsChart 
Show-COVIDCases

    




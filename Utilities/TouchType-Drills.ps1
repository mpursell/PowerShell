$drills = @("afsd afsd j;kl j;kl", "add add add add")


function Test-Type($string){

    Write-Information $string
    $typedString = Read-Host -Prompt "Your typing:"

    if($typedString -match $string){

        Write-Host "Passed" -ForegroundColor Green
    }else{

        Write-Host "Failed" -ForegroundColor Red
    }
}

foreach($string in $drills){

    Test-Type $string
}
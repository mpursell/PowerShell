$range = 0..100

foreach ($number in $range){

   if(((($number % 3) -eq 0) -and ($number -ne 0)) -and ($number % 5) -eq 0){

    Write-Host "FizzBuzz" -ForegroundColor Yellow
   }
   
   elseif ((($number % 3) -eq 0) -and ($number -ne 0)){

        Write-Host "Fizz" -ForegroundColor Green
   }

   elseif ((($number % 5) -eq 0) -and ($number -ne 0)){

    Write-Host "Buzz" -ForegroundColor Blue
   }


    else {
        Write-Host "$number"
    }
}
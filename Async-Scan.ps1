# Quick port scan functions to start playing with multi-threading

Function Async-Scan{


    # start scriptblock
    $scriptblock={

        param([string]$ip)

        $ports = 21,22,80,443,445
        

        foreach($port in $ports){
            try{
                $socket = New-Object System.Net.Sockets.TcpClient($ip, $port)
            

                if($socket.Connected){

                    Write-Host "Connection to $ip on $port  ...SUCCESS" -ForegroundColor Green

                }else{

                    Write-Host "Connection to $ip on $port  ...FAILED" -ForegroundColor Red

                }

            }catch{

                    Write-Host "Connection to $ip on $port  ...FAILED" -ForegroundColor Red
        
            }
        }
    } # end scriptblock




    $ipRange = ('10.93.128.6','10.93.128.9','10.93.128.10')
    $maxThreads = 20

    foreach($ip in $ipRange){
    
        $jobcount = (Get-Job -State Running).count

        if($jobcount -lt $maxThreads){

        
            Start-Job -ScriptBlock $scriptblock -ArgumentList $ip | Out-Null
            

        
        }else{

            Start-Sleep 1000
        }

    }

   
    Get-Job| Wait-Job | Receive-Job

}



Function Linear-Scan{

    $ipRange = ('10.93.128.6','10.93.128.9','10.93.128.10')
    $ports = 1..100

     foreach($ip in $ipRange){

        foreach($port in $ports){

            try{
                $socket = New-Object System.Net.Sockets.TcpClient($ip, $port)
            

                if($socket.Connected){

                    Write-Host "Connection to $ip on $port  ...SUCCESS" -ForegroundColor Green
                }else{

                    Write-Host "Connection to $ip on $port  ...FAILED" -ForegroundColor Red
                }
            }catch{

                    Write-Host "Connection to $ip on $port  ...FAILED" -ForegroundColor Red
        
            }

        }


     }

}

Measure-Command{Async-Scan}
#Measure-Command{Linear-Scan}

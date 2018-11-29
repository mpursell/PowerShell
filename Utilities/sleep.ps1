function Start-Sleeping($minutes){

    $seconds = $minutes * 60
    try{

        Start-Sleep -Seconds $seconds
        return 0
    }
    catch{

        return 1
    }
    
}

Start-Sleeping 1
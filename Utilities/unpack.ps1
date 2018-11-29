function Unpack-modules {

    $folderpath = "C:\Users\sa_pursellm\Desktop\PowerCli"
    $folders = Get-ChildItem $folderpath -Recurse -Directory -Depth 1

    foreach($folder in $folders){

        $folderName = $folder.FullName
        $folderParent = $folder.Parent

        Write-Host "Copying $folderName contents to $folderpath\$folderParent"
        Copy-Item -Path "$folderName\*" -Destination $folderpath\$folderParent -Force -Confirm:$False -Recurse
        

    }

    
}

Unpack-Modules 
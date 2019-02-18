$imageName = "local/config-vars"
$imageTag = "latest"
$imageFullName = $imageName + ':' + $imageTag

function Get-Containers-Count {
    $runningContainers = docker ps -a -q  --filter ancestor=$imageFullName 
    if ($runningContainers) {
        return $runningContainers.split(" ").length
    } 

    return 0;
}

function Check-Images {
    $dockerImages = docker images -q $imageFullName 
    return $dockerImages -and $dockerImages.split(' ').length -gt 0
}

function Clean-Images {

    $runningContainersCount = Get-Containers-Count

    if (Check-Images) {
        $isRemoveImage = Read-Host -Prompt "Image $imageFullName will be removed. Do you wan to continue ? [y or n] "

        if ($isRemoveImage -eq 'y') {
      
            if ($runningContainersCount -gt 0) {
                $isRemoveContainer = Read-Host -Prompt "There are $runningContainersCount containers using this image. This container will be removed. Do you wan to continue ? [y or n] "
            
                if ($isRemoveContainer -eq 'y') {
                    docker rm -f $(docker ps  --filter ancestor=$imageFullName -aq)
                }
                else {
                    exit
                }
            }
            docker rmi -f $imageFullName
        }
        else {
            exit
        }
    }
}

dotnet publish ConfigVars\ConfigVars.csproj #publish app

Clean-Images

docker build -t $imageFullName . #create image

$isRunImageNow = Read-Host -Prompt "Would you like to run the container ? [y or n] "

if ($isRunImageNow -eq 'y') {
    docker run  -p 9696:80 -e ASPNETCORE_ENVIRONMENT=Docker $imageFullName #run container
}

#-e Kestrel__Certificates__Default__Path=/root/.aspnet/https/cert-aspnetcore.pfx -e Kestrel__Certificates__Default__Password=ufo -v c:\tmp\:/root/.aspnet/https
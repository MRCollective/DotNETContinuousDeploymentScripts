Param(  $servicesPath,
        $serviceAssemblyName,
        $environment,
        $serviceAccount,
        $servicePassword
     )

try
{
    $serviceFullName = "$serviceAssemblyName$environment"
    $serviceInstallPath = "$servicesPath\$serviceFullName"

    write-output "Starting postsync command for $serviceFullName in the $environment environment."
    write-output "Using install path $serviceInstallPath."

    $service = Get-Service $serviceFullName -ErrorAction:SilentlyContinue

    if (!$service) # Service does not exist yet
    {
        write-output "Installing $serviceFullName."
        &"$serviceInstallPath\$serviceAssemblyName.exe" install -username:$serviceAccount -password:$servicePassword
        write-output "Installed $serviceFullName."
        
        write-output "Starting $serviceFullName."
        Start-Service -name $serviceFullName -ErrorAction Stop
        write-output "Started $serviceFullName."
    }
    else # Service exists
    {
        if ($service.Status -ne "Stopped")
        {
            write-output "Error: Service was not stopped post sync. You should investigate this manually. Service Status: " + $service.Status
            exit 1
        }
        else
        {
            write-output "Starting $serviceFullName."
            Start-Service -name $serviceFullName -ErrorAction Stop
            write-output "Started $serviceFullName."
        }
    }

    write-output "Finished postsync command for $serviceFullName in the $environment environment."
    exit 0
}
catch
{
    write-error $_
    exit 1
}
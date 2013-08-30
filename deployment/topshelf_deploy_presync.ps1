Param(  $serviceAssemblyName,
        $environment
     )

try
{
    $maxAttempts = 5
    $serviceFullName = "$serviceAssemblyName$environment"
    
    write-output "Starting presync command for $serviceFullName in the $environment environment."

    $service = Get-Service $serviceFullName -ErrorAction:SilentlyContinue

    if ($service) # Service exists already
    {
        if ($service.Status -eq "Stopped")
        {
            write-output "Service was already stopped."
        }
        else
        {
            write-output "Stopping $serviceFullName."
            $procId = (gwmi win32_service -filter "name = '$serviceFullName'").ProcessId
            $attempts = 1
            Stop-Service -name $serviceFullName -ErrorAction Stop
            
            while (Get-Process -id $procId -ea SilentlyContinue)
            {
                write-output "Waiting for the $serviceFullName process (PID $procId) to stop ($attempts/$maxAttempts)..."
                $attempts++
                start-sleep -s 5
                if ($attempts -gt $maxAttempts)
                {
                    write-output "Force killing PID $procId"
                    Stop-Process -Force $procId
                }
            }
            
            write-output "Stopped $serviceFullName."
        }
    }

    write-output "Finished presync command for $serviceFullName in the $environment environment."
    exit 0
}
catch
{
    write-error $_
    exit 1
}
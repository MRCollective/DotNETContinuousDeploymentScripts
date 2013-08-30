Param(  $websiteName,
        $bindingUrl,
        $physicalPath,
        $createIisSite
     )

$ErrorActionPreference = "Stop"

$bindingUrl = $bindingUrl.ToLower()

if ($createIisSite -ne "true")
{
    write-output "IIS site creation not required for this build configuration."
    exit 0
}

try
{
    eventcreate /ID 1 /L APPLICATION /T INFORMATION /SO $websiteName /D "A deployment of $websiteName started"

    import-module WebAdministration

    write-output "Checking if IIS site $websiteName already exists..."

    if (Get-Item "IIS:\Sites\$websiteName" -ea:"SilentlyContinue")
    {
        write-output "Site exists, continuing."
    }
    else
    {
        write-output "Site does not exist, creating..."
        new-item "$physicalPath" -type directory -force
		write-output "Path $physicalPath created..."
        New-Website -Name "$websiteName" -HostHeader "$bindingUrl" -PhysicalPath "$physicalPath" -ApplicationPool "ASP.NET v4.0" -Ssl -Port 443
		write-output "Website $websiteName created..."
        New-WebBinding -Name "$websiteName" -HostHeader "$bindingUrl" -Protocol http
		write-output "Binding $bindingUrl created..."
		Start-Website -Name "$websiteName" -ea:"SilentlyContinue"
        write-output "Site created as $websiteName under the url $bindingUrl."
    }
    
    eventcreate /ID 1 /L APPLICATION /T INFORMATION /SO $websiteName /D "A deployment of $websiteName finished"

    write-output (Get-Item "IIS:\Sites\$websiteName")
}
catch
{
    write-error $_
    exit 1
}
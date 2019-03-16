$ErrorActionPreference = 'Continue'
# work ongoing!

# Warn if the $env:DOCKER_HOST socket does not exist
if ($env:DOCKER_HOST -eq $null) 
{
	Write-Warning "Warning: unable to determine DOCKER_HOST"
	Exit
}

# Generate dhparam file if required
# Note: if $env:DHPARAM_BITS is not defined, generate-dhparam.sh will use 2048 as a default
# Note2: if $env:DHPARAM_GENERATION is set to false in environment variable, dh param generator will skip completely
.\generate-dhparam.ps1 -DHPARAM_GENERATION $env:DHPARAM_GENERATION -DHPARAM_BITS $env:DHPARAM_BITS

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
#$(Get-NetIPConfiguration | select -ExpandProperty DNSServer).ServerAddresses | select -unique | % { if ($_.contains(":")) {$env:RESOLVERS += "[$($_)] "}else{$env:RESOLVERS += "$($_) "} }
$env:RESOLVERS = $(Get-ItemProperty -Path HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\*).NameServer.replace(","," ")
if ($env:RESOLVERS -eq $null) 
{
    Write-Warning "Warning: unable to determine DNS resolvers for nginx"
}

forego.exe start -r
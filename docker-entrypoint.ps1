$ErrorActionPreference = 'Stop'
# work ongoing!

# Warn if the $env:DOCKER_HOST socket does not exist
if ($env:DOCKER_HOST -ne "") 
{
	$socket=$env:DOCKER_HOST
}
else
{
	Exit
}

# Generate dhparam file if required
# Note: if $env:DHPARAM_BITS is not defined, generate-dhparam.sh will use 2048 as a default
# Note2: if $env:DHPARAM_GENERATION is set to false in environment variable, dh param generator will skip completely
.\generate-dhparam.ps1 $env:DHPARAM_BITS $env:DHPARAM_GENERATION

# Compute the DNS resolvers for use in the templates - if the IP contains ":", it's IPv6 and must be enclosed in []
$env:RESOLVERS=$(awk '$1 == "nameserver" {print ($2 ~ ":")? "["$2"]": $2}' ORS=' ' /etc/resolv.conf | sed 's/ *$//g')
if ($env:RESOLVERS -eq "") 
{
    Write-Warning "Warning: unable to determine DNS resolvers for nginx"
}

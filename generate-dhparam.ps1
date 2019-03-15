Param
(
    [int] $DPARAM_BITS = 2048,
    [switch] $GENERATE_DHPARAM = $true
)
$ErrorActionPreference = 'Stop'

# If a dhparam file is not available, use the pre-generated one and generate a new one in the background.
# Note that /etc/nginx/dhparam is a volume, so this dhparam will persist restarts.
$PREGEN_DHPARAM_FILE = Get-Content "dhparam.pem.default"
$DHPARAM_FILE = Get-Content "C:\Program Files\nginx\dhparam\dhparam.pem"
$GEN_LOCKFILE  = Get-Content "dhparam_generating.lock"

# The hash of the pregenerated dhparam file is used to check if the pregen dhparam is already in use
$PREGEN_HASH = Get-FileHash -Path $PREGEN_DHPARAM_FILE -Algorithm MD5
if ($DHPARAM_FILE) 
{
    $CURRENT_HASH = Get-FileHash -Path $DHPARAM_FILE -Algorithm MD5
    if ($PREGEN_HASH -ne $CURRENT_HASH )
    {
        Write-Host "Custom dhparam.pem file found, generation skipped"
        Exit 0
    }

    if ($GEN_LOCKFILE)
    {
        # Generation is already in progress
        Exit 0
    }
}

if (!$GENERATE_DHPARAM)
{
    Write-Host "Skipping Diffie-Hellman parameters generation and Ignoring pre-generated dhparam.pem"
    Exit 0
}

Write-Warning "WARNING: $DHPARAM_FILE was not found. A pre-generated dhparam.pem will be used for now while a new one
is being generated in the background.  Once the new dhparam.pem is in place, nginx will be reloaded."

# Put the default dhparam file in place so we can start immediately
Copy-Item $PREGEN_DHPARAM_FILE $DHPARAM_FILE
($GEN_LOCKFILE).LastWriteTime = Get-Date

# Generate a new dhparam in the background in a low priority and reload nginx when finished (grep removes the progress indicator).
openssl dhparam -out $DHPARAM_FILE.tmp $DHPARAM_BITS
Move-Item $DHPARAM_FILE.tmp $DHPARAM_FILE
Write-Host "dhparam generation complete, reloading nginx"
nginx -s reload
Remove-Item $GEN_LOCKFILE
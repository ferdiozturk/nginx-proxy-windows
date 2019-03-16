Param
(
    [int] $DHPARAM_BITS = 2048,
    [switch] $DHPARAM_GENERATION = $true
)
$ErrorActionPreference = 'Continue'

# If a dhparam file is not available, use the pre-generated one and generate a new one in the background.
# Note that /etc/nginx/dhparam is a volume, so this dhparam will persist restarts.
$PREGEN_DHPARAM_FILE = "C:\app\dhparam.pem.default"
$DHPARAM_FILE = "C:\nginx\dhparam\dhparam.pem"
$GEN_LOCKFILE = "C:\dhparam_generating.lock"

# The hash of the pregenerated dhparam file is used to check if the pregen dhparam is already in use
$PREGEN_HASH = Get-FileHash -Path $PREGEN_DHPARAM_FILE -Algorithm MD5 -ErrorAction SilentlyContinue
if ($null -ne $(Get-Content $DHPARAM_FILE -ErrorAction SilentlyContinue)) 
{
    $CURRENT_HASH = Get-FileHash -Path $DHPARAM_FILE -Algorithm MD5
    if ($PREGEN_HASH -ne $CURRENT_HASH )
    {
        Write-Host "Custom dhparam.pem file found, generation skipped"
        Exit 0
    }

    if ($null -ne $(Get-Content $GEN_LOCKFILE -ErrorAction SilentlyContinue))
    {
        Write-Warning "Generation already in progress"
        Exit 0
    }
}

if ($false -eq $DHPARAM_GENERATION)
{
    Write-Host "Skipping Diffie-Hellman parameters generation and Ignoring pre-generated dhparam.pem"
    Exit 0
}

Write-Warning "$DHPARAM_FILE was not found. A pre-generated dhparam.pem will be used for now while a new one
is being generated in the background.  Once the new dhparam.pem is in place, nginx will be reloaded."

# Put the default dhparam file in place so we can start immediately
Copy-Item $PREGEN_DHPARAM_FILE $DHPARAM_FILE
New-Item $GEN_LOCKFILE
#($GEN_LOCKFILE).LastWriteTime = Get-Date

Get-Content $DHPARAM_FILE
Write-Host $DHPARAM_BITS

# Generate a new dhparam in the background in a low priority and reload nginx when finished (grep removes the progress indicator).
openssl dhparam -out $DHPARAM_FILE $DHPARAM_BITS
#Move-Item $DHPARAM_FILE.tmp $DHPARAM_FILE
Write-Host "dhparam generation complete, reloading nginx"
nginx -s reload
Remove-Item $GEN_LOCKFILE
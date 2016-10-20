param(
    [ValidateSet('win', 'linux')]
    [string]$plat = "win"
)

Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$dockerRepo="microsoft/dotnet-samples"

$dockerfileName = "Dockerfile"
if ($plat -eq "win") {
    $dockerfileName += ".nano"
    $rid = "win10-x64"
    $tagSuffix = "-nanoserver"
}
else {
    $rid = "debian.8-x64"
    $tagSuffix = ""
}

pushd $PSScriptRoot

Get-ChildItem -Recurse -Filter $dockerfileName | foreach {
    pushd $_.DirectoryName

    $tag = "$($dockerRepo):" + $_.DirectoryName.Replace($PSScriptRoot, '').TrimStart('\').TrimStart('/').Replace('\', '-').Replace('/', '-') + $tagSuffix
    Write-Host "--- Building $($_.DirectoryName)\$dockerfileName to produce $tag ---"

    if (($_.DirectoryName.EndsWith("prod")) -or ($_.DirectoryName.EndsWith("selfcontained"))) {
        dotnet restore
        if (-NOT $?) {
            throw "Failed dotnet restore"
        }
	dotnet publish -c Release -o out -r $rid
        if (-NOT $?) {
            throw "Failed dotnet build"
        }
    }

    docker build -t $tag -f $dockerfileName .
    if (-NOT $?) {
        throw "Failed docker build"
    }

    popd
}

popd


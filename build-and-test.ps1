Set-StrictMode -Version Latest
$ErrorActionPreference="Stop"

$dockerRepo="microsoft/dotnet-samples"

pushd $PSScriptRoot

Get-ChildItem -Recurse -Filter Dockerfile.nano | sort DirectoryName | foreach {
    pushd $_.DirectoryName

    $tag = "$($dockerRepo):" + $_.DirectoryName.Replace($PSScriptRoot, '').TrimStart('\').Replace('\', '-') + "-nanoserver"
    Write-Host "--- Building $($_.DirectoryName)\Dockerfile.nano to produce $tag ---"

    if (($_.DirectoryName.EndsWith("prod")) -or ($_.DirectoryName.EndsWith("selfcontained"))) {
        dotnet restore
        if (-NOT $?) {
            throw "Failed dotnet restore"
        }
	dotnet publish -c Release -o out -r win10-x64
        if (-NOT $?) {
            throw "Failed dotnet build"
        }
    }

    docker build -t $tag -f Dockerfile.nano .
    if (-NOT $?) {
        throw "Failed docker build"
    }

    popd
}

popd


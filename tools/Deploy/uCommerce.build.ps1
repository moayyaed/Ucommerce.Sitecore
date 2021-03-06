Framework "4.7.1"

properties {
    $configuration = 'Debug'
    $src = "."
    $zipFileName = "Ucommerce-for-Sitecore-{1}.zip"
    $zipDestinationFolder = "C:\tmp"
    $solution_file = "Ucommerce.Sitecore.sln"
    $working_dir = $null
    $version = $null
    $base_dir = $null
    $updatePackageVersion = $false
    $UpdateAssemblyInfo = "False"
    $script:hash = @{}
    $target="none"
    $CreatePackage = $True
}

function GetZipFilename {
    $newFileName = [string]::Format($zipDestinationFolder + "\" + $zipFileName, $target, $script:version)

    # Make sure to delete the file else 7Zip will append files to the zip.
    if(Test-Path $newFileName)
    {
        Remove-Item $newFileName -Force
    }

    return $newFileName;
}

function IsVersionNumber($thisVersion){
    return [System.Text.RegularExpressions.Regex]::IsMatch($thisVersion, "^[0-9]{1,5}(\.[0-9]{1,5}){2}$")
}

function CopyFiles($srcDirectory, $dstDirectory, $files){
    foreach($file in $files)
    {
        if(Test-Path "$srcDirectory\$file")
        {
            Copy-Item "$srcDirectory\$file" "$dstDirectory\$file" -Force
        }
    }
}

function MoveFiles($srcDirectory, $dstDirectory, $files){
    foreach($file in $files)
    {
        if(Test-Path "$srcDirectory\$file")
        {
            Move-Item "$srcDirectory\$file" "$dstDirectory\$file" -Force
        }
        else{
            throw "source file '$srcDirectory\$file' does not exist"
        }
    }
}

function RemoveFiles($directory, $files){
    foreach($file in $files)
    {
        if(Test-Path "$directory\$file")
        {
            Remove-Item "$directory\$file" -Force
        }
    }
}

. .\uCommerce.Sitecore.ps1
. .\Get-FolderItem.ps1

task PostDeployMoveBinFiles -description "used to move all uCommerce bin files to the root bin folder when deploying local" {
    $root = $script:hash.files_root_dir
    Move-Item "$root\bin\ucommerce\Ucommerce.*" "$root\bin\" -Force
}

task CleanSolution -description "Cleans the complete solution" {
    Push-Location "$src"
    Exec { msbuild "$solution_file" /p:Configuration=$configuration /p:VisualStudioVersion=16.0 /t:Clean /verbosity:quiet }
    Pop-Location
}

task CleanUcommerceWebBinDirectory -description "Cleans the UCommerceWeb bin directory" {
	Push-Location "$src"
	if (Test-Path $src\UcommerceWeb\bin)
	{
		Remove-Item -Recurse "$src\Ucommerce.Sitecore.Web\bin\*" -Force
	}
	Pop-Location
}

task Rebuild -depend CleanSolution, CleanUcommerceWebBinDirectory, Compile

task Compile -description "Compiles the complete solution" -depends UpdateAssemblyInfo {
    Push-Location "$src"

    # Set Visual Studio version explicitly so the proper build tasks can be found
    # Disable post build event to avoid deploying the solution as part of packaging
    Exec { msbuild "$solution_file" /p:Configuration=$configuration /p:VisualStudioVersion=16.0 /m /p:WarningLevel=0 /verbosity:quiet /p:PostBuildEvent= }

    Pop-Location
}

task UpdateAssemblyInfo -description "Updates the AssemblyInfo.cs file if there is a valid version string supplied" -depends UpdateSitecorePackageInfo{
    if ($UpdateAssemblyInfo -eq "True") {
        Push-Location $src

		$hgChangeSetHash = git rev-parse HEAD

        $assemblyVersionPattern = 'AssemblyVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
        $fileVersionPattern = 'AssemblyFileVersion\("[0-9]+(\.([0-9]+|\*)){1,3}"\)'
	$assemblyInformationalVersionPattern = 'AssemblyInformationalVersion\("[0-9]+(\.([0-9]+|\*)){1,3} .*\)'
        #$cmsVersionPattern = 'CompiledFor\("\w*"\)'
        $assemblyVersion = 'AssemblyVersion("' + $script:version + '")';
        $fileVersion = 'AssemblyFileVersion("' + $script:version + '")';
	$assemblyInformationalVersion = 'AssemblyInformationalVersion("' + $script:version + ' ' + $hgChangeSetHash + '")';
        #$cmsVersion = 'CompiledFor("' + $target + '")';
        Get-FolderItem -Path $src -Filter AssemblyInfo.cs | ForEach-Object {
            $filename = $_.FullName
            $filename + ' -> ' + $script:version

            # If you are using a source control that requires to check-out files before
            # modifying them, make sure to check-out the file here.
            # For example, TFS will require the following command:
            # tf checkout $filename
            (Get-Content $filename) | ForEach-Object {
                % {$_ -replace $assemblyVersionPattern, $assemblyVersion } |
                % {$_ -replace $fileVersionPattern, $fileVersion } |
                % {$_ -replace $assemblyInformationalVersionPattern, $assemblyInformationalVersion }
            } | Set-Content $filename
        }

        $clientDependencyVersionPattern = 'version="[0-9]+"';
		$clientDependencyVersion = 'version="' + $script:versionDateNumberPart + '"';

        Pop-Location
    }
}
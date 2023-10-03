
."${PowerScriptsDirectory}\function_definitions.ps1"

$OldPath = Get-Location

# Update conda
conda deactivate
conda config --set auto_update_conda true
conda config --set report_errors false

Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "              Checking all base conda packages for potential updates" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
conda activate base
conda update --all --yes
conda deactivate

# Update Node.js
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                Checking all NPM packages for potential updates" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
$CommandString = "npm install -g npm"
Invoke-Expression $CommandString
$CommandString = "npm update -g"
Invoke-Expression $CommandString

# Create the conda environment
."${PowerScriptsDirectory}\update_conda_environment.ps1"

# Add the kernel to the Launcher
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                        Adding the kernel to the Launcher" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Add-Python-Executable-To-Path $EnvironmentPath
Add-Kernel-To-Launcher $EnvironmentPath -DisplayName $DisplayName
$KernelPath = "${HomeDirectory}\AppData\Roaming\jupyter\kernels\${EnvironmentName}\kernel.json"
If (Test-Path -Path $KernelPath -PathType Leaf) {
	Add-Logos-To-Kernel-Folder $EnvironmentName -RepositoryName $RepositoryName
	(Get-Content $KernelPath) | ConvertFrom-Json | ConvertTo-Json -depth 7 | Format-Json -Indentation 2
}

# Add a workspace file for bookmarking. You can create a temporary workspace file in the 
# $Env:UserProfile\.jupyter\lab\workspaces folder by going to this URL:
# http://localhost:8888/lab/?clone=$EnvironmentName
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "                        Importing the workspace file" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
$WorkspacePath = Import-Workspace-File $EnvironmentPath -RepositoryPath $RepositoryPath
If ($WorkspacePath -Ne $null) {
	If (Test-Path -Path $WorkspacePath -PathType Leaf) {
		(Get-Content $WorkspacePath) | ConvertFrom-Json | ConvertTo-Json -depth 7 | Format-Json -Indentation 2
	}
} else {

	# Get the path to the Jupyter workspaces folder
	$WorkspacesFolder = "$Env:UserProfile\.jupyter\lab\workspaces"

	# Check if the folder exists
	if (Test-Path $WorkspacesFolder) {
		
		# Empty the folder
		Remove-Item $WorkspacesFolder -Recurse -Force
		if (-not (Test-Path $WorkspacesFolder)) {
			 New-Item -ItemType Directory -Path $WorkspacesFolder
		}
		
		# Create the workspace
		Start-Process "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" -ArgumentList "http://localhost:8888/lab/?clone=${EnvironmentName}"
		
		# Get a list of the files in the workspaces folder
		$FilesList = Get-ChildItem $WorkspacesFolder
		
		# Loop through the files list
		if ($FilesList -ne $null) {
			foreach ($FileObj in $FilesList) {
				Write-Host $FileObj.FullName
			}
		}
		
	}
	
}


# Copy the favicon asset to the static directory
$IconPath = "${EnvironmentPath}\saves\ico\notebook_static_favicon.ico"
If (Test-Path -Path $IconPath -PathType Leaf) {
	$FaviconsFoldersList = @("${HomeDirectory}\anaconda3\share\jupyter\lab\static\favicons","${EnvironmentPath}\share\jupyter\lab\static\favicons")
	ForEach ($FaviconsFolder in $FaviconsFoldersList) {
		$NewIconPath = "${FaviconsFolder}\favicon.ico"
		If (!(Test-Path -Path $NewIconPath -PathType Leaf)) {
			If (!(Test-Path -Path $FaviconsFolder -PathType Container)) {
				New-Item -ItemType Directory -Path $FaviconsFolder
			}
			Copy-Item $IconPath -Destination $NewIconPath
		}
	}
}

cd $OldPath
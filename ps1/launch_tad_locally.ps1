#Requires -Version 2.0

# Soli Deo gloria

# Run this in a PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\ITM\ps1
# cls
# .\launch_tad_locally.ps1

# Set up global variables
$RepositoryName = "ITM"
$EnvironmentName = "tad_env"
$HomeDirectory = $Env:UserProfile
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"
$PowerScriptsDirectory = "${RepositoryPath}\ps1"
$EnvironmentsDirectory = "${HomeDirectory}\anaconda3\envs"
$EnvironmentPath = "${EnvironmentsDirectory}\${EnvironmentName}"
$DisplayName = "TAD System"

conda activate base

# Update the repository
if (Test-Path $RepositoryPath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Updating the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Set-Location $RepositoryPath
	git pull
}

# Clone the repository
else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Cloning the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	$WebUrl = "https://github.com/Parallax-Advanced-Research/${RepositoryName}.git"
	git clone $WebUrl $RepositoryPath
}

# Delete the environment
."${PowerScriptsDirectory}\delete_conda_environment.ps1"

# Create the environment
."${PowerScriptsDirectory}\create_conda_environment.ps1"

# Activate that environment (./venv/Scripts/activate on windows)
."${PowerScriptsDirectory}\function_definitions.ps1"
$ActiveEnvironment = Get-Active-Conda-Environment
if (-not ($ActiveEnvironment -contains $EnvironmentName)) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "                       Activating the ${EnvironmentName} environment" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	conda activate $EnvironmentName
	conda info --envs
}

# Install the requirements via pip
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "  Installing the required dependencies in the ${EnvironmentName} environment" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
cd $RepositoryPath
pip install -r requirements.txt

# Install the TA3 ITM MVP modules
."${PowerScriptsDirectory}\install_ncc_itm_mvp.ps1"

# Run TAD Locally
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
Write-Host "       Running TAD Locally from the ${RepositoryName} repository" -ForegroundColor Green
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
$RepositoryName = "ITM"
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"
cd $RepositoryPath
python tad.py -h
#Requires -Version 2.0

# Soli Deo gloria

# Run this in an Admin PowerShell window:
# 
# cd $Env:UserProfile\Documents\GitHub\notebooks\ps1
# cls
# .\install_ncc_itm_mvp.ps1

# Set up global variables
$RepositoryName = "itm-mvp"
$RepositoriesDirectory = "${HomeDirectory}\Documents\GitHub"
$EnvironmentLocation = "${HomeDirectory}\anaconda3\envs\${EnvironmentName}"

# Get the folder path of the repository
$RepositoryPath = "${RepositoriesDirectory}\${RepositoryName}"

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
	$WebUrl = "https://github.com/NextCenturyCorporation/${RepositoryName}.git"
	git clone $WebUrl $RepositoryPath
}

# Install the TA3 ITM MVP client module
$FilePath = "${EnvironmentLocation}\Lib\site-packages\swagger-client.egg-link"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             The TA3 ITM MVP client module is already installed" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "       Installing the TA3 ITM MVP client module from the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd "${RepositoriesDirectory}\${RepositoryName}\itm_client"
	pip install -e .
}

# Install the TA3 ITM MVP server module
$FilePath = "${EnvironmentLocation}\lib\site-packages\swagger_ui_bundle\__init__.py"
if (Test-Path $FilePath) {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "             The TA3 ITM MVP server module is already installed" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
} else {
	Write-Host ""
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	Write-Host "       Installing the TA3 ITM MVP server module from the ${RepositoryName} repository" -ForegroundColor Green
	Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green
	cd "${RepositoriesDirectory}\${RepositoryName}\itm_server"
	pip install -r requirements.txt
}
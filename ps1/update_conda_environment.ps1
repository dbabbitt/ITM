
# Create the conda environment
cd $RepositoryPath
Write-Host ""
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green

# Assume here that if the environment folder is missing, the environment was already deleted
If (Test-Path -Path $EnvironmentPath -PathType Container) {
	Write-Host "           Updating the ${DisplayName} conda environment (${EnvironmentName})" -ForegroundColor Green
} Else {
	Write-Host "           Creating the ${DisplayName} conda environment (${EnvironmentName})" -ForegroundColor Green
}
Write-Host "-------------------------------------------------------------------------------" -ForegroundColor Green

# You can control where a conda environment lives by providing a path to a target directory when creating the environment.
$FilePath = "${RepositoryPath}\environment.yml"
If (Test-Path $FilePath) {
	conda env update --prefix $EnvironmentPath --file $FilePath --prune --quiet
}

# Installation
# To install the dependencies, we suggest using virtualenv. This can be done by running:
If (conda env list | findstr $EnvironmentName) {
	conda update --all --yes --quiet --name $EnvironmentName
}

# TAD is tested on Python 3.11, but should work on anything above Python 3.10.
# TAD is currently setup to run via the commandline via the tad.py script in this projects root directory.
Else {
	conda create --yes --quiet --name $EnvironmentName python=3.11
}
conda info --envs
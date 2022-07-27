param (
<<<<<<< HEAD
[string] $DataSourceFile = "DataSource1.rds", 
[string] $SourceFolder = "SSRS",
[string] $TargetReportServerUri = "http://localhost/ReportServer/ReportService2010.asmx?wsdl",
[string] $TargetFolder = "MyReports"


=======
[string] $SourceFolder,
[string] $TargetReportServerUri,
[string] $TargetFolder
>>>>>>> origin/master
)

$ErrorActionPreference = "Stop"

<<<<<<< HEAD
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 
Install-Module PowerShellGet -RequiredVersion 2.2.4 -SkipPublisherCheck
=======
>>>>>>> origin/master

if ($SourceFolder -eq "") {
    $SourceFolder = $(Get-Location).Path + "\"
}

if (!$SourceFolder.EndsWith("\"))
{
    $SourceFolder = $SourceFolder + "\"
}

Write-Output "====================================================================================="
Write-Output "                             Deploying SSRS Reports"
Write-Output "Source Folder: $SourceFolder"
Write-Output "Target Server: $TargetReportServerUri"
Write-Output "Target Folder: $TargetFolder"
Write-Output "====================================================================================="

<<<<<<< HEAD
Write-Output "Marking PSGallery as Trusted..."
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

Write-Output "Installing ReportingServicesTools Module..."
Install-Module -Name ReportingServicesTools            

Write-Output "Requesting RSTools..."
Invoke-Expression (Invoke-WebRequest https://aka.ms/rstools)

=======
>>>>>>> origin/master
#Get-Command -Module ReportingServicesTools

Write-Output "Creating Folder: $TargetFolder"
New-RsFolder -ReportServerUri $TargetReportServerUri -Path / -Name $TargetFolder -Verbose -ErrorAction SilentlyContinue

$TargetFolder = "/" + $TargetFolder

Write-Output "Deploying Data Source files from: $SourceFolder"
DIR $SourceFolder -Filter *.rds | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Data Set files from: $SourceFolder"
DIR $SourceFolder -Filter *.rsd | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Report Definition files from: $SourceFolder"
DIR $SourceFolder -Filter *.rdl | % { $_.FullName } |
<<<<<<< HEAD
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite
=======
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite
>>>>>>> origin/master
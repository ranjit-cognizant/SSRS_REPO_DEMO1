param (
[string] $SourceFolder = "SSRS_REPORT",
[string] $TargetReportServerUri = "http://vm-sqlsvr-tmg-f/ReportServer",
[string] $TargetFolder = "SSRS_REPORT"
)

$ErrorActionPreference = "Stop"


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
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite
Param(
#[string] $DataSourceFolder = "/MyFolder111111111", 
#[string] $DataSourceFile = "DataSource1.rds", 
#[string] $ReportServerUri = "http://vm-sqlsvr-tmg-f/ReportServer/ReportService2010.asmx?wsdl", 
#[string] $DBServerName = "VM-SQLSVR-TMG-P", 
#[string] $DatabaseName = "Facetsext",
#[string] $TargetFolder = "MyReports",
#[string] $DataSourceUserName = "alocalbox",
##[string] $DataSourcePassword = "TriZett02022"

[string] $DataDataSourceFolder = "SSRS_REPORT",
[string] $DataSourceFile = "DataSource1.rds", 
[string] $ReportServerUri = "http://vm-sqlsvr-tmg-f/ReportServer/ReportService2010.asmx?wsdl",
[string] $DBServerName = "VM-SQLSVR-TMG-F", 
[string] $DatabaseName = "Facetsext",
[string] $TargetFolder = "MyReports",
[string] $DataSourceUserName = "alocalbox",
[string] $DataSourcePassword = "TriZett02022"
)

$ErrorActionPreference = "Stop"

Echo "Data Source Folder: $DataSourceFolder"
Echo "Data Source File: $DataSourceFile"
Echo "Report Server URI: $ReportServerUri"
Echo "DB Server Name: $DBServerName"
Echo "Database Name: $DatabaseName"
Echo "Data Target Folder: $TargetFolder"
Echo "Data Source UserName: $DataSourceUserName"
Echo "Data Source Password: $DataSourcePassword"

Write-Output "Creating Folder: $TargetFolder"
New-RsFolder -ReportServerUri $ReportServerUri -Path / -Name $TargetFolder -Verbose -ErrorAction SilentlyContinue

$TargetFolder = "/" + $TargetFolder

#Data Source Connection String
$ConnectString = "Data Source="+ $DBServerName+ ";Initial Catalog="+ $DatabaseName

try{
#Create Proxy
$global:proxy = New-WebServiceProxy -Uri $ReportServerUri -UseDefaultCredential -ErrorAction Stop;
If ($proxy -ne $null) 
{
echo $global:proxy.ToString()
}
}
catch {
$valProxyError = $_.Exception.Message;
echo $_.Exception.Message;
}

[xml]$XmlDataSourceDefinition = Get-Content $DataSourceFile;

Echo("Data Source Name: $($XmlDataSourceDefinition.RptDataSource.Name)")
$xmlDataSourceName = $XmlDataSourceDefinition.RptDataSource | where {$_ | get-member ConnectionProperties};

try{ $type = $proxy.GetType().Namespace; }catch{ throw $_.Exception; }
$dataSourceDefinitionType = ($type + '.DataSourceDefinition');
$dataSourceDefinition = new-object ($dataSourceDefinitionType);
$dataSourceDefinition.Extension = $xmlDataSourceName.ConnectionProperties.Extension; #SQL

$dataSourceDefinition.ConnectString = $ConnectString
$credentialRetrievalDataType = ($type + '.CredentialRetrievalEnum'); 
$credentialRetrieval = new-object ($credentialRetrievalDataType);
$credentialRetrieval.value__ = 1;# Stored
$dataSourceDefinition.CredentialRetrieval = $credentialRetrieval;
$dataSourceDefinition.WindowsCredentials = $true;
$dataSourceDefinition.UserName = $DataSourceUserName;
$dataSourceDefinition.Password = $DataSourcePassword;
try{ $newDataSource = $proxy.CreateDataSource($xmlDataSourceName.Name,$TargetFolder,$true,
    $dataSourceDefinition,$null); }catch{ throw $_.Exception; }
	

Write-Output "====================================================================================="
Write-Output "                             Deploying SSRS Reports"
Write-Output "Source Folder: $DataSourceFolder"
Write-Output "Target Server: $ReportServerUri"
Write-Output "Target Folder: $TargetFolder"
Write-Output "====================================================================================="

#Write-Output "Deploying Data Source files from: $DataSourceFolder"
#DIR $DataSourceFolder -Filter *.rds | % { $_.FullName } |
    #Write-RsCatalogItem -ReportServerUri $ReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Data Set files from: $DataSourceFolder"
DIR $DataSourceFolder -Filter *.rsd | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $ReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Report Definition files from: $DataSourceFolder"
DIR $DataSourceFolder -Filter *.rdl | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $ReportServerUri -Destination $TargetFolder -Verbose -Overwrite

echo "Done.";


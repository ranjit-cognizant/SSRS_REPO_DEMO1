Param(
[string] $SourceFolder, 
[string] $DataSourceFile = "DataSource1.rds", 
[string] $TargetReportServerUri = "http://vm-sqlsvr-tmg-f/ReportServer/ReportService2010.asmx?wsdl", 
[string] $DBServerName = "VM-SQLSVR-TMG-P", 
[string] $DatabaseName = "Facetsext",
[string] $TargetFolder = "MyReports",
[string] $DataSourceUserName = "alocalbox",
[string] $DataSourcePassword = "TriZett02022"
)

$ErrorActionPreference = "Stop"

Echo "Data Source Folder: $SourceFolder"
Echo "Data Source File: $DataSourceFile"
Echo "Report Server URI: $TargetReportServerUri"
Echo "DB Server Name: $DBServerName"
Echo "Database Name: $DatabaseName"
Echo "Data Target Folder: $TargetFolder"
Echo "Data Source UserName: $DataSourceUserName"
Echo "Data Source Password: $DataSourcePassword"

Write-Output "Creating Folder: $TargetFolder"
New-RsFolder -ReportServerUri $TargetReportServerUri -Path / -Name $TargetFolder -Verbose -ErrorAction SilentlyContinue

$TargetFolder = "/" + $TargetFolder

#Data Source Connection String
$ConnectString = "Data Source="+ $DBServerName+ ";Initial Catalog="+ $DatabaseName

try{
#Create Proxy
$global:proxy = New-WebServiceProxy -Uri $TargetReportServerUri -UseDefaultCredential -ErrorAction Stop;
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
try{ $newDataSource = $proxy.CreateDataSource($xmlDataSourceName.Name,$SourceFolder,$true,
    $dataSourceDefinition,$null); }catch{ throw $_.Exception; }
	

Write-Output "====================================================================================="
Write-Output "                             Deploying SSRS Reports"
Write-Output "Source Folder: $SourceFolder"
Write-Output "Target Server: $TargetReportServerUri"
Write-Output "Target Folder: $TargetFolder"
Write-Output "====================================================================================="

Write-Output "Deploying Data Source files from: $SourceFolder"
DIR $SourceFolder -Filter *.rds | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Data Set files from: $SourceFolder"
DIR $SourceFolder -Filter *.rsd | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite

Write-Output "Deploying Report Definition files from: $SourceFolder"
DIR $SourceFolder -Filter *.rdl | % { $_.FullName } |
    Write-RsCatalogItem -ReportServerUri $TargetReportServerUri -Destination $TargetFolder -Verbose -Overwrite

echo "Done.";


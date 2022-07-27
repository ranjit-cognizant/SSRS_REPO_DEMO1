Param(
[string] $DataSourceFile = "DataSource1.rds", 
[string] $ReportServerUri = "http://vm-sqlsvr-tmg-f/ReportServer/ReportService2010.asmx?wsdl",
[string] $DataSourceFolder = "/SSRS_REPORT", 
[string] $DBServerName = "VM-SQLSVR-TMG-P", 
[string] $DatabaseName = "Facetsext",
#[string] $TargetFolder = "MyReports"
[string] $DataSourceUserName = "alocalbox",
[string] $DataSourcePassword = "TriZett02022"
)

Echo "Data Source File: $DataSourceFile"
Echo "Report Server URI: $ReportServerUri"
Echo "Data Source Folder: $DataSourceFolder"
Echo "DB Server Name: $DBServerName"
Echo "Database Name: $DatabaseName"
Echo "Data Source User Name: $DataSourceUserName"
Echo "Data Source Password: $DataSourcePassword"

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
try{ $newDataSource = $proxy.CreateDataSource($xmlDataSourceName.Name,$DataSourceFolder,$true,
    $dataSourceDefinition,$null); }catch{ throw $_.Exception; }
echo "Done.";
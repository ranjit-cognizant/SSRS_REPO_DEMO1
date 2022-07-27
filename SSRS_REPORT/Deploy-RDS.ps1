Param(

[Parameter(Mandatory=$True,Position=1)]
[string]$DataSourceFile, 
[Parameter(Mandatory=$True,Position=2)]
[string]$ReportServerUri, 
[Parameter(Mandatory=$True,Position=3)]
[string]$DataSourceFolder, 
[Parameter(Mandatory=$True,Position=4)]
[string]$DBServerName, 
[Parameter(Mandatory=$True,Position=5)]
[string]$DatabaseName
#[Parameter(Mandatory=$True,Position=6)]
#[string]$DataSourceUserName,
#[Parameter(Mandatory=$True,Position=7)]
#[string]$DataSourcePassword

)

Echo "Data Source File: $DataSourceFile"
Echo "Report Server URI: $ReportServerUri"
Echo "Data Source Folder: $DataSourceFolder"
Echo "DB Server Name: $DBServerName"
Echo "Database Name: $DatabaseName"
Echo "Data Source UserName: $DataSourceUserName"

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

#Echo("Data Source Name:$($XmlDataSourceDefinition.RptDataSource.Name)")
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
Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
    [string] $ResourceGroupName = 'Monitor',
    [string] $TemplateFile = 'azuredeploy.json',
    [string] $TemplateParametersFile = 'azuredeploy.parameters.json',
    [string] $ConnectionMonitorTemplateFile = 'ConnectionMonitor.json'
)

### Create Resource Group if not exists

if (!(Get-AzResourceGroup -Name $ResourceGroupName)){
    Write-Host "Creating new Resource Group $ResourceGroupName"
    New-AzResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation
}

### Deploy Monitoring environment

New-AzResourceGroupDeployment -Name "Monitor-deployment" `
                                       -ResourceGroupName $ResourceGroupName `
                                       -TemplateFile $TemplateFile `
                                       -TemplateParameterFile $TemplateParametersFile `
                                       -Force -Verbose `
                                       -ErrorVariable ErrorMessages


### Deploy Connection Monitor 2

$networkWatchers_NetworkWatcher_region_name = "NetworkWatcher_$ResourceGroupLocation"
$virtualMachines_r1_web_externalid = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name "R1-AppVM1").Id
$virtualMachines_r1_db_externalid = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name "R1-DbVM1").Id
$virtualMachines_r2_externalid = (Get-AzVM -ResourceGroupName $ResourceGroupName -Name "R2-WinVM1").Id
$virtualMachines_onprem_name = "onprem-WinVM1"
$virtualMachines_onprem_fqdn = (Get-AZNetworkInterface -ResourceGroupName $ResourceGroupName -Name "onprem-vm1-nic1").IpConfigurations[0].PrivateIpAddress
$loganalytics_workspace_externalid = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName).ResourceId

New-AzResourceGroupDeployment -Name "ConnectionMonitor-deployment" `
                                       -ResourceGroupName "NetworkWatcherRG" `
                                       -TemplateFile $ConnectionMonitorTemplateFile `
                                       -networkWatchers_NetworkWatcher_region_name $networkWatchers_NetworkWatcher_region_name `
                                       -virtualMachines_r1_web_externalid $virtualMachines_r1_web_externalid `
                                       -virtualMachines_r1_db_externalid $virtualMachines_r1_db_externalid `
                                       -virtualMachines_r2_externalid $virtualMachines_r2_externalid `
                                       -virtualMachines_onprem_name $virtualMachines_onprem_name `
                                       -virtualMachines_onprem_fqdn $virtualMachines_onprem_fqdn `
                                       -loganalytics_workspace_externalid $loganalytics_workspace_externalid `
                                       -Force -Verbose `
                                       -ErrorVariable ErrorMessages


                                       


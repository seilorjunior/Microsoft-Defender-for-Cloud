param(
[Parameter(Mandatory = $False)] $exclusionTags=@{},
[Parameter(Mandatory = $True)][string]$subscriptionId
)

az account set --subscription $subscriptionId

$objectid= (az ad sp list --display-name "Microsoft Defender for Cloud Servers Scanner Resource Provider" --query [].id --output tsv)
if ([string]::IsNullOrWhiteSpace($objectid))
{
	$objectid= (az ad sp list --display-name "Microsoft Defender for Cloud Servers Scanner Resource Provider" --query [].objectId --output tsv)
}

$exclusionTagsJson = ($exclusionTags | ConvertTo-Json -Compress).Replace('"', '\"')

az feature register --namespace Microsoft.Security --name VmScanners.Preview
az provider register --namespace "Microsoft.Security" --wait

az role assignment create --assignee $objectid --role "VM Scanner Operator"

az deployment sub create --location "West Europe" --template-uri "https://raw.githubusercontent.com/Azure/Microsoft-Defender-for-Cloud/main/Powershell%20scripts/VM%20Scanners/onboardingTemplate.json" --parameters exclusionTags=$exclusionTagsJson

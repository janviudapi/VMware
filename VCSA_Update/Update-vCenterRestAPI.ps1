Write-Host "vCenter authentication information" -BackgroundColor Yellow
$vCenter = 'dccomics.vcloud-lab.com'  
$username = 'administrator@vsphere.local'   
$password = '123456'  
 
$secureStringPassword = ConvertTo-SecureString $password -AsPlainText -Force  
$encryptedPassword = ConvertFrom-SecureString -SecureString $secureStringPassword  
$credential = New-Object System.Management.Automation.PsCredential($username,($encryptedPassword | ConvertTo-SecureString))  
#$credential.GetNetworkCredential().Password  
 
#Type credential and process to base 64  
#$credential = Get-Credential -Message 'Type vCenter Password' -UserName 'administrator@vsphere.local'  
$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($credential.UserName+':'+$credential.GetNetworkCredential().Password))  
$head = @{  
  Authorization = "Basic $auth"  
}  

Write-Host "Login to vCenter" -BackgroundColor Yellow
#Authenticate against vCenter  
$a = Invoke-WebRequest -Uri "https://$vCenter/rest/com/vmware/cis/session" -Method Post -Headers $head -SkipCertificateCheck
$token = ConvertFrom-Json $a.Content | Select-Object -ExpandProperty Value  
$session = @{'vmware-api-session-id' = $token}  
  

#Get All vCenter server VAMI updates 
$vamiUpdateAPiUrl = "https://$vCenter/api/appliance/update"  
  
#Get vCenter appliance version
$vamiUpdatAPI = Invoke-WebRequest -Uri $vamiUpdateAPiUrl -Method Get -Headers $session -SkipCertificateCheck
$vamiUpdateList = ConvertFrom-Json $vamiUpdatAPI.Content 

#Get list of available updates for vCenter Server, It takes some time to download update catalog.
#https://developer.vmware.com/apis/vsphere-automation/latest/appliance/api/appliance/update/pending/version/get/
#https://developer.vmware.com/apis/vsphere-automation/latest/vcenter/
#https://vdc-repo.vmware.com/vmwb-repository/dcr-public/30fe7bca-1d83-49ec-985d-2b944e996948/4c5145e2-1d5a-4866-af04-f56c12fda442/landing_types.html#PKG_com.vmware.appliance
#https://vdc-download.vmware.com/vmwb-repository/dcr-public/423e512d-dda1-496f-9de3-851c28ca0814/0e3f6e0d-8d05-4f0c-887b-3d75d981bae5/VMware-vSphere-Automation-SDK-REST-6.7.0/docs/apidocs/operations/com/vmware/appliance/update/pending.stage_and_install-operation.html
#https://dccomics.vcloud-lab.com/ui/app/devcenter/api-explorer
$vamiCheckUpdateUrl = "https://$vCenter/api/appliance/update/pending?source_type=LOCAL_AND_ONLINE"
$vamiCheckUpdatAPI = Invoke-WebRequest -Uri $vamiCheckUpdateUrl -Method Get -Headers $session -SkipCertificateCheck
$vamiCheckUpdatesList = ConvertFrom-Json $vamiCheckUpdatAPI.Content
$vamiLastestUpdate = $vamiCheckUpdatesList | Sort-Object Version -Descending | Select-Object -First 1

#Check VCSA detailed update information
$vamiCheckUpdateVersionUrl = "https://$vCenter/api/appliance/update/pending/$($vamiLastestUpdate.version)"
$vamiCheckUpdateVersionAPI = Invoke-WebRequest -Uri $vamiCheckUpdateVersionUrl -Method Get -Headers $session -SkipCertificateCheck
$vamiCheckUpdateVersionAPI | ConvertFrom-Json | Select-Object name, release_date

Write-Host "Get vCenter Patches updates list" -BackgroundColor Yellow  
#PreCheck VCSA detailed update information - Post
$vamiPreCheckUpdateUrl = "https://$vCenter/api/appliance/update/pending/$($vamiLastestUpdate.version)?action=precheck" 
$vamiPreCheckUpdateAPI = Invoke-WebRequest -Uri $vamiPreCheckUpdateUrl -Method Post -Headers $session -SkipCertificateCheck
ConvertFrom-Json $vamiPreCheckUpdateAPI.Content
$vamiPreCheckUpdateAPI.Content | ConvertFrom-Json | select-object -expandproperty issues

Write-Host "Stage update on vCenter Server" -BackgroundColor Yellow  
$vamiStageUpdateUrl = "https://$vCenter/api/appliance/update/pending/$($vamiLastestUpdate.version)?action=stage" 
$vamiStageUpdateAPI = Invoke-WebRequest -Uri $vamiStageUpdateUrl -Method Post -Headers $session -SkipCertificateCheck
#ConvertFrom-Json $vamiStageUpdateAPI.Content
Start-Sleep -Seconds 600

Write-Host "Check Staged update info on vCenter Server" -BackgroundColor Yellow  
$vamiGetStageUpdateUrl = "https://$vCenter/api/appliance/update/staged" 
$vamiGetStageUpdateAPI = Invoke-WebRequest -Uri $vamiGetStageUpdateUrl -Method Get -Headers $session -SkipCertificateCheck
ConvertFrom-Json $vamiGetStageUpdateAPI.Content

<#
#Working on installation part
Write-Host "Install update on vCenter Server" -BackgroundColor Yellow
# $vamiInstallUpdateRawBody = @'
# {
# 	"user_data": {
# 		"key": "obj-103",
#     "value": "string"
#   }
# }
# '@

$vamiInstallUpdateRawBody = @'
{
  "user_data": { 
    "key": "id",
    "value": "8.0.0.10200"
  }
}
'@
$vamiInstallUpdateBody = $vamiInstallUpdateRawBody | ConvertFrom-Json
$vamiInstallUpdateUrl = "https://$vCenter/api/appliance/update/pending/$($vamiLastestUpdate.version)?action=install" 
$vamiInstallUpdateAPI = Invoke-WebRequest -Uri $vamiInstallUpdateUrl -Method Post -Headers $session -Body $vamiInstallUpdateBody -SkipCertificateCheck
#ConvertFrom-Json $vamiInstallUpdateAPI.Content

#>
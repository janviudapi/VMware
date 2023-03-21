Write-Host "vCenter authentication information" -BackgroundColor Yellow
$vCenter = 'dccomics.vcloud-lab.com'  
$username = 'administrator@vsphere.local'   
$password = '123456'  

Write-Host "Login to vCenter" -BackgroundColor Yellow
Connect-CisServer -Server $vCenter -User $username -Password $password

Write-Host "Get CIS Service for pending updates" -BackgroundColor Yellow
$updateService = Get-CisService -Name "com.vmware.appliance.update.pending"
$availableVersions = $updateService.list("LOCAL_AND_ONLINE")

Write-Host "Get available latest version" -BackgroundColor Yellow
$latestVersion = $availableVersions.version | Sort-Object -Descending | Select-Object -First 1 -ExpandProperty Value

Write-Host "State and install latest version" -BackgroundColor Yellow
$userData = $updateService.help.stage_and_install.user_data.Create()
$userData.add('id', $latestVersion)
$updateService.stage_and_install($latestVersion,$userData)

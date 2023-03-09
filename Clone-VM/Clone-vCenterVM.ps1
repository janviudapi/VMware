#Created By: vcloud-lab.com 
#Owner:  vJanvi
#Clone a Virtual Machine from Template with Customization in VMware vCenter Using PowerCLI

#vCenter Info
$vCenterServer = 'marvel.vcloud-lab.com'
$vCenterUser = 'Administrator@vsphere.local'
$vCenterPassword = 'Computer@123'

#Windows OS customization Spec
$newVMInfo = @(
    @{
        Template = 'Quantumania_Win_22' #'Wakanda_Forever_Win_01'
        OSCustomizationSpec = 'Windows_Customization'
        NewVMName = 'Test003'
        NewVMFolder = 'TempVMs'
        NewVMCluster = 'BiFrost'
        NewVMNetwork = 'VM Network'
        NewVMDataStore = 'StarLord_Datastore01'
        NewVMIPv4 = '192.168.34.90'
        NewVMSubnet = '255.255.255.0'
        NewVMGateway = '192.168.34.1'
        NewVMDNS = @('192.168.34.11', '192.168.34.12')
    },
    @{
        Template = 'Wakanda_Forever_Win_01' 
        OSCustomizationSpec = 'Windows_Customization'
        NewVMName = 'Test002'
        NewVMFolder = 'TempVMs'
        NewVMCluster = 'BiFrost'
        NewVMNetwork = 'VM Network'
        NewVMDataStore = 'StarLord_Datastore01'
        NewVMIPv4 = '192.168.34.91'
        NewVMSubnet = '255.255.255.0'
        NewVMGateway = '192.168.34.1'
        NewVMDNS = @('192.168.34.11', '192.168.34.12')
    }    
)

Import-Module VMware.VimAutomation.Core
Connect-VIServer -Server $vCenterServer -User $vCenterUser -Password $vCenterPassword

foreach ($rawNewVM in $newVMInfo)
{
    # try {
    #     Get-OSCustomizationSpec -Name tempCustom -ErrorAction Stop | Remove-OSCustomizationSpec -Confirm:$false
    # }
    # catch {
    #     <#Do this if a terminating exception happens#>
    # }
     
    $newVM = [PSCustomObject]$rawNewVM
    $cluster = Get-Cluster -Name $newVM.NewVMCluster
    $template = Get-Template -Name $newVM.Template
    $folder = Get-Folder -Name $newVMInfo.NewVMFolder
    #$portGroup = Get-VirtualPortGroup -Name $newVM.NewVMNetwork
    $datastore = Get-Datastore -Name $newVM.NewVMDataStore

    Write-Host "Configuring Customization spec - $($newVM.NewVMName)" - -BackgroundColor DarkYellow
    $specs = Get-OSCustomizationSpec -Name $newVM.OSCustomizationSpec | New-OSCustomizationSpec -Name $rawNewVM.NewVMName -Type NonPersistent
    $tempSpecs = Get-OSCustomizationSpec -Name $specs.Name | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $newVM.NewVMIPv4 -SubnetMask $newVM.NewVMSubnet -DefaultGateway $newVM.NewVMGateway -Dns $newVM.NewVMDNS
    #New-OSCustomizationSpec -Name 'TempWin2019' -FullName 'TestName' -OrgName 'TestOrg' -OSType Windows -ChangeSid -AdminPassword (Read-Host -AsSecureString -Prompt typepassword) -Domain 'vCloud-lab.com' -TimeZone 035 -DomainCredentials (Get-Credential) -ProductKey '1111-1111-1111-1111' -AutoLogonCount 1
    #$tempCustom = Get-OSCustomizationSpec -Name $specs.Name

    $parameters = @{
        Name = $newVM.NewVMName 
        Template = $template 
        Location = $folder 
        ResourcePool = $cluster 
        Datastore = $datastore 
        DiskStorageFormat = 'Thin'
    }

    Write-Host "Creating VM and customizing OS - $($newVM.NewVMName)"  -BackgroundColor DarkYellow
    New-VM @parameters | Select-Object Name, VMHost, PowerState
    Get-VM -Name $newVM.NewVMName | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $newVM.NewVMNetwork -Confirm:$false | Select-Object Parent, Type, NetworkName
    Get-VM -Name $newVM.NewVMName | Set-VM -OSCustomizationSpec $specs.Name -Confirm:$false | Select-Object Name, PowerState, VMHost
    Get-VM -Name $newVM.NewVMName | Start-VM | Select-Object Name, PowerState, VMHost
}

Disconnect-VIServer * -Confirm:$false -Force

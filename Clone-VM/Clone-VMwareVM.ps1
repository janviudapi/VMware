#Created By: vcloud-lab.com 
#Owner:  vJanvi
#Clone a Virtual Machine in VMware vCenter Using PowerCLI

Import-Module VMware.VimAutomation.Core
$currenPath = Split-Path -parent $MyInvocation.MyCommand.Definition #$PSScriptRoot
$vcCreds = Get-Content $currenPath\vCenterCredentials.json | ConvertFrom-Json
Connect-VIServer -Server $vcCreds.Server -User $vcCreds.User -Password $vcCreds.Password
$newVMInfo = Import-Csv -Path $currenPath\VM_Data.csv

foreach ($rawNewVM in $newVMInfo)
{
    $newVM = [PSCustomObject]$rawNewVM
    $cluster = Get-Cluster -Name $newVM.NewVMCluster
    $template = Get-Template -Name $newVM.Template
    $folder = Get-Folder -Name $newVMInfo.NewVMFolder
    #$portGroup = Get-VirtualPortGroup -Name $newVM.NewVMNetwork
    $datastore = Get-Datastore -Name $newVM.NewVMDataStore

    $parameters = @{
        Name = $newVM.NewVMName 
        Template = $template 
        Location = $folder 
        ResourcePool = $cluster 
        Datastore = $datastore 
        DiskStorageFormat = 'Thin'
        #MemoryGB = $newVM.MemoryGB
        #NumCpu = $newVM.NumCpu
        #CoresPerSocket = $newVM.CoresPerSocket
    }

    Write-Host "Creating VM - $($newVM.NewVMName)" -BackgroundColor DarkGreen
    New-VM @parameters | Select-Object Name, VMHost, PowerState
    $vm = Get-VM -Name $newVM.NewVMName
    $vm | Set-VM -NumCpu $newVM.NumCpu -CoresPerSocket $newVM.CoresPerSocket -MemoryGB $newVM.MemoryGB -Confirm:$false | Select-Object Name, PowerState, NumCpu, CoresPerSocket, MemoryGB
    $vm | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $newVM.NewVMNetwork -Confirm:$false | Select-Object NetworkName, Parent, MacAddress
    $vm | Start-VM | Select-Object Name, VMHost, PowerState
}

Write-Host "Wait for 2 minutes - VM restart in progress" -BackgroundColor DarkRed
Start-Sleep -Seconds 120

foreach ($rawNewVM in $newVMInfo)
{
    $vm = Get-VM -Name $rawNewVM.NewVMName
    $configScript = @"
        New-Item -Path C:\ -Name Temp -ItemType Directory 
        Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
        Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
        Disable-NetAdapterBinding -Name 'Ethernet0' -ComponentID 'ms_tcpip6'
        Get-NetIpAddress -InterfaceAlias Ethernet0 -AddressFamily IPv4 | New-NetIPAddress -IPAddress $($rawNewVM.NewVMIPv4) -PrefixLength $($rawNewVM.NewVMSubnet) -DefaultGateway $($rawNewVM.NewVMGateway) | Select-Object IPAddress, ifIndex
        Set-DnsClientServerAddress -InterfaceAlias Ethernet0 -ServerAddresses "$($rawNewVM.NewVMDNS1), $($rawNewVM.NewVMDNS2)"
        Rename-Computer -NewName $($rawNewVM.NewVMName)
"@
    Write-Host "Configuring VM - $($rawNewVM.NewVMName)" -BackgroundColor DarkRed
    Invoke-VMScript -VM $rawNewVM.NewVMName -ScriptText $configScript -GuestUser $rawNewVM.NewVMUserName -GuestPassword $rawNewVM.NewVMPassword -ScriptType Powershell
    $vm | Restart-VMGuest | Select-Object VM, HostName, State, ToolsVersion
    Write-Host "VM - $($rawNewVM.NewVMName) - Restart in progress - Wait 90 Seconds" -BackgroundColor DarkRed
    Start-Sleep -Seconds 90

    Write-Host "Copy suppliment files to VM - $($rawNewVM.NewVMName)" -BackgroundColor DarkYellow
    "`$userName = '$($rawNewVM.NewVMDomainUserName)'" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1"
    "`$password = '$($rawNewVM.NewVMDomainPassword)'" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "# create secure string from plain-text string" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "`$secureString = ConvertTo-SecureString -AsPlainText -Force -String `$password" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "# convert secure string to encrypted string (for safe-ish storage to config/file/etc.)" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "`$encryptedString = ConvertFrom-SecureString -SecureString `$secureString" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "# convert encrypted string back to secure string" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "`$secureString = ConvertTo-SecureString -String `$encryptedString" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append 
    "# use secure string to create credential object" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "`$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList `$userName,`$secureString" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append
    "Add-Computer -DomainName $($rawNewVM.NewVMDomain) -Credential `$credential #-Restart -Force" | Out-File -FilePath "$currenPath\Suppliments\Join-Domain.ps1" -Append

    Copy-VMGuestFile -Source $PSScriptRoot\Suppliments\Join-Domain.ps1 -Destination c:\temp\ -VM $vm -LocalToGuest -GuestUser $rawNewVM.NewVMUserName -GuestPassword $rawNewVM.NewVMPassword #-GuestCredential
    Start-Sleep -Seconds 5

    $domainJoinScriptText = @"
        & 'C:\temp\Join-Domain.ps1'
"@
    Write-Host "Adding VM $($rawNewVM.NewVMName) to domain - Restarting VM - wait 90 Seconds" -BackgroundColor DarkYellow
    Invoke-VMScript -VM $rawNewVM.NewVMName -ScriptText $domainJoinScriptText -GuestUser $rawNewVM.NewVMUserName -GuestPassword $rawNewVM.NewVMPassword -ScriptType Powershell
    Start-Sleep -Seconds 5
    $vm | Restart-VMGuest | Select-Object VM, HostName, State, ToolsVersion
    Start-Sleep -Seconds 90
    
    $deleteFileText = @"
    Remove-Item -Path 'C:\temp\Join-Domain.ps1' -Force
"@
    Write-Host "Configuration of VM $($rawNewVM.NewVMName) completed - Removing suppliment files" -BackgroundColor DarkGreen
    Invoke-VMScript -VM $rawNewVM.NewVMName -ScriptText $deleteFileText -GuestUser $rawNewVM.NewVMUserName -GuestPassword $rawNewVM.NewVMPassword -ScriptType Powershell
}

Disconnect-VIServer * -Confirm:$false -Force
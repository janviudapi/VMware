#Load required libraries
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing 

#Website: http://vcloud-lab.com
#Written By: vJanvi
#Date: 20 May 2021
#Tested Environment:
    #Microsoft Windows 10
    #PowerShell Version 5.1
    #PowerCLI Version 12.2.0
    #Esxi offline bundle ESXi 7.0
    #vSphere 7
    #Dell drivers for Esxi version 7

#Read xaml file
#$xamlFile = 'D:\Projects\PowerShell\WPF\Esxi_patch\Esxi_patch\MainWindow.xaml'
$xamlContent = @'
<Window x:Class="Esxi_patch.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:Esxi_patch"
        mc:Ignorable="d"
        Title="ESXi Patch Bundle Builder - http://vcloud-lab.com" Height="616" Width="996" ResizeMode="NoResize">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
            <ColumnDefinition Width="120"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="40"/>
            <RowDefinition Height="*"/>
        </Grid.RowDefinitions>
        <TextBlock x:Name="patchBundleTextBlock" HorizontalAlignment="Center" Margin="0,10,0,0" Text="Patch Bundle:" TextWrapping="Wrap" VerticalAlignment="Top" Width="100" Grid.Row="0"/>
        <TextBlock x:Name="imageProfilesTextBlock" HorizontalAlignment="Center" Margin="0,10,0,0" Text="Image Profiles:" TextWrapping="Wrap" VerticalAlignment="Top" Width="100" Grid.Row="1"/>
        <TextBox x:Name="patchBundleTextBox" Grid.Column="1" Margin="10,0,10,0" Text="Type ESXi patch bundle with path" TextWrapping="Wrap" VerticalAlignment="Center" Grid.ColumnSpan="3"/>
        <ComboBox x:Name="imageProfilesComboBox" Grid.Column="1" Margin="10,9,10,10" Text="Image Patch name" Grid.ColumnSpan="3" Grid.Row="1"/>
        <Button x:Name="addDepotButton" Content="Add Depot" Grid.Column="4" HorizontalAlignment="Center" VerticalAlignment="Center" Width="100"/>
        <Button x:Name="getProfilesButton" Content="Get Profiles" Grid.Column="4" HorizontalAlignment="Center" Width="100" Grid.Row="1" Margin="0,9,0,11" IsEnabled="False"/>
        <GroupBox x:Name="addremoveVIBsGroupBox" Header="Add or Remove VIBs" Grid.Row="2" Margin="10,10,10,10" Grid.ColumnSpan="5" Grid.RowSpan="8">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition/>
                </Grid.ColumnDefinitions>
                <CheckBox x:Name="net_mlx4_en_checkBox" Content="net-mlx4-en" Margin="17,10,427,247" IsChecked="True" Height="20"/>
                <CheckBox x:Name="net_mlx4_core_checkBox" Content="net-mlx4-core" Margin="17,33,427,224" IsChecked="True" Height="20" Width="124"/>
                <CheckBox x:Name="nmlx4_core_checkBox" Content="nmlx4-core" Margin="17,58,427,199" IsChecked="True" Height="20"/>
                <CheckBox x:Name="nmlx4_en_checkBox" Content="nmlx4-en" Margin="17,83,427,174" IsChecked="True" Height="20"/>
                <CheckBox x:Name="nmlx4_rdma_checkBox" Content="nmlx4-rdma" Margin="17,108,427,149" IsChecked="True" Height="20" Width="124"/>
                <CheckBox x:Name="ipfc_checkBox" Content="ipfc" Margin="17,133,427,124" IsChecked="True" Height="20" Width="124"/>
                <CheckBox x:Name="lsi_checkBox" Content="lsi" Margin="17,158,427,99" IsChecked="True" Height="20"/>
                <CheckBox x:Name="net_tg3_checkBox" Content="net-tg3" Margin="17,183,427,74" IsChecked="True" Height="20" Width="124"/>
                <CheckBox x:Name="net_ixgbe_checkBox" Content="net-ixgbe" Margin="169,10,275,247" IsChecked="True" Height="20" Width="124"/>
                <CheckBox x:Name="net_igb_checkBox" Content="net-igb" Margin="169,33,242,224" IsChecked="True" Height="20"/>
                <CheckBox x:Name="net_bnx2x_checkBox" Content="net-bnx2x" Margin="169,58,242,199" IsChecked="True" Height="20"/>
                <CheckBox x:Name="lsu_lsi_lsi_mr3_plugin_checkBox" Content="lsu_lsi_lsi_mr3_plugin" Margin="169,83,242,174" IsChecked="True" Height="20"/>
                <CheckBox x:Name="elxnet_checkBox" Content="elxnet" Margin="169,108,242,149" IsChecked="True" Height="20"/>
                <CheckBox x:Name="scsi_hpsa_checkBox" Content="scsi-hpsa" Margin="169,133,242,124" IsChecked="True" Height="20"/>
                <CheckBox x:Name="tools_light_checkBox" Content="tools-light" Margin="169,158,242,99" IsChecked="True" Height="20"/>
                <TextBox x:Name="removeVibstextBox" Margin="10,208,275,10" Text="Type additional VIB names to remove, each on newline" TextWrapping="Wrap" AcceptsReturn="True"/>
                <Slider x:Name="slider" HorizontalAlignment="Left" Margin="326,10,0,10" Width="20" Orientation="Vertical" IsEnabled="False"/>
                <TextBox x:Name="addVIBsTextBox" Height="20" Margin="351,10,10,247" Text="Add VIB File" TextWrapping="Wrap"/>
                <Button x:Name="addVIBbutton" Content="Add VIB" Margin="454,35,10,222" Height="20" IsEnabled="False"/>
                <TextBox x:Name="addedVibstextBox" Margin="351,60,10,10" Text="No VIB drivers or softwares added" TextWrapping="Wrap" IsReadOnly="True"/>

            </Grid>
        </GroupBox>
        <TextBlock x:Name="LogstextBlock" Grid.Column="5" HorizontalAlignment="Left" Margin="11,10,0,0" Text="Logs" TextWrapping="Wrap" VerticalAlignment="Top"/>
        <TextBox x:Name="logTextBox" Grid.Column="5" Margin="10,10,-110,10" Text="Logs" TextWrapping="Wrap" Grid.RowSpan="9" Grid.ColumnSpan="2" IsReadOnly="True" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" Grid.Row="1"/>
        <TextBlock x:Name="vendorNameTextBlock" Margin="10,10,10,10" Grid.Row="10" Text="Vendor Name:" TextWrapping="Wrap"/>
        <TextBlock x:Name="newProfileNamesTextBlock" Margin="10,10,10,10" Grid.Row="11" Text="New Profile Name:" TextWrapping="Wrap"/>
        <TextBox x:Name="venderNameTextBox" Margin="10,10,10,10" Grid.Row="10" Text="vcloud-lab-engineering-virutalization" TextWrapping="Wrap" Grid.Column="1" Grid.ColumnSpan="3" IsReadOnly="True"/>
        <TextBox x:Name="newProfileNameTextBox" Margin="10,10,10,10" Grid.Row="11" Text="vcloud-lab-engineering-virutalization" TextWrapping="Wrap" Grid.Column="1" Grid.ColumnSpan="3" IsReadOnly="True"/>
        <TextBlock x:Name="acceptanceLevelTextBlock" Margin="10,10,10,10" Grid.Row="10" Text="Acceptance Level:" TextWrapping="Wrap" Grid.Column="4"/>
        <ComboBox x:Name="acceptanceLevelComboBox" Grid.Column="5" Margin="10,8,-110,8" Text="Image Patch name" Grid.ColumnSpan="2" Grid.Row="10" SelectedIndex="1">
            <ComboBoxItem Content="CommunitySupported"/>
            <ComboBoxItem Content="PartnerSupported"/>
            <ComboBoxItem Content="VMwareAccepted"/>
            <ComboBoxItem Content="VMwareCertified"/>
        </ComboBox>
        <RadioButton x:Name="zipRadioButton" Content="Zip File" Grid.Column="4" HorizontalAlignment="Left" Margin="10,0,0,0" Grid.Row="11" VerticalAlignment="Center" IsChecked="True"/>
        <RadioButton x:Name="isoRadioButton" Content="ISO File" Grid.Column="5" HorizontalAlignment="Left" Margin="10,0,0,0" Grid.Row="11" VerticalAlignment="Center"/>
        <Button x:Name="exportBundleButton" Content="Export File" Grid.Column="6" Margin="117,5,-110,0" Grid.Row="11" VerticalAlignment="Top" IsEnabled="False" Width="113"/>
        <Button x:Name="getNewVIBListButton" Content="Get new bundle VIB list CSV" Grid.ColumnSpan="2" Margin="10,10,10,10" Grid.Row="13" IsEnabled="False"/>
        <Button x:Name="getFileHashListButton" Content="Get-FileHash" Margin="10,10,10,10" Grid.Row="13" Grid.Column="2" IsEnabled="False"/>
        <TextBlock x:Name="ProcessTextBlock" Grid.Column="6" Margin="10,10,37,10" Grid.Row="12" Text="Progress" TextWrapping="Wrap" Height="20"/>
        <ProgressBar x:Name="progressBar" Grid.Column="6" Margin="88,10,-110,10" Grid.Row="12"/>
        <!-- -->
    </Grid>
</Window>
'@

#$xamlContent = Get-Content -Path $xamlFile -ErrorAction Stop
#[xml]$xaml = $xamlContent -replace 'mc:Ignorable="d"', '' -replace "x:N", 'N' -replace 'x:Class=".*?"', '' -replace 'd:DesignHeight="\d*?"', '' -replace 'd:DesignWidth="\d*?"', ''
[xml]$xaml = $xamlContent -replace 'x:Class=".*?"', '' -replace 'xmlns:d="http://schemas.microsoft.com/expression/blend/2008"', '' -replace 'mc:Ignorable="d"', ''

#Read the forms in xaml
$reader = (New-Object System.Xml.XmlNodeReader $xaml) 
$form = [Windows.Markup.XamlReader]::Load($reader) 

#AutoFind all controls
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { 
    New-Variable  -Name $_.Name -Value $form.FindName($_.Name) -Force 
}

Function Confirm-Powercli
{
	$AllModules = Get-Module -ListAvailable VMware.PowerCLI
	if (!$AllModules)
	{
		Show-MessageBox -Message "Install VMware Powercli 12.0 or Latest. `n`nUse either 'Install-Module VMware.VimAutomation.Core' `nor download Powercli from 'http://my.vmware.com'" -Title 'VMware Powercli Missing error' | Out-Null
	}
	else
	{
		Import-Module VMware.PowerCLI
		$PowercliVer = Get-Module -ListAvailable VMware.VimAutomation.Core | Select-Object -First 1
		$ReqVersion = New-Object System.Version('12.0.0.0')
		if ($PowercliVer.Version -gt $ReqVersion)
		{
			$logTextBox.Text = ''
			$logTextBox.AppendText("VMware PowerCLI Version: $($PowercliVer.Version).`r`n")
            $logTextBox.AppendText("$('-' * 65)`r`n")
			#$textboxLogs.Text = "VMware PowerCLI Version: $($PowercliVer.Version)"
            $progressBar.Value = 10
		}
		else
		{
			Show-MessageBox -Message "Install VMware Powercli 6.0 or Latest. `n`nUse either 'Install-Module VMware.VimAutomation.Core' `nor download Powercli from 'http://my.vmware.com'" -Title 'Lower version Powercli' | Out-Null
		}
	}
}

function Show-MessageBox
{
	param (
		[string]$Message = "Show user friendly Text Message",
		[string]$Title = 'Title here',
		[ValidateRange(0, 5)]
		[Int]$Button = 0,
		[ValidateSet('None', 'Hand', 'Error', 'Stop', 'Question', 'Exclamation', 'Warning', 'Asterisk', 'Information')]
		[string]$Icon = 'Error'
	)
	#Note: $Button is equl to [System.Enum]::GetNames([System.Windows.Forms.MessageBoxButtons])   
	#Note: $Icon is equl to [System.Enum]::GetNames([System.Windows.Forms.MessageBoxIcon])   
	$MessageIcon = [System.Windows.Forms.MessageBoxIcon]::$Icon
	[System.Windows.Forms.MessageBox]::Show($Message, $Title, $Button, $MessageIcon)
}

function Open-FileDialog 
{
	param (
		[string]$Path = [Environment]::GetFolderPath('Desktop')
    )
    $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = $Path
        Filter = 'zip (*.zip)|*.zip'
    }
    $null = $fileBrowser.ShowDialog()
    $fileBrowser.FileName
}

Confirm-Powercli

$path = [Environment]::GetFolderPath('Desktop')
$addDepotButton.Add_click({
    Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot -ErrorAction SilentlyContinue
    $patchBundleTextBox.Text = $null
    $esxiPatchBundle = Open-FileDialog -Path $path
    $patchBundleTextBox.Text = $esxiPatchBundle
	if (($esxiPatchBundle -eq $null) -or ($esxiPatchBundle -eq ''))
	{
		Show-MessageBox -Message 'Choose correct ESXi zip patch bundle' -Title 'Error - Select correct zip bundle'
		$logTextBox.AppendText("Error: Select correct zip bundle.`r`n")
        $logTextBox.AppendText("$('-' * 65)`r`n")
	}
	else
	{
		if (Test-path -Path $patchBundleTextBox.Text)
		{
            try 
            {
            	$softwareDepot = Add-EsxSoftwareDepot -DepotUrl $patchBundleTextBox.Text #-ErrorAction Stop
			    $logTextBox.AppendText("Zip Path: $($patchBundleTextBox.Text).`r`n")
			    $logTextBox.AppendText("Added Depot Url: $($softwareDepot.DepotUrl).`r`n")
                $logTextBox.AppendText("$('-' * 65)`r`n")
			    $getProfilesButton.IsEnabled = $true
                $progressBar.Value = 20
                $patchBundleTextBox.IsReadOnly = $true
            }
            catch
            {
                Show-MessageBox -Message 'Selected ESXi bundle is not valid!' -Title 'Error - Select correct zip bundle'
                $logTextBox.AppendText("Error: Selected ESXi bundle is not valid!.`r`n")
                $logTextBox.AppendText("$('-' * 65)`r`n")
                $addDepotButton.IsEnabled = $true
            }
		}
		else
		{
			Show-MessageBox -Message 'Choose correct ESXi zip patch bundle' -Title 'Error - Select correct zip bundle'
			$logTextBox.AppendText("Error: Choose correct ESXi zip patch bundle.`r`n")
            $logTextBox.AppendText("$('-' * 65)`r`n")
            $addDepotButton.IsEnabled = $true
		}
	}
})

$getProfilesButton.Add_Click({
    $global:ImageProfiles = Get-EsxImageProfile
	$esxiProfile = $ImageProfiles.Name | Where-Object { $_ -match '-no-tools' } | Sort-Object Length -Descending | Select-Object -First 1
	#Update-ComboBox $imageProfilesComboBox -Items $imageProfiles.Name
    $imageProfilesComboBox.ItemsSource = $imageProfiles.Name
    $imageProfilesComboBox.SelectedIndex = $imageProfilesComboBox.items.IndexOf(1)
	
	$imageProfilesComboBox.Text = $esxiProfile
	$logTextBox.AppendText("Selected Esxi Profile: $esxiProfile.`r`n")
    $logTextBox.AppendText("$('-' * 65)`r`n")
	$getProfilesButton.IsEnabled = $false
	
	$exportBundleButton.IsEnabled = $true
	$newProfileNameTextBox.IsReadOnly = $false
    $progressBar.Value = 30
    $logTextBox.ScrollToEnd()
    $addVIBbutton.IsEnabled = $true
    $venderNameTextBox.IsReadOnly = $false
    $newProfileNameTextBox.IsReadOnly = $false
})

$global:AddedVIBList = @()
$addVIBbutton.Add_Click({
    #$allDriverPackages = $addedVibstextBox.Text
    #$addVIBsTextBox.Text = $null
    $esxiVIBDrivers = Open-FileDialog -Path $path
    $addVIBsTextBox.Text = $esxiVIBDrivers
    if ($addedVibstextBox.Text -eq 'No VIB drivers or softwares added')
    {
        $addedVibstextBox.Text = $null
    }
    if ($(Test-Path $addVIBsTextBox.Text -ErrorAction SilentlyContinue) -eq $true)
    {
        try
        {
            $driverDepot = Add-EsxSoftwareDepot $addVIBsTextBox.Text -ErrorAction Stop
            $packages = $driverDepot | Get-EsxSoftwarePackage
            foreach ($package in $packages)
            {
                $AddedVIBList += $package.Name + "`n"
                $logTextBox.AppendText("Added package name: $($package.Name)`r`n")
            }
            $addedVibstextBox.Text += $AddedVIBList
        }
        catch
        {
            Show-MessageBox -Message 'Selected VIB Software/Drivers is not valid!' -Title 'Error - Select correct zip bundle'
            $logTextBox.AppendText("Error: Selected VIB Software/Drivers is not valid.`r`n")
        }
        $logTextBox.AppendText("$('-' * 25)`r`n")
    }
    $logTextBox.ScrollToEnd()
})

$exportBundleButton.Add_Click({
    $groupChildern = $addremoveVIBsGroupBox.Content.Children
    $allCheckBoxes = $groupChildern | Where-Object {$_.name -match 'checkBox'}
    $unwantedVIBList =  $allCheckBoxes | Where-Object {$_.IsChecked -eq $true} | Select-Object -ExpandProperty Content
   
	if ($removeVibstextBox.Text -ne 'Type additional VIB names to remove, each on newline')
	{
		$unwantedVIBList += $removeVibstextBox.Text -split "`r`n"
	}
    $logTextBox.AppendText("VIBs will be removed:- $($unwantedVIBList -Join ', ')`r`n")
	$exportBundleButton.IsEnabled = $true
    $logTextBox.AppendText("$('-' * 65)`r`n")

	$selectedImageProfile = $ImageProfiles | Where-Object {$_.Name -eq $imageProfilesComboBox.Text}
    $global:NewVIBList = $selectedImageProfile.Viblist | Where-Object {$_.Name -notin $unwantedVIBList} | Sort-Object -Property Name

	$logTextBox.AppendText("Total VIBs count in New Patch Bundle: $($NewVIBList.Count).`r`n")
    $logTextBox.AppendText("$('-' * 30)`r`n")

	$logTextBox.AppendText("VIB Name :- VIB Version`r`n")
	foreach ($vib in $NewVIBList)
	{
        $vibName = $vib.Name
        $vibVersion = $vib.Version
		$logTextBox.AppendText("$vibName :- $vibVersion`r`n")
	}
    $logTextBox.AppendText("$('-' * 65)`r`n")
    $progressBar.Value = 50
    #########################################################

    $logTextBox.AppendText("Typed Profile Name: $($newProfileNameTextBox.Text).`r`n")
    $logTextBox.AppendText("$('-' * 65)`r`n")

	$global:BundlePath = Split-Path $patchBundleTextBox.Text -Parent
	$newImage = New-EsxImageProfile -NewProfile $newProfileNameTextBox.Text -SoftwarePackage $NewVIBList -Vendor $venderNameTextBox.Text -AcceptanceLevel $acceptanceLevelComboBox.Text
    
    if (($addedVibstextBox.Text -ne 'No VIB drivers or softwares added') -or ($addedVibstextBox.Text -ne '') -or ($addedVibstextBox.Text -ne $null))
    {
        foreach ($driverVIB in $(($addedVibstextBox.Text -split "`n").trim() | Where-Object {$_ -ne ''}))
        {
            if ($driverVIB -ne $null)
            {
                Add-EsxSoftwarePackage -ImageProfile $newProfileNameTextBox.Text -SoftwarePackage $driverVIB #-ErrorAction SilentlyContinue
            }
        }
    }
	if ($zipRadioButton.IsChecked -eq $true)
	{
		Export-EsxImageProfile -ImageProfile $newProfileNameTextBox.Text -ExportToBundle -FilePath "$bundlePath\$($newProfileNameTextBox.Text).zip" -Force
    	$logTextBox.AppendText("Esxi Zip bundle path: $BundlePath\$($newProfileNameTextBox.Text).zip.`r`n")
        $logTextBox.AppendText("$('-' * 65)`r`n")
        $progressBar.Value = 90
        $global:bundleFile = "$BundlePath\$($newProfileNameTextBox.Text).zip"
	}
	else
	{
		Export-EsxImageProfile -ImageProfile $newProfileNameTextBox.Text -ExportToISO -FilePath "$BundlePath\$($newProfileNameTextBox.Text).iso" -Force
        $logTextBox.AppendText("Esxi Iso path: $BundlePath\$($newProfileNameTextBox.Text).iso.`r`n")
        $logTextBox.AppendText("$('-' * 65)`r`n")
        $progressBar.Value = 90
        $global:bundleFile = "$BundlePath\$($newProfileNameTextBox.Text).iso"
	}
    $logTextBox.ScrollToEnd()
    $progressBar.Value = 100
    Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot -ErrorAction SilentlyContinue

    $addVIBbutton.IsEnabled = $false
    $venderNameTextBox.IsReadOnly = $true
    $newProfileNameTextBox.IsReadOnly =  $true
    $exportBundleButton.IsEnabled = $false

    $getNewVIBListButton.IsEnabled = $true
    $getFileHashListButton.IsEnabled = $true
})

$getNewVIBListButton.Add_Click({
    $progressBar.Value = 1
    Get-EsxSoftwareDepot | Remove-EsxSoftwareDepot -ErrorAction SilentlyContinue
    $newSoftwareDepot = Add-EsxSoftwareDepot -DepotUrl $bundleFile
    $newPackageList =  $newSoftwareDepot | Get-EsxSoftwarePackage -ErrorAction Silently | Sort-Object Name
    $newPackageList | Export-Csv "$bundlePath\$($newProfileNameTextBox.Text).csv" -NoTypeInformation
    $logTextBox.AppendText("New Bundle Pacakge list csv: $BundlePath\$($newProfileNameTextBox.Text).csv.`r`n")
    $logTextBox.AppendText("$('-' * 65)`r`n")
    $progressBar.Value = 100
    $logTextBox.ScrollToEnd()
})

$getFileHashListButton.Add_Click({
    $progressBar.Value = 1
    $fileHashMD5 = Get-FileHash $bundleFile -Algorithm MD5
    $fileHashSHA256 = Get-FileHash $bundleFile -Algorithm SHA256
    $logTextBox.AppendText("MD5: $($fileHashMD5.Hash).`r`n")
    $logTextBox.AppendText("SHA256: $($fileHashSHA256.Hash).`r`n")
    $logTextBox.AppendText("$('-' * 65)`r`n")
    $progressBar.Value = 100
    $logTextBox.ScrollToEnd()
})

[void]$form.ShowDialog()


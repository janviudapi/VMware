function Set-WbemServiceEsxi {
    <#
    .SYNOPSIS
        Disable then enable Wbem service on ESXi Server.
    .DESCRIPTION
        Set-WbemServiceEsxi - Disable then enable Wbem service on ESXi Server. It uses esxcli command to set service
    .PARAMETER ClusterName
        Prompts you to provide cluster name in vCenter server.
    .INPUTS
        System.String
    .OUTPUTS
        System.Object
    .NOTES
        Version:        2.0
        Author:         Janvi
        Creation Date:  10 September 2021
        Purpose/Change: Disable then enable Wbem service on ESXi Server.
        Useful URLs: http://vcloud-lab.com
    .EXAMPLE
        PS C:\>Set-WbemServiceEsxi -ClusterName 'Bat_Cave'
        Disable then enable Wbem service on ESXi Server.
    #>

    # Parameter help description
    [CmdletBinding(HelpUri='http://vcloud-lab.com')]
    [Alias("wbem")]
    param (
        [Parameter(HelpMessage='Type Cluster Name')]
        [Alias('cluster')]
        [System.String]$ClusterName
    )
   
    $esxiServers = Get-Cluster -Name $ClusterName | Get-VMHost -State Connected, Maintenance

    foreach ($esxi in $esxiServers)
    {
        
        $esxcli = $esxi | Get-EsxCLI -V2
        $wbemArgs = $esxcli.system.wbem.set.CreateArgs()
        $wbemArgs.enable = $false
        $disable = $esxcli.system.wbem.set.Invoke($wbemArgs)
        "{0} -->`t`tDisabled: {1} " -f $esxi.Name.PadRight(35, ' '), $disable
        $wbemArgs = $esxcli.system.wbem.set.CreateArgs()
        $wbemArgs.enable = $true
        $enable = $esxcli.system.wbem.set.Invoke($wbemArgs)
        "{0} -->`t`tEnabled: {1} " -f $esxi.Name.PadRight(35, ' '), $enable
    }
}

#Import-Module Vmware.VimAutomation.core
#Connect-VIServer -Server dccomics.vcloud-lab.com -User Administrator@vsphere.local -Password Computer@123

Set-WbemServiceEsxi -ClusterName bat_cave
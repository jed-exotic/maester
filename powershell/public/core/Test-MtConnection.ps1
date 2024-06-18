﻿<#
.SYNOPSIS
   Checks if the current session is connected to the specified service. Use -Verbose to see the connection status for each service.

.DESCRIPTION
    Tests the connection for each service and returns $true if the session is connected to the specified service.

.EXAMPLE
    Test-MtConnection

    Checks if the current session is connected to Microsoft Graph.

.EXAMPLE
    Test-MtConnection -Service All

    Checks if the current session is connected to all services including Azure, Exchange and Microsoft Graph.
#>
Function Test-MtConnection {
    [CmdletBinding()]
    param(
        # Checks if the current session is connected to the specified service
        [ValidateSet("All", "Azure", "ExchageOnline", "Graph")]
        [Parameter(Position = 0, Mandatory = $false)]
        [string[]]$Service = "Graph"
    )

    $connectionState = $true

    if ($Service -contains "Azure" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne (Get-AzContext -ErrorAction SilentlyContinue)
        } catch {
            Write-Debug "Azure: $false"
        }
        Write-Verbose "Azure: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    if ($Service -contains "ExchageOnline" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne ((Get-ConnectionInformation | Where-Object { $_.Name -match 'ExchangeOnline' -and $_.state -eq 'Connected' }))
        } catch {
            Write-Debug "Exchange Online: $false"
        }
        Write-Verbose "Exchange Online: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    if ($Service -contains "Graph" -or $Service -contains "All") {
        $isConnected = $false
        try {
            $isConnected = $null -ne (Get-MgContext -ErrorAction SilentlyContinue)
        } catch {
            Write-Debug "Graph: $false"
        }
        Write-Verbose "Graph: $isConnected"
        if (!$isConnected) { $connectionState = $false }
    }

    Write-Output $connectionState
}
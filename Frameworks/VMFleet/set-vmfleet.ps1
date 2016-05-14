<#
DISKSPD - VM Fleet

Copyright(c) Microsoft Corporation
All rights reserved.

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
#>

param( [int] $ProcessorCount,
       [int64] $MemoryStartupBytes,
       [int64] $MemoryMaximumBytes = 0,
       [int64] $MemoryMinimumBytes = 0,
       [switch]$DynamicMemory = $true )

if ($MemoryMaximumBytes -eq 0) {
    $MemoryMaximumBytes = $MemoryStartupBytes
}
if ($MemoryMinimumBytes -eq 0) {
    $MemoryMinimumBytes = $MemoryStartupBytes
}

$g = Get-ClusterGroup |? Name -ilike vm-* | group -Property OwnerNode -NoElement

icm ($g.Name) -ArgumentList $ProcessorCount,$MemoryStartupBytes,$MemoryMaximumBytes,$MemoryMinimumBytes,$DynamicMemory {

    param( [int] $ProcessorCount,
           [int64] $MemoryStartupBytes,
           [int64] $MemoryMaximumBytes,
           [int64] $MemoryMinimumBytes,
           [boolean]$DynamicMemory )

    Get-ClusterGroup |? Name -ilike vm-* |? OwnerNode -eq $env:COMPUTERNAME |% {

        $memswitch = '-DynamicMemory'
        if (-not $DynamicMemory) {
            $memswitch = '-StaticMemory'
        }

        if ($_.State -ne 'Offline') {
            write-host -ForegroundColor Yellow Cannot alter VM sizing on running VMs "($($_.Name))"
        } else {
            iex "Set-VM -ComputerName $($_.OwnerNode) -Name $($_.Name) -ProcessorCount $ProcessorCount -MemoryStartupBytes $MemoryStartupBytes -MemoryMinimumBytes $MemoryMinimumBytes -MemoryMaximumBytes $MemoryMaximumBytes $memswitch"
        }
    }
}

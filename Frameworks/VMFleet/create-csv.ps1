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
param(
    [string[]]$nodes = @()
    [string]$storagepool = $null
    )

if (Get-ClusterNode |? State -ne Up) {
    throw "not all cluster nodes are up; please address before creating vmfleet"
}

# if no nodes specified, use the entire cluster
if ($nodes.count -eq 0) {
    $nodes = Get-ClusterNode
}

# if storage pool not specified use default pool
if ($storagepool -eq $null){
	$storagepool = get-storagepool "S2D *"
	if ($storagepool -eq $null){
		throw "No Storage Pool found"
	}
} else {
	$storagepool = get-storagepool $storagepool
}

# Create the fleet CSVs
icm $nodes {
	New-Volume -StoragePoolFriendlyName $storagepool.FriendlyName -FriendlyName $env:computername -FileSystem CSVFS_ReFS -Size 1TB
}

# Create collect CSV
icm $nodes[-1] {
	New-Volume -StoragePoolFriendlyName $storagepool.FriendlyName -FriendlyName collect -FileSystem CSVFS_ReFS -Size 1TB
}
#Declerations
$resourceGroup = "codesizzlerrg"
$location = "SouthIndia"

#Creating new RG
New-AzureRmResourceGroup -Name $resourceGroup -Location $location

#Creating storage account
$storageAccount = New-AzureRmStorageAccount -ResourceGroupName $resourceGroup -Name "storage1541"  -Location $location  -SkuName Standard_LRS  -Kind Storage 

#Creating Context for storage account
$ctx = $storageAccount.Context

#creating Container
$containerName = "howtoblobs"
New-AzureStorageContainer -Name $containerName -Context $ctx -Permission container


#Uploding blob to container
$path = "C:\Users\kishore\Desktop\codesizzler.png"
Set-AzureStorageBlobContent -File $path -Container howtoblobs -Context $ctx

#Listing available containers
Get-AzureStorageBlob -Container howtoblobs -Context $ctx

#Reading and writing blob data
$blobName = "codesizzler.png"
$blob = Get-AzureStorageBlob -Context $ctx -Container howtoblobs -Blob $blobName

$cloudBlockBlob = [Microsoft.WindowsAzure.Storage.Blob.CloudBlockBlob] $blob.ICloudBlob

Write-Host "Blob type = " $cloudBlockBlob.BlobType
Write-Host "Blob Name = " $cloudBlockBlob.Name
Write-Host "Blob Uri = " $cloudBlockBlob.Uri

#Getting properties of blobs
$cloudBlockBlob.FetchAttributes()
Write-Host "Content type = " $cloudBlockBlob.Properties.ContentType
Write-Host "Size = " $cloudBlockBlob.Properties.Length

#Changing properties of blob content type
$contentType = "image/jpg"
$cloudBlockBlob.Properties.ContentType = $contentType
$cloudBlockBlob.SetProperties()

#Getting changed properties of blobs
$cloudBlockBlob.FetchAttributes()
Write-Host "Content type = " $cloudBlockBlob.Properties.ContentType

#Setting blob level access to private
Set-AzureStorageContainerAcl -Name howtoblobs -Context $ctx -Permission private 

#Creating a SAS URI with expiry time
$starttime = Get-Date
$endtime = $starttime.AddMinutes(1.0)
$SASURI = New-AzureStorageBlobSASToken -Container howtoblobs -Blob codesizzler.png -Context $ctx -Permission "rwd" -StartTime $starttime -ExpiryTime $endtime -FullUri 
Write-Host "URL with SAS = " $SASURI

#Copying blobs - Simple blob copy
$blobName = "codesizzler.png"
$newblobname = "copy of " + $blobName
Start-AzureStorageBlobCopy -SrcBlob $blobName -SrcContainer howtoblobs -DestContainer howtoblobs -DestBlob $newblobname -Context $ctx

#Verifying the copied blob
Get-AzureStorageBlob -Container howtoblobs -Context $ctx

#Copying Blob to different storage account
#Creating storage account
$storageAccount2 = New-AzureRmStorageAccount -ResourceGroupName codesizzlerrg -Name "storage1575"  -Location southindia  -SkuName Standard_LRS  -Kind Storage `

#Creating Context for storage account
$ctx2 = $storageAccount2.Context

#creating Container
$containerName = "newblob"
New-AzureStorageContainer -Name $containerName -Context $ctx2 -Permission container

#Performing copy operation
Start-AzureStorageBlobCopy -SrcBlob codesizzler.png -SrcContainer howtoblobs -DestContainer newblob -DestBlob copiedblob -SrcContext $ctx -DestContext $ctx2

#Verifying the copied blob
Get-AzureStorageBlob -Container newblob -Context $ctx2

#Copying Very large files in between storage accounts Asynchronously
$blobresult = Start-AzureStorageBlobCopy -SrcBlob codesizzler.MKV -SrcContainer howtoblobs -DestContainer newblob -DestBlob copy_codesizzler.mkv -SrcContext $ctx -DestContext $ctx2 -Verbose

#Getting the copying status 
$status = $blobresult | Get-AzureStorageBlobCopyState
$status

#Verifying the copied blob
Get-AzureStorageBlob -Container newblob -Context $ctx2

#Removing blob
Remove-AzureStorageBlob -Container newblob -Blob copy_codesizzler.mkv -Context $ctx2
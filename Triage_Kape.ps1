<#
.DESCRIPTION
The purpose of this script is to download Kape from AWS S3, triage the Client's endpoint, and upload results to AWS S3.

Version:            1
Author:             Mike Dunn
Creation Date       September 2022
#>

$AccessKey = "ACCESS KEY GOES HERE"
$SecretKey = "SECRET KEY GOES HERE"
$Bucket = "NAME OF BUCKET"
$Object = "NAME OF FILE/FOLDER IN AWS"
$Folder = "NAME OF FOLDER TO UPLOAD RESULTS"
$Hostname = hostname
 
 function Create_Folders{
    New-Item -Path C:\Windows\Temp -Name Triage -ItemType Directory
    New-Item -Path C:\Windows\Temp\Triage -Name Image -ItemType Directory
}

function Install_AWS{
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
    Install-PackageProvider -Name Nuget -MinimumVersion 2.8.5.201 -Force
    Find-Module -Name AWSPowerShell | Save-Module -Path "C:\Program Files\WindowsPowerShell\Modules"
    Import-Module AWSPowerShell
}

function Download_File{
    Set-AWSCredential -AccessKey $AccessKey -SecretKey $SecretKey -StoreAs Triage
    Initialize-AWSDefaultConfiguration -ProfileName Triage -Region us-east-1
    cd C:\Windows\Temp\Triage
    Read-S3Object -BucketName $Bucket -Key $Object -File KAPE.zip
}

function Kape{
    Expand-Archive -Path C:\Windows\Temp\Triage\KAPE.zip -DestinationPath C:\Windows\Temp\Triage
    cd C:\Windows\Temp\Triage\KAPE\KAPE
    .\kape.exe --tsource C: --tdest C:\Windows\Temp\Triage\Image --target !BasicCollection,!SANS_Triage --vhd vhd
}

function Upload_Kape{
    Write-S3Object -BucketName $Bucket -KeyPrefix "$Folder/$Hostname" -Folder C:\Windows\Temp\Triage\Image
}

function Cleanup{
    Remove-AWSCredentialProfile -ProfileName Triage -Force
    cd C:\Windows\Temp
    Remove-Item -Path C:\Windows\Temp\Triage -Force -Recurse
}

Create_Folders
Install_AWS
Download_File
Kape
Upload_Kape
Cleanup

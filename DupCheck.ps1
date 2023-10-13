# Prompt user to select a folder via folder browser GUI
Add-Type -AssemblyName System.Windows.Forms
$foldername = New-Object System.Windows.Forms.FolderBrowserDialog
$foldername.Description = "Select a folder"
$foldername.rootfolder = "MyComputer"
$foldername.ShowNewFolderButton = $false
[void]$foldername.ShowDialog()
$folder = $foldername.SelectedPath

# Create an empty hashtable to store file hashes
$hashes = @{}

# Traverse all child folders and calculate file hashes
Write-Host "Getting file list..."
$filecount = 0
$dupcount = 0
$subfiles = Get-ChildItem -Path $folder -Recurse -File 
$totalfiles = $subfiles.Count
Write-Host "Calculating file hashes..."
$subfiles | ForEach-Object {
    $hash = Get-FileHash -Path $_.FullName -Algorithm MD5 | Select-Object -ExpandProperty Hash
    if ($hashes.ContainsKey($hash)) {
        #move current file to temp directory
        $tempdir = "D:\temp"
        if (!(Test-Path $tempdir)) {
            New-Item -ItemType Directory -Path $tempdir
        }
        $tempfile = Join-Path -Path $tempdir -ChildPath $_.Name
        Write-Host "`nRemoving duplicate file: $_"
        Remove-Item -Path $_.FullName -Force | Out-Null
        $dupcount += 1
    } else {
        $hashes.Add($hash, @($_.FullName))
    }
    $filecount+=1
    Write-Host "`r$filecount files hashed of $totalfiles - $dupcount duplicates." -NoNewline
}
#Delete empty directories below $folder
Write-Host ""
Write-Host "Deleting empty directories..."
Get-ChildItem -Path $folder -Recurse -Directory | Where-Object { (Get-ChildItem -Path $_.FullName -Recurse -File).Count -eq 0 -and (Get-ChildItem -Path $_.FullName -Recurse -Directory).Count -eq 0 } | Remove-Item -Force -Recurse | Out-Null

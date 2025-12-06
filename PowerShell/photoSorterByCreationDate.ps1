param(
    [string]$SourceFolder = "D:\MeenuMobile\Camera"
)

# Supported file types
$extensions = @("*.jpg","*.jpeg","*.png","*.heic","*.mp4","*.mov","*.avi","*.mkv")

# Function to get EXIF DateTimeOriginal for images
function Get-ExifDate {
    param([string]$FilePath)

    try {
        $shell = New-Object -ComObject Shell.Application
        $folder = $shell.Namespace((Split-Path $FilePath))
        $file = $folder.ParseName((Split-Path $FilePath -Leaf))

        # 12 = "Date Taken" field in Windows EXIF metadata
        $dateTaken = $folder.GetDetailsOf($file, 12)

        if ($dateTaken -and $dateTaken -ne "") {
            return [DateTime]::Parse($dateTaken)
        }
    } catch {
        return $null
    }
    return $null
}

Write-Host "`nSorting photos from: $SourceFolder" -ForegroundColor Cyan

foreach ($ext in $extensions) {

    Get-ChildItem -Path $SourceFolder -Filter $ext -File | ForEach-Object {

        $file = $_.FullName

        # Try EXIF date first
        $date = Get-ExifDate -FilePath $file

        # Fallback: file creation time
        if (-not $date) {
            $date = $_.CreationTime
        }

        $year = $date.Year
        $month = $date.ToString("MMMM") # "January", "February", etc.

        $targetFolder = Join-Path $SourceFolder "$year\$month"

        # Create folder if missing
        if (-not (Test-Path $targetFolder)) {
            New-Item -ItemType Directory -Path $targetFolder | Out-Null
        }

        $destination = Join-Path $targetFolder $_.Name

        Write-Host "Moving $($_.Name) → $year\$month"

        Move-Item -LiteralPath $file -Destination $destination -Force
    }
}



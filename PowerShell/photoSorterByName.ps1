param(
    [string]$SourceFolder = "D:\MeenuMobile\Camera"
)

Write-Host "`nSorting based on YYYYMMDD in filenames..." -ForegroundColor Cyan

# Regex pattern to detect YYYYMMDD
#$pattern = "\b(20\d{6})\b"   # Matches years beginning with 20 (e.g., 20180122)
$pattern = '(?<!\d)(20\d{6})(?!\d)'

Get-ChildItem -Path $SourceFolder -File | ForEach-Object {

    $file = $_
    $name = $_.Name
    Write-Host "DEBUG: $name" -ForegroundColor Yellow
    # Extract date using regex
    $match = [regex]::Match($name, $pattern)

    if ($match.Success) {

        $dateString = $match.Groups[1].Value   # "20240718"

        # Parse date
        try {
            $date = [DateTime]::ParseExact($dateString, "yyyyMMdd", $null)
        }
        catch {
            Write-Host "Skipping (invalid date): $name" -ForegroundColor Yellow
            return
        }

        # Generate folder structure
        $year = $date.Year
        $month = $date.ToString("MM MMMM")  # "07 July"

        $targetFolder = Join-Path $SourceFolder "$year\$month"

        # Create folder if missing
        if (-not (Test-Path $targetFolder)) {
            New-Item -ItemType Directory -Path $targetFolder | Out-Null
        }

        $destination = Join-Path $targetFolder $name

        Write-Host "Moving $name → $year\$month"

        Move-Item -LiteralPath $file.FullName -Destination $destination -Force

    } else {
        Write-Host "No date found in filename: $name" -ForegroundColor DarkYellow
    }
}

Write-Host "`nSorting completed." -ForegroundColor Green
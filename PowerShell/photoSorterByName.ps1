param(
    [string]$SourceFolder = "D:\MeenuMobile\Camera",
    [switch]$CopyInsteadOfMove
)

Write-Host "`nSorting based on YYYYMMDD or YYYY-MM-DD in filenames (folders: YYYY\MM)..." -ForegroundColor Cyan

# Two regex patterns:
# 1) YYYYMMDD (without separators)
# 2) YYYY-MM-DD (with separators)
$patterns = @(
    '(?<!\d)(20\d{6})(?!\d)',          # matches 20210822
    '(?<!\d)(20\d{2})-(\d{2})-(\d{2})(?!\d)'  # matches 2021-08-22
)

Get-ChildItem -Path $SourceFolder -File | ForEach-Object {

    $file = $_
    $name = $_.Name
    $date = $null

    foreach ($pattern in $patterns) {

        $match = [regex]::Match($name, $pattern)

        if ($match.Success) {

            # Pattern 1: YYYYMMDD
            if ($match.Groups.Count -eq 2) {
                $dateString = $match.Groups[1].Value  # "20210822"
                try {
                    $date = [DateTime]::ParseExact($dateString, "yyyyMMdd", $null)
                } catch {}
            }

            # Pattern 2: YYYY-MM-DD
            elseif ($match.Groups.Count -eq 4) {
                $year  = $match.Groups[1].Value
                $month = $match.Groups[2].Value
                $day   = $match.Groups[3].Value
                $dateString = "$year-$month-$day"
                try {
                    $date = [DateTime]::ParseExact($dateString, "yyyy-MM-dd", $null)
                } catch {}
            }

            if ($date) { break }
        }
    }

    if (-not $date) {
        Write-Host "No date found in filename: $name" -ForegroundColor DarkYellow
        return
    }

    # Create folder path: YYYY\MM
    $year = $date.Year.ToString()
    $month = $date.ToString("MM")

    $targetFolder = Join-Path $SourceFolder "$year\$month"

    if (-not (Test-Path $targetFolder)) {
        New-Item -ItemType Directory -Path $targetFolder | Out-Null
    }

    $destination = Join-Path $targetFolder $name

    Write-Host "Moving $name → $year\$month"

    try {
        if ($CopyInsteadOfMove) {
            Copy-Item -LiteralPath $file.FullName -Destination $destination -Force
        } else {
            Move-Item -LiteralPath $file.FullName -Destination $destination -Force
        }
    }
    catch {
        Write-Host "Error moving/copying $name : $_" -ForegroundColor Red
    }
}

Write-Host "`n Sorting completed using YYYY/MM format!" -ForegroundColor Green

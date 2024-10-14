# Function to get valid input
function Get-ValidInput($prompt) {
    do {
        $input = Read-Host -Prompt $prompt
        if ([string]::IsNullOrWhiteSpace($input)) {
            Write-Host "Input is empty. Please enter a value."
        }
    } while ([string]::IsNullOrWhiteSpace($input))
    return $input
}

# Get output directory from user input
$outputName = Get-ValidInput "Enter the output output name"

# Create the output directory if it doesn't exist
if (!(Test-Path -Path $outputName)) {
    New-Item -ItemType Directory -Force -Path $outputName
}

# Get PDF filename from user input
$pdfPath = Join-Path -Path $outputName -ChildPath "$outputName.pdf"

# Source directory for PNG files
$sourceDir = ".\img"

# Check if source directory exists
if (!(Test-Path -Path $sourceDir)) {
    Write-Host "Error: Source directory '$sourceDir' does not exist."
    exit
}

# Create a temporary directory for AVIF files
$tempDir = Join-Path -Path $outputName -ChildPath "temp_avif"
New-Item -ItemType Directory -Force -Path $tempDir | Out-Null

try {
    # Convert PNG to AVIF
    Write-Host "Converting PNG files to AVIF..."
    Get-ChildItem -Path $sourceDir -Filter "*.png" | ForEach-Object {
        $avifPath = Join-Path -Path $tempDir -ChildPath ($_.BaseName + ".avif")
        magick convert $_.FullName -quality 75 $avifPath
        Write-Host "Converted: $($_.Name) -> $($_.BaseName).avif"
    }

    # Convert AVIF files to PDF
    Write-Host "Converting AVIF files to PDF..."
    magick convert "$tempDir\*.avif" $pdfPath
    Write-Host "Conversion complete. PDF saved as '$pdfPath'."
} catch {
    Write-Host "Error: An issue occurred during conversion."
    Write-Host $_.Exception.Message
} finally {
    # Clean up temporary directory
    Remove-Item -Path $tempDir -Recurse -Force
    Write-Host "Temporary files deleted."
}

$page_number = 1

# Create the img directory if it doesn't exist
if (-not (Test-Path "img")) {
    New-Item -ItemType Directory -Path "img"
}

# Get Screen Resolution
$screen_resolution = adb shell wm size
$screen_resolution = $screen_resolution -replace "Physical size: ", ""
$screen_resolution = $screen_resolution -split "x"
$screen_width = [int]$screen_resolution[0]
$screen_height = [int]$screen_resolution[1]

# Tap coordinates
$tap_x = $screen_width - 10
$tap_y = $screen_height / 2

while ($true) {
    $formatted_page_number = $page_number.ToString("D4")
    adb exec-out screencap -p > "img/$formatted_page_number.png"
    adb shell input touchscreen tap $tap_x $tap_y
    Start-Sleep -Seconds 0.3
    $page_number++
}

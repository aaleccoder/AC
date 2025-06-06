# Build script for the two-stage bootloader racing game
# PowerShell version for Windows

Write-Host "Building Racing Game Bootloader..." -ForegroundColor Green

# Check if nasm is available
try {
    $nasmVersion = nasm -v 2>$null
    Write-Host "Found NASM: $nasmVersion" -ForegroundColor Cyan
} catch {
    Write-Host "Error: NASM assembler not found. Please install NASM." -ForegroundColor Red
    Write-Host "Download from: https://www.nasm.us/pub/nasm/releasebuilds/"
    exit 1
}

# Assemble the first stage bootloader
Write-Host "Assembling boot.asm..." -ForegroundColor Yellow
nasm -f bin boot.asm -o boot.bin
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error assembling boot.asm" -ForegroundColor Red
    exit 1
}

# Assemble the second stage (game)
Write-Host "Assembling game.asm..." -ForegroundColor Yellow
nasm -f bin game.asm -o game.bin
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error assembling game.asm" -ForegroundColor Red
    exit 1
}

# Create a disk image (1.44MB floppy)
Write-Host "Creating disk image..." -ForegroundColor Yellow
$diskSize = 1474560  # 1.44MB in bytes
$diskImage = New-Object byte[] $diskSize
[System.IO.File]::WriteAllBytes("racing_game.img", $diskImage)

# Write the bootloader to the first sector
Write-Host "Writing bootloader to disk image..." -ForegroundColor Yellow
$bootData = [System.IO.File]::ReadAllBytes("boot.bin")
$imageData = [System.IO.File]::ReadAllBytes("racing_game.img")

# Copy boot sector
for ($i = 0; $i -lt $bootData.Length; $i++) {
    $imageData[$i] = $bootData[$i]
}

# Write the game starting at sector 2 (byte offset 512)
Write-Host "Writing game to disk image..." -ForegroundColor Yellow
$gameData = [System.IO.File]::ReadAllBytes("game.bin")
for ($i = 0; $i -lt $gameData.Length; $i++) {
    $imageData[512 + $i] = $gameData[$i]
}

# Write the complete image
[System.IO.File]::WriteAllBytes("racing_game.img", $imageData)

Write-Host "Build complete! racing_game.img ready." -ForegroundColor Green
Write-Host "Boot sizes:" -ForegroundColor Cyan
Write-Host "  boot.bin: $((Get-Item boot.bin).Length) bytes"
Write-Host "  game.bin: $((Get-Item game.bin).Length) bytes"

# Clean up intermediate files
Remove-Item boot.bin, game.bin -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "To run the game:" -ForegroundColor White
Write-Host "  With QEMU: qemu-system-i386 -fda racing_game.img" -ForegroundColor Gray
Write-Host "  With VirtualBox: Create new VM and use racing_game.img as floppy" -ForegroundColor Gray

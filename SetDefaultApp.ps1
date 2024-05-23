# Set default browser to Google Chrome
$chromeRegKey = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\http\UserChoice"
Set-ItemProperty -Path $chromeRegKey -Name ProgId -Value "ChromeHTML" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice" -Name ProgId -Value "ChromeHTML" -Force

# Set default email client to Outlook
$outlookRegKey = "HKCU:\Software\Microsoft\Windows\Shell\Associations\UrlAssociations\mailto\UserChoice"
Set-ItemProperty -Path $outlookRegKey -Name ProgId -Value "Outlook.Email" -Force

# Set default application for .pdf files to PDF-XChange Editor
$pdfRegKey = "HKCU:\Software\Classes\.pdf"
Set-ItemProperty -Path $pdfRegKey -Name "(Default)" -Value "PDFXEdit.Document" -Force

$pdfFileTypeRegKey = "HKCU:\Software\Classes\PDFXEdit.Document\shell\open\command"
Set-ItemProperty -Path $pdfFileTypeRegKey -Name "(Default)" -Value "C:\Program Files\Tracker Software\PDF Editor" -Force

# Update default apps displayed in the Settings menu
$regUpdateCommand = @"
$UpdateSession = New-Object -ComObject IApplicationActivationManager
$hr = $UpdateSession.RefreshApplicationContent
"@

Invoke-Expression -Command $regUpdateCommand

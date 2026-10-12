$env:EMAIL_ACCOUNT = [System.Environment]::GetEnvironmentVariable('EMAIL_ACCOUNT', 'User')
$env:EMAIL_PASSWORD = [System.Environment]::GetEnvironmentVariable('EMAIL_PASSWORD', 'User')
$env:MY_EMAIL = [System.Environment]::GetEnvironmentVariable('MY_EMAIL', 'User')

Write-Host "EMAIL_ACCOUNT: $($env:EMAIL_ACCOUNT)"
Write-Host "MY_EMAIL: $($env:MY_EMAIL)"

python "$PSScriptRoot\send_email.py" @args

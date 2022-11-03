# Debug
## Error related to `-PredictionViewStyle ListView`
If when starting powershell 7 you're getting and error related to `-PredictionViewStyle ListView` it means that the latest version of `PSReadLine` could not be installed.
To fix this do the following:
- make sure that no instance of `Visual Studio Code` is running
- open cmd as administrator
- run the following commands in cmd
  ```
  taskkill /im:powershell.exe /t /f
  taskkill /im:pwsh.exe /t /f
  pwsh.exe -noprofile -command "Install-Module PSReadLine -Force -AllowPrerelease -SkipPublisherCheck"
  ```
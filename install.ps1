#irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/install.ps1 | iex

Write-Information 'Installing wsl...'  -InformationAction Continue
wsl --install

Write-Information 'Adding PSGallery'  -InformationAction Continue
Write-Warning 'If prompted to install NuGet choose Y'
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

Write-Information 'Getting winget install script...'  -InformationAction Continue
Install-Script -Name winget-install -Force

Write-Information 'Installing winget...'  -InformationAction Continue
winget-install.ps1
sleep 5

Write-Information 'Getting winget-apps.json...'  -InformationAction Continue
irm https://raw.githubusercontent.com/emanuelpaul/dotnet-dev-install-prereqs/dev/winget-apps.json -o winget-apps.json

Write-Information 'Starting to install apps using winget...'  -InformationAction Continue
winget import winget-apps.json
winget install Microsoft.VisualStudio.2022.Professional -s winget --override "--wait --quiet --add Microsoft.VisualStudio.Workload.Node --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools --add Microsoft.Net.Component.4.8.1.SDK --add Microsoft.Net.Component.4.8.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.1.DeveloperTools --add Microsoft.Net.Core.Component.SDK.2.1 --add Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1 --add wasm.tools --add Microsoft.NetCore.Component.Runtime.3.1"
shutdown -r -t 60
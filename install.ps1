wsl --install
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
Install-Script -Name winget-install -Force
winget import test.json
winget install Microsoft.VisualStudio.2022.Professional -s winget --override "--wait --quiet --add Microsoft.VisualStudio.Workload.Node --add Microsoft.VisualStudio.Workload.Data --add Microsoft.VisualStudio.Workload.ManagedDesktop --add Microsoft.VisualStudio.Workload.NetWeb --add Microsoft.Net.Component.4.8.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.DeveloperTools --add Microsoft.Net.Component.4.8.1.SDK --add Microsoft.Net.Component.4.8.1.TargetingPack --add Microsoft.Net.ComponentGroup.4.8.1.DeveloperTools --add Microsoft.Net.Core.Component.SDK.2.1 --add Microsoft.NetCore.ComponentGroup.DevelopmentTools.2.1 --add wasm.tools --add Microsoft.NetCore.Component.Runtime.3.1"
shutdown -r -t 60
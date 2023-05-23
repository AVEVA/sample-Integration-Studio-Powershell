# List the node details of all failed VMs in AVEVA Integration Studio
#
# You MUST MAKE edit to this script to update the authentication before you can use it
#
# To Update It:
#
#    1. Open Integration Studio in your browser and log in
#    2. Open the browser's DevTools (F12) and in the "Network" tab find one of the request for ""Copy to Powershell" for "projects". If none are listed, refresh the page
#    3. Right-click on "projects" and select "Copy-->Copy as Powershell"
#    4. Replace the section below with the contents of the clipboard from #3
#    5. Remove the last few lines pasted in #4 starting with "Invoke-WebRequest" to the end of the pasted section
#    6. Expect two runtime exceptions "Exception calling 'Add' with '1' argument(s)..."--ignore these
#

# ------------ Begin Section to Replace ---------------
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$session.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36 Edg/113.0.1774.50"
$session.Cookies.Add((New-Object System.Net.Cookie("CookieConsent", "Date of Consent...", "/", ".aveva.com")))
# ....
$session.Cookies.Add((New-Object System.Net.Cookie(".AspNetCore.CookiesC2", "ArAiOTpS-_...qVHaK9U2A", "/", "integrationstudio.connect.aveva.com")))
$session.Cookies.Add((New-Object System.Net.Cookie(".AspNetCore.CookiesC3", "yv75inT9ZE..._IvHaoHks", "/", "integrationstudio.connect.aveva.com")))
# ------------ End Section to Replace ---------------


$ProjectsResponse = Invoke-WebRequest -UseBasicParsing -Uri "https://integrationstudio.connect.aveva.com/home/api/projects" `
-WebSession $session `
-Headers @{
"authority"="integrationstudio.connect.aveva.com"
  "method"="GET"
  "scheme"="https"
  "accept"="application/json"
  "accept-encoding"="gzip, deflate, br"
  "accept-language"="en-US,en;q=0.9"
  "cache-control"="no-cache"
  "pragma"="no-cache"
  "sec-ch-ua"="`"Microsoft Edge`";v=`"113`", `"Chromium`";v=`"113`", `"Not-A.Brand`";v=`"24`""
  "sec-ch-ua-mobile"="?0"
  "sec-ch-ua-platform"="`"Windows`""
  "sec-fetch-dest"="empty"
  "sec-fetch-mode"="cors"
  "sec-fetch-site"="same-origin"
} `
-ContentType "application/json"

    $ErrorCount = 0
    $Projects = $ProjectsResponse | ConvertFrom-Json
    foreach( $Project in $Projects ) {

    if ($Project.status.error -gt 0)  {
        $InstancesResponse = Invoke-WebRequest -UseBasicParsing -Uri ("https://integrationstudio.connect.aveva.com/home/api/projects/" + $Project.projectId + "/instances") `
        -WebSession $session `
        -Headers @{
        "authority"="integrationstudio.connect.aveva.com"
          "method"="GET"
          "scheme"="https"
          "accept"="application/json"
          "accept-encoding"="gzip, deflate, br"
          "accept-language"="en-US,en;q=0.9"
          "cache-control"="no-cache"
          "pragma"="no-cache"
          "sec-ch-ua"="`"Microsoft Edge`";v=`"113`", `"Chromium`";v=`"113`", `"Not-A.Brand`";v=`"24`""
          "sec-ch-ua-mobile"="?0"
          "sec-ch-ua-platform"="`"Windows`""
          "sec-fetch-dest"="empty"
          "sec-fetch-mode"="cors"
          "sec-fetch-site"="same-origin"
        } `
        -ContentType "application/json"

            $Instances = $InstancesResponse | ConvertFrom-Json
            foreach( $Instance in $Instances ) {
            if ($Instance.status -eq "error") {
                $ErrorCount = $ErrorCount + 1
                Write-Host $Project.name "`t" $Instance.alias "`t" $Instance.projectId "`t" $Instance.instanceId "`t" $Instance.instanceRef


                $NodesResponse = Invoke-WebRequest -UseBasicParsing -Uri ("https://integrationstudio.connect.aveva.com/home/api/instances/" + $Instance.instanceId + "/nodes") `
                -WebSession $session -Headers @{
                "authority"="integrationstudio.connect.aveva.com"
                  "method"="GET"
                  "scheme"="https"
                  "accept"="application/json"
                  "accept-encoding"="gzip, deflate, br"
                  "accept-language"="en-US,en;q=0.9"
                  "cache-control"="no-cache"
                  "pragma"="no-cache"
                  "sec-ch-ua"="`"Microsoft Edge`";v=`"113`", `"Chromium`";v=`"113`", `"Not-A.Brand`";v=`"24`""
                  "sec-ch-ua-mobile"="?0"
                  "sec-ch-ua-platform"="`"Windows`""
                  "sec-fetch-dest"="empty"
                  "sec-fetch-mode"="cors"
                  "sec-fetch-site"="same-origin"
                } -ContentType "application/json"

                $Nodes = $NodesResponse | ConvertFrom-Json
                foreach( $Node in $Nodes ) {
                    Write-Host "`t`t`t`t" ($Node.name + ': ' + $Node.nodeId)
                }
            }
        }
    }
}

if ($ErrorCount -eq 0) {
    Write-Host "No VMs with errors were found."
} else {
    Write-Host "Found" $ErrorCount "VMs with errors."
}

    
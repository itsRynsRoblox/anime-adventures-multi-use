#Requires Autohotkey v2.0

CheckForUpdates() {
    global repoOwner, repoName

    url := "https://api.github.com/repos/" repoOwner "/" repoName "/releases/latest"
    http := ComObject("MSXML2.XMLHTTP")
    http.Open("GET", url, false)
    http.Send()

    if (http.Status != 200) {
        AddToLog("Failed to check for updates.")
        return
    }

    response := http.responseText
    latestVersion := JSON.parse(response).Get("tag_name")

    if (latestVersion != currentVersion) {
        AddToLog("🔄 Update available! Current: " currentVersion " → Latest: " latestVersion)
    } else {
        AddToLog("You are using the latest version.")
    }
}
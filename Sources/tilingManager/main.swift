import AppKit // drawing windows, panels..
import ApplicationServices 

print("App is running")

let options = ["AXTrustedCheckOptionPrompt":true] as CFDictionary
let isTrusted = AXIsProcessTrustedWithOptions(options)

print("Accessibility permision: \(isTrusted ? "Granted":"Missing")")

// Which app is in the front

if let app = NSWorkspace.shared.frontmostApplication{ // if exist bring the name of the app we are working on
    let name = app.localizedName ?? "Unknown"
    print("App: \(name)")
}else{
    print("No frontmost app found")
}
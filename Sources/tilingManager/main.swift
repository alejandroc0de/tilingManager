import AppKit // drawing windows, panels..
import ApplicationServices 

print("App is running")

let options = ["AXTrustedCheckOptionPrompt":true] as CFDictionary
let isTrusted = AXIsProcessTrustedWithOptions(options)

print("Accessibility permision: \(isTrusted ? "Granted":"Missing")")


print("Switch to another app.... reading in 3 seconds")
sleep(3)



// Which app is in the front
// I use guard to be able to use app outside of the scope, but then we have to use it as an early return. 
guard let app = NSWorkspace.shared.frontmostApplication else{
    print("No frontmost app found")
    exit(1)
} // if early return is not triggered continue.. 
let name = app.localizedName ?? "Unknown"
print("App: \(name) PID: \(app.processIdentifier)")


// Turn the app into an AX element so we can ask details (AX element == UI element)
let appElement = AXUIElementCreateApplication(app.processIdentifier) // creates a reference to this PID

// call function to ask details of this app 
guard let windows = attribute(appElement, kAXWindowsAttribute) as? [AXUIElement] else { // convert result to a list if not nil 
    print("Could not read windows")
    exit(1)
}

print("\(windows.count) windows: ") // number of windows open 
for (index,window) in windows.enumerated(){ // for to go tru the list and get the title of each active window 
    let title = (attribute(window,kAXTitleAttribute) as? String) ?? "(no title)"
    print("\(index+1) - \(title)")
}
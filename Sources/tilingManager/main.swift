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

// Moving the focused window to the left 
// 1. Ask for active window
guard let focusedRef = attribute(appElement,kAXFocusedWindowAttribute), // within the window open, what tab is opened? / , is and AND 
    CFGetTypeID(focusedRef) == AXUIElementGetTypeID() // Is it any GUI item? Or is it a error or nil 
    else{
        print("No focused Window")
        exit(1)
    }
let focusedWindow = focusedRef as! AXUIElement // Forces cast, but we already checked before so no issue. We cast it as a GUI element
// 2. Get the screen usable area

guard let screen = NSScreen.screens.first else{
    print("No screens found")
    exit(1)
}
let screenHeight = screen.frame.height
let visible = screen.visibleFrame

// 3. Flipped coordinates convertion, NSscreen has diferent starting cords than AXUI 
print(visible.origin)
let topY = screenHeight - (visible.origin.y + visible.height) // visible origin after dock measuares + rest of the screen VIEW NOTES

//4. Calculate left half 
let leftHalf = CGRect( // cr
    x : visible.origin.x,
    y : topY,
    width : visible.width/2,
    height : visible.height
)
print("Moving window to the left")

setFrame(of:focusedWindow, to: leftHalf)
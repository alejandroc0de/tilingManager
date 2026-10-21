// Actions for the window 
import AppKit // drawing windows, panels..
import ApplicationServices 

// Posible actions we will have 
enum WindowAction {
    case leftHalf
    case rightHalf
    case maximize
    case minimize
}

@MainActor // Avoid concurrency errors
// functions in swift need a name for parms, with _ we can call the function like .leftHalf (Ommited external parms name)
func perform(_ action: WindowAction){

    // Which app is in the front
    // I use guard to be able to use app outside of the scope, but then we have to use it as an early return. 
    guard let app = NSWorkspace.shared.frontmostApplication else{
        print("No frontmost app found")
        return
    } // if early return is not triggered continue.. 

    // Turn the app into an AX element so we can ask details (AX element == UI element)
    let appElement = AXUIElementCreateApplication(app.processIdentifier) // creates a reference to this PID


    // --- What is the focused Window
    // 1. Ask for active window
    guard let focusedRef = attribute(appElement,kAXFocusedWindowAttribute), // within the window open, which of the apps windows is opened / , is and AND 
        CFGetTypeID(focusedRef) == AXUIElementGetTypeID() // Is it any GUI item? Or is it a error or nil 
        else{
            print("No focused Window")
            return
        }
    let focusedWindow = focusedRef as! AXUIElement // Forces cast, but we already checked before so no issue. We cast it as a GUI element

    // Getting the windowFrame to identify the screen we are workin on
    print("Dimensiones son : ") 
    guard let windowFrame = frame(of: focusedWindow)
    else {
        print("No dimensions found for window")
        return
    }
    let center = CGPoint(x: windowFrame.midX, y: windowFrame.midY)
    print(center)


    for screen in NSScreen.screens {
        print(toAX(of: screen.frame))
    }
    

    

    // ---- Get Usable Area and Convertion to AX cords
    guard let screen = NSScreen.screens.first else{
        print("No screens found")
        return
    }
    let screenHeight = screen.frame.height
    let visible = screen.visibleFrame

    // 3. Flipped coordinates convertion, NSscreen has diferent starting cords than AXUI 
    let topY = screenHeight - (visible.origin.y + visible.height) // visible origin after dock measuares + rest of the screen VIEW NOTES
    let area = CGRect(x:visible.origin.x, y: topY, width: visible.width, height: visible.height ) // This is the work area

    // --- Calculate rect to send to System 
    let target : CGRect
    switch action {
        case .leftHalf:
            target = CGRect(x : visible.origin.x, y : topY, width : visible.width/2, height : visible.height)
        case .rightHalf:
            target = CGRect(x: area.minX + area.width / 2, y:area.minY, width: area.width/2, height: area.height)
        case .maximize:
            target = area // It is already a CGRect
        case .minimize:
            AXUIElementSetAttributeValue(focusedWindow, kAXMinimizedAttribute as CFString, kCFBooleanTrue)
            return
    }

    // --- Move it 
    setFrame(of: focusedWindow, to: target)
}
import ApplicationServices
import AppKit // drawing windows, panels..

// element is what we want to lookup and name the data we want to check
func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? { // -> we dont know what is returned (what data)
    var value : CFTypeRef? // value to store answer, (CFTypeRef) stores any apple data
    let result = AXUIElementCopyAttributeValue(element, name as CFString, &value) // as CFString porque la funcion esta en C / &escribe el resultado en value
    return result == AXError.success ? value : nil //AXError is a list of possible outcomes for the function 
}

// Function to move windows 
func setFrame(of window: AXUIElement, to rect: CGRect){ // OR (window: , rect: ) the OF is to improve reading, rect is receive from main
    var origin = rect.origin // x,y cords
    var size = rect.size // size of new window

    //Pack (x,y) into a AXValue box to be able to write it. CGPoint is not readable by C API
    if let positionValue = AXValueCreate(.cgPoint, &origin){ //.cgPoint indicates type of data - &origin (use origin variable for data)
        let result = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        // print("Set position to: ", result.rawValue, result)
    }

    if let sizeValue = AXValueCreate(.cgSize, &size){
        let result = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue) //kAXSize is a string with the name of the attribute we want to change
        // print("Set size to: ", result, result.rawValue)
    }
}

func frame(of window: AXUIElement) -> CGRect? {
    guard let result = attribute(window, kAXSizeAttribute),
    CFGetTypeID(result) == AXValueGetTypeID()
    else{
        print("Not a GUI VALUE")
        return nil
    }
    var size = CGSize.zero
    AXValueGetValue(result as! AXValue, .cgSize, &size)

    guard let resultB = attribute(window, kAXPositionAttribute),
    CFGetTypeID(resultB) == AXValueGetTypeID()
    else {
        print("Not a GUI Value")
        return nil
    }
    var position = CGPoint.zero
    AXValueGetValue(resultB as! AXValue, .cgPoint, &position)
    let dimensions = CGRect(x: position.x, y: position.y, width: size.width, height: size.height)
    return dimensions
}   

// this function received a rect with the dimensions of all screen and convert them into AX Dimmensions
@MainActor
func toAX(of rect: CGRect) -> CGRect? {
    guard let mainScreen = NSScreen.screens.first else{
        print("No screens found")
        return nil
    }
    let screenHeight = mainScreen.frame.height
    let newY = screenHeight - (rect.origin.y + rect.height)
    let dimensions = CGRect(x: rect.origin.x, y: newY, width: rect.width, height: rect.height)
    return dimensions
}

@MainActor
// Function to check in which window we working
func findScreen(of screenPoint : CGPoint) -> NSScreen? {
    for screen in NSScreen.screens{
        guard let dimensions = toAX(of: screen.frame) else {
            print(("Error trying to find current screen"))
            return nil
        }
        if dimensions.contains(screenPoint){
            return screen
        }
    }
    return NSScreen.main // IF it doesnt find a screen returns main or active screen as a fallback
}

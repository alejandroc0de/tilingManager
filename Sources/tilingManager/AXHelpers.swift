import ApplicationServices

// element is what we want to lookup and name the data we want to check
func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? { // -> we dont know what is returned (what data)
    var value : CFTypeRef? // value to store answer, (CFTypeRef) stores any apple data
    let result = AXUIElementCopyAttributeValue(element, name as CFString, &value) // as CFString porque la funcion esta en C / &escribe el resultado en value
    print(result)
    return result == AXError.success ? value : nil //AXError is a list of possible outcomes for the function 
}

// Function to move windows 
func setFrame(of window: AXUIElement, to rect: CGRect){ // OR (window: , rect: ) the OF is to improve reading, rect is receive from main
    var origin = rect.origin // x,y cords
    var size = rect.size // size of new window

    //Pack (x,y) into a AXValue box to be able to write it. CGPoint is not readable by C API
    if let positionValue = AXValueCreate(.cgPoint, &origin){ //.cgPoint indicates type of data - &origin (use origin variable for data)
        let result = AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, positionValue)
        print("Set position to: ", result.rawValue, result)
    }

    if let sizeValue = AXValueCreate(.cgSize, &size){
        let result = AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue) //kAXSize is a string with the name of the attribute we want to change
        print("Set size to: ", result, result.rawValue)
    }
}


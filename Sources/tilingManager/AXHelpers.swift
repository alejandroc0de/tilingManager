import ApplicationServices

// element is what we want to lookup and name the data we want to check
func attribute(_ element: AXUIElement, _ name: String) -> CFTypeRef? { // -> we dont know what is returned (what data)
    var value : CFTypeRef? // value to store answer, (CFTypeRef) stores any apple data
    let result = AXUIElementCopyAttributeValue(element, name as CFString, &value) // as CFString porque la funcion esta en C / &escribe el resultado en value
    print(result)
    return result == AXError.success ? value : nil //AXError is a list of possible outcomes for the function 
}
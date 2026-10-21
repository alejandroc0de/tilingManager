import Carbon.HIToolbox

let hotKeyActions : [UInt32: WindowAction] = [
    1: .leftHalf,
    2: .rightHalf,
    3: .maximize, 
    4: .minimize
]


func registerHotKey(keycode: Int, modifiers: Int, id:UInt32){ // this info will be received from main 
    let hotKeyId = EventHotKeyID(signature: OSType(0x544C4D47), id: id) // Give it a signature to diferenciate from other processes
    var hotKeyRef : EventHotKeyRef? // ?? 
    let status = RegisterEventHotKey(UInt32(keycode), UInt32(modifiers), hotKeyId, GetApplicationEventTarget(), 0, &hotKeyRef) //register and save the result to status

    if status != noErr{ // If there is error
    print("Could not register hotkey \(id): \(status)")
    }
}

// Bunch of stuff i dont really get 

func installHotKeyHandler(){
    var eventType = EventTypeSpec( // what event are we waiting for?
        eventClass : OSType(kEventClassKeyboard),
        eventKind: UInt32(kEventHotKeyPressed)
        )
    
    InstallEventHandler (GetApplicationEventTarget(), {_, event, _ in
        var hotKeyID = EventHotKeyID()
        GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
    ) 
    let id = hotKeyID.id

    MainActor.assumeIsolated{
        if let action = hotKeyActions[id]{
            perform(action)
        }
    }
    return noErr
    }, 1, &eventType, nil,nil)
}
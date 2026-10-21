import AppKit // drawing windows, panels..
import ApplicationServices 
import Carbon.HIToolbox

print("App is running")

let options = ["AXTrustedCheckOptionPrompt":true] as CFDictionary
let isTrusted = AXIsProcessTrustedWithOptions(options)

print("Accessibility permision: \(isTrusted ? "Granted":"Missing")")



installHotKeyHandler() //This listens for the hot keys
let modifiers = cmdKey | controlKey 
registerHotKey(keycode: kVK_LeftArrow, modifiers: modifiers, id: 1)
registerHotKey(keycode: kVK_RightArrow, modifiers: modifiers, id: 2)
registerHotKey(keycode: kVK_UpArrow, modifiers: modifiers, id: 3)
registerHotKey(keycode: kVK_DownArrow, modifiers: modifiers, id: 4)

NSApplication.shared.setActivationPolicy(.accessory) // Tell system this is an app in the background
NSApplication.shared.run() // Keep running

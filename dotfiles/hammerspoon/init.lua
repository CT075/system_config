require("hs.ipc")

reloader = hs.loadSpoon('ReloadConfiguration'):start()

function alertf(...)
    hs.alert.show(string.format(...))
end

function launchOrFocus(name)
    local app = hs.application.launchOrFocus(name)

    if not app then
        alertf("%s failed to launch", name)
        return
    end

    return app
end

cmd = {"cmd"}
ctrl = {"ctrl"}
super = {"cmd", "shift"}

hs.hotkey.bind(super, "p", function()
    alertf("ping")
end)

hs.hotkey.bind(cmd, "p", function()
    hs.osascript.applescript('tell application "System Events" to key code 49 using {command down}')
end)

-- disable a bunch of hotkeys that keep messing me up

hs.hotkey.bind(cmd, "r", function() end)
hs.hotkey.bind(cmd, "j", function() end)
hs.hotkey.bind(cmd, "k", function() end)
hs.hotkey.bind(cmd, "m", function() end)
hs.hotkey.bind(cmd, "d", function() end)

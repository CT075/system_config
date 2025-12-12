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

-- disable cmd-n for all n from 1-9 in other apps

for i=1,9 do
    hs.hotkey.bind(cmd, string.format("%d", i), function() end)
end

-- idiosyncratic numbering is loosely due to which desktop I tend to put these
-- windows on when at home

hs.hotkey.bind(cmd, "1", function()
    launchOrFocus("iTerm")
end)

hs.hotkey.bind(cmd, "7", function()
    launchOrFocus("Slack")
end)

hs.hotkey.bind(cmd, "9", function()
    launchOrFocus("Google Chrome")
end)

-- disable a bunch of hotkeys that keep messing me up

hs.hotkey.bind(cmd, "r", function() end)
hs.hotkey.bind(cmd, "j", function() end)
hs.hotkey.bind(cmd, "k", function() end)
hs.hotkey.bind(cmd, "m", function() end)
hs.hotkey.bind(cmd, "d", function() end)

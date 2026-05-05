local store = require 'client.modules.store'
local config = require 'client.modules.config'

local dui = {
    visible = false
}
local screenW, screenH = GetActualScreenResolution()
local controlsRunning = false

function dui.register()
    if dui.instance then
        dui.instance:remove()
    end

    local resourceName = GetCurrentResourceName()

    dui.instance = lib.dui:new(
        {
            url = ("nui://%s/web/index.html"):format(resourceName),
            width = screenW,
            height = screenH,
        }
    )

    -- The ox_lib DUI object already has dictName and txtName. 
    -- We just need to make sure we don't overwrite them if they already exist.
    dui.instance.dictName = dui.instance.dictName or dui.instance.dictionary or dui.instance.id
    dui.instance.txtName = dui.instance.txtName or dui.instance.texture or dui.instance.id

    CreateThread(function()
        local timeout = 0
        while not dui.loaded and timeout < 100 do
            Wait(100)
            timeout = timeout + 1
        end

        if dui.loaded then
            dui.sendMessage('visible', true)
            dui.sendMessage('setColor', config.themeColor)
        else
            warn("^1[DUI] DUI Load Timeout! Check if web/index.html exists and is valid.^7")
        end
    end)
end

RegisterNuiCallback('load', function(_, cb)
    dui.loaded = true
    Wait(1000)
    cb(1)
end)

RegisterNuiCallback('currentOption', function(data, cb)
    store.current.index = data[1]
    cb(1)
end)

function dui.sendMessage(action, value)
    dui.instance:sendMessage({
        action = action,
        value = value
    })

    if action == 'visible' then
        dui.visible = value
    end

    if action == 'setOptions' then
        dui.sendMessage('visible', true)
        if not controlsRunning then
            controlsRunning = true
            CreateThread(function()
                while dui.visible do
                    dui.handleDuiControls()
                    Wait(0)
                end
                controlsRunning = false
            end)
        end
    end
end

local IsControlJustPressed = IsControlJustPressed
local SendDuiMouseWheel = SendDuiMouseWheel

dui.handleDuiControls = function()
    if not dui.instance or not dui.instance.duiObject then return end

    local input = false

    if (IsControlJustPressed(3, 180)) then -- SCROLL DOWN
        SendDuiMouseWheel(dui.instance.duiObject, -50, 0.0)
        input = true
    end

    if (IsControlJustPressed(3, 181)) then -- SCROLL UP
        SendDuiMouseWheel(dui.instance.duiObject, 50, 0.0)
        input = true
    end

    if (IsControlJustPressed(3, 173)) then -- ARROW DOWN
        SendDuiMouseWheel(dui.instance.duiObject, -50, 0.0)
        input = true
    end

    if (IsControlJustPressed(3, 172)) then -- ARROW UP
        SendDuiMouseWheel(dui.instance.duiObject, 50, 0.0)
        input = true
    end

    if input then
        Wait(200)
    end
end

dui.register() --- on load and on resource start?

return dui

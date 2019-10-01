local M = class("View")

M.TouchLayers = {}

function M.createTouchLayer(priority)
    local layer = cc.Layer:create()
    layer:setTouchEnabled(true)
    layer:registerScriptTouchHandler(function(evt, gx, gy)
        if evt == "began" then
            if layer:isTouchEnabled() then
                if layer.touchHandler then
                    return layer.touchHandler(evt, gx, gy)
                else
                    return 1
                end
            else
                return 0
            end

        else
            if layer.touchHandler then
                layer.touchHandler(evt, gx, gy)
            end
        end
    end, false, priority or -2, true)

    layer.safeRelease = function(sender)
        Utils.arrayRemove(M.TouchLayers, sender)
        sender:release()
    end

    M.TouchLayers[#M.TouchLayers + 1] = layer

    return layer
end

function M.bind(parent, child, name, callback)
    parent[name] = name

    Utils.addScriptCleanupHandler(child, function()
        if callback then callback() end
        self[name] = nil
    end)
end
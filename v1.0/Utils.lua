local M = class("Utils")

-- Convert a table to an array
function M.tableToArray(table, func)
    local arr = {}
    for k, v in pairs(table) do
        if func then
            func(arr, k, v)
        else
            arr[#arr + 1] = v
        end
    end
    return arr
end

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
        lc.arrayRemove(M.TouchLayers, sender)
        sender:release()
    end

    M.TouchLayers[#M.TouchLayers + 1] = layer

    return layer
end
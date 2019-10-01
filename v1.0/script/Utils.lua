local M = class("Utils")

M.App = cc.Application:getInstance()
M.Director = cc.Director:getInstance()
M.Dispatcher = M.Director:getEventDispatcher()
M.Scheduler = M.Director:getScheduler()
M.TextureCache = M.Director:getTextureCache()
M.FrameCache = cc.SpriteFrameCache:getInstance()
M.File = cc.FileM:getInstance()
M.UserDefault = cc.UserDefault:getInstance()
M.AppStartTime = os.time()

function M.sendEvent(evt, param, userString)
    if cc == nil or M.disableSendEvent then return end

    local eventCustom = cc.EventCustom:new(evt)
    eventCustom._param = param
    if userString then
        eventCustom:setUserString(userString)
    end
    M.Dispatcher:dispatchEvent(eventCustom)
end

function M.setScriptHandler(node)
    if node._isRegisterScriptHandler then return end

    node:registerScriptHandler(function(evt)
        if evt == "enter" then
            if node.onEnter then node:onEnter() end

        elseif evt == "exit" then
            if node.onExit then node:onExit() end

        elseif evt == "cleanup" then
            if node.onCleanup then node:onCleanup() end

        else
            if node.onScriptHandler then node:onScriptHandler(evt) end
        end
    end)

    node._isRegisterScriptHandler = true
end

function M.addScriptCleanupHandler(node, func)
    if node._isRegisterScriptHandler then
        local nodeCleanupFunc = node.onCleanup
        node.onCleanup = function()
            func()
            if nodeCleanupFunc then nodeCleanupFunc(node) end
        end
    else
        node.onCleanup = func
        M.setScriptHandler(node)
    end
end

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

function M.arraySearch(array, ele)
    if type(ele) == "function" then
        for i = 1, #array do
            if ele(array[i]) then
                return i, array[i]
            end
        end
    else
        for i = 1, #array do
            if array[i] == ele then
                return i, ele
            end
        end
    end
end

function M.arrayRemove(array, ele)
    local index = M.arraySearch(array, ele)
    if index then
        table.remove(array, index)
        return true
    end
end
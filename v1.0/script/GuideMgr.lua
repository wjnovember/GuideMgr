local M = class("GuideMgr")

M.Type = {
    dialog              = 1,
    click               = 2
}

M.GroupId = {
    equip_skill         = 1
}

M.Cond = {
    card_lv_10          = 1
}

M.Operation = {
}

-- Initialize the guide here
function M.setup()
    M.reset()
end

-- Reset the value here
function M.reset()
    -- Record the id of the GuideStep.xlsx
    M.guideId = nil
end

function M.resetOnStarted()
    M.isStarted = true
    M.isWaiting = false
    
    M.GuideNode = nil
end

function M.resetOnFinished()
    M.isStarted = false
    M.isWaiting = false
end

--- The entrance of checking the guide
--- @param point number @The trigger point
--- @param groupIds table|number @May be an array or a number
--- @return bool @Whether the guide is triggered
function M.checkStart(point, groupIds)
    -- Invalid param
    if point == nil then return false end

    -- Do not check when the guide is on
    if M.isGuiding() then return false end

    -- Check all the guide groups
    if groupIds == nil then
        local infos = M.getGuideTriggerInfos()
        for k, v in pairs(infos) do
            if M.isTriggerValid(point, v) then
                M.startGuideByGroupId(k)
                return true
            end
        end
    end
end

function M.startGuideByGroupId(groupId)
    -- Invalid param
    if groupId == nil then return end

    -- Finish the current guide
    M.finish()
    M.guideId = groupId * 100 + 1

    M.next()
end

--- Move to the next step guide
function M.next()
    if M.isStarted() then
        M.checkSave(M.guideId)

        local stepInfos = M.getGuideStepInfos()
        local info = stepInfos[M.guideId]
        if info then
            M.start()
        else
            M.finish()
        end

    else
        M.start()
        Utils.sendEvent(Event.Guide.start)
    end
end

function M.start(guideId)
    guideId = guideId or M.guideId
    if guideId == nil then return false end
    M.guideId = guideId

    local stepInfos = M.getGuideStepInfos()
    local info = stepInfos[guideId]
    if info == nil then return false end

    M.initTouchLayer()
    M.resetOnStarted()

    local t = info.type
    print("[Guide Start] GuideId = " .. guideId .. "; type = " .. t .. "; operation = " .. info.operation)

    if t == M.Type.dialog then
        M.showDialog()

    -- Click
    else
        return false
    end
end

function M.initTouchLayer()
    if M.TouchLayer == nil then
        local touchLayer = View.createTouchLayer()
        touchLayer:retain()

        touchLayer.setHandler = function(node)
            if node then
                V.bind(M, node, "GuideNode")
            else
                M.GuideNode = nil
            end

            M.setAllowNext(true)
            M.TouchLayer.touchHandler = M.touchHandler
        end
    end
end

function M.touchHandler(evt, gx, gy)
    if evt == "began" then
        local guideNode = M.GuideNode
        if guideNode then
            if M.isTouchContain(guideNode, gx, gy) then
                return 0
            else
                return 1
            end

        else
            if M.isAllowNext() then
                M.next(true)
            else
                M.wait()
            end
            return 1
        end
    end
end

function M.isTouchContain(node, x, y)
    -- Custom coding ...
end

--- Check whether the next is allowed when guiding the step except touch
function M.isAllowNext()
    return M.isAllowNext
end

function M.setAllowNext(isAllow)
    M.isAllowNext = isAllow
end

--- Save the guide step id into the server when guiding
function M.checkSave(guideId)
    local stepInfos = M.getGuideStepInfos()
    local info = stepInfos[guideId]
    if info == nil then return end

    if info.saveId > 0 then
        M.saveGuideStep(info.saveId)
    end
end

--- Finish the current group guide
function M.finish()
    if not M.isStarted() then return end

    M.removeAll()
    M.resetOnFinished()

    if M.isGuiding() then
        local groupId = math.floor(M.guideId / 100)
        M.setIsTriggered(groupId, true)
        M.guideId = nil
        print("[Guide Finish] Group id = " .. groupId)

        Utils.sendEvent(Event.Guide.finish)
    end
end

function M.removeAll()
    M.removeTouchLayer()
    M.removeDialog()
    M.removeFinger()
end

function M.removeTouchLayer()
    if M.TouchLayer then
        M.TouchLayer:unregisterScriptTouchHandler()
        M.TouchLayer:safeRelease()
        M.TouchLayer = nil
        M.GuideNode = nil
    end
end

function M.removeDialog()
    if M.Dialog then
        M.Dialog:removeFromParent(true)
        M.Dialog = nil
    end
end

function M.removeFinger()
    if M.Finger then
        M.Finger:removeFromParent(true)
        M.Finger = nil
    end
end

function M.showDialog(info)
    if info == nil then
        local stepInfos = M.getGuideStepInfos()
        info = stepInfos[M.guideId]
    end
    if info == nil then return end

    -- TODO: To be continued
end

function M.isStarted()
    return M.isStarted
end

function M.setIsStarted(isStarted)
    M.isStarted = isStarted
end

function M.isTriggerValid(point, groupInfo)
    if M.hasTriggered(groupInfo.id) then return false end

    -- Inalid trigger point
    if point ~= groupInfo.point then return false end

    return M.isCondValid(groupInfo.cond)
end

function M.isCondValid(cond)
    -- Invalid param
    if cond == nil then return false end

    -- The following is the custom coding.
    if cond == M.Cond.card_lv_10 then
        local form = Form.getTopForm()
        local card = forM.card
        if card == nil then return false end

        return card._lv >= 10
    end

    return false
end

--- Save the guide step id into the server, so that the guide will keep on in next login.
function M.saveGuideStep(saveId)
    -- Custom coding
end

function M.hasTriggered(groupId)
    --- Custom coding
end

--- Save the group id into the server.
function M.setIsTriggered(groupId, isTriggered)
    -- Custom coding ...
end

function M.isGuiding(guideId)
    guideId = guideId or M.guideId
    if guideId == nil then return false end
    return (M.guideId % 100) ~= 0
end

--- How to code depends on your project data structure.
--- It's a map with the structure lick <id, info>
--- @return table @Return the data of GuideTrigger.xlsx
function M.getGuideTriggerInfos()

end

--- How to code depends on your project data structure.
--- It's a map with the structure lick <id, info>
--- @return table @Return the data of GuideStep.xlsx
function M.getGuideStepInfos()
    -- ...
end
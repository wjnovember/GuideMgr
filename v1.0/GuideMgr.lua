local M = class("GuideMgr")

M.GroupId = {
    equip_skill         = 1
}

M.Cond = {
    card_lv_10          = 1
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

                return true
            end
        end
    end
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
        local card = form._card
        if card == nil then return false end

        return card._lv >= 10
    end

    return false
end

--- Custom coding
function M.hasTriggered(groupId)
    
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
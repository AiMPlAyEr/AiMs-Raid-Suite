ARS = ARS or {}

local pool
local timer = {}

local function CreateBuff(pool)
    local name      = "ARSTracker" .. pool:GetNextControlId()
    local container = WINDOW_MANAGER:CreateControlFromVirtual(name, ARSSingleTrackerFrame, "TrackerTemplate")

    container.stimer    = container:GetNamedChild('SynergyTimer')
    container.texture   = container:GetNamedChild("SynergyIcon")

    return container
end
 
local function RemoveBuff(control)
    control:SetHidden(true)
    control:ClearAnchors()
end

function ARS.UpdateTracker()
    pool:ReleaseAllObjects()
    
    local index = 1
    for k, v in ipairs(ARS.savedsolo.synergies) do
        if v then
            local trackerunit = pool:AcquireObject(k)
            trackerunit:SetAnchor(TOPLEFT, ARSSingleTrackerFrame, TOPLEFT, 61 * (index - 1), 0)

            trackerunit:SetHidden(false)
            trackerunit.texture:SetTexture(ARS.SynergyTexture[k])
            index = index + 1
        end
    end
end

function ARS.SetPosition()
    ARS.savedsolo.left  = ARSSingleTrackerFrame:GetLeft()
    ARS.savedsolo.top   = ARSSingleTrackerFrame:GetTop()
end

local function RestorePosition()
    ARSSingleTrackerFrame:ClearAnchors();
    ARSSingleTrackerFrame:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ARS.savedsolo.left, ARS.savedsolo.top)
end

local function AddToFragment(element)
    fragment = ZO_HUDFadeSceneFragment:New(element)
 
    HUD_SCENE:AddFragment(fragment)
    HUD_UI_SCENE:AddFragment(fragment)
end

local function SynergyCheck(eventCode, result, _, abilityName, _, _, _, sourceType, _, targetType, _, _, _, _, sourceUnitId, targetUnitId, abilityId)
    if (sourceType == COMBAT_UNIT_TYPE_PLAYER or sourceType == COMBAT_UNIT_TYPE_GROUP) then
        if ARS.savedsolo.synergies[ARS.Synergies[abilityId]] then 
            timer[ARS.Synergies[abilityId]] = GetFrameTimeSeconds() + 20
        end
    end
end

local function Cooldown()
    for k, v in pairs(timer) do
        local unit  = pool:AcquireObject(k)
        local rTime = math.floor(v - GetGameTimeSeconds())

        if rTime > 0 then
            unit.stimer:SetText(rTime)
            unit.texture:SetColor(0.3, 0.3, 0.3, 1)
        elseif rTime <= 0 then
            unit.stimer:SetText('0')
            unit.texture:SetColor(1, 1, 1, 1)
            timer[k] = nil
        end
    end
end

function ARS:InitializeTracker(enabled)
    if not enabled then return end

    local defaults = {
        synergies = {
            [1] = true,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [6] = false,
            [7] = false,
            [8] = false,
            [9] = false,
            [10] = false,
            [11] = false,
            [12] = false,
            [13] = false,
            [14] = false,
            [15] = false,
            [16] = false,
            [17] = false,
        },
        top = 500,
        left = 500,

    }

    ARS.savedsolo = ZO_SavedVars:NewCharacterIdSettings("ARSsaved", 1, "SoloTracker", defaults)

    pool = ZO_ObjectPool:New(CreateBuff, RemoveBuff)

    AddToFragment(ARSSingleTrackerFrame)

    ARS.UpdateTracker()
    RestorePosition()

    for k, v in pairs(ARS.Synergies) do
        EVENT_MANAGER:RegisterForEvent(ARS.name..k, EVENT_COMBAT_EVENT, SynergyCheck)
        EVENT_MANAGER:AddFilterForEvent(ARS.name..k, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, k)
    end

    EVENT_MANAGER:RegisterForUpdate(ARS.name .. "Cooldown", 100, Cooldown)
end
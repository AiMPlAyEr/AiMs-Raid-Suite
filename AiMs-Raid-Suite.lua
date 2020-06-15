ARS = ARS or {}

ARS.name = "AiMs-Raid-Suite"
ARS.suiteversion = "0.2"
ARS.default = {}

function ARS:Initialize()
	defaults = {
		synergytracker 	= true,
		grouptracker 	= false,
		synergyblocker 	= false,
	}

	ARS.savedgeneral = ZO_SavedVars:NewCharacterIdSettings("ARSsaved", 1, "general", defaults)

    ARS:InitializeSynergyTracker(ARS.savedgeneral.grouptracker) --group tracker
	ARS:InitializeTracker(ARS.savedgeneral.synergytracker) --solo tracker
	ARS:InitializeBlockingSynergies(ARS.savedgeneral.synergyblocker)

	ARS.SynergyTrackerSettings()
end

function ARS.OnAddOnLoaded(event, addonName)
	if addonName ~= ARS.name then return end
        ARS:Initialize()
end

EVENT_MANAGER:RegisterForEvent(ARS.name, EVENT_ADD_ON_LOADED, ARS.OnAddOnLoaded)
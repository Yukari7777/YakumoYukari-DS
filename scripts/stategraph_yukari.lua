local ActionHandler = GLOBAL.ActionHandler
local EventHandler = GLOBAL.EventHandler
local EQUIPSLOTS = GLOBAL.EQUIPSLOTS
local TimeEvent = GLOBAL.TimeEvent
local SpawnPrefab = GLOBAL.SpawnPrefab
local State = GLOBAL.State
local FRAMES = GLOBAL.FRAMES
local ACTIONS = GLOBAL.ACTIONS

local domediumaction = State({
    name = "domediumaction",

    onenter = function(inst)
        inst.sg:GoToState("dolongaction", .5)
    end,
})

AddStategraphState("wilson", domediumaction)

local function SetFastPicker(inst, action)
	if action.target.components.pickable then
        if action.target.components.pickable.quickpick or inst.fastactionlevel >= 1 then
            return "doshortaction"
        else
            return "dolongaction"
        end
    end
end

local function SetFastBuilder(inst, action)
	if action.recipe and action.recipe == "livinglog" and action.doer and action.doer.prefab == "wormwood" then
        return "form_log"
	elseif inst.fastactionlevel >= 2 then
		return "domediumaction"
    else            
        return "dolongaction"
    end
end

local function SetFastResetter(inst, action)
	return inst.fastactionlevel >= 3 and "doshortaction" or "dolongaction"
end

local function SetFastHarvester(inst, action) 
	return inst.fastactionlevel >= 4 and "doshortaction" or "dolongaction"
end

AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.PICK, SetFastPicker))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.BUILD, SetFastBuilder))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.RESETMINE, SetFastResetter))
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.HARVEST, SetFastHarvester))

local casttoho = State({
    name = "casttoho",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
       inst.AnimState:PlayAnimation("staff_pre")
       inst.AnimState:PushAnimation("staff", false)
	   inst.components.locomotor:Stop()

		--Spawn an effect on the player's location
        local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local colour = staff ~= nil and staff.fxcolour or {95/255,0,1}

        inst.sg.statemem.spellfx = SpawnPrefab("staffcastfx")
        inst.sg.statemem.spellfx.entity:SetParent(inst.entity)
        inst.sg.statemem.spellfx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.sg.statemem.spellfx:SetUp(colour)

        inst.sg.statemem.spelllight = SpawnPrefab("staff_castinglight")
        inst.sg.statemem.spelllight.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.sg.statemem.spelllight:SetUp(colour, 1.9, .33)

		inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "soundpack/spell/spelldt"
    end,
		
	timeline = 
	{
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("soundpack/spell/spelldt")
        end),
        TimeEvent(53 * FRAMES, function(inst)
            inst.sg.statemem.spellfx = nil --Can't be cancelled anymore
            inst.sg.statemem.spelllight = nil --Can't be cancelled anymore
            --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
            inst:PerformBufferedAction()
        end),
    },

	events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

	onexit = function(inst)
		if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
            inst.sg.statemem.stafffx:Remove()
        end
        if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
            inst.sg.statemem.stafflight:Remove()
        end
    end,
})

local casttoho = State({
    name = "casttoho",
    tags = {"doing", "busy", "canrotate"},

    onenter = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
       inst.AnimState:PlayAnimation("staff_pre")
       inst.AnimState:PushAnimation("staff", false)
	   inst.components.locomotor:Stop()

		--Spawn an effect on the player's location
        local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local colour = staff ~= nil and staff.fxcolour or {95/255,0,1}

        inst.sg.statemem.spellfx = SpawnPrefab("staffcastfx")
        inst.sg.statemem.spellfx.entity:SetParent(inst.entity)
        inst.sg.statemem.spellfx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.sg.statemem.spellfx:SetUp(colour)

        inst.sg.statemem.spelllight = SpawnPrefab("staff_castinglight")
        inst.sg.statemem.spelllight.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.sg.statemem.spelllight:SetUp(colour, 1.9, .33)

		inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "soundpack/spell/spelldt"
    end,
		
	timeline = 
	{
        TimeEvent(13 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("soundpack/spell/spelldt")
        end),
        TimeEvent(53 * FRAMES, function(inst)
            inst.sg.statemem.spellfx = nil --Can't be cancelled anymore
            inst.sg.statemem.spelllight = nil --Can't be cancelled anymore
            --V2C: NOTE! if we're teleporting ourself, we may be forced to exit state here!
            inst:PerformBufferedAction()
        end),
    },

	events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

	onexit = function(inst)
		if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
            inst.sg.statemem.stafffx:Remove()
        end
        if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
            inst.sg.statemem.stafflight:Remove()
        end
    end,
})

AddStategraphState("wilson", casttoho)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CASTTOHO, "casttoho"))

local casttohoh = State({
    name = "casttohoh",
    tags = {"doing", "busy"},

    onenter = function(inst)
        if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(false)
        end
		inst.components.health:SetInvincible(true)
        inst.AnimState:PlayAnimation("staff_pre")
        inst.AnimState:PushAnimation("staff", false)
        inst.components.locomotor:Stop()

		--Spawn an effect on the player's location
        local staff = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
        local colour = staff ~= nil and staff.fxcolour or {95/255,0,1}

        inst.sg.statemem.stafffx = SpawnPrefab("staffcastfx")
        inst.sg.statemem.stafffx.entity:SetParent(inst.entity)
        inst.sg.statemem.stafffx.Transform:SetRotation(inst.Transform:GetRotation())
        inst.sg.statemem.stafffx:SetUp(colour)

        inst.sg.statemem.stafflight = SpawnPrefab("staff_castinglight")
        inst.sg.statemem.stafflight.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inst.sg.statemem.stafflight:SetUp(colour, 1.9, .33)

		inst.sg.statemem.castsound = staff ~= nil and staff.castsound or "soundpack/spell/spelldt"
    end,
		
	timeline = 
	{
        TimeEvent(10 * FRAMES, function(inst)
            inst.SoundEmitter:PlaySound("soundpack/spell/bigspell")
        end),
        TimeEvent(67 * FRAMES, function(inst)
			inst.SoundEmitter:PlaySound("soundpack/spell/border")
            inst.sg.statemem.stafffx = nil 
            inst.sg.statemem.stafflight = nil --Can't be cancelled anymore
            inst:PerformBufferedAction()
        end),
    },

	events = {
        EventHandler("animqueueover", function(inst)
            if inst.AnimState:AnimDone() then
                inst.sg:GoToState("idle")
            end
        end),
    },

	onexit = function(inst)
		if inst.components.playercontroller ~= nil then
            inst.components.playercontroller:Enable(true)
        end
        if inst.sg.statemem.stafffx ~= nil and inst.sg.statemem.stafffx:IsValid() then
            inst.sg.statemem.stafffx:Remove()
        end
        if inst.sg.statemem.stafflight ~= nil and inst.sg.statemem.stafflight:IsValid() then
            inst.sg.statemem.stafflight:Remove()
        end
		inst.components.health:SetInvincible(false)
    end,
})

AddStategraphState("wilson", casttohoh)
AddStategraphActionHandler("wilson", ActionHandler(ACTIONS.CASTTOHOH, "casttohoh"))
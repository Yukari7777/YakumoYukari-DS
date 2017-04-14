require("stategraphs/commonstates")

local actionhandlers=
{
	
}

local events=
{

}

local states=
{
	State{
		name = "idle",
		tags = {"idle"},
		onenter = function(inst, playanim)
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("closed", true)
            else
                inst.AnimState:PlayAnimation("closed", true)
            end
		end,

	},
	
	State{
		name = "open",
		tags = {"idle", "open"},
		onenter = function(inst, playanim)
            if playanim then
                inst.AnimState:PlayAnimation(playanim)
                inst.AnimState:PushAnimation("open", true)
            else
                inst.AnimState:PlayAnimation("open", true)
            end
			
			
		end,
	},

	State{
		name = "opening",
		tags = {"busy", "opening"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("opening")
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/open", "wormhole_opening")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("open")
			end),
		},
	},
		
	State{
		name = "closing",
		tags = {"busy"},
		onenter = function(inst)
			inst.AnimState:PlayAnimation("closing")
			inst.SoundEmitter:PlaySound("dontstarve/common/teleportworm/close", "wormhole_closing")
		end,

		events=
		{
			EventHandler("animover", function(inst)
				inst.sg:GoToState("idle")
			end),
		},
	},
}

return StateGraph("tunnel", states, events, "idle", actionhandlers)
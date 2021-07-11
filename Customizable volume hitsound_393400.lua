local oldStatus = g_Config:FindVar("Visuals", "World", "Hit", "Hit Sound"):GetBool()
g_Config:FindVar("Visuals", "World", "Hit", "Hit Sound"):SetBool(false)
local sounds = 
{
    [0]                = "",
    [1]                = "doors/wood_stop1.wav",
    [2]                = "physics/wood/wood_strain7.wav",
    [3]                = "buttons/arena_switch_press_02.wav",
    [4]                = ""
}

soundname = menu.Combo("Hitsound", "HitSound", {"Off","Wood stop","Wood strain","Arena Switch","Custom"}, 0, "")
conditions = menu.MultiCombo("Hitsound", "Conditions", {"Attack Enemy", "Attack Teammate", "Attack Yourself"}, 1, "")
FileName = menu.TextBox("Hitsound", "FileName", 32, "", "")
TIPS = menu.Text("Hitsound", "Please note that there must be no space characters in the file name\nAll capitalization may also prevent play sound")
volume = menu.SliderInt("Hitsound","Sound Volume", 50, 0, 100)


local function check()
    if soundname:GetInt() == 4 then
        FileName:SetVisible(true)
		TIPS:SetVisible(true)
    else
        FileName:SetVisible(false)
		TIPS:SetVisible(false)
    end
end

soundname:RegisterCallback(function()
    check()
end)

check()

local function PlaySound()
    if soundname:GetInt() == 4 then
        g_EngineClient:ExecuteClientCmd(string.format("playvol nl_hitsound/%s %.2f", FileName:GetString(),volume:GetInt() / 100 ))
    else
        g_EngineClient:ExecuteClientCmd(string.format("playvol %s %.2f", sounds[soundname:GetInt()],volume:GetInt() / 100 ))
    end
end

local function events(event)
    local event_name = event:GetName()
    if event_name == "player_hurt" then
        local attacker = g_EngineClient:GetPlayerForUserId(event:GetInt("attacker", 0))
        local userid = g_EngineClient:GetPlayerForUserId(event:GetInt("userid", 0))

        local attacker_entity = g_EntityList:GetClientEntity(attacker):GetPlayer()
        local userid_entity = g_EntityList:GetClientEntity(userid):GetPlayer()

        if attacker == g_EngineClient:GetLocalPlayer() then
            if bit.band(conditions:GetInt(),1) == 1 and userid_entity:IsTeamMate() == false then -- is enemy
                PlaySound()
            end

            if bit.band(conditions:GetInt(),2) == 2 and userid_entity:IsTeamMate() == true then -- is TeamMate
                PlaySound()
            end

            if bit.band(conditions:GetInt(),4) == 4 and attacker_entity == userid_entity then
                PlaySound()
            end

        end
    end
end
cheat.RegisterCallback("events", events)
local function destroy()
    g_Config:FindVar("Visuals","World", "Hit", "Hit Sound"):SetBool(oldStatus)
end
cheat.RegisterCallback("destroy", destroy)
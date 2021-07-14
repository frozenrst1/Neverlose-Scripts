local WEAPON_ID_ZEUS = 31
local LocalDebug = menu.Switch("Zeus Warning","Draw LocalPlayer For Debug", false, "")
local DrawTeammate = menu.Switch("Zeus Warning","Draw Teammate", false, "")
local Circle_OffsetX = menu.SliderInt("Zeus Warning","Offset X", 0, -120, 120)
local Circle_OffsetY = menu.SliderInt("Zeus Warning","Offset Y", 0, -120, 120)
local Circle_Speed = menu.SliderFloat("Zeus Warning", "Animation Speed", 2.0, 0.1, 8.0, "")

local Circle_CenterCol = menu.ColorEdit("Zeus Warning","Center Color",Color.new(0.03, 0.03, 0.03, 0.78),"")
local Circle_OuterCol = menu.ColorEdit("Zeus Warning","Outer Color",Color.new(1.0, 1.0, 1.0, 1.0),"")
local Icon_Col = menu.ColorEdit("Zeus Warning","Icon Color",Color.new(1.0, 1.0, 1.0, 1.0),"")

local Circle_Star = 0
local Circle_End = 360

local function animation_run()
    if Circle_Star >= 360 then
        Circle_End = Circle_End + Circle_Speed:GetFloat()
    else
        Circle_Star = Circle_Star + Circle_Speed:GetFloat()
        Circle_End = 360
    end
    
    if Circle_End >= 720 then
        Circle_End = 0
    end
end

local function draw_warning(entity)
    local localplayer = g_EntityList:GetClientEntity(g_EngineClient:GetLocalPlayer())
    if LocalDebug:GetBool() == false then
        if localplayer == entity then
            return
        end
    end

    local player = entity:GetPlayer()
    if DrawTeammate:GetBool() == false then
        if player:IsTeamMate() == true and localplayer ~= entity then
            return
        end
    end

    if player:IsDormant() == true then
        return
    end

    local hitbox_center = player:GetHitboxCenter(0)
    local position2d = g_Render:ScreenPosition(hitbox_center)
    local ScreenPos = Vector2.new(position2d.x - Circle_OffsetX:GetInt(),position2d.y - Circle_OffsetY:GetInt())
    g_Render:CircleFilled(ScreenPos, 22.0, 30, Circle_CenterCol:GetColor())
    g_Render:CirclePart(ScreenPos, 22.0, 58, Circle_OuterCol:GetColor(), math.rad(Circle_Star), math.rad(Circle_End), 1.3)
    g_Render:WeaponIcon(WEAPON_ID_ZEUS, Vector2.new(ScreenPos.x - 14,ScreenPos.y - 10), Icon_Col:GetColor(), 23)
end

local function onPanel()
    if g_EngineClient:IsInGame() == true then
        animation_run()
        for i = 1, 64 do
            local entity = g_EntityList:GetClientEntity(i)
            if entity ~= nil then
                if entity:IsPlayer() == true then
                    local player = entity:GetPlayer()
                    if player ~= nil then
                        local weapon = player:GetActiveWeapon()
                        if weapon ~= nil then
                            local weapon_id = weapon:GetWeaponID()
                            if weapon_id == WEAPON_ID_ZEUS then
                                draw_warning(entity)
                            end
                        end
                    end
                end 
            end
        end
    end
end

cheat.RegisterCallback("draw", onPanel)
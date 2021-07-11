local QuckPeek_Bind = menu.Switch("Quick Peek", "Auto Peek", false, "")
local Circle_CenterCol = menu.ColorEdit("Quick Peek","Center Color",Color.new(1.0, 1.0, 1.0, 1.0),"")
local Circle_OuterCol = menu.ColorEdit("Quick Peek","Outer Color",Color.new(1.0, 1.0, 1.0, 1.0),"")
local pos
local hotkey_prev = false
local standing = true
local shots = 0

IN_ATTACK = 1
IN_JUMP = 2
N_DUCK = 4
IN_FORWARD = 8
IN_BACK = 16
IN_USE = 32
IN_CANCEL = 64
IN_LEFT = 128
IN_RIGHT = 256
IN_MOVELEFT = 512
IN_MOVERIGHT = 1024
IN_RUN = 4096
IN_RELOAD = 8192
IN_SPEED = 131072

local glb_cmd

local function distance3d(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1))
end

local function onPanel()
    local hotkey = QuckPeek_Bind:GetBool()
    if hotkey then
        if pos ~= nil then
            g_Render:Circle3DFilled(pos, 128, 18.0, Circle_CenterCol:GetColor())
            g_Render:Circle3D(pos, 128, 18.0, Circle_OuterCol:GetColor())
        end
    end
    if glb_cmd.sidemove >= 1 then
        --g_Render:Text(string.format("sidemove:%1.f", glb_cmd.sidemove), Vector2.new(800.0, 500.0), Color.new(1.0, 1.0, 1.0), 16)
    end
end

local M_PI = 3.14159265358979323846

local function vector_angles(x1, y1, z1, x2, y2, z2)
    local entity = g_EntityList:GetClientEntity(g_EngineClient:GetLocalPlayer())
    local player = entity:GetPlayer()
    local eye_pos = player:GetEyePosition()
    
	local origin_x, origin_y, origin_z
	local target_x, target_y, target_z

	if x2 == nil then
		target_x, target_y, target_z = x1, y1, z1
		origin_x, origin_y, origin_z = eye_pos.x,eye_pos.y,eye_pos.z
		if origin_x == nil then
			return
		end
	else
		origin_x, origin_y, origin_z = x1, y1, z1
		target_x, target_y, target_z = x2, y2, z2
	end

	local delta_x, delta_y, delta_z = target_x-origin_x, target_y-origin_y, target_z-origin_z

	if delta_x == 0 and delta_y == 0 then
		return (delta_z > 0 and 270 or 90), 0
	else
		local yaw = math.deg(math.atan2(delta_y, delta_x))
		local hyp = math.sqrt(delta_x*delta_x + delta_y*delta_y)
		local pitch = math.deg(math.atan2(-delta_z, hyp))

		return pitch, yaw
	end
end

local function ragebot_shot(ragebot_shot)
	shots = shots + 1
end

local function events(event)
    local event_name = event:GetName()
    local me = g_EntityList:GetClientEntity(g_EngineClient:GetLocalPlayer())
    if event_name == "weapon_fire" then
        local userid = g_EngineClient:GetPlayerForUserId(event:GetInt("userid", 0))
        if userid == g_EngineClient:GetLocalPlayer() then
            shots = shots + 1
        end
    end
end

local function Standing(cmd)
    if cmd.sidemove >= 0 and cmd.sidemove <= 120 then
        return true
    end

    if cmd.sidemove <= 0 and cmd.sidemove >= -120 then
        return true
    end

    if cmd.forwardmove >= 0 and cmd.forwardmove <= 120 then
        return true
    end

    if cmd.forwardmove <= 0 and cmd.forwardmove >= -120 then
        return true
    end

    return false
end

local function onCreateMove(cmd)
    glb_cmd = cmd
    local hotkey = QuckPeek_Bind:GetBool()
    if hotkey then
        local local_player = g_EntityList:GetClientEntity(g_EngineClient:GetLocalPlayer())
        if not hotkey_prev then
            pos = local_player:GetProp("m_vecOrigin")
            shots = 0
        end

        if not standing and distance3d(0, 0, 0, local_player:GetProp("m_vecVelocity[0]"),local_player:GetProp("m_vecVelocity[1]"),local_player:GetProp("m_vecVelocity[2]")) < 2 then
            standing = true
        elseif Standing(cmd) == true then
            standing = false
        end

        if shots == -1 or standing then
            local local_vecOri = local_player:GetProp("m_vecOrigin")
            if 10 > distance3d(local_vecOri.x, local_vecOri.y, local_vecOri.z, pos.x, pos.y, pos.z) then
                shots = 0
            else
                local pitch, yaw = vector_angles(local_vecOri.x, local_vecOri.y, local_vecOri.z, pos.x, pos.y, pos.z)
                local require_moving = false
                if not require_moving then
                    --cmd.buttons = bit.bor(cmd.buttons, IN_FORWARD)
                    cmd.sidemove = 0
                    cmd.upmove = 0
                    cmd.viewangles = QAngle.new(pitch,yaw,0)
                    cmd.forwardmove = 450
                    shots = -1
                end
            end
        end

        if bit.band(cmd.buttons,IN_ATTACK) == IN_ATTACK and shots > 0 then
            shots = -1
        end
    else
        shots = 0
        pos = nil
    end
    hotkey_prev = hotkey
end
cheat.RegisterCallback("createmove", onCreateMove)
cheat.RegisterCallback("draw", onPanel)
cheat.RegisterCallback("ragebot_shot", ragebot_shot)
cheat.RegisterCallback("events", events)
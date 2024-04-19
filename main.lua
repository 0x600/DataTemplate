local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ProfileService = require(script.ProfileService)

local Data = {}
local Profiles = {} -- {[player] = {_player = player, _profile = profile}}

local ProfileStoreIndex = if RunService:IsServer() then "prod" else "dev"
local ProfileStore = ProfileService.GetProfileStore(ProfileStoreIndex, {
	-- add your values here
	-- eg. Clicks = 0
})

function Data:fetchData(player: Player)
	local profile = Profiles[player]
	
	if profile ~= nil then
		return profile._profile.Data
	else
		warn("player no no profile!")
	end
end

function Data:incrementValue(player: Player, value: string, increment: number)
	local profile = Profiles[player]
	
	if profile ~= nil then
		-- print(profile._profile)
		profile._profile.Data[value] += increment
	else
		warn(`cannot set {value} to {player.Name}!`)
	end
end

Players.PlayerAdded:Connect(function(player)
	local profile = ProfileStore:LoadProfileAsync(`{player.UserId}/DATA`)
	
	if profile ~= nil then
		profile:AddUserId(player.UserId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			Profiles[player] = nil
		end)
		
		if player:IsDescendantOf(Players) then
			Profiles[player] = {
				_player = player,
				_profile = profile,
			}
		else
			profile._profile:Release()
		end
	else
		player:Kick("Unable to load your data, try again later.")
	end
end)

Players.PlayerRemoving:Connect(function(player)
	local profile = Profiles[player]
	
	if profile ~= nil then
		profile._profile:Release()
	else
		return
	end
end)

return Data

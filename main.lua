local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local PLACE_ID = game.PlaceId

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MainMenu"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.5, -75)
frame.BackgroundTransparency = 0.1
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 45)
title.Text = "Main Menu"
title.TextScaled = true
title.BackgroundTransparency = 1
title.Parent = frame

local hopButton = Instance.new("TextButton")
hopButton.Size = UDim2.new(0.8, 0, 0, 50)
hopButton.Position = UDim2.new(0.1, 0, 0.45, 0)
hopButton.Text = "Server Hop"
hopButton.TextScaled = true
hopButton.Parent = frame

local function getSmallServer()
	local url = "https://games.roblox.com/v1/games/" ..
		PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"

	local success, result = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not success then
		return nil
	end

	local data = HttpService:JSONDecode(result)

	for _, server in ipairs(data.data) do
		if server.id ~= game.JobId
			and server.playing <= 4
			and server.max

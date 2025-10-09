local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

_G.workout = true

function workout()
    while wait() do
        game:GetService("ReplicatedStorage"):WaitForChild("StrongmanWorkout_TriggerWorkoutGain"):FireServer()
     end
    end

--WINDOW
local Window = Rayfield:CreateWindow({
   Name = "💪 Strongman Ultra",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "💪 Strongman Ultra",
   LoadingSubtitle = "by crzn999",
   ShowText = "", -- for mobile users to unhide rayfield, change if you'd like
   Theme = "Default", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from warning when the script has a version mismatch with the interface

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Big Hub"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include discord.gg/. E.g. discord.gg/ ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that will be accepted by the system, can be RAW file links (pastebin, github etc) or simple strings ("hello","key22")
   }
})
--TELEPORT TAB
local Tab = Window:CreateTab("Teleport", 4483362458)

-- Dropdown for teleport locations
local teleportDropdown = Tab:CreateDropdown({
    Name = "Choose Teleport Location",
    Options = {"None", "Spawn", "Area 2", "Area 3", "Area 4"},
    CurrentOption = {"None"}, -- <-- default is now None
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(selected)
        local locationName = selected[1]
        if locationName == "None" then
            return -- do nothing if None is selected
        end
        teleportTo(locationName)
    end,
})


-- Teleport coordinates
local teleportPoints = {
    ["Spawn"] = Vector3.new(320.415283203125, 26.927330017089844, 79.33695220947266),
    ["Area 2"] = Vector3.new(320.15753173828125, 26.52733039855957, -129.78140258789062),
    ["Area 3"] = Vector3.new(319.9266357421875, 26.68018913269043, -313.67681884765625),
    ["Area 4"] = Vector3.new(320.3466796875, 26.858694076538086, -538.7765502929688),
}

-- Teleport function
function teleportTo(name)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart")

    local pos = teleportPoints[name]
    if pos then
        root.CFrame = CFrame.new(pos)
        Rayfield:Notify({
            Title = "Teleport Success",
            Content = "Teleported to " .. name,
            Duration = 3
        })
    else
        warn("Teleport point not found: " .. tostring(name))
        Rayfield:Notify({
            Title = "Teleport Failed",
            Content = "Unknown teleport location.",
            Duration = 3
        })
    end
end

--FARM TAB
local Tab = Window:CreateTab("Farm", 4483362458)

--// Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Constants
local KEY_TO_SPAM = Enum.KeyCode.E
local WAIT_TIME = 0.02
local FARM_POS = Vector3.new(351.9051818847656, 26.52733039855957, -582.2877197265625)

-- DragGoal
local DragGoal = workspace.Areas.Area_004_Livingroom.DragArea.DragGoal
local originalSize = DragGoal and DragGoal:IsA("BasePart") and DragGoal.Size or nil

-- State
local farming = false

-- Spam E function
local function startSpam()
	while farming do
		if VirtualInputManager and VirtualInputManager.SendKeyEvent then
			VirtualInputManager:SendKeyEvent(true, KEY_TO_SPAM, false, game)
			task.wait(0.005)
			VirtualInputManager:SendKeyEvent(false, KEY_TO_SPAM, false, game)
		else
			UserInputService:SimulateKeyPress(KEY_TO_SPAM)
		end
		task.wait(WAIT_TIME)
	end
end

-- Wiggle function (moves slightly along Z axis)
local function wigglePosition(character, center, amplitude, stepDelay)
	local root = character:WaitForChild("HumanoidRootPart")
	task.spawn(function()
		while farming do
			for i = -amplitude, amplitude, 0.1 do
				root.CFrame = CFrame.new(center.X, center.Y, center.Z + i)
				task.wait(stepDelay)
			end
			for i = amplitude, -amplitude, -0.1 do
				root.CFrame = CFrame.new(center.X, center.Y, center.Z + i)
				task.wait(stepDelay)
			end
		end
	end)
end

-- Lock/Unlock functions
local function lockPosition(character, position)
	local root = character:WaitForChild("HumanoidRootPart")
	root.CFrame = CFrame.new(position)
	-- do NOT permanently anchor; let wiggle move the character
end

-- Main Toggle
Tab:CreateToggle({
	Name = "Auto Farm",
	CurrentValue = false,
	Flag = "AutoFarmToggle",
	Callback = function(value)
		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()

		if value then
			farming = true
			lockPosition(character, FARM_POS)

			-- Expand DragGoal
			if DragGoal and DragGoal:IsA("BasePart") then
				DragGoal.Size = Vector3.new(150, 75, 400) -- slightly bigger X/Y for reliability
			end

			-- Start wiggle to simulate movement
			wigglePosition(character, FARM_POS, 1, 0.03) -- ±1 stud, small step delay

			-- Start E spam
			task.spawn(startSpam)

			Rayfield:Notify({
				Title = "Auto Farm Enabled",
				Content = "Spamming E with subtle movement...",
				Duration = 3
			})

		else
			farming = false

			-- Restore DragGoal size
			if DragGoal and originalSize and DragGoal:IsA("BasePart") then
				DragGoal.Size = originalSize
			end

			Rayfield:Notify({
				Title = "Auto Farm Disabled",
				Content = "Stopped farming.",
				Duration = 3
			})
		end
	end,
})

--WORKOUT TAB
local Tab = Window:CreateTab("Workout", 4483362458)
local Toggle = Tab:CreateToggle({
   Name = "Workout",
   CurrentValue = false,
   Flag = "Toggle1", -- A flag is the identifier for the configuration file, make sure every element has a different flag if you're using configuration saving to ensure no overlaps
   Callback = function(Value)
        _G.workout = Value
        workout()
   end,
})

Rayfield:LoadConfiguration()

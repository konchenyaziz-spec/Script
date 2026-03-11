local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.9 Global",
   LoadingTitle = "idkkkk hub",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local text_svc = game:GetService("TextService")
local players = game:GetService("Players")

local settings = {
    ai_enabled = false,
    esp_enabled = false,
    fov_value = 70,
    following_target = nil
}

-- [[ GLOBAL CHAT SYSTEM ]]
local function aiChat(msg)
    local success, err = pcall(function()
        local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
            chatEvents.SayMessageRequest:FireServer(msg, "All")
        else
            local tcs = game:GetService("TextChatService")
            if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                tcs.TextChannels.RBXGeneral:SendAsync(msg)
            end
        end
    end)
end

-- Filter Check
local function isFiltered(text)
    local success, result = pcall(function()
        return text_svc:FilterStringAsync(text, lp.UserId):GetNonChatStringForBroadcastAsync()
    end)
    return success and result:find("#")
end

-- [[ IDK AI CORE ]]
local function handleAiCommand(sender, message)
    if not settings.ai_enabled then return end
    
    local raw_msg = message:lower()
    if not raw_msg:find("idkai") then return end

    -- Command Processing
    if raw_msg:find("follow me") then
        settings.following_target = sender
        aiChat("Understood, " .. sender.Name .. ". I am now following you.")
    
    elseif raw_msg:find("say") then
        local content = message:match("[sS][aA][yY]%s+(.+)")
        if content then
            if isFiltered(content) then
                aiChat("Sorry, this word is blocked by game filters.")
            else
                aiChat(content)
            end
        end

    elseif raw_msg:find("jump") then
        local count = tonumber(raw_msg:match("jump%s+(%d+)")) or 1
        aiChat("Acknowledged. Jumping " .. count .. " times.")
        task.spawn(function()
            for i = 1, count do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.6)
            end
        end)

    elseif raw_msg:find("stop") then
        settings.following_target = nil
        aiChat("All active AI tasks have been stopped.")
    
    else
        -- Unrecognized command starting with IDKAI
        aiChat("sorry, its not added in my system:(")
    end
end

-- Listen to chat
players.PlayerChatted:Connect(function(chatType, sender, message)
    if sender ~= lp then
        handleAiCommand(sender, message)
    end
end)

-- Follow Logic
run_svc.Heartbeat:Connect(function()
    if settings.ai_enabled and settings.following_target and settings.following_target.Character then
        local targetChar = settings.following_target.Character
        local myChar = lp.Character
        if myChar and myChar:FindFirstChild("Humanoid") and targetChar:FindFirstChild("HumanoidRootPart") then
            myChar.Humanoid:MoveTo(targetChar.HumanoidRootPart.Position - (targetChar.HumanoidRootPart.CFrame.LookVector * 5))
        end
    end
end)

-- [[ VISUALS ]]
local highlights = {}
local function updateESP()
    for _, p in pairs(players:GetPlayers()) do
        if p ~= lp and p.Character then
            local high = p.Character:FindFirstChild("IDK_High")
            if settings.esp_enabled then
                if not high then
                    high = Instance.new("Highlight")
                    high.Name = "IDK_High"
                    high.Parent = p.Character
                    high.FillColor = Color3.fromRGB(0, 255, 255)
                    high.OutlineColor = Color3.fromRGB(255, 255, 255)
                    high.FillTransparency = 0.5
                end
            else
                if high then high:Destroy() end
            end
        end
    end
end

-- [[ TABS ]]

local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)
local AiTab = Window:CreateTab("IDK AI", "bot")
local SocialTab = Window:CreateTab("Socials", 4483345906)

-- AI Toggle
AiTab:CreateToggle({
   Name = "Activate IDK AI",
   CurrentValue = false,
   Callback = function(Value)
       settings.ai_enabled = Value
       if Value then
           aiChat("Hello, I am IDK AI. Write 'IDKAI' followed by your request and I will obey!")
       else
           settings.following_target = nil
       end
   end,
})

-- Visuals
VisualTab:CreateToggle({
   Name = "Player Highlight ESP",
   CurrentValue = false,
   Callback = function(v)
       settings.esp_enabled = v
       updateESP()
   end,
})

VisualTab:CreateSlider({
   Name = "Camera FOV",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(v) workspace.CurrentCamera.FieldOfView = v end,
})

-- Main
MainTab:CreateSlider({
   Name = "Speed",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end,
})

-- Socials
SocialTab:CreateButton({
   Name = "Telegram: @idkkkk_dev",
   Callback = function() setclipboard("https://t.me/idkkkk_dev") end,
})

run_svc.Stepped:Connect(updateESP)

Rayfield:Notify({Title = "idkkkk hub", Content = "Global Version 2.9 Loaded", Duration = 3})

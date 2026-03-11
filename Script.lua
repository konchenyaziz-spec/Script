local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.8 AI & Visuals",
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

-- Вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)
local AiTab = Window:CreateTab("IDK AI", "bot")
local SocialTab = Window:CreateTab("Socials", 4483345906)

-- [[ СИСТЕМА ЧАТА ]]
local function aiChat(msg)
    local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
    if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
        chatEvents.SayMessageRequest:FireServer(msg, "All")
    else
        -- Для нового чата Roblox (TextChatService)
        local tcs = game:GetService("TextChatService")
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            tcs.TextChannels.RBXGeneral:SendAsync(msg)
        end
    end
end

-- Проверка фильтрации
local function isFiltered(text)
    local success, result = pcall(function()
        return text_svc:FilterStringAsync(text, lp.UserId):GetNonChatStringForBroadcastAsync()
    end)
    return success and result:find("#")
end

-- [[ ЛОГИКА IDK AI ]]
local function handleAiCommand(sender, message)
    if not settings.ai_enabled then return end
    
    local raw_msg = message:lower()
    if not raw_msg:find("idkai") then return end

    -- Разбор команды
    if raw_msg:find("follow me") then
        settings.following_target = sender
        aiChat("OK, " .. sender.Name .. "! I am following you now.")
    
    elseif raw_msg:find("say") then
        local content = message:match("[sS][aA][yY]%s+(.+)")
        if content then
            if isFiltered(content) then
                aiChat("извини, данное слово запрещено правилами игры")
            else
                aiChat(content)
            end
        end

    elseif raw_msg:find("jump") then
        local count = tonumber(raw_msg:match("jump%s+(%d+)")) or 1
        aiChat("Jumping " .. count .. " times for you!")
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
        aiChat("I stopped following.")
    
    else
        -- Если команда начинается с IDKAI, но не распознана
        aiChat("sorry, its not added in my system:(")
    end
end

-- Обработка чата
players.PlayerChatted:Connect(function(chatType, sender, message)
    if sender ~= lp then
        handleAiCommand(sender, message)
    end
end)

-- Следование
run_svc.RenderStepped:Connect(function()
    if settings.ai_enabled and settings.following_target and settings.following_target.Character then
        local targetChar = settings.following_target.Character
        local myChar = lp.Character
        if myChar and myChar:FindFirstChild("Humanoid") and targetChar:FindFirstChild("HumanoidRootPart") then
            myChar.Humanoid:MoveTo(targetChar.HumanoidRootPart.Position - (targetChar.HumanoidRootPart.CFrame.LookVector * 4))
        end
    end
end)

-- [[ VISUALS LOGIC ]]
local esp_highlights = {}

local function createESP(player)
    if player == lp then return end
    local function addHighlight()
        if player.Character and not esp_highlights[player] then
            local highlight = Instance.new("Highlight")
            highlight.Parent = player.Character
            highlight.FillColor = Color3.fromRGB(255, 0, 0)
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.FillTransparency = 0.5
            highlight.Enabled = settings.esp_enabled
            esp_highlights[player] = highlight
        end
    end
    player.CharacterAdded:Connect(addHighlight)
    addHighlight()
end

players.PlayerAdded:Connect(createESP)
for _, p in pairs(players:GetPlayers()) do createESP(p) end

-- [[ UI ]]

-- AI TAB
AiTab:CreateToggle({
   Name = "Activate IDK AI",
   CurrentValue = false,
   Callback = function(Value)
       settings.ai_enabled = Value
       if Value then
           aiChat("Hello, I am IDK AI. write IDKAI your wish and he will carry out all orders!")
           Rayfield:Notify({Title = "IDK AI", Content = "Бот активирован и поприветствовал игроков!", Duration = 3})
       else
           settings.following_target = nil
       end
   end,
})

-- VISUALS TAB
VisualTab:CreateToggle({
   Name = "Player ESP (Highlights)",
   CurrentValue = false,
   Callback = function(v)
       settings.esp_enabled = v
       for _, h in pairs(esp_highlights) do
           if h then h.Enabled = v end
       end
   end,
})

VisualTab:CreateSlider({
   Name = "Field of View (FOV)",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(v)
       workspace.CurrentCamera.FieldOfView = v
   end,
})

-- MAIN TAB (Speed & Jump)
MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end,
})

MainTab:CreateButton({
   Name = "Reset Character",
   Callback = function() if lp.Character then lp.Character:BreakJoints() end end,
})

-- SOCIALS
SocialTab:CreateButton({
   Name = "Copy Discord ID",
   Callback = function() setclipboard("idkkkk_dev") end,
})

Rayfield:Notify({Title = "Loaded", Content = "v2.8 Ready!", Duration = 2})

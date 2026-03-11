--[[
    IDK AI v5.5 - Interactive & Social
    Оптимизировано для Delta. 
    Бот теперь сам объясняет правила и отвечает игрокам.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v5.5 Interactive AI",
   LoadingTitle = "Starting IDK AI...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local players = game:GetService("Players")

local settings = {
    ai_active = false,
    following = nil,
    prefix = "idkai"
}

-- [[ УНИВЕРСАЛЬНАЯ СИСТЕМА ЧАТА ]]
local function aiChat(msg)
    local success, err = pcall(function()
        local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
            chatEvents.SayMessageRequest:FireServer(msg, "All")
        else
            local tcs = game:GetService("TextChatService")
            if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
                if channel then channel:SendAsync(msg) end
            end
        end
    end)
end

-- [[ ИНТЕРАКТИВНЫЙ МОЗГ ]]
local function handleChat(sender, text)
    if not settings.ai_active or sender == lp then return end
    
    local msg = text:lower()
    -- Проверка обращения
    if not msg:find(settings.prefix) then return end

    -- Эффект "раздумья" (опционально можно добавить задержку)
    
    -- 1. Команда: JUMP
    if msg:find("jump") then
        local count = tonumber(msg:match("(%d+)")) or 3
        if count > 20 then count = 20 end
        
        aiChat("Of course, " .. sender.Name .. "! I will jump " .. count .. " times for you.")
        task.spawn(function()
            for i = 1, count do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.7)
            end
            aiChat("Done! What's next?")
        end)
        return
    end

    -- 2. Команда: FOLLOW
    if msg:find("follow") or msg:find("come") then
        settings.following = sender
        aiChat("Roger that! I am now following " .. sender.Name .. ".")
        return
    end

    -- 3. Команда: STOP
    if msg:find("stop") or msg:find("stay") then
        settings.following = nil
        aiChat("Stopping. I will stay here until your next command.")
        return
    end

    -- 4. Команда: SAY
    if msg:find("say") then
        local content = text:match("[sS][aA][yY]%s+(.+)")
        if content then
            -- Проверка на "плохие" слова (базовая)
            if content:find("badword") or #content > 100 then
                aiChat("Sorry, I can't say that. It might violate the rules.")
            else
                aiChat(content)
            end
        else
            aiChat("Tell me what exactly you want me to say!")
        end
        return
    end

    -- 5. Неизвестная команда
    aiChat("sorry, its not added in my system:( Please try: jump, follow, or say.")
end

-- [[ ЦИКЛЫ ]]
players.PlayerChatted:Connect(handleChat)

run_svc.Heartbeat:Connect(function()
    if settings.ai_active and settings.following and settings.following.Character then
        local myChar = lp.Character
        local targetRoot = settings.following.Character:FindFirstChild("HumanoidRootPart")
        if myChar and myChar:FindFirstChild("Humanoid") and targetRoot then
            myChar.Humanoid:MoveTo(targetRoot.Position + Vector3.new(3, 0, 3))
        end
    end
end)

-- [[ ИНТЕРФЕЙС ]]
local AiTab = Window:CreateTab("IDK AI", "bot")
local VisualTab = Window:CreateTab("Visuals", 4483346362)

AiTab:CreateToggle({
   Name = "Activate IDK AI Brain",
   CurrentValue = false,
   Callback = function(v)
       settings.ai_active = v
       if v then
           -- Приветствие и инструкция
           aiChat("Hello! I am IDK AI. To use me, write 'idkai' and then your wish!")
           aiChat("Example: 'idkai jump 5 times' or 'idkai follow me'.")
           Rayfield:Notify({Title = "AI Active", Content = "Инструкция отправлена в чат!", Duration = 4})
       else
           settings.following = nil
           aiChat("IDK AI is going offline. Goodbye!")
       end
   end,
})

AiTab:CreateSection("AI Helper Settings")
AiTab:CreateLabel("Status: Active & Listening")

-- Вкладка Визуалов (ESP)
VisualTab:CreateToggle({
   Name = "ESP Highlights",
   CurrentValue = false,
   Callback = function(v)
       for _, p in pairs(players:GetPlayers()) do
           if p ~= lp and p.Character then
               local h = p.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", p.Character)
               h.Enabled = v
               h.FillColor = Color3.fromRGB(255, 85, 0)
           end
       end
   end,
})

Rayfield:Notify({
    Title = "idkkkk hub",
    Content = "v5.5 Ready! Type idkai in chat to start.",
    Duration = 5
})

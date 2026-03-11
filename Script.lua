--[[
    IDK AI v5.0 - Hybrid Intelligence
    Оптимизировано для Delta Executor.
    Работает БЕЗ внешнего API ключа (использует локальный парсер смыслов).
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v5.0 HYBRID AI",
   LoadingTitle = "Initializing AI Core...",
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
    auto_jump = false
}

-- [[ УНИВЕРСАЛЬНАЯ СИСТЕМА ЧАТА ]]
local function aiChat(msg)
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
end

-- [[ LOCAL AI BRAIN (SENSE ANALYZER) ]]
-- Этот блок заменяет Gemini, если нет API ключа. Он ищет намерения.
local function processIntent(sender, text)
    if not settings.ai_active or sender == lp then return end
    
    local msg = text:lower()
    if not msg:find("idkai") then return end

    -- 1. Намерение: Прыжки
    if msg:find("jump") or msg:find("hop") or msg:find("bounce") then
        local count = tonumber(msg:match("(%d+)")) or 5
        if count > 30 then count = 30 end
        
        aiChat("Understood, " .. sender.Name .. ". Performing " .. count .. " jumps now.")
        task.spawn(function()
            for i = 1, count do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.6)
            end
        end)
        return
    end

    -- 2. Намерение: Следование
    if msg:find("follow") or msg:find("come") or msg:find("behind") then
        settings.following = sender
        aiChat("Target locked. I'm following you, " .. sender.Name .. "!")
        return
    end

    -- 3. Намерение: Остановка
    if msg:find("stop") or msg:find("stay") or msg:find("wait") or msg:find("freeze") then
        settings.following = nil
        aiChat("Stopping all active tasks. Standing by.")
        return
    end

    -- 4. Намерение: Повторение (Say)
    if msg:find("say") or msg:find("repeat") or msg:find("talk") then
        local content = text:match("[sS][aA][yY]%s+(.+)") or text:match("[rR][eE][pP][eE][aA][tT]%s+(.+)")
        if content then
            aiChat(content)
        else
            aiChat("What do you want me to say?")
        end
        return
    end

    -- 5. Если команда не ясна
    aiChat("Sorry, my system doesn't recognize that command yet. Try: jump, follow, say, or stop.")
end

-- [[ LOOPS ]]
players.PlayerChatted:Connect(processIntent)

run_svc.Heartbeat:Connect(function()
    if settings.ai_active and settings.following and settings.following.Character then
        local myChar = lp.Character
        local targetRoot = settings.following.Character:FindFirstChild("HumanoidRootPart")
        if myChar and myChar:FindFirstChild("Humanoid") and targetRoot then
            myChar.Humanoid:MoveTo(targetRoot.Position + Vector3.new(2, 0, 2))
        end
    end
end)

-- [[ INTERFACE ]]
local MainTab = Window:CreateTab("Main", 4483362458)
local AiTab = Window:CreateTab("IDK AI (Hybrid)", "bot")
local VisualTab = Window:CreateTab("Visuals", 4483346362)

AiTab:CreateToggle({
   Name = "Activate IDK AI Brain",
   CurrentValue = false,
   Callback = function(v)
       settings.ai_active = v
       if v then
           aiChat("Hello! IDK AI v5.0 Hybrid Mode is active. I can hear your commands now!")
       else
           settings.following = nil
       end
   end,
})

AiTab:CreateSection("AI Info")
AiTab:CreateLabel("Mode: Hybrid (No API Key Required)")

-- Visuals (ESP)
VisualTab:CreateToggle({
   Name = "Player Highlights",
   CurrentValue = false,
   Callback = function(v)
       for _, p in pairs(players:GetPlayers()) do
           if p ~= lp and p.Character then
                local h = p.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", p.Character)
                h.Enabled = v
                h.FillColor = Color3.fromRGB(0, 255, 255)
           end
       end
   end,
})

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 200},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end,
})

Rayfield:Notify({
    Title = "idkkkk hub",
    Content = "Hybrid AI is ready. No API key needed!",
    Duration = 5
})

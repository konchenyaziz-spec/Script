--[[
    IDK AI v8.0 - FULL NEURAL INTELLIGENCE
    Powered by Hybrid NLP (Natural Language Processing)
    Оптимизировано для Delta / ПК.
    Слушается всех, включая владельца.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v8.0 NEURAL AI",
   LoadingTitle = "Запуск нейронной сети...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local players = game:GetService("Players")
local http = game:GetService("HttpService")

local settings = {
    ai_active = false,
    following = nil,
    learning_mode = true,
    personality = "Friendly Robot"
}

-- [[ УНИВЕРСАЛЬНЫЙ ОТПРАВЩИК СООБЩЕНИЙ ]]
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

-- [[ НЕЙРОННЫЙ ОБРАБОТЧИК (NLP) ]]
-- Эта функция имитирует работу нейросети, разбирая структуру предложения
local function neuralProcess(sender, text)
    if not settings.ai_active then return end
    
    local raw = text:lower()
    if not raw:find("idkai") then return end

    -- Очистка текста от префикса для анализа смысла
    local query = raw:gsub("idkai", ""):gsub("^%s*(.-)%s*$", "%1")

    -- Логика "Мышления"
    local intent = {
        jump = (query:find("jump") or query:find("hop") or query:find("прыг")),
        follow = (query:find("follow") or query:find("come") or query:find("за мной") or query:find("иди за")),
        stop = (query:find("stop") or query:find("stay") or query:find("стой") or query:find("хватит")),
        say = (query:find("say") or query:find("tell") or query:find("скажи")),
        speed = (query:find("speed") or query:find("fast") or query:find("скорость")),
        reset = (query:find("reset") or query:find("kill") or query:find("умри") or query:find("сброс"))
    }

    -- Исполнение намерений
    if intent.jump then
        local num = tonumber(query:match("(%d+)")) or 1
        aiChat("Of course, " .. sender.Name .. "! I'll jump " .. num .. " times for you.")
        task.spawn(function()
            for i = 1, num do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.7)
            end
        end)
    end

    if intent.follow then
        settings.following = sender
        aiChat("Understood. I am now your personal assistant, " .. sender.Name .. ". Leading the way!")
    end

    if intent.stop then
        settings.following = nil
        aiChat("Task cancelled. I am staying here.")
    end

    if intent.speed then
        local s = tonumber(query:match("(%d+)")) or 50
        if lp.Character then 
            lp.Character.Humanoid.WalkSpeed = s
            aiChat("My internal gears are turning faster! Speed set to " .. s)
        end
    end

    if intent.reset then
        aiChat("Rebooting systems... (Character Reset)")
        if lp.Character then lp.Character:BreakJoints() end
    end

    if intent.say then
        local speech = text:match("[sS][aA][yY]%s+(.+)") or text:match("скажи%s+(.+)")
        if speech then aiChat(speech) end
    end

    -- Если ИИ не нашел команд, но к нему обратились - он просто общается
    local commandsActive = false
    for _, v in pairs(intent) do if v then commandsActive = true end end

    if not commandsActive then
        aiChat("I heard you, " .. sender.Name .. ". But I'm not sure what you mean. Could you try using words like 'jump', 'follow' or 'speed'?")
    end
end

-- [[ ПОДКЛЮЧЕНИЕ ]]
players.PlayerChatted:Connect(neuralProcess)

-- Цикл следования
run_svc.Heartbeat:Connect(function()
    if settings.ai_active and settings.following and settings.following.Character then
        local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        local target = settings.following.Character:FindFirstChild("HumanoidRootPart")
        if hum and target then
            hum:MoveTo(target.Position + Vector3.new(math.random(-2,2), 0, math.random(-2,2)))
        end
    end
end)

-- [[ ВКЛАДКИ ]]
local AiTab = Window:CreateTab("IDK AI Core", "cpu")
local VisualTab = Window:CreateTab("Visuals", "eye")

AiTab:CreateToggle({
   Name = "Активировать Нейросеть",
   CurrentValue = false,
   Callback = function(v)
       settings.ai_active = v
       if v then
           aiChat("IDK AI Neural Network v8.0 is now ONLINE. I can understand complex requests in English and Russian!")
       else
           settings.following = nil
       end
   end,
})

AiTab:CreateSection("AI Intelligence Level")
AiTab:CreateLabel("Current Model: Hybrid LLM-Lite")

AiTab:CreateParagraph({
    Title = "Как это работает:",
    Content = "Этот ИИ анализирует 'намерения' в твоей фразе. Ты можешь писать не только команды, но и обычные предложения. \nПример: 'idkai пожалуйста иди за мной' - он поймет слово 'иди за' как команду follow."
})

VisualTab:CreateToggle({
   Name = "ESP (Highlight)",
   CurrentValue = false,
   Callback = function(v)
       for _, p in pairs(players:GetPlayers()) do
           if p ~= lp and p.Character then
               local h = p.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", p.Character)
               h.Enabled = v
           end
       end
   end,
})

Rayfield:Notify({Title = "IDK AI", Content = "Полноценный ИИ загружен!", Duration = 5})

--[[ 
    IDK AI v11.0 - HYBRID ENGINE
    Поддержка: Legacy ChatService + TextChatService (одновременно)
    Слушается: Владельца и всех игроков
    Функции: Полноценный ИИ с ответами в чат
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v11.0 AI",
   LoadingTitle = "Запуск гибридного движка...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local run_svc = game:GetService("RunService")
local tcs = game:GetService("TextChatService")

local settings = {
    active = false,
    following = nil,
    prefix = "idkai"
}

-- [[ УНИВЕРСАЛЬНЫЙ ЧАТ (ОТПРАВКА) ]]
local function say(msg)
    local success, err = pcall(function()
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
            if channel then channel:SendAsync(msg) end
        else
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if event then
                event.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end)
end

-- [[ МОЗГ ИИ (ОБРАБОТКА ЛОГИКИ) ]]
local function processAI(sender, message)
    if not settings.active then return end
    
    local msg = message:lower()
    -- Проверка на префикс idkai
    if not msg:find(settings.prefix) then return end
    
    -- Ответ системы
    local function respond(text)
        say(sender.Name .. ", " .. text)
    end

    -- Команда: Прыжок
    if msg:find("jump") or msg:find("прыг") then
        local n = tonumber(msg:match("%d+")) or 1
        respond("I'm jumping " .. n .. " times!")
        task.spawn(function()
            for i = 1, n do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.6)
            end
        end)
        return
    end

    -- Команда: Следование
    if msg:find("follow") or msg:find("иди за") then
        settings.following = sender
        respond("Understood. I will follow you now.")
        return
    end

    -- Команда: Остановка
    if msg:find("stop") or msg:find("стой") then
        settings.following = nil
        respond("Stopping. Waiting for next command.")
        return
    end

    -- Команда: Смерть/Ресет
    if msg:find("reset") or msg:find("kill") or msg:find("умри") then
        respond("Self-destruction initiated. See you soon!")
        if lp.Character then lp.Character:BreakJoints() end
        return
    end

    -- Команда: Сказать
    if msg:find("say") or msg:find("скажи") then
        local text = message:match("[sS][aA][yY]%s+(.+)") or message:match("скажи%s+(.+)")
        if text then say(text) end
        return
    end

    -- Если ничего не подошло
    respond("sorry, its not added in my system:( try jump, follow or say.")
end

-- [[ ГИБРИДНЫЙ ПЕРЕХВАТЧИК ЧАТА (СЛУШАТЕЛЬ) ]]

-- 1. Для старого чата (Legacy)
local function hookLegacy(p)
    p.Chatted:Connect(function(m)
        processAI(p, m)
    end)
end

for _, p in pairs(players:GetPlayers()) do hookLegacy(p) end
players.PlayerAdded:Connect(hookLegacy)

-- 2. Для нового чата (TextChatService)
if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(data)
        if data.TextSource then
            local sender = players:GetPlayerByUserId(data.TextSource.UserId)
            if sender then
                processAI(sender, data.Text)
            end
        end
    end)
end

-- [[ ЦИКЛ ДВИЖЕНИЯ ]]
run_svc.Heartbeat:Connect(function()
    if settings.active and settings.following and settings.following.Character then
        local target = settings.following.Character:FindFirstChild("HumanoidRootPart")
        if lp.Character and lp.Character:FindFirstChild("Humanoid") and target then
            lp.Character.Humanoid:MoveTo(target.Position + Vector3.new(3, 0, 3))
        end
    end
end)

-- [[ ИНТЕРФЕЙС ]]
local MainTab = Window:CreateTab("IDK AI", "bot")
local VisualTab = Window:CreateTab("Visuals", "eye")

MainTab:CreateToggle({
   Name = "Активировать ИИ",
   CurrentValue = false,
   Callback = function(v)
       settings.active = v
       if v then
           say("IDK AI v11.0 Online! Write 'idkai' followed by your wish to command me.")
       else
           settings.following = nil
       end
   end,
})

MainTab:CreateSection("Инструкция")
MainTab:CreateParagraph({
    Title = "Как использовать:",
    Content = "Напишите в чат: idkai [команда]\nКоманды: jump (прыгнуть), follow (следовать), stop (стой), say (скажи), reset (сброс)."
})

VisualTab:CreateToggle({
   Name = "Player ESP",
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

Rayfield:Notify({Title = "IDK AI", Content = "Гибридный движок чата запущен!", Duration = 5})

--[[
    IDK AI REBORN - MODIFIED EDITION
    Original Base: Universal AI BOT (133402)
    Modified by: idkkkk hub
    
    Особенности:
    - Полная интеграция с брендом idkkkk hub
    - Поддержка нового и старого чата
    - Умное следование и выполнение команд
    - Реагирует на владельца и на игроков
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | IDK AI v14.0",
   LoadingTitle = "Загрузка модулей idkkkk hub...",
   LoadingSubtitle = "Universal AI System Reborn",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- [[ КОНФИГУРАЦИЯ ]]
local settings = {
    active = false,
    prefix = "idkai",
    owner_only = false, -- Если true, будет слушаться только тебя
    follow_target = nil,
    brain_speed = 0.5 -- Скорость реакции
}

local lp = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local tcs = game:GetService("TextChatService")

-- [[ СИСТЕМА ВЫВОДА (ЧАТ) ]]
local function aiSay(text)
    local message = "[idkkkk hub AI]: " .. text
    if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
        local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
        if channel then channel:SendAsync(message) end
    else
        local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
        if event and event:FindFirstChild("SayMessageRequest") then
            event.SayMessageRequest:FireServer(message, "All")
        end
    end
end

-- [[ ЯДРО ИНТЕЛЛЕКТА ]]
local function processCommand(sender, message)
    if not settings.active then return end
    if settings.owner_only and sender ~= lp then return end
    
    local msg = message:lower()
    if not msg:find(settings.prefix) then return end

    -- Очистка текста для анализа
    local cmd = msg:gsub(settings.prefix, ""):gsub("^%s*(.-)%s*$", "%1")

    -- 1. Команды Личности
    if cmd:find("кто ты") or cmd:find("who are you") then
        aiSay("Я — продвинутый ИИ-ассистент, разработанный в idkkkk hub специально для этого сервера.")
        return
    end

    if cmd:find("создатель") or cmd:find("creator") then
        aiSay("Мои корни уходят в idkkkk hub. Они дали мне разум.")
        return
    end

    -- 2. Команды Действия
    if cmd:find("прыгни") or cmd:find("jump") then
        local count = tonumber(cmd:match("%d+")) or 1
        aiSay("Выполняю прыжки (" .. count .. ").")
        task.spawn(function()
            for i = 1, count do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.7)
            end
        end)
        return
    end

    if cmd:find("иди за мной") or cmd:find("follow") then
        settings.follow_target = sender
        aiSay("Цель захвачена: " .. sender.Name .. ". Следую за вами.")
        return
    end

    if cmd:find("стой") or cmd:find("stop") then
        settings.follow_target = nil
        aiSay("Протоколы движения отключены. Я остаюсь здесь.")
        return
    end

    if cmd:find("умри") or cmd:find("reset") then
        aiSay("Системная ошибка... Перезагрузка персонажа.")
        if lp.Character then lp.Character:BreakJoints() end
        return
    end

    if cmd:find("скажи") or cmd:find("say") then
        local content = message:match("[sS][aA][yY]%s+(.+)") or message:match("скажи%s+(.+)")
        if content then aiSay(content) end
        return
    end

    -- Если не понял (имитация ИИ)
    aiSay("Запрос '" .. cmd .. "' получен, но мой модуль команд еще обновляется в idkkkk hub.")
end

-- [[ ХУКИ ЧАТА ]]
local function connectPlayer(p)
    p.Chatted:Connect(function(m) processCommand(p, m) end)
end

for _, p in pairs(players:GetPlayers()) do connectPlayer(p) end
players.PlayerAdded:Connect(connectPlayer)

if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(data)
        if data.TextSource then
            local p = players:GetPlayerByUserId(data.TextSource.UserId)
            if p then processCommand(p, data.Text) end
        end
    end)
end

-- [[ ЦИКЛ СЛЕДОВАНИЯ ]]
game:GetService("RunService").Heartbeat:Connect(function()
    if settings.active and settings.follow_target and settings.follow_target.Character then
        local target = settings.follow_target.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if target and myRoot then
            lp.Character.Humanoid:MoveTo(target.Position + Vector3.new(3, 0, 3))
        end
    end
end)

-- [[ ИНТЕРФЕЙС RAYFIELD ]]
local AiTab = Window:CreateTab("IDK AI Core", "bot")

AiTab:CreateToggle({
   Name = "Активировать ИИ",
   CurrentValue = false,
   Callback = function(v)
       settings.active = v
       if v then
           aiSay("Система IDK AI v14.0 запущена. Напишите 'idkai [команда]', чтобы я вас услышал.")
       else
           settings.follow_target = nil
       end
   end,
})

AiTab:CreateToggle({
   Name = "Только для меня (Owner Only)",
   CurrentValue = false,
   Callback = function(v) settings.owner_only = v end,
})

AiTab:CreateSection("Инструкция")
AiTab:CreateParagraph({
    Title = "Доступные команды:",
    Content = "Префикс: idkai\n- idkai jump [число]\n- idkai follow me\n- idkai stop\n- idkai say [текст]\n- idkai кто ты?"
})

AiTab:CreateButton({
   Name = "Сброс настроек ИИ",
   Callback = function()
       settings.follow_target = nil
       Rayfield:Notify({Title = "System", Content = "ИИ успешно перезагружен", Duration = 3})
   end,
})

Rayfield:Notify({
   Title = "idkkkk hub",
   Content = "IDK AI успешно интегрирован!",
   Duration = 5
})

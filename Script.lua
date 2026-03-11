--[[
    IDK AI - ROBLOX CHAT BOT
    Инструкция:
    1. Нажмите F9 после запуска, чтобы увидеть статус подключения.
    2. Команда в чате: idkai [ваш вопрос]
]]

repeat task.wait() until game:IsLoaded()

-- // КОНФИГУРАЦИЯ \\ --
local SETTINGS = {
    API_KEY = "Sk-ijklmnopqrstuvwxijklmnopqrstuvwxijklmnop", -- Ваш ключ
    PREFIX = "idkai",
    HUB_NAME = "IDK AI BOT",
    COOLDOWN = 5, -- Задержка между ответами (анти-спам)
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local isBusy = false
local request = (syn and syn.request) or (http and http.request) or http_request or request

-- // ФУНКЦИЯ ОТПРАВКИ В ЧАТ \\ --
local function sendMessage(text)
    local success, err = pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("RBXGeneral", true) or TextChatService:FindFirstChild("All", true)
            if channel then
                channel:SendAsync(text)
            end
        else
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(text, "All")
        end
    end)
    if not success then
        warn("Ошибка отправки в чат: " .. tostring(err))
    end
end

-- // ЗАПРОС К OPENAI \\ --
local function getAIResponse(prompt)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. SETTINGS.API_KEY
    }
    
    local body = HttpService:JSONEncode({
        model = "gpt-3.5-turbo",
        messages = {
            {role = "system", content = "Ты помощник в игре Roblox. Отвечай кратко на русском языке."},
            {role = "user", content = prompt}
        },
        max_tokens = 100
    })

    if not request then
        return "Ошибка: Ваш чит не поддерживает HTTP-запросы."
    end

    local success, result = pcall(function()
        return request({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    if not success then return "Ошибка сети." end
    
    if result.StatusCode == 200 then
        local data = HttpService:JSONDecode(result.Body)
        return data.choices[1].message.content
    elseif result.StatusCode == 401 then
        return "Ошибка: Неверный API ключ (401)."
    elseif result.StatusCode == 429 then
        return "Ошибка: Превышен лимит запросов или нет средств на балансе."
    else
        return "Ошибка API: " .. tostring(result.StatusCode)
    end
end

-- // ОБРАБОТЧИК СООБЩЕНИЙ \\ --
local function onChatted(sender, message)
    if sender == LocalPlayer then return end
    
    local lowerMsg = message:lower()
    if string.find(lowerMsg, "^" .. SETTINGS.PREFIX) then
        if isBusy then return end
        
        local query = message:sub(#SETTINGS.PREFIX + 2)
        if #query < 3 then return end

        isBusy = true
        print("[" .. SETTINGS.HUB_NAME .. "] Обработка запроса от " .. sender.Name)
        
        local response = getAIResponse(query)
        
        -- Ограничение длины сообщения Roblox (200 символов)
        if #response > 190 then
            response = response:sub(1, 187) .. "..."
        end
        
        sendMessage(sender.Name .. ", " .. response)
        
        task.wait(SETTINGS.COOLDOWN)
        isBusy = false
    end
end

-- // ЗАПУСК \\ --
print("--- " .. SETTINGS.HUB_NAME .. " ЗАГРУЖЕН ---")
print("Используйте префикс: " .. SETTINGS.PREFIX)

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg) onChatted(player, msg) end)
end

Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg) onChatted(player, msg) end)
end)

sendMessage("🤖 [" .. SETTINGS.HUB_NAME .. "] запущен! Напишите '" .. SETTINGS.PREFIX .. " привет', чтобы проверить.")

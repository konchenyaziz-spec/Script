--[[
    IDK AI - INTERACTIVE VERSION
    Скрипт автоматически объявляет о себе в чате при запуске.
]]

repeat task.wait() until game:IsLoaded()

-- // КОНФИГУРАЦИЯ \\ --
local SETTINGS = {
    API_KEY = "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",
    PREFIX = "idkai", -- Префикс для команд
    HUB_NAME = "IDKKKK HUB",
    COOLDOWN = 5, -- Задержка между ответами (секунды)
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local isBusy = false

-- // ФУНКЦИЯ ОТПРАВКИ В ЧАТ \\ --
local function sendMessage(text)
    task.spawn(function()
        local message = tostring(text)
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("RBXGeneral", true) or TextChatService:FindFirstChild("All", true)
            if channel then
                channel:SendAsync(message)
            end
        else
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if remote and remote:FindFirstChild("SayMessageRequest") then
                remote.SayMessageRequest:FireServer(message, "All")
            end
        end
    end)
end

-- // ПРИВЕТСТВИЕ ПРИ ЗАПУСКЕ \\ --
local function announceStartup()
    task.wait(2) -- Небольшая пауза, чтобы чат успел прогрузиться
    local welcomeMsg = string.format(
        "🤖 [%s] ЗАГРУЖЕН! | Префикс: '%s' | Пример: %s привет!", 
        SETTINGS.HUB_NAME, 
        SETTINGS.PREFIX, 
        SETTINGS.PREFIX
    )
    sendMessage(welcomeMsg)
end

-- // ЗАПРОС К НЕЙРОСЕТИ \\ --
local function fetchAIResponse(prompt)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. SETTINGS.API_KEY
    }
    
    local body = HttpService:JSONEncode({
        model = "gpt-3.5-turbo",
        messages = {
            {role = "system", content = "You are an assistant for " .. SETTINGS.HUB_NAME .. ". Answer briefly and helpfully in the user's language."},
            {role = "user", content = prompt}
        },
        max_tokens = 150
    })

    -- Пытаемся использовать доступные методы запросов в чите
    local requestMethod = (syn and syn.request) or (http and http.request) or http_request or request
    
    if not requestMethod then
        return "❌ Ошибка: Ваш чит не поддерживает HTTP запросы."
    end

    local success, result = pcall(function()
        return requestMethod({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    if not success then return "❌ Ошибка соединения." end
    
    if result.StatusCode == 200 then
        local data = HttpService:JSONDecode(result.Body)
        return data.choices[1].message.content
    elseif result.StatusCode == 429 then
        return "❌ Ошибка: Закончились токены или лимит API (429)."
    else
        return "❌ Ошибка API: Код " .. tostring(result.StatusCode)
    end
end

-- // ЛОГИКА ОБРАБОТКИ СООБЩЕНИЙ \\ --
local function handleChat(sender, message)
    if sender == LocalPlayer or isBusy then return end
    
    local rawText = message:lower()
    -- Проверка на наличие префикса в начале сообщения
    if rawText:sub(1, #SETTINGS.PREFIX) == SETTINGS.PREFIX then
        isBusy = true
        
        -- Извлекаем сам вопрос (убираем префикс)
        local query = message:sub(#SETTINGS.PREFIX + 1):gsub("^%s*(.-)%s*$", "%1")
        
        if query == "" or query == " " then
            sendMessage("❓ Напишите вопрос после префикса. Пример: " .. SETTINGS.PREFIX .. " как дела?")
        else
            sendMessage("⏳ [IDK AI] Думаю...")
            local response = fetchAIResponse(query)
            sendMessage("💬 @ " .. sender.Name .. ": " .. response)
        end
        
        task.wait(SETTINGS.COOLDOWN)
        isBusy = false
    end
end

-- // ПОДКЛЮЧЕНИЕ СОБЫТИЙ \\ --
Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(msg) handleChat(player, msg) end)
end)

for _, player in ipairs(Players:GetPlayers()) do
    player.Chatted:Connect(function(msg) handleChat(player, msg) end)
end

-- Поддержка нового TextChatService
if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
    TextChatService.MessageReceived:Connect(function(data)
        if data.TextSource then
            local sender = Players:GetPlayerByUserId(data.TextSource.UserId)
            if sender then handleChat(sender, data.Text) end
        end
    end)
end

-- Запуск
announceStartup()

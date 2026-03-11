--[[
    IDK AI - DEBUG & FIX VERSION
    Этот скрипт включает логирование ошибок в чат, чтобы понять, почему "не работает".
    ВАЖНО: Для работы API OpenAI в Roblox часто требуется прокси-сервер.
]]

repeat task.wait() until game:IsLoaded()

-- // НАСТРОЙКИ \\ --
local SECRET_KEY = "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"
local PREFIX = "idkai"
local HUB_NAME = "idkkkk hub"

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local tcs = game:GetService("TextChatService")
local debounce = false

-- // ФУНКЦИЯ ОТПРАВКИ СООБЩЕНИЙ \\ --
local function aiSay(text)
    local formatted = "[IDK AI SYSTEM]: " .. tostring(text)
    warn(formatted) -- Дублируем в консоль (F9)
    task.spawn(function()
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
            if channel then channel:SendAsync(formatted) end
        else
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if event and event:FindFirstChild("SayMessageRequest") then
                event.SayMessageRequest:FireServer(formatted, "All")
            end
        end
    end)
end

-- // НЕЙРОСЕТЬ С ЛОГИРОВАНИЕМ \\ --
local function getAiResponse(userPrompt)
    -- Пытаемся отправить запрос
    local requestHeaders = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. SECRET_KEY
    }
    
    local requestBody = HttpService:JSONEncode({
        model = "gpt-3.5-turbo",
        messages = {
            {role = "system", content = "You are a helpful assistant from idkkkk hub. Answer in English."},
            {role = "user", content = userPrompt}
        }
    })

    local success, response = pcall(function()
        -- Используем универсальный обработчик запросов для читов
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or request
        if not httpRequest then
            return "ERROR: Your executor (чит) does not support HTTP requests."
        end

        return httpRequest({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = requestHeaders,
            Body = requestBody
        })
    end)

    if not success then
        return "CONNECTION ERROR: " .. tostring(response)
    end

    if response then
        -- Проверка статус-кода
        if response.StatusCode == 401 then
            return "API ERROR: Invalid API Key (401)."
        elseif response.StatusCode == 429 then
            return "API ERROR: Rate limit or No Funds (429)."
        elseif response.StatusCode ~= 200 then
            return "API ERROR: Code " .. tostring(response.StatusCode)
        end

        local data = HttpService:JSONDecode(response.Body)
        if data.choices and data.choices[1] then
            return data.choices[1].message.content
        end
    end

    return "Unknown error occurred."
end

-- // ОБРАБОТЧИК ЧАТА \\ --
local function onChatted(sender, message)
    if sender == lp or debounce then return end
    local msg = message:lower()
    
    if msg:find(PREFIX) then
        debounce = true
        local query = msg:gsub(PREFIX, ""):gsub("^%s*(.-)%s*$", "%1")
        
        aiSay("Thinking...")
        local response = getAiResponse(query)
        aiSay(response)
        
        task.wait(3)
        debounce = false
    end
end

-- ПОДКЛЮЧЕНИЕ
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(m) onChatted(p, m) end)
end)

for _, p in pairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(m) onChatted(p, m) end)
end

if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(data)
        if data.TextSource then
            local sender = Players:GetPlayerByUserId(data.TextSource.UserId)
            if sender then onChatted(sender, data.Text) end
        end
    end)
end

aiSay("Debug Mode Online. Type 'idkai hello' to test.")

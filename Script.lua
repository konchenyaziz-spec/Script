--[[
    IDK AI - QUANTUM ENGLISH EDITION
    Developed by: idkkkk hub
    
    FIXES:
    1. Fully translated to English.
    2. Anti-Blur logic for the initial announcement.
    3. Support for Legacy and TextChatService.
]]

repeat task.wait() until game:IsLoaded()

-- // CONFIGURATION \\ --
local SETTINGS = {
    API_KEY = "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", -- Replace with your active key
    PREFIX = "idkai",
    HUB_NAME = "idkkkk hub",
    COOLDOWN = 5,
}

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TextChatService = game:GetService("TextChatService")
local LocalPlayer = Players.LocalPlayer

local isBusy = false
local request = (syn and syn.request) or (http and http.request) or http_request or request

-- // UNIVERSAL CHAT SYSTEM \\ --
local function sendMessage(text)
    local success, err = pcall(function()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = TextChatService:FindFirstChild("RBXGeneral", true) or TextChatService:FindFirstChild("All", true)
            if channel then
                channel:SendAsync(text)
            end
        else
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if remote and remote:FindFirstChild("SayMessageRequest") then
                remote.SayMessageRequest:FireServer(text, "All")
            end
        end
    end)
    if not success then warn("Chat Error: " .. tostring(err)) end
end

-- // AI ENGINE (GPT-3.5) \\ --
local function getAIResponse(prompt)
    local headers = {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bearer " .. SETTINGS.API_KEY
    }
    
    local body = HttpService:JSONEncode({
        model = "gpt-3.5-turbo",
        messages = {
            {role = "system", content = "You are an AI assistant from idkkkk hub. Speak only in English. Be concise and helpful."},
            {role = "user", content = prompt}
        },
        max_tokens = 80
    })

    if not request then return "Error: Executor does not support HTTP requests." end

    local success, result = pcall(function()
        return request({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = headers,
            Body = body
        })
    end)

    if not success then return "Error: Connection failed." end
    
    if result.StatusCode == 200 then
        local data = HttpService:JSONDecode(result.Body)
        return data.choices[1].message.content
    elseif result.StatusCode == 429 then
        return "Error: Rate limit reached or No funds."
    else
        return "Error Code: " .. tostring(result.StatusCode)
    end
end

-- // COMMAND HANDLER \\ --
local function handleChat(sender, message)
    if sender == LocalPlayer or isBusy then return end
    
    local raw = message:lower()
    if string.sub(raw, 1, #SETTINGS.PREFIX) == SETTINGS.PREFIX then
        isBusy = true
        
        -- Extract the query (removing prefix and spaces)
        local query = message:sub(#SETTINGS.PREFIX + 1):gsub("^%s*(.-)%s*$", "%1")
        
        if query == "" or query == " " then
            sendMessage("Query required. Example: " .. SETTINGS.PREFIX .. " hello!")
        else
            -- Small delay to simulate thinking and avoid filter detection
            task.wait(0.5)
            local response = getAIResponse(query)
            
            -- Roblox Message Length Guard (max ~200)
            if #response > 190 then response = response:sub(1, 187) .. "..." end
            
            sendMessage("@" .. sender.Name .. ": " .. response)
        end
        
        task.wait(SETTINGS.COOLDOWN)
        isBusy = false
    end
end

-- // INITIALIZATION \\ --
local function boot()
    print("--- [" .. SETTINGS.HUB_NAME .. "] INITIALIZED ---")
    
    -- Anti-Filter Startup: We send the info in parts to avoid the blur
    task.wait(2)
    sendMessage("IDK AI System Activated.")
    task.wait(1)
    sendMessage("Prefix: " .. SETTINGS.PREFIX .. " | Developed by " .. SETTINGS.HUB_NAME)
    
    -- Listeners
    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg) handleChat(player, msg) end)
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        player.Chatted:Connect(function(msg) handleChat(player, msg) end)
    end

    if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
        TextChatService.MessageReceived:Connect(function(data)
            if data.TextSource then
                local sender = Players:GetPlayerByUserId(data.TextSource.UserId)
                if sender then handleChat(sender, data.Text) end
            end
        end)
    end
end

boot()

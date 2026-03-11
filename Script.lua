--[[
    IDK AI QUANTUM EDITION - ENGLISH VERSION
    Modified by: idkkkk hub
    Status: Fully Translated to English
    
    SYSTEM FEATURES: 
    - AI Model: GPT-3.5-Turbo
    - Identity: idkkkk hub Official AI
    - Commands: jump, follow, reset, ask
]]

repeat task.wait() until game:IsLoaded()

-- // IDKKKK HUB CONFIGURATION \\ --
-- Using the provided API Key
local SECRET_KEY = "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"
local PREFIX = "idkai"
local HUB_NAME = "idkkkk hub"
local CLOSE_RANGE_ONLY = true -- Bot hears only nearby players

_G.AI_SETTINGS = {
    ["MIN_CHARS"] = 2,
    ["MAX_STUDS"] = 30, 
    ["COOLDOWN"] = 5,
    ["SYSTEM_PROMPT"] = "You are IDK AI, a robotic assistant from idkkkk hub. Speak only in English. Be precise and helpful."
}

-- // SERVICES \\ --
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local tcs = game:GetService("TextChatService")
local debounce = false

-- // REQUEST HANDLER (Modern Synapse/Delta/Wave Request) \\ --
local req = syn and syn.request or http_request or request

-- // UNIVERSAL CHAT OUTPUT (Supports All Games) \\ --
local function aiSay(text)
    local formatted = "[IDK AI]: " .. text
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

-- // NEURAL CORE (GPT-3.5-TURBO) \\ --
local function getAiResponse(userPrompt)
    local success, result = pcall(function()
        local response = req({
            Url = "https://api.openai.com/v1/chat/completions",
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = "Bearer " .. SECRET_KEY
            },
            Body = HttpService:JSONEncode({
                model = "gpt-3.5-turbo",
                messages = {
                    {role = "system", content = _G.AI_SETTINGS.SYSTEM_PROMPT},
                    {role = "user", content = userPrompt}
                },
                max_tokens = 70,
                temperature = 0.8
            })
        })
        return HttpService:JSONDecode(response.Body).choices[1].message.content
    end)
    
    if success then return result else return "System error: Connection to neural network lost." end
end

-- // INPUT ANALYZER \\ --
local function onChatted(sender, message)
    if sender == lp or debounce then return end
    
    local rawMsg = message:lower()
    
    -- Detect Prefix
    if not rawMsg:find(PREFIX) then return end
    
    -- Range Filter
    if CLOSE_RANGE_ONLY then
        if not sender.Character or not lp.Character then return end
        local dist = (sender.Character.PrimaryPart.Position - lp.Character.PrimaryPart.Position).Magnitude
        if dist > _G.AI_SETTINGS.MAX_STUDS then return end
    end
    
    debounce = true
    local userQuery = rawMsg:gsub(PREFIX, ""):gsub("^%s*(.-)%s*$", "%1")
    
    -- Hardcoded Action Modules
    if userQuery:find("who are you") or userQuery:find("creator") then
        aiSay("I am IDK AI, an advanced intelligence system developed by " .. HUB_NAME .. ".")
    elseif userQuery:find("jump") then
        aiSay("Instruction received. Performing jump sequence.")
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.Jump = true
        end
    elseif userQuery:find("reset") or userQuery:find("die") then
        aiSay("Rebooting character systems...")
        if lp.Character then lp.Character:BreakJoints() end
    else
        -- AI Conversation Module
        local response = getAiResponse(userQuery)
        aiSay(response)
    end
    
    task.wait(_G.AI_SETTINGS.COOLDOWN)
    debounce = false
end

-- // SYSTEM BOOT \\ --
for _, p in pairs(Players:GetPlayers()) do
    p.Chatted:Connect(function(m) onChatted(p, m) end)
end
Players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(m) onChatted(p, m) end)
end)

-- TextChatService Listener
if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(data)
        if data.TextSource then
            local sender = Players:GetPlayerByUserId(data.TextSource.UserId)
            if sender then onChatted(sender, data.Text) end
        end
    end)
end

warn("IDK AI Quantum Hub Edition Loaded Successfully!")
aiSay("Systems online. idkkkk hub AI is ready to assist you in English.")

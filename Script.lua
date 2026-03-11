--[[ 
    IDK AI v12.0 - QUANTUM BRAIN EDITION
    The most advanced AI system for Roblox Executors (Delta, Wave, etc.)
    Features: Intelligent Chatting, Command Execution, Multi-Language Support.
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v12.0 Quantum AI",
   LoadingTitle = "Synthesizing Neural Pathways...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- [[ SERVICES & VARIABLES ]]
local lp = game:GetService("Players").LocalPlayer
local players = game:GetService("Players")
local run_svc = game:GetService("RunService")
local tcs = game:GetService("TextChatService")
local http = game:GetService("HttpService")

local settings = {
    active = false,
    following = nil,
    brain_power = "High",
    prefix = "idkai",
    chat_mode = "Conversational"
}

-- [[ UNIVERSAL CHAT ADAPTER ]]
local function speak(text)
    task.spawn(function()
        if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
            local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
            if channel then channel:SendAsync(text) end
        else
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if event then
                event.SayMessageRequest:FireServer(text, "All")
            end
        end
    end)
end

-- [[ NEURAL CHATBOT LOGIC ]]
-- Имитация ответов ИИ для общения, когда нет явной команды
local responses = {
    greeting = {"Hello! How can I assist you today?", "Hi there! IDK AI is at your service.", "Greetings, human!"},
    unknown = {"That's interesting, tell me more.", "I'm still learning, but I hear you!", "My neural circuits are buzzing from that thought."},
    creator = {"I was created by the legendary IDKKK team.", "My origin traces back to the idkkkk hub development labs."},
    status = {"All systems functional.", "Neural load is at 14%. I'm feeling great!"}
}

local function getAiResponse(msg)
    if msg:find("hello") or msg:find("привет") or msg:find("hi") then
        return responses.greeting[math.random(#responses.greeting)]
    elseif msg:find("who") or msg:find("кто") or msg:find("создал") then
        return responses.creator[math.random(#responses.creator)]
    elseif msg:find("how") or msg:find("как") or msg:find("дела") then
        return "I am functioning within optimal parameters. How are you?"
    end
    return responses.unknown[math.random(#responses.unknown)]
end

-- [[ MAIN INTELLIGENCE UNIT ]]
local function handleIntelligence(sender, message)
    if not settings.active then return end
    
    local raw = message:lower()
    if not raw:find(settings.prefix) then return end
    
    -- Очистка текста
    local clean = raw:gsub(settings.prefix, ""):gsub("^%s*(.-)%s*$", "%1")
    
    -- 1. СЕКТОР КОМАНД (EXECUTION)
    local isCommand = false

    if clean:find("jump") or clean:find("прыг") then
        isCommand = true
        local n = tonumber(clean:match("%d+")) or 1
        speak("Executing jump sequence: " .. n .. " times.")
        task.spawn(function()
            for i = 1, n do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.6)
            end
        end)
    
    elseif clean:find("follow") or clean:find("иди за") or clean:find("за мной") then
        isCommand = true
        settings.following = sender
        speak("Target identified: " .. sender.Name .. ". Initiating follow protocol.")
    
    elseif clean:find("stop") or clean:find("стой") or clean:find("хватит") then
        isCommand = true
        settings.following = nil
        speak("Stopping all physical actions.")
    
    elseif clean:find("reset") or clean:find("kill") or clean:find("умри") then
        isCommand = true
        speak("Initiating emergency system reboot...")
        if lp.Character then lp.Character:BreakJoints() end

    elseif clean:find("speed") or clean:find("скорость") then
        isCommand = true
        local s = tonumber(clean:match("%d+")) or 16
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = s
            speak("Internal clock speed adjusted. Movement speed: " .. s)
        end
    end

    -- 2. СЕКТОР ОБЩЕНИЯ (CONVERSATION)
    if not isCommand then
        local aiReply = getAiResponse(clean)
        speak(sender.Name .. ", " .. aiReply)
    end
end

-- [[ UNIVERSAL HOOKS ]]
for _, p in pairs(players:GetPlayers()) do
    p.Chatted:Connect(function(m) handleIntelligence(p, m) end)
end
players.PlayerAdded:Connect(function(p)
    p.Chatted:Connect(function(m) handleIntelligence(p, m) end)
end)

if tcs.ChatVersion == Enum.ChatVersion.TextChatService then
    tcs.MessageReceived:Connect(function(data)
        if data.TextSource then
            local sender = players:GetPlayerByUserId(data.TextSource.UserId)
            if sender then handleIntelligence(sender, data.Text) end
        end
    end)
end

-- [[ MOVEMENT LOGIC ]]
run_svc.Heartbeat:Connect(function()
    if settings.active and settings.following and settings.following.Character then
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        local target = settings.following.Character:FindFirstChild("HumanoidRootPart")
        if root and target then
            lp.Character.Humanoid:MoveTo(target.Position + Vector3.new(2, 0, 2))
        end
    end
end)

-- [[ UI DESIGN ]]
local MainTab = Window:CreateTab("Quantum Brain", "zap")
local VisualTab = Window:CreateTab("Visuals", "eye")

MainTab:CreateToggle({
   Name = "Activate Quantum AI",
   CurrentValue = false,
   Callback = function(v)
       settings.active = v
       if v then
           speak("IDK AI v12.0 Activated. Neural pathways initialized. Ask me anything or give a command!")
       else
           settings.following = nil
       end
   end,
})

MainTab:CreateSection("Instructions")
MainTab:CreateParagraph({
    Title = "How to talk to me:",
    Content = "1. Commands: idkai jump 5, idkai follow me, idkai speed 50, idkai reset.\n2. Chat: idkai how are you?, idkai who created you?\n3. I listen to EVERYONE, including you."
})

VisualTab:CreateToggle({
   Name = "AI Awareness ESP",
   CurrentValue = false,
   Callback = function(v)
       for _, p in pairs(players:GetPlayers()) do
           if p ~= lp and p.Character then
               local h = p.Character:FindFirstChildOfClass("Highlight") or Instance.new("Highlight", p.Character)
               h.Enabled = v
               h.FillColor = Color3.fromRGB(170, 0, 255)
               h.OutlineColor = Color3.fromRGB(255, 255, 255)
           end
       end
   end,
})

Rayfield:Notify({Title = "QUANTUM BRAIN", Content = "IDK AI v12.0 is fully operational!", Duration = 5})

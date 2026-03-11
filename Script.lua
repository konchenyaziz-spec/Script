local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v3.0 AI Edition",
   LoadingTitle = "IDK AI System Loading...",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- [[ SERVICES ]]
local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local text_svc = game:GetService("TextService")
local players = game:GetService("Players")

-- [[ SETTINGS ]]
local settings = {
    ai_enabled = false,
    esp_enabled = false,
    following_target = nil,
    ai_prefix = "idkai"
}

-- [[ UNIVERSAL CHAT SYSTEM ]]
local function aiChat(msg)
    task.spawn(function()
        local success, err = pcall(function()
            -- Try Legacy Chat
            local chatEvents = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if chatEvents and chatEvents:FindFirstChild("SayMessageRequest") then
                chatEvents.SayMessageRequest:FireServer(msg, "All")
            else
                -- Try Modern TextChatService
                local tcs = game:GetService("TextChatService")
                if tcs and tcs.ChatVersion == Enum.ChatVersion.TextChatService then
                    local channel = tcs:FindFirstChild("RBXGeneral", true) or tcs:FindFirstChild("All", true)
                    if channel then channel:SendAsync(msg) end
                end
            end
        end)
    end)
end

-- [[ AI BRAIN - BETTER RECOGNITION ]]
local function processAI(sender, message)
    if not settings.ai_enabled or sender == lp then return end
    
    local msg = message:lower()
    if not msg:find(settings.ai_prefix) then return end

    -- Trigger detected
    print("AI detected command from: " .. sender.Name)

    -- Command: JUMP
    if msg:find("jump") then
        local times = tonumber(msg:match("(%d+)")) or 1
        if times > 20 then times = 20 end -- Anti-spam cap
        
        aiChat("Okay " .. sender.Name .. ", jumping " .. times .. " times for you!")
        
        task.spawn(function()
            for i = 1, times do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.7)
            end
        end)
        return
    end

    -- Command: FOLLOW
    if msg:find("follow") or msg:find("come to") then
        settings.following_target = sender
        aiChat("I'm coming! I will follow you now, " .. sender.Name)
        return
    end

    -- Command: STOP
    if msg:find("stop") or msg:find("stay") or msg:find("wait") then
        settings.following_target = nil
        aiChat("Stopping all actions. I'll stay here.")
        return
    end

    -- Command: SAY / REPEAT
    if msg:find("say") or msg:find("repeat") then
        local to_say = message:match("[sS][aA][yY]%s+(.+)") or message:match("[rR][eE][pP][eE][aA][tT]%s+(.+)")
        if to_say then
            aiChat(to_say)
        end
        return
    end

    -- Command: WHO ARE YOU
    if msg:find("who are you") or msg:find("what is your name") then
        aiChat("I am IDK AI, the most advanced assistant in this server. Use 'idkai' to command me!")
        return
    end

    -- Default fallback
    aiChat("I heard you, " .. sender.Name .. ", but I don't know how to do that yet. Try 'jump', 'follow' or 'say'!")
end

-- [[ LIFESTYLE LOOPS ]]
players.PlayerChatted:Connect(processAI)

run_svc.Heartbeat:Connect(function()
    if settings.ai_enabled and settings.following_target then
        local target = settings.following_target
        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") and lp.Character then
            local myRoot = lp.Character:FindFirstChild("HumanoidRootPart")
            local myHum = lp.Character:FindFirstChild("Humanoid")
            if myRoot and myHum then
                myHum:MoveTo(target.Character.HumanoidRootPart.Position + Vector3.new(2, 0, 2))
            end
        end
    end
end)

-- [[ UI SETUP ]]
local MainTab = Window:CreateTab("Main", 4483362458)
local AiTab = Window:CreateTab("IDK AI", 4483346362)

AiTab:CreateToggle({
   Name = "Enable IDK AI Brain",
   CurrentValue = false,
   Callback = function(v)
       settings.ai_enabled = v
       if v then
           aiChat("IDK AI System v3.0 Online. Commands: jump, follow, stop, say.")
       else
           settings.following_target = nil
       end
   end,
})

AiTab:CreateSection("AI Customization")

AiTab:CreateLabel("Current Prefix: idkai")

MainTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 250},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(v) 
       if lp.Character and lp.Character:FindFirstChild("Humanoid") then
           lp.Character.Humanoid.WalkSpeed = v
       end 
   end,
})

MainTab:CreateButton({
   Name = "Reset Character",
   Callback = function() if lp.Character then lp.Character:BreakJoints() end end,
})

Rayfield:Notify({Title = "IDK AI", Content = "Script ready for English servers!", Duration = 5})

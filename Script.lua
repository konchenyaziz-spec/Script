local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.7 AI Update",
   LoadingTitle = "idkkkk hub",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local tween_svc = game:GetService("TweenService")
local text_svc = game:GetService("TextService")
local camera = workspace.CurrentCamera

local settings = {
    ai_enabled = false,
    sans_walk = false,
    rgb_speed = 1,
    following_target = nil
}

-- Вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)
local AnimTab = Window:CreateTab("Animations", "accessibility")
local AiTab = Window:CreateTab("IDK AI", "bot") -- Вкладка ИИ
local SocialTab = Window:CreateTab("Socials", 4483345906)

-- [[ IDK AI LOGIC ]]
local function aiChat(msg)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
end

local function checkBadWords(text)
    local success, result = pcall(function()
        return text_svc:FilterStringAsync(text, lp.UserId):GetNonChatStringForBroadcastAsync()
    end)
    if success and result:find("#") then
        return true
    end
    return false
end

local function handleAiCommand(sender, message)
    if not settings.ai_enabled then return end
    
    local msg = message:lower()
    if not msg:find("idkai") then return end

    -- Команда: follow me
    if msg:find("follow me") then
        local targetPlayer = game:GetService("Players"):FindFirstChild(sender.Name)
        if targetPlayer then
            settings.following_target = targetPlayer
            aiChat("OK, " .. sender.Name .. "! I am following you now.")
        end

    -- Команда: say [text]
    elseif msg:find("say") then
        local content = message:match("say%s+(.+)")
        if content then
            if checkBadWords(content) then
                aiChat("Sorry, this word is prohibited by the game rules.")
            else
                aiChat(content)
            end
        end

    -- Команда: jump [count]
    elseif msg:find("jump") then
        local count = tonumber(msg:match("jump%s+(%d+)")) or 1
        aiChat("Jumping " .. count .. " times!")
        task.spawn(function()
            for i = 1, count do
                if lp.Character and lp.Character:FindFirstChild("Humanoid") then
                    lp.Character.Humanoid.Jump = true
                end
                task.wait(0.6)
            end
        end)
    
    -- Команда: stop
    elseif msg:find("stop") then
        settings.following_target = nil
        aiChat("Stopping all actions.")
    end
end

-- Следование за игроком
run_svc.Heartbeat:Connect(function()
    if settings.ai_enabled and settings.following_target and settings.following_target.Character then
        local targetPos = settings.following_target.Character:GetPivot().Position
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid:MoveTo(targetPos - (targetPos - lp.Character:GetPivot().Position).Unit * 5)
        end
    end
end)

-- Прослушка чата
game:GetService("Players").PlayerChatted:Connect(function(chatType, sender, message)
    if sender ~= lp then
        handleAiCommand(sender, message)
    end
end)

-- [[ UI ELEMENTS ]]

AiTab:CreateToggle({
   Name = "Enable IDK AI Mode",
   CurrentValue = false,
   Callback = function(Value)
       settings.ai_enabled = Value
       if Value then
           aiChat("Hello, I am IDK AI. Write 'IDKAI' and your wish, and I will fulfill your orders!")
           Rayfield:Notify({Title = "AI Active", Content = "IDK AI приветствует игроков!", Duration = 3})
       else
           settings.following_target = nil
       end
   end,
})

AiTab:CreateParagraph({Title = "Commands List", Content = "1. IDKAI follow me\n2. IDKAI say [word]\n3. IDKAI jump [number]\n4. IDKAI stop"})

-- [[ Вкладка Animations (Sans) ]]
AnimTab:CreateToggle({
   Name = "Sans Walk",
   CurrentValue = false,
   Callback = function(v) settings.sans_walk = v end,
})

-- Логика Санса из v2.6
run_svc.Stepped:Connect(function()
    if settings.sans_walk and lp.Character then
        local char = lp.Character
        local r_arm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        local l_arm = char:FindFirstChild("Left Arm") or char:FindFirstChild("LeftUpperArm")
        local hum = char:FindFirstChild("Humanoid")
        
        if hum and hum.MoveDirection.Magnitude > 0 then
            local t = tick() * (hum.WalkSpeed / 5)
            if r_arm and l_arm then
                local r_joint = char.Torso:FindFirstChild("Right Shoulder") or char.RightUpperArm:FindFirstChild("RightShoulder")
                local l_joint = char.Torso:FindFirstChild("Left Shoulder") or char.LeftUpperArm:FindFirstChild("LeftShoulder")
                if r_joint then r_joint.C0 = r_joint.C0:Lerp(CFrame.new(1.2, 0.2, 0.2) * CFrame.Angles(math.rad(-10), 0, math.rad(10)), 0.1) end
                if l_joint then l_joint.C0 = l_joint.C0:Lerp(CFrame.new(-1.2, 0.2, 0.2) * CFrame.Angles(math.rad(-10), 0, math.rad(-10)), 0.1) end
            end
        end
    end
end)

-- Main / Socials (упрощено для примера)
MainTab:CreateSlider({Name = "WalkSpeed", Range = {16, 300}, Increment = 1, CurrentValue = 16, Callback = function(v) if lp.Character then lp.Character.Humanoid.WalkSpeed = v end end})
SocialTab:CreateButton({Name = "Copy Telegram", Callback = function() setclipboard("https://t.me/idkkkk_dev") end})

Rayfield:Notify({Title = "Update v2.7", Content = "IDK AI Mode added!", Duration = 5})

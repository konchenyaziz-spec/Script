--[[
    █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
    █  _     _ _     _ _     _ _     _   _    _ _     _ _______     _______       █
    █ | |   | | \   | | |   | | |   | | | |  | | \   | |  ____ |   |  ____ |      █
    █ | |   | |  \  | | |   | | |   | | | |__| |  \  | | |____ |   | |____ |      █
    █ | |   | |   \ | | |   | | |   | | |  __  |   \ | |  ____ |   |  ____ |      █
    █ | |___| | |\  \| | |___| | |___| | |  |  | |\  \| | |____ |   | |____ |      █
    █ |_______|_| \____|_______|_______|_|  |_|_| \____|_______|   |_______|      █
    █                                                                             █
    █   BUILD: 03-11-2024 | VERSION: 1.1.0 | DEVELOPER: idkkkk                  █
    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
]]

if getgenv().idkkkk_loaded then return end
getgenv().idkkkk_loaded = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local run_svc = game:GetService("RunService")

local Window = Fluent:CreateWindow({
    Title = "idkkkk HUB",
    SubTitle = "v1.1.0 Premium",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Troll = Window:AddTab({ Title = "Trolling", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

local Options = Fluent.Options

-- [[ MAIN FUNCTIONS ]]
Tabs.Main:AddSlider("WS", { Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 1, Callback = function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end })
Tabs.Main:AddSlider("JP", { Title = "JumpPower", Default = 50, Min = 50, Max = 300, Rounding = 1, Callback = function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.JumpPower = v end end })

-- [[ FLY LOGIC ]]
local flying = false
local flySpeed = 50
Tabs.Main:AddToggle("FlyToggle", { Title = "Fly (Admin Style)", Default = false, Callback = function(v) 
    flying = v 
    if v then
        task.spawn(function()
            local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
            local bg = Instance.new("BodyGyro", lp.Character.HumanoidRootPart)
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.cframe = lp.Character.HumanoidRootPart.CFrame
            bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
            while flying do
                run_svc.RenderStepped:Wait()
                bv.velocity = (workspace.CurrentCamera.CFrame.LookVector * (lp.Character.Humanoid.MoveDirection.Magnitude > 0 and flySpeed or 0))
                bg.cframe = workspace.CurrentCamera.CFrame
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end})

-- [[ TROLLING ]]
Tabs.Troll:AddButton({
    Title = "Fling Players",
    Description = "Powerful Velocity Fling",
    Callback = function()
        local hrp = lp.Character.HumanoidRootPart
        local vel = hrp.Velocity
        hrp.Velocity = Vector3.new(0, 5000, 0)
        task.wait(0.1)
        hrp.Velocity = vel
        local bfv = Instance.new("BodyAngularVelocity", hrp)
        bfv.AngularVelocity = Vector3.new(0, 99999, 0)
        bfv.MaxTorque = Vector3.new(0, math.huge, 0)
        bfv.P = math.huge
        task.wait(1.5)
        bfv:Destroy()
    end
})

Tabs.Troll:AddToggle("Spam", { Title = "Chat Spam", Default = false })
task.spawn(function()
    while task.wait(3) do
        if Options.Spam.Value then
            local phrases = {"idkkkk HUB ON TOP", "GET REKT BY IDKKKK", "EZ LLLLL"}
            local msg = phrases[math.random(#phrases)]
            if game:GetService("TextChatService").ChatVersion == Enum.ChatVersion.TextChatService then
                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(msg)
            else
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end
    end
end)

-- [[ ADVANCED ESP ]]
local esp_opt = { tracers = false, health = false, names = false }
Tabs.Visuals:AddToggle("E_Tracer", { Title = "Tracers", Default = false, Callback = function(v) esp_opt.tracers = v end })
Tabs.Visuals:AddToggle("E_Health", { Title = "Health Bar", Default = false, Callback = function(v) esp_opt.health = v end })

local function createESP(p)
    if p == lp then return end
    local hl = Instance.new("Highlight")
    hl.FillTransparency = 1
    hl.OutlineColor = Color3.fromRGB(255, 0, 0)
    
    local attachment = Instance.new("Attachment")
    local beam = Instance.new("Beam")
    beam.Width0 = 0.5
    beam.Width1 = 0.5
    beam.FaceCamera = true
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))

    run_svc.RenderStepped:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            hl.Parent = p.Character
            hl.Enabled = true
            
            -- Tracers logic
            if esp_opt.tracers then
                beam.Parent = lp.Character.HumanoidRootPart
                local a1 = Instance.new("Attachment", p.Character.HumanoidRootPart)
                beam.Attachment0 = lp.Character.HumanoidRootPart.RootAttachment
                beam.Attachment1 = a1
                task.delay(0.1, function() a1:Destroy() end)
            end
            
            -- Health logic (basic billboard)
            if esp_opt.health and not p.Character:FindFirstChild("HealthBar") then
                local bb = Instance.new("BillboardGui", p.Character)
                bb.Name = "HealthBar"
                bb.Size = UDim2.new(4, 0, 1, 0)
                bb.AlwaysOnTop = true
                bb.ExtentsOffset = Vector3.new(0, 3, 0)
                local frame = Instance.new("Frame", bb)
                frame.Size = UDim2.new(p.Character.Humanoid.Health/100, 0, 0.2, 0)
                frame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            end
        else
            hl.Parent = nil
        end
    end)
end

for _, player in pairs(plrs:GetPlayers()) do createESP(player) end
plrs.PlayerAdded:Connect(createESP)

Window:SelectTab(1)


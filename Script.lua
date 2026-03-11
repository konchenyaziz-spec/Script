--[[
    █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
    █  _     _ _     _ _     _ _     _   _    _ _     _ _______     _______       █
    █ | |   | | \   | | |   | | |   | | | |  | | \   | |  ____ |   |  ____ |      █
    █ | |   | |  \  | | |   | | |   | | | |__| |  \  | | |____ |   | |____ |      █
    █ | |   | |   \ | | |   | | |   | | |  __  |   \ | |  ____ |   |  ____ |      █
    █ | |___| | |\  \| | |___| | |___| | |  |  | |\  \| | |____ |   | |____ |      █
    █ |_______|_| \____|_______|_______|_|  |_|_| \____|_______|   |_______|      █
    █                                                                             █
    █   BUILD: 03-11-2024 | VERSION: 1.0.5 | DEVELOPER: idkkkk                  █
    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
]]

if getgenv().idkkkk_loaded then return end
getgenv().idkkkk_loaded = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()

local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local run_svc = game:GetService("RunService")
local core_gui = game:GetService("StarterGui")

local Window = Fluent:CreateWindow({
    Title = "idkkkk HUB",
    SubTitle = "v1.0.5",
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

Tabs.Main:AddSlider("WS_Slider", {
    Title = "WalkSpeed",
    Default = 16,
    Min = 16,
    Max = 500,
    Rounding = 1,
    Callback = function(v)
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = v
        end
    end
})

Tabs.Main:AddSlider("JP_Slider", {
    Title = "JumpPower",
    Default = 50,
    Min = 50,
    Max = 500,
    Rounding = 1,
    Callback = function(v)
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = v
        end
    end
})

Tabs.Troll:AddButton({
    Title = "Fling Players",
    Description = "Aggressive spin fling",
    Callback = function()
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local velocity = Instance.new("BodyAngularVelocity")
            velocity.AngularVelocity = Vector3.new(0, 9999, 0)
            velocity.MaxTorque = Vector3.new(0, math.huge, 0)
            velocity.P = math.huge
            velocity.Parent = root
            task.wait(2)
            velocity:Destroy()
        end
    end
})

Tabs.Troll:AddToggle("SpamToggle", {Title = "Chat Spam", Default = false})

task.spawn(function()
    while task.wait(3) do
        if Options.SpamToggle.Value then
            local phrase = {"idkkkk HUB ON TOP", "GET SKILL", "idkkkk HUB RUNNING"}
            local event = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
            if event then
                event.SayMessageRequest:FireServer(phrase[math.random(1, #phrase)], "All")
            end
        end
    end
end)

local esp_enabled = false
Tabs.Visuals:AddToggle("ESPToggle", {
    Title = "Player ESP",
    Default = false,
    Callback = function(v)
        esp_enabled = v
    end
})

local function applyESP(player)
    if player == lp then return end
    local function setupHighlight()
        if player.Character then
            local hl = player.Character:FindFirstChild("idkkkk_ESP") or Instance.new("Highlight")
            hl.Name = "idkkkk_ESP"
            hl.Parent = player.Character
            hl.FillColor = Color3.fromRGB(255, 0, 0)
            hl.Enabled = esp_enabled
            run_svc.RenderStepped:Connect(function()
                if hl.Parent then hl.Enabled = esp_enabled end
            end)
        end
    end
    setupHighlight()
    player.CharacterAdded:Connect(setupHighlight)
end

for _, p in pairs(plrs:GetPlayers()) do applyESP(p) end
plrs.PlayerAdded:Connect(applyESP)

Window:SelectTab(1)
core_gui:SetCore("SendNotification", {
    Title = "idkkkk HUB",
    Text = "Loaded",
    Duration = 3
})

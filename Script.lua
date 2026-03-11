--[[
    █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
    █  _     _ _     _ _     _ _     _   _    _ _     _ _______     _______       █
    █ | |   | | \   | | |   | | |   | | | |  | | \   | |  ____ |   |  ____ |      █
    █ | |   | |  \  | | |   | | |   | | | |__| |  \  | | |____ |   | |____ |      █
    █ | |   | |   \ | | |   | | |   | | |  __  |   \ | |  ____ |   |  ____ |      █
    █ | |___| | |\  \| | |___| | |___| | |  |  | |\  \| | |____ |   | |____ |      █
    █ |_______|_| \____|_______|_______|_|  |_|_| \____|_______|   |_______|      █
    █                                                                             █
    █   BUILD: 03-11-2024 | VERSION: 1.2.0 | DEVELOPER: idkkkk                  █
    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█
]]

if getgenv().idkkkk_loaded then return end
getgenv().idkkkk_loaded = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local run_svc = game:GetService("RunService")
local input_svc = game:GetService("UserInputService")

-- Переменные для визуалов
local visual_settings = {
    boxes = false,
    tracers = false,
    chinahat = false,
    jumpcircles = false
}

-- [[ СОЗДАНИЕ ПЛАВАЮЩЕЙ КНОПКИ ]]
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local ToggleButton = Instance.new("TextButton", ScreenGui)
ToggleButton.Size = UDim2.new(0, 50, 0, 50)
ToggleButton.Position = UDim2.new(0, 10, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleButton.Text = "idk"
ToggleButton.TextColor3 = Color3.new(1, 1, 1)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Visible = false
ToggleButton.ZIndex = 1000

local corner = Instance.new("UICorner", ToggleButton)
corner.CornerRadius = ToolUnit.new(0.5, 0)

-- Драг для кнопки
local dragging, dragInput, dragStart, startPos
ToggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = ToggleButton.Position
    end
end)

input_svc.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType.Touch) then
        local delta = input.Position - dragStart
        ToggleButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

input_svc.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType.Touch then
        dragging = false
    end
end)

-- [[ ОКНО МЕНЮ ]]
local Window = Fluent:CreateWindow({
    Title = "idkkkk HUB",
    SubTitle = "v1.2.0 Minecraft Style",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

ToggleButton.MouseButton1Click:Connect(function()
    Window:Minimize()
end)

-- Следим за сворачиванием
task.spawn(function()
    while task.wait(0.1) do
        ToggleButton.Visible = Window.Minimized
    end
end)

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Troll = Window:AddTab({ Title = "Trolling", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

local Options = Fluent.Options

-- [[ MAIN FUNCTIONS ]]
Tabs.Main:AddSlider("WS", { Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 1, Callback = function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end })

local flying = false
local flySpeed = 50
Tabs.Main:AddToggle("FlyToggle", { Title = "Fly (Admin)", Default = false, Callback = function(v) 
    flying = v 
    if v and lp.Character then
        task.spawn(function()
            local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            local bv = Instance.new("BodyVelocity", hrp)
            local bg = Instance.new("BodyGyro", hrp)
            bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
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

-- [[ JUMP CIRCLES ]]
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(old, new)
        if new == Enum.HumanoidStateType.Jumping and visual_settings.jumpcircles then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local p = Instance.new("Part", workspace)
                p.Anchored = true
                p.CanCollide = false
                p.Transparency = 0.5
                p.Color = Color3.fromRGB(255, 255, 255)
                p.Material = Enum.Material.Neon
                p.Size = Vector3.new(1, 0.1, 1)
                p.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))
                local m = Instance.new("SpecialMesh", p)
                m.MeshType = Enum.MeshType.Cylinder
                
                task.spawn(function()
                    for i = 1, 20 do
                        p.Size = p.Size + Vector3.new(0.5, 0, 0.5)
                        p.Transparency = p.Transparency + 0.025
                        task.wait(0.02)
                    end
                    p:Destroy()
                end)
            end
        end
    end)
end)

-- [[ TROLLING ]]
Tabs.Troll:AddButton({
    Title = "Fling",
    Callback = function()
        local hrp = lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bfv = Instance.new("BodyAngularVelocity", hrp)
            bfv.AngularVelocity = Vector3.new(0, 99999, 0)
            bfv.MaxTorque = Vector3.new(0, math.huge, 0)
            bfv.P = math.huge
            task.wait(2)
            bfv:Destroy()
        end
    end
})

-- [[ VISUALS ]]
Tabs.Visuals:AddToggle("V_Box", { Title = "3D Boxes", Default = false, Callback = function(v) visual_settings.boxes = v end })
Tabs.Visuals:AddToggle("V_Hat", { Title = "China Hat", Default = false, Callback = function(v) visual_settings.chinahat = v end })
Tabs.Visuals:AddToggle("V_Circ", { Title = "Jump Circles", Default = false, Callback = function(v) visual_settings.jumpcircles = v end })

-- CHINA HAT LOGIC
run_svc.RenderStepped:Connect(function()
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("ChinaHat") or Instance.new("Part")
        if not head:FindFirstChild("ChinaHat") then
            hat.Name = "ChinaHat"
            hat.CanCollide = false
            hat.Parent = head
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.fromRGB(255, 0, 0)
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://177899205" -- Конус
            mesh.Scale = Vector3.new(1.2, 0.5, 1.2)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("ChinaHat") then
        lp.Character.Head.ChinaHat:Destroy()
    end
end)

-- ESP 3D BOX LOGIC
local function updateESP()
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character then
            local char = p.Character
            local box = char:FindFirstChild("idk_3DBox")
            
            if visual_settings.boxes then
                if not box then
                    box = Instance.new("SelectionBox")
                    box.Name = "idk_3DBox"
                    box.Color3 = Color3.fromRGB(255, 0, 0)
                    box.LineThickness = 0.05
                    box.Adornee = char
                    box.Parent = char
                end
            else
                if box then box:Destroy() end
            end
        end
    end
end

run_svc.Heartbeat:Connect(updateESP)

Window:SelectTab(1)

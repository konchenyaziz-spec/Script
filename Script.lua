--[[
    IDKKKK HUB v1.2.2
    FIXED BUILD
]]

if getgenv().idkkkk_executed then return end
getgenv().idkkkk_executed = true

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local plrs = game:GetService("Players")
local lp = plrs.LocalPlayer
local run_svc = game:GetService("RunService")

local visual_settings = {
    boxes = false,
    chinahat = false,
    jumpcircles = false
}

-- [[ ОКНО ]]
local Window = Fluent:CreateWindow({
    Title = "idkkkk HUB",
    SubTitle = "v1.2.2",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- Отключил акрил для стабильности на мобилках
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.RightControl
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Troll = Window:AddTab({ Title = "Trolling", Icon = "zap" }),
    Visuals = Window:AddTab({ Title = "Visuals", Icon = "eye" })
}

-- [[ ФУНКЦИИ ]]
Tabs.Main:AddSlider("WS", { Title = "WalkSpeed", Default = 16, Min = 16, Max = 300, Rounding = 1, Callback = function(v) if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = v end end })

local flying = false
local flySpeed = 50
Tabs.Main:AddToggle("Fly", { Title = "Admin Fly", Default = false, Callback = function(v) 
    flying = v 
    if v and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        task.spawn(function()
            local hrp = lp.Character.HumanoidRootPart
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
local function onJump(old, new)
    if new == Enum.HumanoidStateType.Jumping and visual_settings.jumpcircles then
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local p = Instance.new("Part", workspace)
            p.Anchored = true
            p.CanCollide = false
            p.Transparency = 0.5
            p.Color = Color3.new(1, 1, 1)
            p.Material = Enum.Material.Neon
            p.Size = Vector3.new(1, 0.1, 1)
            p.CFrame = CFrame.new(root.Position - Vector3.new(0, 3, 0))
            local m = Instance.new("SpecialMesh", p)
            m.MeshType = Enum.MeshType.Cylinder
            task.spawn(function()
                for i = 1, 20 do
                    p.Size = p.Size + Vector3.new(0.6, 0, 0.6)
                    p.Transparency = p.Transparency + 0.03
                    task.wait(0.02)
                end
                p:Destroy()
            end)
        end
    end
end

if lp.Character and lp.Character:FindFirstChild("Humanoid") then
    lp.Character.Humanoid.StateChanged:Connect(onJump)
end
lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").StateChanged:Connect(onJump)
end)

-- [[ TROLLING ]]
Tabs.Troll:AddButton({ Title = "Fling Players", Callback = function()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bfv = Instance.new("BodyAngularVelocity", hrp)
        bfv.AngularVelocity = Vector3.new(0, 99999, 0)
        bfv.MaxTorque = Vector3.new(0, math.huge, 0)
        bfv.P = math.huge
        task.wait(2)
        bfv:Destroy()
    end
end})

-- [[ VISUALS ]]
Tabs.Visuals:AddToggle("Box3D", { Title = "3D Box ESP", Default = false, Callback = function(v) visual_settings.boxes = v end })
Tabs.Visuals:AddToggle("CHat", { Title = "China Hat", Default = false, Callback = function(v) visual_settings.chinahat = v end })
Tabs.Visuals:AddToggle("JCir", { Title = "Jump Circles", Default = false, Callback = function(v) visual_settings.jumpcircles = v end })

run_svc.RenderStepped:Connect(function()
    -- China Hat logic
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("ChinaHat")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "ChinaHat"
            hat.CanCollide = false
            hat.Parent = head
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.new(1, 0, 0)
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://177899205"
            mesh.Scale = Vector3.new(1.2, 0.4, 1.2)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("ChinaHat") then
        lp.Character.Head.ChinaHat:Destroy()
    end

    -- 3D Box ESP logic
    for _, p in pairs(plrs:GetPlayers()) do
        if p ~= lp and p.Character then
            local box = p.Character:FindFirstChild("IDK_BOX")
            if visual_settings.boxes then
                if not box then
                    box = Instance.new("BoxHandleAdornment")
                    box.Name = "IDK_BOX"
                    box.AlwaysOnTop = true
                    box.ZIndex = 5
                    box.Adornee = p.Character
                    box.Color3 = Color3.new(1, 0, 0)
                    box.Transparency = 0.5
                    box.Size = p.Character:GetExtentsSize()
                    box.Parent = p.Character
                end
                box.Size = p.Character:GetExtentsSize()
            else
                if box then box:Destroy() end
            end
        end
    end
end)

-- Вместо шарика используем уведомление о кнопке
Fluent:Notify({
    Title = "idkkkk HUB",
    Content = "Нажми RightControl (или кнопку в углу), чтобы скрыть меню.",
    Duration = 5
})

Window:SelectTab(1)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v1.6 Visual Plus",
   LoadingTitle = "idkkkk hub",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local camera = workspace.CurrentCamera

local settings = {
    boxes = false,
    tracers = false,
    chinahat = false,
    jumpcircles = false,
    rgb_speed = 1
}

local function getRGB()
    local t = tick() * settings.rgb_speed
    return Color3.fromHSV(t % 1, 0.8, 1)
end

local MainTab = Window:CreateTab("Main", 4483362458)
MainTab:CreateSection("Локальный игрок")

MainTab:CreateSlider({
   Name = "Скорость (WalkSpeed)",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
          lp.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

local VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "Улучшенные Box ESP",
   CurrentValue = false,
   Callback = function(Value) settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Линии (Tracers)",
   CurrentValue = false,
   Callback = function(Value) settings.tracers = Value end,
})

VisualTab:CreateToggle({
   Name = "RGB China Hat (Красивая)",
   CurrentValue = false,
   Callback = function(Value) settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "Jump Circles + Текст",
   CurrentValue = false,
   Callback = function(Value) settings.jumpcircles = Value end,
})

-- Функция для создания красивого круга при прыжке
local function createJumpCircle()
    if not settings.jumpcircles then return end
    local char = lp.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        local pos = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
        
        -- Основной диск
        local p = Instance.new("Part")
        p.Name = "IDK_Circle"
        p.Parent = workspace
        p.Anchored = true
        p.CanCollide = false
        p.Size = Vector3.new(4, 0.1, 4)
        p.Material = Enum.Material.Neon
        p.Transparency = 0.4
        p.CFrame = CFrame.new(pos) * CFrame.Angles(0, 0, 0)
        
        local mesh = Instance.new("SpecialMesh", p)
        mesh.MeshType = Enum.MeshType.Cylinder -- Используем цилиндр для формы диска
        
        -- Интерфейс с надписью внутри круга
        local gui = Instance.new("SurfaceGui", p)
        gui.Face = Enum.NormalId.Top
        gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
        gui.PixelsPerStud = 50
        
        local label = Instance.new("TextLabel", gui)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "IDKKKK HUB"
        label.TextColor3 = Color3.new(1, 1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextScaled = true
        
        task.spawn(function()
            local hue = 0
            for i = 1, 40 do
                hue = hue + 0.02
                p.Size = p.Size + Vector3.new(0.5, 0, 0.5)
                p.Transparency = p.Transparency + 0.015
                p.Color = Color3.fromHSV(hue % 1, 0.7, 1)
                label.TextTransparency = p.Transparency
                run_svc.Heartbeat:Wait()
            end
            p:Destroy()
        end)
    end
end

-- Обработка визуалов в цикле
run_svc.RenderStepped:Connect(function()
    local rgb = getRGB()
    
    -- Красивая China Hat
    if settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat_V2")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "IDK_Hat_V2"
            hat.CanCollide = false
            hat.Parent = head
            hat.Size = Vector3.new(1.8, 0.2, 1.8)
            hat.Material = Enum.Material.Neon
            hat.Transparency = 0.2
            
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshId = "rbxassetid://1033714" -- Классическая коническая форма
            mesh.Scale = Vector3.new(2, 1, 2)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0)
        hat.Color = rgb
    elseif lp.Character and lp.Character:FindFirstChild("Head") and lp.Character.Head:FindFirstChild("IDK_Hat_V2") then
        lp.Character.Head.IDK_Hat_V2:Destroy()
    end

    -- ESP и Трейсеры
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local root = p.Character.HumanoidRootPart
            
            -- Box ESP
            local box = p.Character:FindFirstChild("IDK_Visual_Box")
            if settings.boxes then
                if not box then
                    box = Instance.new("BoxHandleAdornment", p.Character)
                    box.Name = "IDK_Visual_Box"
                    box.Adornee = p.Character
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Transparency = 0.6
                    box.Size = Vector3.new(4, 6, 1)
                end
                box.Color3 = rgb
            elseif box then box:Destroy() end
            
            -- Tracers
            local tracer = p.Character:FindFirstChild("IDK_Tracer")
            if settings.tracers then
                local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    if not tracer then
                        tracer = Instance.new("Part", p.Character)
                        tracer.Name = "IDK_Tracer"
                        tracer.Anchored = true
                        tracer.CanCollide = false
                        tracer.Material = Enum.Material.Neon
                        tracer.Transparency = 0.4
                    end
                    local startPos = camera:ViewportToWorldPoint(Vector3.new(camera.ViewportSize.X/2, 0, 10))
                    local dist = (root.Position - startPos).Magnitude
                    tracer.Size = Vector3.new(0.05, 0.05, dist)
                    tracer.CFrame = CFrame.lookAt(startPos, root.Position) * CFrame.new(0, 0, -dist/2)
                    tracer.Color = rgb
                elseif tracer then tracer:Destroy() end
            elseif tracer then tracer:Destroy() end
        end
    end
end)

-- Детекция прыжка
local function setupDetection(char)
    local hum = char:WaitForChild("Humanoid")
    hum.StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then
            createJumpCircle()
        end
    end)
end

lp.CharacterAdded:Connect(setupDetection)
if lp.Character then setupDetection(lp.Character) end

Rayfield:Notify({
   Title = "idkkkk hub",
   Content = "Визуалы обновлены! Наслаждайтесь.",
   Duration = 5
})


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk hub | v2.0 Fixes",
   LoadingTitle = "idkkkk hub",
   LoadingSubtitle = "by IDKKK team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local camera = workspace.CurrentCamera
local userInput = game:GetService("UserInputService")

local settings = {
    boxes = false,
    tracers = false,
    chinahat = false,
    jumpcircles = false,
    rgb_speed = 1,
    line_thickness = 1.5
}

local function getRGB()
    local t = tick() * settings.rgb_speed
    return Color3.fromHSV(t % 1, 0.8, 1)
end

-- Вкладки
local MainTab = Window:CreateTab("Main", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "2D Box ESP (Drawing)",
   CurrentValue = false,
   Callback = function(Value) settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Линии (Tracers)",
   CurrentValue = false,
   Callback = function(Value) settings.tracers = Value end,
})

VisualTab:CreateToggle({
   Name = "RGB China Hat",
   CurrentValue = false,
   Callback = function(Value) settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "2D Jump Circles",
   CurrentValue = false,
   Callback = function(Value) settings.jumpcircles = Value end,
})

-- Система Drawing ESP
local cache = {}

local function createEsp(player)
    local drawings = {
        box = Drawing.new("Square"),
        tracer = Drawing.new("Line"),
        label = Drawing.new("Text")
    }
    
    drawings.box.Visible = false
    drawings.box.Thickness = 1.5
    drawings.box.Filled = false
    
    drawings.tracer.Visible = false
    drawings.tracer.Thickness = 1.5
    
    drawings.label.Visible = false
    drawings.label.Center = true
    drawings.label.Outline = true
    drawings.label.Size = 18
    
    cache[player] = drawings
end

for _, p in pairs(game:GetService("Players"):GetPlayers()) do
    if p ~= lp then createEsp(p) end
end

game:GetService("Players").PlayerAdded:Connect(function(p)
    if p ~= lp then createEsp(p) end
end)

game:GetService("Players").PlayerRemoving:Connect(function(p)
    if cache[p] then
        for _, d in pairs(cache[p]) do d:Remove() end
        cache[p] = nil
    end
end)

-- Функция Jump Circle (2D)
local function spawnJumpCircle()
    if not settings.jumpcircles then return end
    local char = lp.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local pos = char.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
    local circle = Drawing.new("Circle")
    local text = Drawing.new("Text")
    
    circle.Visible = true
    circle.Thickness = 2
    circle.NumSides = 32
    circle.Radius = 0
    
    text.Visible = true
    text.Text = "IDKKKK HUB"
    text.Size = 20
    text.Center = true
    text.Outline = true
    
    task.spawn(function()
        for i = 1, 30 do
            local screenPos, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen then
                circle.Visible = true
                text.Visible = true
                circle.Position = Vector2.new(screenPos.X, screenPos.Y)
                circle.Radius = i * 4
                circle.Color = getRGB()
                circle.Transparency = 1 - (i/30)
                
                text.Position = Vector2.new(screenPos.X, screenPos.Y - 10)
                text.Color = circle.Color
                text.Transparency = circle.Transparency
            else
                circle.Visible = false
                text.Visible = false
            end
            run_svc.RenderStepped:Wait()
        end
        circle:Remove()
        text:Remove()
    end)
end

-- Основной цикл рендеринга
run_svc.RenderStepped:Connect(function()
    local rgb = getRGB()
    
    -- China Hat (3D объект)
    if settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat")
        if not hat then
            hat = Instance.new("Part", head)
            hat.Name = "IDK_Hat"
            hat.CanCollide = false
            hat.Size = Vector3.new(1.5, 0.1, 1.5)
            hat.Material = Enum.Material.Neon
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshId = "rbxassetid://1033714"
            mesh.Scale = Vector3.new(1.8, 0.8, 1.8)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.7, 0)
        hat.Color = rgb
    elseif lp.Character and lp.Character:FindFirstChild("Head") and lp.Character.Head:FindFirstChild("IDK_Hat") then
        lp.Character.Head.IDK_Hat:Destroy()
    end

    -- Обновление ESP через Drawing API
    for player, drawings in pairs(cache) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local root = player.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(root.Position)
            
            if onScreen then
                -- Tracers
                if settings.tracers then
                    drawings.tracer.Visible = true
                    drawings.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) -- Из центра снизу
                    drawings.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    drawings.tracer.Color = rgb
                else
                    drawings.tracer.Visible = false
                end
                
                -- 2D Boxes
                if settings.boxes then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        local legPos = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                        
                        local height = math.abs(headPos.Y - legPos.Y)
                        local width = height / 1.5
                        
                        drawings.box.Visible = true
                        drawings.box.Size = Vector2.new(width, height)
                        drawings.box.Position = Vector2.new(screenPos.X - width/2, screenPos.Y - height/2)
                        drawings.box.Color = rgb
                    end
                else
                    drawings.box.Visible = false
                end
            else
                drawings.box.Visible = false
                drawings.tracer.Visible = false
            end
        else
            drawings.box.Visible = false
            drawings.tracer.Visible = false
        end
    end
end)

-- Детекция прыжка
lp.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid").StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then spawnJumpCircle() end
    end)
end)

if lp.Character then
    lp.Character:WaitForChild("Humanoid").StateChanged:Connect(function(_, new)
        if new == Enum.HumanoidStateType.Jumping then spawnJumpCircle() end
    end)
end

Rayfield:Notify({
   Title = "idkkkk hub",
   Content = "Система Drawing API активирована. Трейсеры теперь работают!",
   Duration = 5
})

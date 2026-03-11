--[[
    IDKKKK HUB v1.4
    Library: Rayfield (Stable & Fast)
    Changes: Improved Visuals, Fixed Jump Circles, Added Bang
credits:Rayfield,Idkkkk Team
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk HUB | v1.4",
   LoadingTitle = "Загрузка IDKKKK HUB...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false 
})

-- Переменные
local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local visual_settings = {
    boxes = false,
    chinahat = false,
    jumpcircles = false
}

-- Вспомогательная функция для Bang
local banging = false
local bangTarget = nil

-- [[ ВКЛАДКА MAIN ]]
local MainTab = Window:CreateTab("Main", 4483362458)

MainTab:CreateSlider({
   Name = "Скорость бега",
   Range = {16, 300},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
          lp.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

-- [[ ВКЛАДКА TROLLING ]]
local TrollTab = Window:CreateTab("Trolling", 4483345998)

TrollTab:CreateInput({
   Name = "Имя жертвы (Bang)",
   PlaceholderText = "Введите имя...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
       for _, v in pairs(game:GetService("Players"):GetPlayers()) do
           if v.Name:lower():find(Text:lower()) or v.DisplayName:lower():find(Text:lower()) then
               bangTarget = v
               break
           end
       end
   end,
})

TrollTab:CreateToggle({
   Name = "Bang (Ебать игрока)",
   CurrentValue = false,
   Callback = function(Value)
       banging = Value
       if Value then
           task.spawn(function()
               while banging do
                   if bangTarget and bangTarget.Character and bangTarget.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                       local targetHrp = bangTarget.Character.HumanoidRootPart
                       local myHrp = lp.Character.HumanoidRootPart
                       
                       -- Движение вперед-назад
                       for i = 1, 10 do
                           if not banging then break end
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.1 + (i/10))
                           run_svc.Heartbeat:Wait()
                       end
                       for i = 10, 1, -1 do
                           if not banging then break end
                           myHrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 1.1 + (i/10))
                           run_svc.Heartbeat:Wait()
                       end
                   else
                       run_svc.Heartbeat:Wait()
                   end
               end
           end)
       end
   end,
})

-- [[ ВКЛАДКА VISUALS ]]
local VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "Neon Box ESP",
   CurrentValue = false,
   Callback = function(Value) visual_settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "Premium China Hat",
   CurrentValue = false,
   Callback = function(Value) visual_settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "Jump Circles (Fixed)",
   CurrentValue = false,
   Callback = function(Value) visual_settings.jumpcircles = Value end,
})

-- [[ ГЛАВНЫЙ ЦИКЛ ]]
run_svc.RenderStepped:Connect(function()
    -- China Hat Logic
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("IDK_Hat")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "IDK_Hat"
            hat.CanCollide = false
            hat.Parent = head
            hat.Size = Vector3.new(1.5, 0.2, 1.5)
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.fromRGB(0, 255, 255) -- Бирюзовый неон
            hat.Transparency = 0.3
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://177899205"
            mesh.Scale = Vector3.new(1.3, 0.5, 1.3)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.6, 0) * CFrame.Angles(0, tick() * 3, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("IDK_Hat") then
        lp.Character.Head.IDK_Hat:Destroy()
    end

    -- Box ESP Logic
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lp and p.Character then
            local box = p.Character:FindFirstChild("IDK_Box")
            if visual_settings.boxes then
                if not box then
                    box = Instance.new("SelectionBox")
                    box.Name = "IDK_Box"
                    box.Adornee = p.Character
                    box.Color3 = Color3.fromRGB(255, 0, 100)
                    box.LineThickness = 0.05
                    box.SurfaceColor3 = Color3.fromRGB(255, 0, 100)
                    box.SurfaceTransparency = 0.85
                    box.AlwaysOnTop = true
                    box.Parent = p.Character
                end
            else
                if box then box:Destroy() end
            end
        end
    end
end)

-- Jump Circles Logic
local function onJump(active)
    if active and visual_settings.jumpcircles then
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = Instance.new("Part")
            p.Parent = workspace
            p.Anchored = true
            p.CanCollide = false
            p.Size = Vector3.new(2, 0.1, 2)
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(255, 255, 255)
            p.Transparency = 0.4
            p.CFrame = hrp.CFrame * CFrame.new(0, -2.8, 0)
            
            local m = Instance.new("SpecialMesh", p)
            m.MeshType = Enum.MeshType.Cylinder
            
            task.spawn(function()
                for i = 1, 20 do
                    p.Size = p.Size + Vector3.new(0.6, 0, 0.6)
                    p.Transparency = p.Transparency + 0.03
                    task.wait(0.01)
                end
                p:Destroy()
            end)
        end
    end
end

-- Подключение прыжка
lp.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Jumping:Connect(onJump)
end)
if lp.Character and lp.Character:FindFirstChild("Humanoid") then
    lp.Character.Humanoid.Jumping:Connect(onJump)
end

Rayfield:Notify({
   Title = "IDKKKK HUB v1.4",
   Content = "Скрипт успешно запущен!",
   Duration = 5,
   Image = 4483362458,
})

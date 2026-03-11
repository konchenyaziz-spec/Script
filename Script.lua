--[[
    IDKKKK HUB v1.3
    Library: Rayfield (Stable & Fast)
]]

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "idkkkk HUB | v1.3",
   LoadingTitle = "Загрузка IDKKKK HUB...",
   LoadingSubtitle = "by Gemini",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "idkkkk_configs",
      FileName = "MainHub"
   },
   KeySystem = false -- Система ключей отключена для удобства
})

-- Переменные состояния
local lp = game:GetService("Players").LocalPlayer
local run_svc = game:GetService("RunService")
local visual_settings = {
    boxes = false,
    chinahat = false,
    jumpcircles = false
}

-- [[ ВКЛАДКА MAIN ]]
local MainTab = Window:CreateTab("Main", 4483362458) -- Иконка Home

MainTab:CreateSlider({
   Name = "WalkSpeed (Скорость)",
   Range = {16, 300},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "WS_Slider",
   Callback = function(Value)
      if lp.Character and lp.Character:FindFirstChild("Humanoid") then
          lp.Character.Humanoid.WalkSpeed = Value
      end
   end,
})

local flying = false
local flySpeed = 50
MainTab:CreateToggle({
   Name = "Admin Fly (Полет)",
   CurrentValue = false,
   Flag = "FlyToggle",
   Callback = function(Value)
      flying = Value
      if Value and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
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
   end,
})

-- [[ ВКЛАДКА TROLLING ]]
local TrollTab = Window:CreateTab("Trolling", 4483345998)

TrollTab:CreateButton({
   Name = "Fling Players (Закрутить всех)",
   Callback = function()
       local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
       if hrp then
           local bfv = Instance.new("BodyAngularVelocity", hrp)
           bfv.AngularVelocity = Vector3.new(0, 99999, 0)
           bfv.MaxTorque = Vector3.new(0, math.huge, 0)
           bfv.P = math.huge
           Rayfield:Notify({Title = "Fling Active", Content = "Вы начали крутиться! Подойдите к игроку.", Duration = 3})
           task.wait(3)
           bfv:Destroy()
       end
   end,
})

-- [[ ВКЛАДКА VISUALS ]]
local VisualTab = Window:CreateTab("Visuals", 4483346362)

VisualTab:CreateToggle({
   Name = "3D Box ESP (Враги в коробках)",
   CurrentValue = false,
   Flag = "ESP_Box",
   Callback = function(Value) visual_settings.boxes = Value end,
})

VisualTab:CreateToggle({
   Name = "China Hat (Шляпа)",
   CurrentValue = false,
   Flag = "HatToggle",
   Callback = function(Value) visual_settings.chinahat = Value end,
})

VisualTab:CreateToggle({
   Name = "Jump Circles (Круги при прыжке)",
   CurrentValue = false,
   Flag = "JumpToggle",
   Callback = function(Value) visual_settings.jumpcircles = Value end,
})

-- [[ ЛОГИКА ОБНОВЛЕНИЯ (RENDER STEPPED) ]]
run_svc.RenderStepped:Connect(function()
    -- China Hat
    if visual_settings.chinahat and lp.Character and lp.Character:FindFirstChild("Head") then
        local head = lp.Character.Head
        local hat = head:FindFirstChild("ChinaHat")
        if not hat then
            hat = Instance.new("Part")
            hat.Name = "ChinaHat"
            hat.CanCollide = false
            hat.Parent = head
            hat.Material = Enum.Material.Neon
            hat.Color = Color3.fromRGB(255, 50, 50)
            local mesh = Instance.new("SpecialMesh", hat)
            mesh.MeshType = Enum.MeshType.FileMesh
            mesh.MeshId = "rbxassetid://177899205"
            mesh.Scale = Vector3.new(1.2, 0.4, 1.2)
        end
        hat.CFrame = head.CFrame * CFrame.new(0, 0.55, 0)
    elseif lp.Character and lp.Character.Head:FindFirstChild("ChinaHat") then
        lp.Character.Head.ChinaHat:Destroy()
    end

    -- Box ESP
    for _, p in pairs(game:GetService("Players"):GetPlayers()) do
        if p ~= lp and p.Character then
            local box = p.Character:FindFirstChild("IDK_ADORN")
            if visual_settings.boxes then
                if not box then
                    box = Instance.new("BoxHandleAdornment")
                    box.Name = "IDK_ADORN"
                    box.AlwaysOnTop = true
                    box.Adornee = p.Character
                    box.Color3 = Color3.new(1, 0, 0)
                    box.Transparency = 0.6
                    box.ZIndex = 10
                    box.Parent = p.Character
                end
                box.Size = p.Character:GetExtentsSize()
            else
                if box then box:Destroy() end
            end
        end
    end
end)

-- Jump Circles Logic
local function jumpEffect(old, new)
    if new == Enum.HumanoidStateType.Jumping and visual_settings.jumpcircles then
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local p = Instance.new("Part", workspace)
            p.Anchored, p.CanCollide = true, false
            p.Transparency, p.Material = 0.5, Enum.Material.Neon
            p.Size = Vector3.new(1, 0.1, 1)
            p.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0))
            local m = Instance.new("SpecialMesh", p)
            m.MeshType = Enum.MeshType.Cylinder
            task.spawn(function()
                for i = 1, 15 do
                    p.Size = p.Size + Vector3.new(0.8, 0, 0.8)
                    p.Transparency = p.Transparency + 0.04
                    task.wait(0.02)
                end
                p:Destroy()
            end)
        end
    end
end

lp.CharacterAdded:Connect(function(c) c:WaitForChild("Humanoid").StateChanged:Connect(jumpEffect) end)
if lp.Character and lp.Character:FindFirstChild("Humanoid") then
    lp.Character.Humanoid.StateChanged:Connect(jumpEffect)
end

Rayfield:Notify({
   Title = "Успешно!",
   Content = "IDKKKK HUB v1.3 загружен. Используйте кнопку Rayfield для закрытия.",
   Duration = 5,
   Image = 4483362458,
})

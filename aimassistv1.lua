--// CONFIG (AUTO ON, HEAD ONLY)
getgenv().Camlock = {
    Enabled = true,
    Smoothness = 0.15,
    FOVRadius = 100,
    ShowFOV = true
}

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// UI FOV Circle
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CamlockUI"
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local FOVCircle = Instance.new("Frame")
FOVCircle.Size = UDim2.new(0, Camlock.FOVRadius * 2, 0, Camlock.FOVRadius * 2)
FOVCircle.Position = UDim2.new(0.5, -Camlock.FOVRadius, 0.5, -Camlock.FOVRadius)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = Camlock.ShowFOV
FOVCircle.Parent = ScreenGui

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 1.5
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Parent = FOVCircle

--// Visibility check
local function IsVisible(part)
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin

    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, part.Parent}
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, params)
    return not result
end

--// Get closest player (HEAD ONLY)
local function GetClosestTarget()
    local closest
    local shortest = Camlock.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
        and player.Character
        and player.Character:FindFirstChild("Humanoid")
        and player.Character.Humanoid.Health > 0 then

            -- Da Hood KO check
            local bodyEffects = player.Character:FindFirstChild("BodyEffects")
            local ko = bodyEffects and bodyEffects:FindFirstChild("K.O")
            if ko and ko.Value then
                continue
            end

            local head = player.Character:FindFirstChild("Head")
            if head and IsVisible(head) then
                local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

--// Main Loop (AUTO LOCK)
RunService.RenderStepped:Connect(function()
    if not Camlock.Enabled then return end

    local head = GetClosestTarget()
    if head then
        local cf = CFrame.new(Camera.CFrame.Position, head.Position)
        Camera.CFrame = Camera.CFrame:Lerp(cf, Camlock.Smoothness)
    end
end)

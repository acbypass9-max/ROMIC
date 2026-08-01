local Players = game:GetService("Players");
local LocalPlayer = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;
local RS = game:GetService("RunService");
local UIS = game:GetService("UserInputService");
local Settings = {Aimbot=false,WallCheck=true,FOV=150,ShowFOV=true,ESP_Box=false,ESP_Line=false,ESP_Name=false,ESP_Distance=false,SpeedHack=false,JumpDash=false,EnemyPull=false,PullDistance=5,Fling=false,Accent=Color3.fromRGB(49, 97, 244)};
local airWalkEnabled = false;
local airWalkHeight = 0;
local airWalkPart = nil;
local baseGroundY = nil;
local function setAirWalk(state)
	airWalkEnabled = state;
	if state then
		if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			baseGroundY = LocalPlayer.Character.HumanoidRootPart.Position.Y;
		end
	else
		baseGroundY = nil;
		if airWalkPart then
			airWalkPart:Destroy();
			airWalkPart = nil;
		end
	end
end
local freezeAnim = false;
local function FreezeAnimations(char)
	local humanoid = char:WaitForChild("Humanoid", 3);
	if not humanoid then
		return;
	end
	local animator = humanoid:FindFirstChildOfClass("Animator");
	if animator then
		for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
			track:Stop(0);
		end
	end
	local animate = char:FindFirstChild("Animate");
	if animate then
		animate.Disabled = true;
	end
end
local function UnfreezeAnimations(char)
	if not char then
		return;
	end
	local animate = char:FindFirstChild("Animate");
	if animate then
		animate.Disabled = false;
	end
end
LocalPlayer.CharacterAdded:Connect(function(char)
	baseGroundY = nil;
	if airWalkPart then
		airWalkPart:Destroy();
		airWalkPart = nil;
	end
	if airWalkEnabled then
		task.wait(0.5);
		local root = char:WaitForChild("HumanoidRootPart", 3);
		if root then
			baseGroundY = root.Position.Y;
		end
	end
	if freezeAnim then
		task.wait(0.5);
		FreezeAnimations(char);
	end
end);
local noclipEnabled = false;
local flingEnabled = false;
local flingThread = nil;
local function flingLoop()
	while flingEnabled do
		RS.Heartbeat:Wait();
		local c = LocalPlayer.Character;
		local hrp = c and c:FindFirstChild("HumanoidRootPart");
		if hrp then
			local vel = hrp.AssemblyLinearVelocity;
			hrp.AssemblyLinearVelocity = (vel * 10000) + Vector3.new(0, 10000, 0);
			RS.RenderStepped:Wait();
			hrp.AssemblyLinearVelocity = vel;
			RS.Stepped:Wait();
			hrp.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0);
		end
	end
end
local function toggleFling(state)
	flingEnabled = state;
	Settings.Fling = state;
	if flingEnabled then
		if (flingThread and (coroutine.status(flingThread) == "suspended")) then
			coroutine.resume(flingThread);
		else
			flingThread = coroutine.create(flingLoop);
			coroutine.resume(flingThread);
		end
	end
end
local warpFlingEnabled = false;
local warpFlingThread = nil;
local warpTarget = nil;
local originalCFrame = nil;
local function getPlayerNames()
	local names = {};
	for _, p in pairs(Players:GetPlayers()) do
		if (p ~= LocalPlayer) then
			table.insert(names, p.Name);
		end
	end
	return names;
end
local function warpFlingLoop()
	while warpFlingEnabled do
		RS.Heartbeat:Wait();
		local char = LocalPlayer.Character;
		local hrp = char and char:FindFirstChild("HumanoidRootPart");
		local humanoid = char and char:FindFirstChildOfClass("Humanoid");
		local animScript = char and char:FindFirstChild("Animate");
		if (warpTarget and warpTarget.Character and warpTarget.Character:FindFirstChild("HumanoidRootPart") and hrp and humanoid) then
			local targetHrp = warpTarget.Character.HumanoidRootPart;
			if animScript then
				animScript.Disabled = true;
			end
			for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
				track:Stop();
			end
			humanoid.PlatformStand = true;
			hrp.CFrame = targetHrp.CFrame * CFrame.Angles(math.rad(90), 0, 0);
			local vel = hrp.AssemblyLinearVelocity;
			hrp.AssemblyLinearVelocity = (vel * 10000) + Vector3.new(0, 10000, 0);
			RS.RenderStepped:Wait();
			hrp.AssemblyLinearVelocity = vel;
			RS.Stepped:Wait();
			hrp.AssemblyLinearVelocity = vel + Vector3.new(0, 0.1, 0);
		end
	end
end
local function toggleWarpFling(state)
	warpFlingEnabled = state;
	local char = LocalPlayer.Character;
	local hrp = char and char:FindFirstChild("HumanoidRootPart");
	local humanoid = char and char:FindFirstChildOfClass("Humanoid");
	local animScript = char and char:FindFirstChild("Animate");
	if state then
		if hrp then
			originalCFrame = hrp.CFrame;
		end
		if (warpFlingThread and (coroutine.status(warpFlingThread) == "suspended")) then
			coroutine.resume(warpFlingThread);
		else
			warpFlingThread = coroutine.create(warpFlingLoop);
			coroutine.resume(warpFlingThread);
		end
	else
		if humanoid then
			humanoid.PlatformStand = false;
		end
		if animScript then
			animScript.Disabled = false;
		end
		-- วาร์ปกลับจุดเดิม แล้วล็อคอยู่กับที่ 3 วิ
		if (hrp and originalCFrame) then
			hrp.CFrame = originalCFrame;
			local lockCFrame = originalCFrame;
			local lockConn;
			lockConn = RS.Heartbeat:Connect(function()
				if hrp and hrp.Parent then
					hrp.CFrame = lockCFrame;
					hrp.AssemblyLinearVelocity = Vector3.zero;
					hrp.AssemblyAngularVelocity = Vector3.zero;
				end
			end);
			task.delay(1, function()
				lockConn:Disconnect();
			end);
		end
		originalCFrame = nil;
	end
end
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))();
local Window = WindUI:CreateWindow({Title="ROMIC HUB",Icon="shield",Theme="Dark",Folder="ROMIC_HUB"});
local function setUIScale(scaleValue)
	task.spawn(function()
		local CoreGui = game:GetService("CoreGui");
		local playerGui = LocalPlayer:FindFirstChild("PlayerGui");
		local function searchAndScale(parent)
			for _, obj in ipairs(parent:GetDescendants()) do
				if (obj:IsA("TextLabel") and (obj.Text == "ROMIC HUB")) then
					local gui = obj:FindFirstAncestorWhichIsA("ScreenGui");
					if gui then
						local uiScale = gui:FindFirstChildOfClass("UIScale") or Instance.new("UIScale", gui);
						uiScale.Scale = scaleValue;
					end
				end
			end
		end
		pcall(function()
			searchAndScale(CoreGui);
		end);
		if playerGui then
			pcall(function()
				searchAndScale(playerGui);
			end);
		end
	end);
end
local AimTab = Window:Tab({Title="Aimbot",Icon="crosshair"});
local VisTab = Window:Tab({Title="Visuals",Icon="eye"});
local MisTab = Window:Tab({Title="Misc",Icon="zap"});
local GrianTab = Window:Tab({Title="เกรียน",Icon="flame"});
local UITab = Window:Tab({Title="ตั้งค่า UI",Icon="settings"});
AimTab:Toggle({Title="Enable Aimbot",Value=Settings.Aimbot,Callback=function(v)
	Settings.Aimbot = v;
end});
AimTab:Toggle({Title="Wall Check",Value=Settings.WallCheck,Callback=function(v)
	Settings.WallCheck = v;
end});
AimTab:Toggle({Title="Show FOV Circle",Value=Settings.ShowFOV,Callback=function(v)
	Settings.ShowFOV = v;
end});
AimTab:Slider({Title="FOV Radius",Step=1,Value={Min=10,Max=500,Default=Settings.FOV},Callback=function(v)
	Settings.FOV = v;
	FOVCircle.Size = UDim2.new(0, v * 2, 0, v * 2);
end});
VisTab:Toggle({Title="ESP Box",Value=Settings.ESP_Box,Callback=function(v)
	Settings.ESP_Box = v;
end});
VisTab:Toggle({Title="ESP Line",Value=Settings.ESP_Line,Callback=function(v)
	Settings.ESP_Line = v;
end});
VisTab:Toggle({Title="ESP Name",Value=Settings.ESP_Name,Callback=function(v)
	Settings.ESP_Name = v;
end});
VisTab:Toggle({Title="ESP Distance",Value=Settings.ESP_Distance,Callback=function(v)
	Settings.ESP_Distance = v;
end});
MisTab:Toggle({Title="Speed Hack  x50",Value=Settings.SpeedHack,Callback=function(v)
	Settings.SpeedHack = v;
	if (not v and LocalPlayer.Character) then
		LocalPlayer.Character.Humanoid.WalkSpeed = 16;
	end
end});
MisTab:Toggle({Title="Jump Dash  x150",Value=Settings.JumpDash,Callback=function(v)
	Settings.JumpDash = v;
end});
MisTab:Toggle({Title="Enemy Pull",Value=Settings.EnemyPull,Callback=function(v)
	Settings.EnemyPull = v;
end});
MisTab:Slider({Title="Pull Distance",Step=1,Value={Min=0,Max=50,Default=Settings.PullDistance},Callback=function(v)
	Settings.PullDistance = v;
end});
MisTab:Toggle({Title="Air Walk",Value=false,Callback=function(v)
	setAirWalk(v);
end});
MisTab:Slider({Title="Walk Height",Step=1,Value={Min=0,Max=200,Default=0},Callback=function(v)
	airWalkHeight = v;
	if (airWalkEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and baseGroundY) then
		local root = LocalPlayer.Character.HumanoidRootPart;
		root.CFrame = CFrame.new(root.Position.X, baseGroundY + airWalkHeight, root.Position.Z);
	end
end});
MisTab:Toggle({Title="Freeze Anim",Desc="ตัวเเข็ง",Value=false,Callback=function(v)
	freezeAnim = v;
	local char = LocalPlayer.Character;
	if v then
		if char then
			FreezeAnimations(char);
		end
	else
		UnfreezeAnimations(char);
	end
end});
MisTab:Toggle({Title="กันปลิวตากผู้เล่นคนอื่น",Value=false,Callback=function(v)
	noclipEnabled = v;
end});
local warpTargetDropdown = GrianTab:Dropdown({Title="เลือกเป้าหมาย",Values=getPlayerNames(),Callback=function(v)
	warpTarget = Players:FindFirstChild(v);
end});
local function refreshWarpDropdown()
	local names = getPlayerNames();
	local ok = pcall(function()
		warpTargetDropdown:SetValues(names);
	end);
	if not ok then
		pcall(function()
			warpTargetDropdown:Refresh(names);
		end);
	end
end
Players.PlayerRemoving:Connect(function(p)
	if (warpTarget == p) then
		warpTarget = nil;
		warpFlingEnabled = false;
		originalCFrame = nil;
	end
end);
GrianTab:Button({Title="รีเซ็ตรายชื่อ",Desc="กดเพื่ออัปเดตรายชื่อผู้เล่นในเกม",Callback=function()
	refreshWarpDropdown();
	WindUI:Notify({Title="รีเซ็ตรายชื่อ",Content="อัปเดตรายชื่อผู้เล่นแล้ว",Duration=1.5});
end});
GrianTab:Toggle({Title="วาปชน",Desc="ห้ามเปิดกับชนปลิวเดี๋ยวมันจะทำให้เราปลิวเอง",Value=false,Callback=function(v)
	if (v and not warpTarget) then
		WindUI:Notify({Title="วาปชน",Content="⚠️ กรุณาเลือกเป้าหมายก่อนหรือผู้เล่นอาจออกจากเกม",Duration=2});
		return;
	end
	toggleWarpFling(v);
end});
GrianTab:Toggle({Title="ชนปลิว",Desc="บูสต์ velocity ให้สูงมาก ทำให้ผู้เล่นอื่นปลิวเมื่อชน",Value=false,Callback=function(v)
	toggleFling(v);
end});
UITab:Dropdown({Title="ปรับขนาด UI",Desc="ย่อ/ขยายหน้าต่าง ROMIC HUB",Values={"100%","75%","50%"},Default="100%",Callback=function(v)
	local map = {["100%"]=1,["75%"]=0.75,["50%"]=0.5};
	setUIScale(map[v] or 1);
end});
local ScreenGui = Instance.new("ScreenGui");
ScreenGui.Name = "ROMIC_FOV";
ScreenGui.IgnoreGuiInset = true;
ScreenGui.ResetOnSpawn = false;
local _ok = pcall(function()
	ScreenGui.Parent = game:GetService("CoreGui");
end);
if not _ok then
	ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui");
end
local FOVCircle = Instance.new("Frame");
FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2);
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5);
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0);
FOVCircle.BackgroundTransparency = 1;
FOVCircle.Visible = Settings.ShowFOV;
FOVCircle.Parent = ScreenGui;
Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0);
local FStroke = Instance.new("UIStroke", FOVCircle);
FStroke.Color = Settings.Accent;
FStroke.Thickness = 1.2;
local ESP_Objects = {};
Players.PlayerRemoving:Connect(function(p)
	if ESP_Objects[p] then
		pcall(function()
			ESP_Objects[p].Box:Remove();
		end);
		pcall(function()
			ESP_Objects[p].Line:Remove();
		end);
		pcall(function()
			ESP_Objects[p].Name:Remove();
		end);
		pcall(function()
			ESP_Objects[p].Dist:Remove();
		end);
		ESP_Objects[p] = nil;
	end
end);
UIS.JumpRequest:Connect(function()
	if Settings.JumpDash then
		if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			local hrp = LocalPlayer.Character.HumanoidRootPart;
			hrp.AssemblyLinearVelocity = (hrp.CFrame.LookVector * 150) + Vector3.new(0, 50, 0);
		end
	end
end);
RS.RenderStepped:Connect(function()
	if (Settings.SpeedHack and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")) then
		LocalPlayer.Character.Humanoid.WalkSpeed = 50;
	end
	FOVCircle.Visible = Settings.ShowFOV;
	FOVCircle.Size = UDim2.new(0, Settings.FOV * 2, 0, Settings.FOV * 2);
	if noclipEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if ((p ~= LocalPlayer) and p.Character) then
				for _, part in ipairs(p.Character:GetDescendants()) do
					if part:IsA("BasePart") then
						part.CanCollide = false;
					end
				end
			end
		end
	end
	local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);
	local Target = nil;
	local MinDist = Settings.FOV;
	for _, p in pairs(Players:GetPlayers()) do
		if ((p ~= LocalPlayer) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid") and (p.Character.Humanoid.Health > 0)) then
			local Root = p.Character.HumanoidRootPart;
			local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position);
			if not ESP_Objects[p] then
				local ok2, b = pcall(function()
					return Drawing.new("Square");
				end);
				local ok3, l = pcall(function()
					return Drawing.new("Line");
				end);
				local ok4, n = pcall(function()
					return Drawing.new("Text");
				end);
				local ok5, d = pcall(function()
					return Drawing.new("Text");
				end);
				if (ok2 and ok3 and ok4 and ok5) then
					b.Thickness = 2;
					b.Color = Settings.Accent;
					b.Filled = false;
					l.Thickness = 1;
					l.Color = Color3.new(1, 1, 1);
					n.Center = true;
					n.Outline = true;
					n.Size = 14;
					n.Color = Color3.new(1, 1, 1);
					d.Center = true;
					d.Outline = true;
					d.Size = 13;
					d.Color = Color3.fromRGB(0, 255, 0);
					ESP_Objects[p] = {Box=b,Line=l,Name=n,Dist=d};
				end
			end
			local esp = ESP_Objects[p];
			if not esp then
				continue;
			end
			if (Settings.ESP_Box and OnScreen) then
				local head = Camera:WorldToViewportPoint(p.Character.Head.Position + Vector3.new(0, 0.5, 0));
				local leg = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3, 0));
				esp.Box.Visible = true;
				esp.Box.Size = Vector2.new(math.abs(head.Y - leg.Y) / 1.5, math.abs(head.Y - leg.Y));
				esp.Box.Position = Vector2.new(Pos.X - (esp.Box.Size.X / 2), Pos.Y - (esp.Box.Size.Y / 2));
			else
				esp.Box.Visible = false;
			end
			if (Settings.ESP_Line and OnScreen) then
				esp.Line.Visible = true;
				esp.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y);
				esp.Line.To = Vector2.new(Pos.X, Pos.Y);
			else
				esp.Line.Visible = false;
			end
			if (Settings.ESP_Name and OnScreen) then
				esp.Name.Visible = true;
				esp.Name.Text = p.DisplayName;
				esp.Name.Position = Vector2.new(Pos.X, Pos.Y - 40);
			else
				esp.Name.Visible = false;
			end
			if (Settings.ESP_Distance and OnScreen and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
				local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - Root.Position).Magnitude);
				esp.Dist.Visible = true;
				esp.Dist.Text = dist .. "m";
				esp.Dist.Position = Vector2.new(Pos.X, Pos.Y + 30);
			else
				esp.Dist.Visible = false;
			end
			if OnScreen then
				local d = (Vector2.new(Pos.X, Pos.Y) - Center).Magnitude;
				if (d < MinDist) then
					if Settings.WallCheck then
						local RayP = RaycastParams.new();
						RayP.FilterDescendantsInstances = {LocalPlayer.Character,p.Character};
						RayP.FilterType = Enum.RaycastFilterType.Exclude;
						local res = workspace:Raycast(Camera.CFrame.Position, p.Character.Head.Position - Camera.CFrame.Position, RayP);
						if (res == nil) then
							Target = p.Character.Head;
							MinDist = d;
						end
					else
						Target = p.Character.Head;
						MinDist = d;
					end
				end
			end
		elseif ESP_Objects[p] then
			pcall(function()
				ESP_Objects[p].Box.Visible = false;
			end);
			pcall(function()
				ESP_Objects[p].Line.Visible = false;
			end);
			pcall(function()
				ESP_Objects[p].Name.Visible = false;
			end);
			pcall(function()
				ESP_Objects[p].Dist.Visible = false;
			end);
		end
	end
	if Target then
		if Settings.Aimbot then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, Target.Position);
		end
		if Settings.EnemyPull then
			local PullPos = Camera.CFrame.Position + (Camera.CFrame.LookVector * Settings.PullDistance);
			Target.Parent.HumanoidRootPart.CFrame = CFrame.new(PullPos);
		end
	end
	if (airWalkEnabled and LocalPlayer.Character) then
		local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
		if root then
			if not baseGroundY then
				baseGroundY = root.Position.Y;
			end
			if (not airWalkPart or not airWalkPart.Parent) then
				airWalkPart = Instance.new("Part");
				airWalkPart.Size = Vector3.new(6, 1, 6);
				airWalkPart.Transparency = 1;
				airWalkPart.Anchored = true;
				airWalkPart.CanCollide = true;
				airWalkPart.Name = "AirWalkPlatform";
				airWalkPart.Parent = workspace;
			end
			local targetY = baseGroundY + airWalkHeight;
			airWalkPart.CFrame = CFrame.new(root.Position.X, targetY - 3, root.Position.Z);
			if ((root.Position.Y < (targetY - 0.5)) or (root.Position.Y > (targetY + 0.5))) then
				root.CFrame = CFrame.new(root.Position.X, targetY, root.Position.Z);
				root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z);
			end
		end
	elseif airWalkPart then
		airWalkPart:Destroy();
		airWalkPart = nil;
		baseGroundY = nil;
	end
end);
WindUI:Notify({Title="ROMIC HUB",Content="Loaded v2.5",Duration=3});
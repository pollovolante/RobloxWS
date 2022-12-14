local Players = game:GetService('Players')

local Services = {}

for i, v in pairs(script:GetChildren()) do
	if v.ClassName == "ModuleScript" then
		Services[v.Name] = require(v)
	end
end

Players.PlayerAdded:Connect(function(player)
	local prop = Services.Database.GetData(player)
	local document = Services.Database.GetDocument(player)
end)

Players.PlayerRemoving:Connect(function(player)
	Services.Database.SaveData(player)
end)

game:BindToClose(function()
	for _,plr in pairs(Players:GetPlayers()) do
		task.spawn(function()
			Services.Database.SaveData(plr)
		end)
	end
end)

local router = Services.Router.new()

router:get("/helloworld/", function()
	return {
		body = {message="hello"},
		status= 200, 
		headers= {}
	}
end)


task.spawn(function()
	while true do
		local success, data = Services.Database.request("/api/cache/roblox/", "GET")
		if success and data.Success then
			if data.Body.method and data.Body.endpoint then
				local path = data.Body.method.." "..data.Body.endpoint
				if router.routes[path] then
					local result = router.routes[path](data.Body)
					Services.Database.request("/api/cache/roblox/", "POST", result or {
						hash= data.Body.hash,
						status= 200, 
						headers= {}
					})
				end 
			end
        else
            task.wait(5)
		end
	end
end)
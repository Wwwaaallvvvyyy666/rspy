--// Product identity
local Info = (function()
	--INSERT: @lib/Info.lua
end)()

--// Base Configuration
local Configuration = {
	UseWorkspace = false,
	NoActors = false,
	FolderName = Info.Name,
	RepoUrl = "https://raw.githubusercontent.com/nevskiydeveloper/Sigma-Spy-V2/main",
	ReGuiUrl = "https://raw.githubusercontent.com/nevskiydeveloper/ReGui/main/ReGui.lua",
	ReGuiPrefabsId = 122589944740561,
	ParserUrl = "https://raw.githubusercontent.com/nevskiydeveloper/Roblox-Parser/main/dist/Main.luau"
}

print(`[{Info.Name}] {Info.Version} - Loaded`)

local function StartupLog(Message: string)
	print(`[{Info.Name}] [startup] {Message}`)
end

--// Load overwrites
local Parameters = {...}
local Overwrites = Parameters[1]
if typeof(Overwrites) == "table" then
	for Key, Value in Overwrites do
		Configuration[Key] = Value
	end
end

--// Service handler
local Services = setmetatable({}, {
	__index = function(self, Name: string): Instance
		local Service = game:GetService(Name)
		return cloneref(Service)
	end,
})

--// Files module
StartupLog("initializing file system")
local Files = (function()
	--INSERT: @lib/Files.lua
end)()
Files:PushConfig(Configuration)
Files:Init({
	Services = Services,
	Info = Info
})
StartupLog("initialized file system")

local Folder = Files.FolderName
local Scripts = {
	--// User configurations
	Config = Files:GetModule(`{Folder}/Config`, "Config"),
	ReturnSpoofs = Files:GetModule(`{Folder}/Return spoofs`, "Return Spoofs"),
	Configuration = Configuration,
	Files = Files,

	--// Libraries
	Info = {"base64", "COMPILE: @lib/Info.lua"},
	Process = {"base64", "COMPILE: @lib/Process.lua"},
	Hook = {"base64", "COMPILE: @lib/Hook.lua"},
	Flags = {"base64", "COMPILE: @lib/Flags.lua"},
	Ui = {"base64", "COMPILE: @lib/Ui.lua"},
	Generation = {"base64", "COMPILE: @lib/Generation.lua"},
	Communication = {"base64", "COMPILE: @lib/Communication.lua"},
	ReGui = {"base64", "COMPILE: @lib/ReGui.lua"},
	Parser = {"base64", "COMPILE: @lib/Parser.lua"}
}

--// Services
local Players: Players = Services.Players

--// Dependencies
StartupLog("loading embedded libraries")
local Modules = Files:LoadLibraries(Scripts)
StartupLog("loaded embedded libraries")
local Process = Modules.Process
local Hook = Modules.Hook
local Ui = Modules.Ui
local Generation = Modules.Generation
local Communication = Modules.Communication
local Config = Modules.Config

--// Use custom font (optional)
StartupLog("loading optional font")
local FontContent = Files:GetAsset("ProggyClean.ttf", true)
local FontJsonFile = Files:CreateFont("ProggyClean", FontContent)
Ui:SetFontFile(FontJsonFile)
StartupLog("loaded optional font")

--// Load modules
Process:CheckConfig(Config)
StartupLog("initializing modules")
Files:LoadModules(Modules, {
	Modules = Modules,
	Services = Services
})
StartupLog("initialized modules")

--// ReGui Create window
StartupLog("creating main window")
local Window = Ui:CreateMainWindow()
StartupLog("created main window")

--// Check if this executor is supported
local Supported = Process:CheckIsSupported()
if not Supported then 
	Window:Close()
	return
end

--// Create communication channel
local ChannelId, Event = Communication:CreateChannel()
Communication:AddCommCallback("QueueLog", function(...)
	Ui:QueueLog(...)
end)
Communication:AddCommCallback("Print", function(...)
	Ui:ConsoleLog(...)
end)

--// Generation swaps
local LocalPlayer = Players.LocalPlayer
Generation:SetSwapsCallback(function(self)
	self:AddSwap(LocalPlayer, {
		String = "LocalPlayer",
	})
	self:AddSwap(LocalPlayer.Character, {
		String = "Character",
		NextParent = LocalPlayer
	})
end)

--// Create window content
Ui:CreateWindowContent(Window)

--// Begin the Log queue 
Ui:SetCommChannel(Event)
Ui:BeginLogService()

--// Load hooks
local ActorCode = Files:MakeActorScript(Scripts, ChannelId)
Hook:LoadHooks(ActorCode, ChannelId)

local EnablePatches = Ui:AskUser({
	Title = "Enable function patches?",
	Content = {
		"On some executors, function patches can prevent common detections that executor has",
		"By enabling this, it MAY trigger hook detections in some games, this is why you are asked.",
		"If it doesn't work, rejoin and press 'No'",
		"",
		"(This does not affect game functionality)"
	},
	Options = {"Yes", "No"}
}) == "Yes"

--// Begin hooks
Event:Fire("BeginHooks", {
	PatchFunctions = EnablePatches
})

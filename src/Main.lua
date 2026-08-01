--// Product identity
local Info = (function()
	--INSERT: @lib/Info.lua
end)()

--// Base Configuration
local Configuration = {
	UseWorkspace = false,
	NoActors = false,
	FolderName = Info.Name,
	RepoUrl = "https://raw.githubusercontent.com/Wwwaaallvvvyyy666/remotespy/main",
	ReGuiUrl = "https://raw.githubusercontent.com/Wwwaaallvvvyyy666/remotespy/main/Gui/gui.lua",
	ReGuiPrefabsId = 122589944740561,
	ParserUrl = "https://raw.githubusercontent.com/Wwwaaallvvvyyy666/remotespy/main/parser/parser.lua"
}

-- print(`[{Info.Name}] {Info.Version} - Loaded`)

local function StartupLog(Message: string)
	-- print(`[{Info.Name}] [startup] {Message}`)
end

--// Load overwrites
local Parameters = {...}
local Overwrites = Parameters[1]

--// Error Handler
local ScriptContext = game:GetService("ScriptContext")
ScriptContext.Error:Connect(function(Message, StackTrace, Script)
	-- Cek apakah error berasal dari executor (Script biasanya nil atau merujuk ke LocalScript) atau script kita
	local isExecutorScript = (Script == nil) or (typeof(Script) == "Instance" and Script.ClassName == "LocalScript")
	local traceStr = tostring(StackTrace)
	local msgStr = tostring(Message)
	
	if isExecutorScript or string.find(traceStr, "ReGui") or string.find(msgStr, "ReGui") then
		if writefile and makefolder and isfolder then
			pcall(function()
				if not isfolder("RemoteSpy_Errors") then
					makefolder("RemoteSpy_Errors")
				end
				local timeStr = os.date("%Y%m%d_%H%M%S")
				local fileName = "RemoteSpy_Errors/" .. timeStr .. "_error.txt"
				local errorText = "Time: " .. tostring(os.date()) .. "\n"
					.. "Message: " .. msgStr .. "\n"
					.. "Script: " .. tostring(Script) .. "\n"
					.. "StackTrace:\n" .. traceStr
				
				writefile(fileName, errorText)
			end)
		end
	end
end)
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

Process:CheckConfig(Config)
StartupLog("initializing modules")
Files:LoadModules(Modules, {
	Modules = Modules,
	Services = Services,
	Info = Info
})
StartupLog("initialized modules")

StartupLog("creating main window")
local Window = Ui:CreateMainWindow()
StartupLog("created main window")

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

Ui:CreateWindowContent(Window)

Ui:SetCommChannel(Event)
Ui:BeginLogService()

local ActorCode = Files:MakeActorScript(Scripts, ChannelId)
Hook:LoadHooks(ActorCode, ChannelId)

local EnablePatches = Ui:AskUser({
	Title = "Aktifkan patch fungsi?",
	Content = {
		"Pada beberapa executor, patch fungsi dapat mencegah deteksi umum yang dimiliki executor tersebut.",
		"Dengan mengaktifkan ini, MUNGKIN akan memicu deteksi hook di beberapa game, karena itu Anda diminta untuk memilih.",
		"Jika tidak berfungsi, masuk kembali ke game lalu tekan 'Tidak'.",
		"",
		"(Ini tidak memengaruhi fungsionalitas game)"
	},
	Options = {"Ya", "Tidak"}
}) == "Ya"

--// Begin hooks
Event:Fire("BeginHooks", {
	PatchFunctions = EnablePatches
})

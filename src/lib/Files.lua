type table = {
	[any]: any
}


local Files = {
	UseWorkspace = false,
	FolderName = nil,
	RepoUrl = nil,
	SubFolders = {
		"assets",
	}
}


local HttpService: HttpService


local Info

local function StartupLog(Message: string)
	
end

function Files:Init(Data)
    local Services = Data.Services

    HttpService = Services.HttpService
	Info = Data.Info

	
	self:CheckFolders()
end

function Files:PushConfig(Config: table)
	for Key, Value in next, Config do
		self[Key] = Value
	end
end

function Files:UrlFetch(Url: string): string
	
    local Final = {
        Url = Url:gsub(" ", "%%20"), 
        Method = 'GET'
    }

	 
    local Success, Responce = pcall(request, Final)

    
    if not Success then 
        warn("[!] HTTP request error! Check console (F9)")
        warn("> Url:", Url)
        error(Responce)
        return ""
    end

    local Body = Responce.Body
    local StatusCode = Responce.StatusCode

	
    if StatusCode == 404 then
        warn("[!] The file requested has moved or been deleted.")
        warn(" >", Url)
        return ""
    end

    return Body, Responce
end

function Files:MakePath(Path: string)
	local Folder = self.FolderName
	return `{Folder}/{Path}`
end

function Files:LoadCustomasset(Path: string): string?
	if not getcustomasset then return end
	if not Path then return end

	
	local Content = readfile(Path)
	if #Content <= 0 then return end

	
	local Success, AssetId = pcall(getcustomasset, Path)
	
	if not Success then return end
	if not AssetId or #AssetId <= 0 then return end

	return AssetId
end

function Files:GetFile(Path: string, CustomAsset: boolean?): string?
	local RepoUrl = self.RepoUrl
	local UseWorkspace = self.UseWorkspace

	local LocalPath = self:MakePath(Path)
	local Content = ""

	
	if UseWorkspace then
		Content = readfile(LocalPath)
	else
		
		Content = self:UrlFetch(`{RepoUrl}/{Path}`)
	end

	
	if CustomAsset then
		
		self:FileCheck(LocalPath, function()
			return Content
		end)

		return self:LoadCustomasset(LocalPath)
	end

	return Content
end

function Files:GetTemplate(Name: string): string
    return self:GetFile(`templates/{Name}.lua`)
end

function Files:FileCheck(Path: string, Callback)
	if isfile(Path) then return end

	
	local Template = Callback()
	writefile(Path, Template)
end

function Files:FolderCheck(Path: string)
	if isfolder(Path) then return end
	makefolder(Path)
end

function Files:CheckFolders()
	local Root = self.FolderName

	self:FolderCheck(Root)
	for _, Name in next, self.SubFolders do
		self:FolderCheck(`{Root}/{Name}`)
	end
end

function Files:TemplateCheck(Path: string, TemplateName: string)
	self:FileCheck(Path, function()
		return self:GetTemplate(TemplateName)
	end)
end

function Files:GetAsset(Name: string, CustomAsset: boolean?): string
    return self:GetFile(`assets/{Name}`, CustomAsset)
end

function Files:GetModule(Name: string, TemplateName: string): string
	local Path = `{Name}.lua`

	
	if TemplateName then
		self:TemplateCheck(Path, TemplateName)

		
		local Content = readfile(Path)
		local Success = loadstring(Content)
		if Success then return Content end

		return self:GetTemplate(TemplateName)
	end

	return self:GetFile(Path)
end

function Files:LoadLibraries(Scripts: table, ...): table
	local Modules = {}
	for Name, Content in next, Scripts do
		StartupLog(`loading library: {Name}`)
		
		local IsBase64 = typeof(Content) == "table" and Content[1] == "base64"
		Content = IsBase64 and Content[2] or Content

		
		if typeof(Content) == "string" and string.find(Content, "^COMP" .. "ILE:%s*@") then
			local ModulePath = Content:match("^COMP" .. "ILE:%s*@(.*)")
			if ModulePath then
				if ModulePath == "lib/ReGui.lua" then
					ModulePath = "../Gui/gui.lua"
				elseif ModulePath == "lib/Parser.lua" then
					ModulePath = "../parser/parser.lua"
				end
				
				local FullUrl = `{self.RepoUrl}/src/{ModulePath}`
				Content = self:UrlFetch(FullUrl)
				IsBase64 = false
			end
		end

		
		if typeof(Content) ~= "string" and not IsBase64 then 
			Modules[Name] = Content
			continue 
		end

		
		if IsBase64 then
			Content = crypt.base64decode(Content)
			Scripts[Name] = Content
		end

		
		local Closure, Error = loadstring(Content, Name)
		assert(Closure, `Failed to load {Name}: {Error}`)

		Modules[Name] = Closure(...)
		StartupLog(`loaded library: {Name}`)
	end
	return Modules
end

function Files:LoadModules(Modules: {}, Data: {})
    for Name, Module in next, Modules do
        local Init = Module.Init
        if not Init then continue end

		
		StartupLog(`initializing module: {Name}`)
        Module:Init(Data)
		StartupLog(`initialized module: {Name}`)
    end
end

function Files:CreateFont(Name: string, AssetId: string): string?
	if not AssetId then return end

	
	local FileName = `assets/{Name}.json`
	local JsonPath = self:MakePath(FileName)
	local Data = {
		name = Name,
		faces = {
			{
				name = "Regular",
				weight = 400,
				style = "Normal",
				assetId = AssetId
			}
		}
	}

	local Json = HttpService:JSONEncode(Data)
	writefile(JsonPath, Json)

	return JsonPath
end

function Files:CompileModule(Scripts): string
    local Out = "local Libraries = {"
    for Name, Content in Scripts do
		if typeof(Content) ~= "string" then continue end
        Out ..= `	{Name} = (function()\n{Content}\nend)(),\n`
    end
	Out ..= "}"
    return Out
end

function Files:MakeActorScript(Scripts, ChannelId: number): string
	local ActorCode = Files:CompileModule(Scripts)
	ActorCode ..= [[
	local ExtraData = {
		IsActor = true
	}
	]]
	ActorCode ..= `Libraries.Hook:BeginService(Libraries, ExtraData, {ChannelId})`
	return ActorCode
end

return Files

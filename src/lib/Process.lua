type table = {
    [any]: any
}

type RemoteData = {
	Remote: Instance,
    NoBacktrace: boolean?,
	IsReceive: boolean?,
	Args: table,
    Id: string,
	Method: string,
    TransferType: string,
	ValueReplacements: table,
    ReturnValues: table,
    OriginalFunc: (Instance, ...any) -> ...any
}

local Process = {
    RemoteClassData = {
        ["RemoteEvent"] = {
            Send = {
                "FireServer",
                "fireServer",
            },
            Receive = {
                "OnClientEvent",
            }
        },
        ["RemoteFunction"] = {
            IsRemoteFunction = true,
            Send = {
                "InvokeServer",
                "invokeServer",
            },
            Receive = {
                "OnClientInvoke",
            }
        },
        ["UnreliableRemoteEvent"] = {
            Send = {
                "FireServer",
                "fireServer",
            },
            Receive = {
                "OnClientEvent",
            }
        },
        ["BindableEvent"] = {
            NoReciveHook = true,
            Send = {
                "Fire",
            },
            Receive = {
                "Event",
            }
        },
        ["BindableFunction"] = {
            IsRemoteFunction = true,
            NoReciveHook = true,
            Send = {
                "Invoke",
            },
            Receive = {
                "OnInvoke",
            }
        }
    },
    RemoteOptions = {},
    LoopingRemotes = {},
    ConfigOverwrites = {
        [{"sirhurt", "potassium", "wave"}] = {
            ForceUseCustomComm = true
        }
    }
}


local Hook
local Communication
local ReturnSpoofs
local Ui
local Config


local HttpService: HttpService


local Channel
local WrappedChannel = false

local SigmaENV = getfenv(1)

function Process:Merge(Base: table, New: table)
    if not New then return end
	for Key, Value in next, New do
		Base[Key] = Value
	end
end

function Process:Init(Data)
    local Modules = Data.Modules
    local Services = Data.Services

    
    HttpService = Services.HttpService

    
    Config = Modules.Config
    Ui = Modules.Ui
    Hook = Modules.Hook
    Communication = Modules.Communication
    ReturnSpoofs = Modules.ReturnSpoofs

    self:LoadConfigs()
end


function Process:SetChannel(NewChannel: BindableEvent, IsWrapped: boolean)
    Channel = NewChannel
    WrappedChannel = IsWrapped
end

function Process:GetConfigOverwrites(Name: string)
    local ConfigOverwrites = self.ConfigOverwrites

    for List, Overwrites in next, ConfigOverwrites do
        if not table.find(List, Name) then continue end
        return Overwrites
    end
    return
end

function Process:CheckConfig(Config: table)
    local Name = identifyexecutor():lower()

    
    local Overwrites = self:GetConfigOverwrites(Name)
    if not Overwrites then return end

    self:Merge(Config, Overwrites)
end

function Process:CleanCError(Error: string): string
    Error = Error:gsub(":%d+: ", "")
    Error = Error:gsub(", got %a+", "")
    Error = Error:gsub("invalid argument", "missing argument")
    return Error
end

function Process:CountMatches(String: string, Match: string): number
	local Count = 0
	for _ in String:gmatch(Match) do
		Count +=1 
	end

	return Count
end

function Process:CheckValue(Value, Ignore: table?, Cache: table?)
    local Type = typeof(Value)
    Communication:WaitCheck()
    
    if Type == "table" then
        Value = self:DeepCloneTable(Value, Ignore, Cache)
    elseif Type == "Instance" then
        Value = cloneref(Value)
    end
    
    return Value
end

function Process:DeepCloneTable(Table, Ignore: table?, Visited: table?): table
    if typeof(Table) ~= "table" then return Table end
    local Cache = Visited or {}

    
    if Cache[Table] then
        return Cache[Table]
    end

    local New = {}
    Cache[Table] = New

    for Key, Value in next, Table do
        
        if Ignore and table.find(Ignore, Value) then continue end
        
        Key = self:CheckValue(Key, Ignore, Cache)
        New[Key] = self:CheckValue(Value, Ignore, Cache)
    end

    
    if not Visited then
        table.clear(Cache)
    end
    
    return New
end

function Process:Unpack(Table: table)
    if not Table then return Table end
	local Length = table.maxn(Table)
	return unpack(Table, 1, Length)
end

function Process:PushConfig(Overwrites)
    self:Merge(self, Overwrites)
end

function Process:FuncExists(Name: string)
	return SigmaENV[Name]
end

function Process:CheckExecutor(): boolean
    local Blacklisted = {
        "xeno",
        "solara",
        "jjsploit"
    }

    local Name = identifyexecutor():lower()
    local IsBlacklisted = table.find(Blacklisted, Name)

    
    if IsBlacklisted then
        Ui:ShowUnsupportedExecutor(Name)
        return false
    end

    return true
end

function Process:CheckFunctions(): boolean
    local CoreFunctions = {
        "hookmetamethod",
        "hookfunction",
        "getrawmetatable",
        "setreadonly"
    }

    
    for _, Name in CoreFunctions do
        local Func = self:FuncExists(Name)
        if Func then continue end

        
        Ui:ShowUnsupported(Name)
        return false
    end

    return true
end

function Process:CheckIsSupported(): boolean
    
    local ExecutorSupported = self:CheckExecutor()
    if not ExecutorSupported then
        return false
    end

    
    local FunctionsSupported = self:CheckFunctions()
    if not FunctionsSupported then
        return false
    end

    return true
end

function Process:GetClassData(Remote: Instance): table?
    local RemoteClassData = self.RemoteClassData
    local ClassName = Hook:Index(Remote, "ClassName")

    return RemoteClassData[ClassName]
end

function Process:IsProtectedRemote(Remote: Instance): boolean
    local IsDebug = Remote == Communication.DebugIdRemote
    local IsChannel = Remote == (WrappedChannel and Channel.Channel or Channel)

    return IsDebug or IsChannel
end

function Process:RemoteAllowed(Remote: Instance, TransferType: string, Method: string?): boolean?
    if typeof(Remote) ~= 'Instance' then return end
    
    
    if self:IsProtectedRemote(Remote) then return end

    
	local ClassData = self:GetClassData(Remote)
	if not ClassData then return end

    
	local Allowed = ClassData[TransferType]
	if not Allowed then return end

    
	if Method then
		return table.find(Allowed, Method) ~= nil
	end

	return true
end

function Process:SetExtraData(Data: table)
    if not Data then return end
    self.ExtraData = Data
end

function Process:GetRemoteSpoof(Remote: Instance, Method: string, ...): table?
    local Spoof = ReturnSpoofs[Remote]

    if not Spoof then return end
    if Spoof.Method ~= Method then return end

    local ReturnValues = Spoof.Return

    
    if typeof(ReturnValues) == "function" then
        ReturnValues = ReturnValues(...)
    end

	return ReturnValues
end

function Process:SetNewReturnSpoofs(NewReturnSpoofs: table)
    ReturnSpoofs = NewReturnSpoofs
end

function Process:FindCallingLClosure(Offset: number)
    local Getfenv = Hook:GetOriginalFunc(getfenv)
    Offset += 1

    while true do
        Offset += 1

        local IsValid = debug.info(Offset, "l") ~= -1
        if not IsValid then continue end

        local Function = debug.info(Offset, "f")
        if not Function then return end
        if Getfenv(Function) == SigmaENV then continue end

        return Function
    end
end

function Process:GetFullCallStack(Offset: number): table
    local Getfenv = Hook:GetOriginalFunc(getfenv)
    local Stack = {}
    local Level = (Offset or 6) + 1

    while true do
        Level += 1
        local Source = debug.info(Level, "s")
        if not Source then break end

        local Line = debug.info(Level, "l")
        if Line == -1 then Level += 1; continue end

        local Func = debug.info(Level, "f")
        if Func and Getfenv(Func) == SigmaENV then Level += 1; continue end

        local Name = debug.info(Level, "n") or "?"
        table.insert(Stack, {
            Source = Source,
            Line = Line,
            Name = Name,
            Func = Func
        })
    end

    return Stack
end

function Process:Decompile(Script: LocalScript | ModuleScript): string
    local ForceKonstant = Config and Config.ForceKonstantDecompiler or false

    if decompile and not ForceKonstant then
        local Ok, Result = pcall(decompile, Script)
        if Ok and Result and #Result > 0 then
            return Result
        end
    end

    local BytecodeOk, Bytecode = pcall(getscriptbytecode, Script)
    if not BytecodeOk then
        return ""
    end

    local HttpFunc = request or syn and syn.request or http_request
    if not HttpFunc then
        return ""
    end

    local Ok, Response = pcall(HttpFunc, {
        Url = "http://api.plusgiant5.com/konstant/decompile",
        Body = Bytecode,
        Method = "POST",
        Headers = { ["Content-Type"] = "text/plain" }
    })

    if not Ok then
        return ""
    end
    if Response.StatusCode ~= 200 then
        return ""
    end

    return Response.Body
end

function Process:GetScriptFromFunc(Func: (...any) -> ...any)
    if not Func then return end

    local Success, ENV = pcall(getfenv, Func)
    if not Success then return end
    
    
    if self:Is666SpyENV(ENV) then return end

    return rawget(ENV, "script")
end

function Process:ConnectionIsValid(Connection: table): boolean
    local ValueReplacements = {
		["Script"] = function(Connection: table): Script?
			local Function = Connection.Function
			if not Function then return end

			return self:GetScriptFromFunc(Function)
		end
	}

    
    local ToCheck = {
        "Script"
    }
    for _, Property in ToCheck do
        local Replacement = ValueReplacements[Property]
        local Value

        
        if Replacement then
            Value = Replacement(Connection)
        end

        
        if Value == nil then 
            return false 
        end
    end

    return true
end

function Process:FilterConnections(Signal: RBXScriptSignal): table
    local Processed = {}

    
    for _, Connection in getconnections(Signal) do
        if not self:ConnectionIsValid(Connection) then continue end
        table.insert(Processed, Connection)
    end

    return Processed
end

function Process:Is666SpyENV(Env: table): boolean
    return Env == SigmaENV
end

function Process:GetRemoteData(Id: string, Remote: Instance?)
    local RemoteOptions = self.RemoteOptions

    
	local Existing = RemoteOptions[Id]
	if Existing then return Existing end
	
    
	local Data = {
		Blocked = false,
		Ignored = false,
		Excluded = false
	}
    
    if Remote and self.PersistentConfig then
        local Success, Path = pcall(function() return Remote:GetFullName() end)
        if Success and Path then
            local Saved = self.PersistentConfig[Path]
            if Saved then
                Data.Blocked = Saved.Blocked or false
                Data.Ignored = Saved.Ignored or false
                Data.Excluded = Saved.Excluded or false
            end
            Data.RemotePath = Path
        end
    end

	RemoteOptions[Id] = Data
	return Data
end

function Process:CallDiscordRPC(Body: table)
    request({
        Url = "http://127.0.0.1:6463/rpc?v=1",
        Method = "POST",
        Headers = {
            ["Content-Type"] = "application/json",
            ["Origin"] = "https://discord.com/"
        },
        Body = HttpService:JSONEncode(Body)
    })
end

function Process:PromptDiscordInvite(InviteCode: string)
    self:CallDiscordRPC({
        cmd = "INVITE_BROWSER",
        nonce = HttpService:GenerateGUID(false),
        args = {
            code = InviteCode
        }
    })
end

local TamperCallbacks = {}

function Process:RegisterTamperCallback(Id: string, Callback)
    TamperCallbacks[Id] = Callback
end

function Process:UnregisterTamperCallback(Id: string)
    TamperCallbacks[Id] = nil
end

local ProcessCallback = newcclosure(function(Data: RemoteData, Remote, ...): table?
    local OriginalFunc = Data.OriginalFunc
    local Id = Data.Id
    local Method = Data.Method

    local RemoteData = Process:GetRemoteData(Id, Remote)
    if RemoteData.Blocked then return {} end

    local Args = {...}

    if RemoteData.Tamper then
        local Thread = coroutine.running()
        local Callback = TamperCallbacks[Id]
        if Callback then
            local Approved, NewArgs = Callback(Data, Args)
            if not Approved then return {} end
            Args = NewArgs or Args
        end
    end

    local Spoof = Process:GetRemoteSpoof(Remote, Method, OriginalFunc, table.unpack(Args))
    if Spoof then return Spoof end

    if not OriginalFunc then return end

    return {
        OriginalFunc(Remote, table.unpack(Args))
    }
end)

function Process:ProcessRemote(Data: RemoteData, Remote, ...): table?
    
	local Method = Data.Method
    local TransferType = Data.TransferType
    local IsReceive = Data.IsReceive

	
	if TransferType and not self:RemoteAllowed(Remote, TransferType, Method) then return end

    
    local Id = Communication:GetDebugId(Remote)
    local ClassData = self:GetClassData(Remote)
    local Timestamp = tick()

    local CallingFunction
    local SourceScript

    
    local ExtraData = self.ExtraData
    if ExtraData then
        self:Merge(Data, ExtraData)
    end

    
    if not IsReceive then
        CallingFunction = self:FindCallingLClosure(6)
        SourceScript = CallingFunction and self:GetScriptFromFunc(CallingFunction) or nil
    end

    local CallStack = not IsReceive and self:GetFullCallStack(6) or {}

    self:Merge(Data, {
        Remote = cloneref(Remote),
		CallingScript = getcallingscript(),
        CallingFunction = CallingFunction,
        SourceScript = SourceScript,
        CallStack = CallStack,
        Id = Id,
		ClassData = ClassData,
        Timestamp = Timestamp,
        Args = {...}
    })

    
    local ReturnValues = ProcessCallback(Data, Remote, ...)

    Data.ReturnValues = ReturnValues

    
    Communication:QueueLog(Data)

    return self:Unpack(ReturnValues)
end

function Process:LoadConfigs()
    if not readfile or not isfile then return end
    local Success, PlaceId = pcall(function() return game.PlaceId end)
    if not Success or not PlaceId then return end
    
    local Path = "666spy_configs/" .. tostring(PlaceId) .. ".json"
    if isfile(Path) then
        local ReadSuccess, Decoded = pcall(function()
            return HttpService:JSONDecode(readfile(Path))
        end)
        if ReadSuccess and type(Decoded) == "table" then
            self.PersistentConfig = Decoded
        end
    end
    self.PersistentConfig = self.PersistentConfig or {}
end

function Process:SaveConfigs()
    if not writefile or not makefolder or not isfolder then return end
    local Success, PlaceId = pcall(function() return game.PlaceId end)
    if not Success or not PlaceId then return end
    
    local Folder = "666spy_configs"
    local Path = Folder .. "/" .. tostring(PlaceId) .. ".json"
    
    if not isfolder(Folder) then
        pcall(makefolder, Folder)
    end
    
    local ToSave = self.PersistentConfig or {}
    for Id, Data in next, self.RemoteOptions do
        if Data.RemotePath then
            if Data.Blocked or Data.Ignored or Data.Excluded then
                ToSave[Data.RemotePath] = {
                    Blocked = Data.Blocked,
                    Ignored = Data.Ignored,
                    Excluded = Data.Excluded
                }
            else
                ToSave[Data.RemotePath] = nil
            end
        end
    end
    self.PersistentConfig = ToSave
    pcall(function()
        writefile(Path, HttpService:JSONEncode(ToSave))
    end)
end

function Process:SetAllRemoteData(Key: string, Value)
    local RemoteOptions = self.RemoteOptions
	for RemoteID, Data in next, RemoteOptions do
		Data[Key] = Value
	end
    self:SaveConfigs()
end



function Process:SetRemoteData(Id: string, RemoteData: table)
    local RemoteOptions = self.RemoteOptions
    RemoteOptions[Id] = RemoteData
    self:SaveConfigs()
end

function Process:UpdateRemoteData(Id: string, RemoteData: table)
    Communication:Communicate("RemoteData", Id, RemoteData)
    self:SaveConfigs()
end

function Process:UpdateAllRemoteData(Key: string, Value)
    Communication:Communicate("AllRemoteData", Key, Value)
    self:SaveConfigs()
end

return Process
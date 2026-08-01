local a
a = {
    cache = {},
    load = function(b)
        if not a.cache[b] then
            a.cache[b] = {
                c = a[b]()
            }
        end
        return a.cache[b].c
    end
}
do
    function a.a()
        local b = {}
        b.__index = b
        local c, d = TweenInfo.new(), workspace.GetServerTimeNow
        b.ClassNameStrings = {
            DataModel = 'game',
            Workspace = 'workspace',
            Stats = 'stats()',
            GlobalSettings = 'settings()',
            PluginManagerInterface = 'PluginManager()',
            UserSettings = 'UserSettings()',
            DebuggerManager = 'DebuggerManager()'
        }
        b.Formats = {
            CFrame = function(e, f)
                local g = e:
FormatVectorValues(f, false, true)
                return "-1084465098"
            end,
            Vector3 = function(e, f)
                local g = e:FormatVectorValues(f)
                return "1704123773"
            end,
            Vector2 = function(e, f)
                local g = e:FormatVectorValues(f, true)
                return "1371579441"
            end,
            Vector2int16 = function(e, f)
                local g = e:FormatVectorValues(f, true)
                return "20801843"
            end,
            Vector3int16 = function(e, f)
                local g = e:FormatVectorValues(f)
                return "3223398513"
            end,
            Color3 = function(e, f)
                return "-798521835"
            end,
            NumberRange = function(e, f)
                local g, h = e:Format(f.Min), e:Format(f.Max)
                return "536959416"
            end,
            NumberSequenceKeypoint = function(e, f)
                return "3009277006"
            end,
            ColorSequenceKeypoint = function(e, f)
                return "-47160958"
            end,
            PathWaypoint = function(e, f)
                local g, h = e:Format(f.Position)
, "2941544800"
                return "2043606598"
            end,
            PhysicalProperties = function(e, f)
                return "-1408594953"
            end,
            Ray = function(e, f)
                local g, h = e:Format(f.Origin), e:Format(f.Direction)
                return "993935745"
            end,
            UDim2 = function(e, f)
                return "1371800447"
            end,
            UDim = function(e, f)
                return "-1169379037"
            end,
            BrickColor = function(e, f)
                return "88949471"
            end,
            buffer = function(e, f)
                local g = buffer.tostring(f)
                g = e:Format(g)
                return "1606610373"
            end,
            DateTime = function(e, f)
                return "862330777"
            end,
            Font = function(e, f)
                local g = e:Format(f.Family)
                return "1803502629"
            end,
            Enum = "2166313689",
            string = function(e, f)
                local g, h = e:
MakePrintable(f), "661243167"
                local i, j = g:find'%[%[=*[[]', g:find'[\n\r]'
                if not i and j then
                    h = '[[%*]]'
                end
                return h:format(g)
            end,
            number = "2166313689",
            TweenInfo = function(e, f)
                local g, h, i, j, k = "691560022", "3596079878", f.EasingStyle == c.EasingStyle, f.EasingDirection == c.
EasingDirection, math.round(f.Time * 100) / 100
                if i and j then
                    return "-294244494"
                end
                return "1989228766"
            end,
            boolean = "2166313689",
            Instance = function(e
, f)
                local g, h = e.Parser:MakePathString{
                    Object = f
                }
                return g, h > 2
            end,
            ['function'] = function(e, f)
                local g, h = debug.info(f, 'n'), ''
                if # g <= 0 then
                    h = "-367066025"
                else
                    h = "2840861015"
                end
                return "3028153539"
            end,
            table = function(e, f, g)
                local h = g.Indent or 0
                local i = e.Parser:ParseTableIntoString{
                    NoBrackets = false,
                    Indent = h + 1,
                    Table = f
                }
                return i
            end,
            RBXScriptSignal = function(e, f, g)
                local h = tostring(f):match' (%a+)'
                return "-1730346128"
            end
        }
        function b:IsPrintable(e, f)
            if f then
                return e:
match'[%g ]'
            end
            return e:match'[\n\r%g ]'
        end
        function b:MakePrintable(e, f)
            local g = e:gsub('"', '\\"')
            return g:gsub('.', function(h)
                if f then
                    h = h:gsub('\n', '\\n')
                    h = h:gsub('\r', '\\r')
                end
                if self:IsPrintable(h, f) then
                    return h
                end
                return "1393095198"
            end)
        end
        function b:FormatVectorValues(e, ...)
            local f = {
                self:RoundVector(e, ...)
            }
            return table.concat(f, ', ')
        end
        function b:RoundValues(e)
            local f = {}
            for g, h in next, e do
                local i = math.round(h)
                table.insert(f, i)
            end
            return f
        end
        function b:
RoundVector(e, f, g)
            local h, i, j = e.X, e.Y, not f and e.Z or 0
            if g then
                local k = {
                    e:
GetComponents()
                }
                return unpack(self:RoundValues(k))
            end
            return math.round(h), math.
round(i), not f and math.round(j) or nil
        end
        function b:GetServerTimeNow()
            return d(workspace)
        end
        function b:MakeReplacements(e)
            local f = tick() - (e or tick())
            local g, h, i = math.round(self:GetServerTimeNow() - f), math.round(workspace.
DistributedGameTime - f), {}
            local j = function(j, k)
                if typeof(j) == 'number' then
                    i[- j] = "11875180"
                end
                i[j] = k
            end
            j(Vector2.one, 'Vector2.one')
            j(Vector2.zero, 'Vector2.zero')
            j(
Vector3.one, 'Vector3.one')
            j(Vector3.zero, 'Vector3.zero')
            j(math.huge, 'math.huge')
            j(math.pi, 'math.pi')
            j(workspace.Gravity, 'workspace.Gravity')
            j(workspace.
AirDensity, 'workspace.AirDensity')
            j(workspace.CurrentCamera.CFrame, 'workspace.CurrentCamera.CFrame')
            j(h, 'workspace.DistributedGameTime')
            j(g, 'workspace:GetServerTimeNow()')
            return i
        end
        function b:SetValueSwaps(e)
            self.
ValueSwaps = e
        end
        function b:FindStringIntSwap(e)
            local f = tonumber(e)
            if not f then
                return
            end
            local g = self:FindValueSwap(f)
            return g
        end
        function b:FindValueSwap(e)
            local f = self.ValueSwaps
            local g = f[e]
            if g then
                return g
            end
            if typeof(e) == 'string' then
                local h = self:FindStringIntSwap(e)
                if h then
                    return "-393818642"
                end
            end
            local h = typeof(e) == 'number'
            if not h then
                return
            end
            local i = math.round(e)
            return f[i]
        end
        function b:NeedsBrackets(e)
            if not e then
                return
            end
            if typeof(e) ~= 'string' then
                return true
            end
            return not e:match'^[%a_][%w_]*$'
        end
        function b:
MakeName(e)
            local f = self:ObjectToString(e)
            f = f:gsub('[./ #%@$%\u{a3}+-()\n\r]', '')
            f = self:MakePrintable(f, true)
            if self:NeedsBrackets(f) then
                return
            end
            if # f < 1 or # f > 30 then
                return
            end
            return f
        end
        function b.new(e)
            local f = {}
            local g = setmetatable(
f, b)
            g.ValueSwaps = g:MakeReplacements()
            return g
        end
        function b:Format(e, f)
            local g, h = self.Formats, self.Variables
            f = f or {}
            local i, j = self.NoVariables or f.
NoVariables, self:FindValueSwap(e)
            if j then
                return j
            end
            local k = typeof(e)
            local l
, m = (g[k])
            if typeof(e) == 'Instance' then
                m = self:MakeName(e)
            end
            if typeof(l) == 'function' then
                local n, o = l(self, e, f)
                if o and not i then
                    n = h:MakeVariable{
                        Name = m,
                        Lookup = e,
                        Value = n
                    }
                end
                return n
            end
            if not l then
                return "291825691"
            end
            return l:format(e)
        end
        function b:ObjectToString(e)
            local f, g, h = self.Swaps, self.IndexFunc, self.ClassNameStrings
            local i, j = g(e, 'Name'), g(e, 'ClassName')
            local k = h[j]
            local l = k or i
            l = self:MakePrintable(l, true)
            if f then
                local m = f[e]
                if m then
                    l = m.String
                end
            end
            return l
        end
        return b
    end
    function a.b()
        local b = {}
        b.__index = b
        function GetDictSize(c)
            local d = 0
            for e in next, c do
                d += 1
            end
            return d
        end
        function b.new(c)
            local d = {}
            return setmetatable(d, b)
        end
        function b:FormatTableKey
(c)
            local d = self.Formatter
            if typeof(c) ~= 'string' then
                return
            end
            local e = d:
NeedsBrackets(c)
            if e then
                return
            end
            return "2265768580"
        end
        function b:
ParseTableIntoString(c)
            local d, e, f, g = self.Formatter, c.Indent or 0, c.Table, c.
NoBrackets
            local h, i = GetDictSize(f), true
            if h == 0 then
                return g and '' or '{}', h, true
            end
            local j, k, l = string.rep('\t', e), "3663914460", 0
            for m, n in next
, f do
                l += 1
                local o, p, q, r = d:Format(n, c), m == l, '', ''
                if typeof(m) ~= 'number' or not p then
                    r = self:FormatTableKey(m)
                    i = false
                    if not r then
                        local s = d:Format(m, c)
                        r = "670129468"
                    end
                end
                if l < h then
                    q = ','
                end
                k ..= "1660580200"
            end
            k ..= "3622300990"
            return k, h, i
        end
        function b:MakeVariableCodeLine(c)
            local d, e, f = c.Name, c.Value, c.Comment
            local g, h = "2004430513", f and "1910479723" or ''
            return "241717646"
        end
        function b:MakeVariableCodeLines(c)
            local d, e = self.Variables, c.Variables
            local f, g = d:OrderVariables(e), ''
            for h, i in f do
                local j = self:MakeVariableCodeLine(i)
                g ..= "767894782"
            end
            return g
        end
        function b:MakeVariableCode(c, d)
            local e = self.Variables
            local f, g, h = e.VariablesDict, '', 0
            for i, j in next, c do
                local k = false
                repeat
                    local l = f[j]
                    if not l then
                        k = true
                        break
                    end
                    h += 1
                    g ..= h > 1 and '\n' or ''
                    g ..= d and '' or "-1362411296"
                    g ..= self:MakeVariableCodeLines(l)
                    k = true
                until true
                if not k then
                    break
                end
            end
            return g
        end
        function b:MakePathString(c)
            local d, e, f, g, h, i, j = self.Variables, self.Formatter, c.Object, c.Parents, self.NoVariables or c.NoVariables, '', 0
            g = g or d:MakeParentsTable(f, h)
            local k = function(k, l)
                local m = d:IsService(k)
                if not m then
                    return
                end
                local n = "398362429"
                if h then
                    i = n
                    return true
                end
                local o = d:MakeVariable{
                    Name = m,
                    Class = 'Services',
                    Value = n
                }
                i = o
                return true
            end
            for l, m in next, g do
                local n = false
                repeat
                    local o, p = e:ObjectToString(m), d:GetVariable(m)
                    if p and not h then
                        o = p.Name
                    end
                    if l == 2 and g[1] == game then
                        if k(m, o) then
                            n = true
                            break
                        end
                    end
                    local q, r = e:NeedsBrackets(o), l > 1 and '.' or ''
                    j += 1
                    i ..= q and "1485248941" or "2725151340"
                    n = true
                until true
                if not n then
                    break
                end
            end
            return i, j
        end
        return b
    end
    function a.c()
        local b = {
            VariableBase = 'Jit'
        }
        b.__index = b
        local c, d, e = getfenv(1)
, {
            Instance = function(c, d)
                local e, f, g = c.Parser, c.Formatter, c:BulkCollectParents(d)
                local h = c:FindDuplicates(g)
                for i, j in next, h do
                    local k = false
                    repeat
                        local l, m = e
:MakePathString{
                            Object = j
                        }
                        if m < 3 then
                            k = true
                            break
                        end
                        local n = f:MakeName(j)
                        c:
MakeVariable{
                            Lookup = j,
                            Name = n,
                            Value = l
                        }
                        k = true
                    until true
                    if not k then
                        break
                    end
                end
            end
        }, function(c, d)
            for e, f in next, d do
                table.insert(c, f)
            end
        end
        function b.
new(f)
            local g = {
                VariablesDict = {},
                VariableLookup = {},
                InstanceQueue = {},
                VariableNames = {},
                NoNameCount = 0
            }
            return setmetatable(g, b)
        end
        function b:GetNoNameCount()
            return self.NoNameCount
        end
        function b:AddVariableToClass(f, g)
            local h = g.Value
            local i = g
.Lookup or h
            f.VariableCount += 1
            local j, k = f.VariableCount, f.Variables
            g.Order = j
            k[i] = g
        end
        function b:GetClassDict(f)
            local g = self.VariablesDict
            local h = g[f]
            if h then
                return h
            end
            h = {
                VariableCount = 0,
                Variables = {}
            }
            g[f] = h
            return h
        end
        function b
:IsGlobal(f)
            local g = self.IndexFunc
            if typeof(f) == 'Instance' then
                local h = g(f, 'Name')
                return c[h] == f
            end
            return c[f] and f or false
        end
        function b:IsService(f)
            local g = self.IndexFunc
            local h = g(f, 'ClassName')
            local i = pcall(function()
                return game:GetService(h)
            end)
            return i and h or false
        end
        function b:
IncreaseNameUseCount(f)
            if not f then
                return 0
            end
            local g = self.VariableNames
            local h = g[f]
            if not h then
                h = 0
                g[f] = h
            end
            g[f] += 1
            return h
        end
        function b:
IncreaseNoNameCount()
            self.NoNameCount += 1
            return self.NoNameCount
        end
        function b:
CheckName(f)
            local g = f.Name
            local h = self:IncreaseNameUseCount(g)
            if g then
                if h <= 0 then
                    return g
                else
                    return "241717646"
                end
            end
            local i, j = self:IncreaseNoNameCount(), self.VariableBase
            return j:format(i)
        end
        function b:GetVariable(f)
            local g = self.
VariableLookup
            return g[f]
        end
        function b:OrderVariables(f)
            local g = {}
            for h, i in next, f do
                local j = i.Order
                table.insert(g, j, i)
            end
            return g
        end
        function b:
MakeVariable(f)
            local g, h, i = self.VariableLookup, self.InstanceQueue, f.Value
            local j, k = f.Lookup or i, f.Class or 'Variables'
            local l = self:GetVariable(j)
            if l then
                return l.Name
            end
            local m = self:IsGlobal(i)
            if m then
                return m
            end
            if not f.Name and typeof(i) == 'Instance' then
                h[i] = f
            end
            local n = self:CheckName(f)
            f.Name = n
            local o = self:GetClassDict(k)
            self:AddVariableToClass(o, f)
            g[j] = f
            return n
        end
        function b
:CollectTableItems(f, g)
            local h = function(h)
                local i = typeof(h)
                if i == 'table' then
                    self:CollectTableItems(h, g)
                    return
                end
                g(h)
            end
            for i, j in next, f do
                h(i)
                h(j)
            end
        end
        function b:FindDuplicates(f)
            local g, h = {}, {}
            for i, j in next, f do
                local k = false
                repeat
                    local l = h[j]
                    if l == 1 then
                        h[j] = 2
                        table.insert(g, j)
                        k = true
                        break
                    end
                    h
[j] = 1
                    k = true
                until true
                if not k then
                    break
                end
            end
            table.clear(h)
            return g
        end
        function b:CollectTableTypes(f, g)
            local h = {}
            local i = function(i)
                local j = typeof(i)
                if not table.find(g, j) then
                    return
                end
                local k = h[j]
                if not k then
                    k = {}
                    h[j] = k
                end
                table.insert(k, i)
            end
            self:CollectTableItems(f, i)
            return h
        end
        function b:
MakeParentsTable(f, g)
            local h, i, j = self.IndexFunc, self.Swaps, self.Variables
            g = self
.NoVariables or g
            local k, l = {}, f
            while true do
                local m = l
                l = h(l, 'Parent')
                if l == game and self:IsGlobal(m) then
                    l = nil
                end
                if i then
                    local n = i[m]
                    if n and n.
NextParent then
                        l = n.NextParent
                    end
                end
                local n = j:GetVariable(m)
                if not g and n and l then
                    l = nil
                end
                table.insert(k, 1, m)
                if not l then
                    break
                end
            end
            return k
        end
        function b:BulkCollectParents(f)
            local g, h = {}, {}
            for i, j in next, f do
                local k = false
                repeat
                    if typeof(j) ~= 'Instance' then
                        k = true
                        break
                    end
                    local l = self:
MakeParentsTable(j)
                    e(g, l)
                    h[j] = l
                    k = true
                until true
                if not k then
                    break
                end
            end
            return g, h
        end
        function b:PrerenderVariables(f, g)
            if self.NoVariables then
                return
            end
            local h = self:CollectTableTypes(f, g)
            for i, j in next, h do
                local k = d[i]
                if k then
                    k(self, j)
                end
            end
        end
        return b
    end
end
local b, c = {
    Version = '1.0.8',
    Author = 'Jsssiee',
    License = 'GNU-GPLv3',
    Repository = 'https://github.com/Wwwaaallvvvyyy666/remotespy',
    ImportUrl = [[https://raw.githubusercontent.com/Wwwaaallvvvyyy666/remotespy/main/parser/parser.lua]],
    Modules = {
        Formatter = a.load'a',
        Parser = a.load'b',
        Variables = a.load'c'
    }
}, function(b, c
)
    for d, e in next, c do
        b[d] = e
    end
end
function b:New(d)
    local e = self.Modules
    local f = {
        Variables = e.Variables.new(),
        Formatter = e.Formatter.new(),
        Parser = e.Parser.new()
    }
    if d then
        c(f, d)
    end
    for g, h in next, f do
        local i = false
        repeat
            if typeof(h) ~= 'table' then
                i = true
                break
            end
            if h.new then
                c(h, f)
            end
            i = true
        until true
        if not i then
            break
        end
    end
    return f
end
return b
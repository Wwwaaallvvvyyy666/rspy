# SigmaSpy V2

A complete Remote Spy with an incredible parser that captures incoming and outgoing remote data, with Actor support.

**Version:** v26.07.29

## Credits 🙏

**Original author:** depso (depthso) — creator of Sigma Spy. The original repository was deleted; this project keeps the work alive and continues it.

> depso: "I am not happy with this version"

*(That quote is a joke, not an actual statement by depso.)*

## Loadstring

```lua
--// SigmaSpy V2 | Modified
loadstring(game:HttpGet("https://raw.githubusercontent.com/Wwwaaallvvvyyy666/remotespy/main/Main.lua"))()
```

The build is self-contained: the config template, the return-spoofs template and the ImGui font are embedded in the file itself, so nothing is downloaded from this repository at runtime. Only the two external libraries (ReGui and Roblox-Parser) are still fetched over HTTP.

If your executor supports `readfile`, you can run it straight from the workspace folder instead:

```lua
loadstring(readfile("SigmaSpyV2.luau"), "SigmaSpy V2")()
```

## What changed in V2 🔧

- Single self-contained file — templates and the font are embedded, no repository fetches at runtime
- Libraries ship as readable Luau source instead of base64 blobs
- Consistent workspace folder name (`SigmaSpy V2`); the old build created `Sigma spy` and `Sigma Spy` side by side
- ReGui and the parser are loaded from own forks with timeouts and clear startup logging
- New Python bundler (`build/bundle.py`); the original lune + darklua pipeline is still in `build/` and produces the legacy `Main.lua`

## Notices 🔔

- If you have issues with the executor's comm library (`get_comm_channel`, `create_comm_channel`), enable `ForceUseCustomComm` in `SigmaSpy V2/Config.lua`, found in your executor's workspace folder after the first run
- Wave and Zenith are recommended executors

## Features ⚡

| | |
| ------------ | ------------- |
| **Actors** support | **Keybinds** for toggling options
| **__index** and __namecall support | **Dumping** logs to file
| **Decompile** large scripts | Argument values for log titles
| **Block** remotes from firing | Wide range of supported data types
| **Spoof** return values _(Return spoofs.lua)_ | Logging client receives _(e.g **OnClientEvent**)_
| Variable compression in the parser | Remote stacking (known as 'Grouping') _(optional)_
| Mobile devices are supported | Pop-out editors

## Screenshots 🖼️

<table>
	<tr>
		<td>
			<img src="/docs/images/Basic.png">
		</td>
		<td>
			<img src="/docs/images/DecompileConnection.png">
			Pop-out Decompile with Connections viewer
		</td>
	</tr>
	<tr>
		<td>
			<img src="/docs/images/PopoutWindows.png">
			Multiple Pop-out editors
		</td>
		<td>
			<img src="/docs/images/Grouping.png">
			Remote stacking ('Grouping')
		</td>
	</tr>
</table>

## Config.lua options ⚙️

| Name | Description |
| ---- | ----------- |
| **ForceUseCustomComm** | Forces the built-in comm library. Used automatically if your executor does not support it |
| **ForceKonstantDecompiler** | Forces the decompile option to use Konstant. Enabled automatically if your executor does not support `decompile` |
| **NoFunctionPatching** | Disables patches for functions in your executor that may be vulnerable |
| **ReplaceMetaCallFunc** | Replaces the meta call function using `getrawmetatable` instead of `hookmetamethod` |
| **NoReceiveHooking** | Disables the hooking of callback functions such as `.OnClientInvoke` |
| **VariableNames** | Variable names used by the parser when the generated ones are not usable |

## Required functions ⚠️

You will be prompted if your executor is missing something.

| Required | Optional |
| ------------ | ------------- |
| hookmetamethod | getcustomasset *(for the true ImGui theme)*
| hookfunction | Comm library (get_comm_channel, create_comm_channel)
| getrawmetatable |
| setreadonly |
| File library |
| getconnections |
| newcclosure |

## Building 🛠️

`SigmaSpyV2.luau` in the repository root is generated — edit the sources in `src/`, then rebuild:

```sh
python build/bundle.py
```

The bundler inlines `src/lib/Info.lua` and `src/lib/Files.lua`, embeds the other libraries as Luau source strings (they are also shipped to Actor VMs at runtime), base64-encodes everything in `assets/`, and renders the header from `build/frame.lua`.

```
src/             source, one library per file (Info.lua holds name and version)
templates/       Config.lua and Return Spoofs.lua, embedded into the build
assets/          ImGui font, embedded into the build
build/           bundle.py (current), build.lua + darklua.json (legacy lune pipeline), frame.lua banner template
lib/             base64 helper, used by the legacy lune pipeline only
SigmaSpyV2.luau  generated single-file build
Main.lua         legacy minified darklua build, kept for reference
.index.html      local dev loader for Main.lua over `py -m http.server`
```

For local testing you can serve the repository and load the build over HTTP:

```sh
py -m http.server 3000 --bind 127.0.0.1
```

```lua
local Url = "http://127.0.0.1:3000"
local Source = game:HttpGet(`{Url}/SigmaSpyV2.luau?cache={os.clock()}`)
local Main, Error = loadstring(Source, "SigmaSpy V2")
assert(Main, Error)
Main({ RepoUrl = Url })
```

## Libraries used 📚

Both are written by depso and are loaded at runtime. The upstream repositories moved, so the build points at forks kept in sync here:

- ReGui — [fork used by this build](https://github.com/nevskiydeveloper/ReGui), [upstream (depso)](https://github.com/depthso/Dear-ReGui/tree/main)
- Roblox-Parser — [fork used by this build](https://github.com/nevskiydeveloper/Roblox-Parser), [upstream (depso)](https://github.com/depthso/Roblox-parser)

Override them at load time with the `ReGuiUrl`, `ReGuiPrefabsId` and `ParserUrl` keys.

## License

MIT — Copyright (c) 2025 Depso. See [LICENSE](LICENSE).
MIT — Copyright (c) 2026 NevskiyDev. See [LICENSE](LICENSE).

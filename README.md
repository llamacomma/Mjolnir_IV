# Mjolnir_IV: GTA IV CPU Performance Fix

A runtime patch that fixes critical CPU performance issues in **GTA IV: The Complete Edition** (Steam).

First known fix for GTA IV's CPU Core 0 pinning bug.

## What It Does

GTA IV was ported from Xbox 360 in 2008. Several design decisions from that era cause severe performance issues on modern hardware:

| Fix | Problem | Solution | Impact |
|-----|---------|----------|--------|
| **CPU Affinity** | Main thread pinned to Core 0 via `SetThreadAffinityMask(thread, 1)`. One core at 70 to 90% while 15 sit idle | NOP the affinity call, let the OS scheduler distribute work | **Core 0: 72% to 29%** |
| **Busy Wait Yield** | Inner engine loop spins `cmp/je` with zero yield, burns 100% of a core doing nothing | Inject `SwitchToThread()` via code cave | Eliminates screen tearing, smoother frametime |
| **Auto Adjuster** | Quality auto adjuster uses broken VRAM estimation from console era, can force quality caps despite 12GB+ VRAM | Disable the adjuster flag, user keeps manual control | Full quality settings unlocked |

### A/B Test Results (per core CPU, 60 second samples)

| Metric | Baseline | With Fix | Delta |
|--------|----------|----------|-------|
| **Core 0 Usage** | **72.4%** | **28.6%** | **-43.8 pp** |
| Total Process CPU | 17.2% | 17.6% | noise |

Load is redistributed by the OS scheduler. Total work identical, just no longer bottlenecked on one core.

## Installation

### With FusionFix (recommended)

Most GTA IV players use [FusionFix](https://github.com/ThirteenAG/GTAIV.EFLC.FusionFix). FusionFix ships its own `dinput8.dll` (Ultimate ASI Loader), so use the `.asi` method:

1. Download `Mjolnir_IV.asi` from the [Releases](../../releases) page
2. Drop it into your `plugins` folder alongside the FusionFix `.asi`
3. Launch the game normally

```
Grand Theft Auto IV/GTAIV/
├── GTAIV.exe
├── dinput8.dll              ← FusionFix's ASI Loader (do not replace)
├── d3d9.dll                 ← DXVK (ships with FusionFix v4.0+)
├── mjolnir_cpu_fix.log      ← created on launch
└── plugins/
    ├── GTAIV.EFLC.FusionFix.asi
    ├── GTAIV.EFLC.FusionFix.ini
    └── Mjolnir_IV.asi       ← drop here
```

### Vanilla (no other mods)

1. Download `dinput8.dll` from the [Releases](../../releases) page
2. Drop it next to `GTAIV.exe` in your game directory
3. Launch the game normally

```
Grand Theft Auto IV/GTAIV/
├── GTAIV.exe
├── dinput8.dll          ← Mjolnir (drop here)
└── mjolnir_cpu_fix.log  ← created on launch
```

### Uninstall
Delete `Mjolnir_IV.asi` from plugins (or `dinput8.dll` from the game directory). That's it.

The DLL creates `mjolnir_cpu_fix.log` in the game directory on each launch. Check it to verify all fixes applied successfully.

## FusionFix Compatibility

Mjolnir works alongside [FusionFix](https://github.com/ThirteenAG/GTAIV.EFLC.FusionFix) with zero patch overlap. FusionFix handles graphics and rendering fixes; Mjolnir handles CPU and threading fixes.

**Audited**: FusionFix's `fixes.ixx` (1042 lines) contains zero thread, affinity, or streaming fixes. No overlapping patches.

## Building from Source

Requires CMake 3.10+ and MSVC (Visual Studio Build Tools).

```powershell
cd fix_template
cmake -B build -A Win32
cmake --build build --config Release
```

Output: `fix_template/build/Release/dinput8.dll`

**Important:** The `.def` file must be in `CMakeLists.txt` SOURCES or exports get stdcall decoration (`_DirectInput8Create@20` instead of `DirectInput8Create`) and the game will crash silently.

## How It Works

The DLL loads as a `dinput8.dll` proxy when used standalone, or as an `.asi` plugin when loaded by FusionFix's ASI loader. It:

1. Patches memory in `DLL_PROCESS_ATTACH` before the game's main thread runs
2. Forwards all real DirectInput8 calls to `C:\Windows\System32\dinput8.dll` (proxy mode only)
3. Handles ASLR: computes runtime base delta, all addresses go through `R(addr)` macro
4. Verifies expected opcodes before patching, won't corrupt a different exe version

### Fix 1: CPU Affinity (NOP patch)
At `0x59D3A1`, the game does `push 1; call GetCurrentThread; push eax; call SetThreadAffinityMask`, force pinning the main thread to CPU 0. We NOP 15 bytes around the `mov esi, ecx` instruction to remove the pin while preserving the register save.

### Fix 2: Busy Wait Yield (code cave)
At `0xD9737D`, the engine spins `cmp byte [esi+0xC34], 0; je loop_top` with zero yield. We replace the 9 byte `cmp+je` with a `JMP` to a VirtualAlloc'd code cave that performs the original comparison, calls `SwitchToThread()` via the IAT, and jumps back.

### Fix 7: Auto Adjuster Disable (DWORD write)
The quality auto adjuster at `0x0110E6BC` (flag: 0=active, nonzero=off) uses a VRAM estimation formula from the Xbox 360 era. Despite detecting 12GB correctly, the estimation math produces a ratio of -33.68, which can trigger quality downgrades on settings changes. Setting the flag to 1 gives users full manual control.

## License

[MIT](LICENSE)

---

*Part of Project Mjolnir: RAGE Engine Analysis & Fix Suite.*
*Framework originally built for Saints Row 2, dedicated to Mike "IdolNinja" Watson (1971-2021).*

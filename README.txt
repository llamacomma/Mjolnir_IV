==============================================================================
  MJOLNIR_IV: GTA IV CPU PERFORMANCE FIX  v1.2
  For GTA IV: The Complete Edition (Steam)
==============================================================================

WHAT THIS IS
  Mjolnir_IV is a runtime patch that corrects three engine level issues in
  GTA IV's RAGE engine. These are not workarounds. They are direct fixes to
  the engine's behavior at the instruction level.


WHAT IT FIXES

Fix 1: CPU Core 0 Affinity Pin

  GTA IV hardcodes a SetThreadAffinityMask call that locks the main engine
  thread to CPU Core 0 exclusively. This was a deliberate decision in 2008
  when single core performance was the primary constraint on Xbox 360
  hardware. On modern 8 to 24 core CPUs, this creates a severe bottleneck:
  one core pegged at 70 to 90% while every other core sits idle.

  This fix removes the pin and allows the OS scheduler to distribute the
  thread freely across available cores.

  A/B test results (60 second samples, per core monitoring):

    Metric                  Baseline    Fixed       Delta
    Core 0 utilization      72.4%       28.6%       -43.8 pp
    Total process CPU       17.2%       17.6%       +0.4 (noise)

  Total CPU work is identical. The load redistributes. Core 0 is no longer
  the single point of failure for frame delivery.

Fix 2: Busy Wait Spinloop Yield

  The RAGE engine contains an inner coordination loop that spins continuously
  without yielding between iterations. No Sleep, no SwitchToThread, no PAUSE
  instruction. On 2008 dual core CPUs this was invisible. On modern
  processors with aggressive power and thermal management, this loop burns a
  full core waiting for a state that could be checked at 1ms intervals with
  zero perceptible latency cost.

  This fix injects a SwitchToThread call into the loop via a code cave. The
  thread cooperates with the Windows scheduler rather than fighting it.

  Observed result: micro tearing reduced, frame delivery noticeably smoother
  across the board.

Fix 3: Quality Auto Adjuster Disabled

  GTA IV ships a quality auto adjuster that re evaluates your graphics
  settings at runtime and can silently downgrade them if its internal VRAM
  estimation decides you are over budget. The estimation logic uses Xbox
  360 era constants and does not correctly account for modern GPU VRAM
  sizes. The adjuster flag is set to inactive, giving you full manual
  control over your graphics settings. The engine's VRAM detection itself
  works correctly on Complete Edition.

INSTALLATION
  This release includes two installation methods. Choose the one that
  matches your setup.


OPTION A: FusionFix (recommended)

  Use this if you have FusionFix installed. FusionFix ships its own
  dinput8.dll (Ultimate ASI Loader), so the .asi method avoids conflicting
  with it.

  1. Navigate to your GTA IV installation directory
     (typically: Steam\steamapps\common\Grand Theft Auto IV\GTAIV)

  2. Create a "plugins" folder if one does not already exist

  3. Copy Mjolnir_IV.asi from the "FusionFix" folder into plugins

  4. Launch the game normally through Steam

  5. A log file (mjolnir_cpu_fix.log) will be created in the game directory
     on first run, confirming which fixes were applied and their patch
     addresses.


OPTION B: Vanilla (no other DLL mods)

  Use this if you are running vanilla with no other mods installed.

  1. Navigate to your GTA IV installation directory
     (typically: Steam\steamapps\common\Grand Theft Auto IV\GTAIV)

  2. Copy dinput8.dll from the "Vanilla" folder into that directory,
     alongside GTAIV.exe

  3. Launch the game normally through Steam

  4. A log file (mjolnir_cpu_fix.log) will be created in the game directory
     on first run, confirming which fixes were applied and their patch
     addresses.

  To uninstall: delete dinput8.dll and any mjolnir_cpu_fix.log from the
  game directory, verify game files.

To uninstall: delete Mjolnir_IV.asi and any mjolnir_cpu_fix.log files from the game directory.

NOTE: Do NOT install both. Use either dinput8.dll (Vanilla) or
Mjolnir_IV.asi (ASI Loader), not both at the same time.

No ini configuration or other dependencies for either method.


SUPPORTED VERSIONS
------------------
  Game:     GTA IV Complete Edition (Steam, patch 1.2.0.59)
  OS:       Windows 10 / Windows 11 (x64)
  CPU:      Any — greatest benefit on 8+ core modern processors
  GPU:      Any — these fixes are CPU-side only

Not tested on: downgraded (pre-CE) exe builds, GFWL builds, or Rockstar
Games Launcher standalone installs. The patch verifies expected byte sequences
before applying and will abort with a log entry if the exe version is wrong.


LICENSE
-------
MIT License. See LICENSE.txt.
Fix source is not published at this time.


CONTACT / UPDATES
-----------------
Check the release thread for updates. Report issues with your log file attached.

==============================================================================

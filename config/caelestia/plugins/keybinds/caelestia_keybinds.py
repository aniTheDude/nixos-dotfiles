#!/usr/bin/env python3
"""
Caelestia Shell Keybinds Plugin
Fuzzy search through default and user-defined keybinds and trigger actions on Enter.
"""

import os
import sys
import json
import shutil
import subprocess
import argparse
from pathlib import Path

PLUGIN_DIR = Path.home() / ".config" / "caelestia" / "plugins" / "keybinds"
EXTRACTOR_LUA = PLUGIN_DIR / "extractor.lua"
SCHEME_FILE = Path.home() / ".config" / "hypr" / "scheme" / "current.lua"

VAR_DESCS = {
    "kbLauncher": "Toggle Caelestia Launcher",
    "kbSession": "Toggle Session Menu (Power / Lock / Logout)",
    "kbShowSidebar": "Toggle Sidebar",
    "kbClearNotifs": "Clear All Notifications",
    "kbShowPanels": "Toggle All Panels (Launcher / Dash / OSD)",
    "kbLock": "Lock Screen",
    "kbRestoreLock": "Restore Shell Lock Screen",
    "kbSleep": "Sleep / Suspend System",
    "kbTerminal": "Launch Terminal",
    "kbBrowser": "Launch Web Browser",
    "kbEditor": "Launch Editor",
    "kbFileExplorer": "Launch File Explorer",
    "kbAudioSettings": "Launch Audio Settings (Volume Control)",
    "kbScreenshot": "Take Full Screenshot",
    "kbScreenshotFreeze": "Take Screenshot (Freeze Screen)",
    "kbScreenshotRegion": "Take Region Screenshot",
    "kbRecord": "Start Screen Recording",
    "kbRecordSound": "Start Screen Recording with Audio",
    "kbRecordRegion": "Start Region Screen Recording",
    "kbColorPicker": "Launch Color Picker",
    "kbMediaToggle": "Play / Pause Media",
    "kbMediaNext": "Next Media Track",
    "kbMediaPrev": "Previous Media Track",
    "kbMediaStop": "Stop Media Playback",
    "kbVolumeMute": "Toggle Audio Mute",
    "kbClipboard": "Open Clipboard History",
    "kbClipboardDel": "Delete from Clipboard History",
    "kbClipboardPasteLatest": "Paste Latest Clipboard Item",
    "kbEmoji": "Open Emoji / Glyph Picker",
    "kbCloseWindow": "Close Active Window",
    "kbToggleWindowFloating": "Toggle Active Window Floating",
    "kbWindowFullscreen": "Toggle Fullscreen",
    "kbWindowBorderedFullscreen": "Toggle Bordered Fullscreen (Maximized)",
    "kbPinWindow": "Pin Active Window Across Workspaces",
    "kbWindowPip": "Toggle Picture-in-Picture for Active Window",
    "kbCenterWindow": "Center Active Window",
    "kbNormalizeWindow": "Normalize Active Window Size and Position",
    "kbMoveWindow": "Move Active Window",
    "kbResizeWindow": "Resize Active Window",
    "kbToggleGroup": "Toggle Window Group",
    "kbUngroup": "Ungroup Window",
    "kbGroupLockActive": "Lock / Unlock Active Group",
    "kbWindowCycleNext": "Cycle Next Window",
    "kbWindowCyclePrev": "Cycle Previous Window",
    "kbWindowGroupCycleNext": "Cycle Next Window in Group",
    "kbWindowGroupCyclePrev": "Cycle Previous Window in Group",
    "kbNextWs": "Go to Next Workspace",
    "kbPrevWs": "Go to Previous Workspace",
    "kbNextWsGroup": "Go to Next Workspace Group",
    "kbPrevWsGroup": "Go to Previous Workspace Group",
    "kbMoveWinToWsNext": "Move Window to Next Workspace",
    "kbMoveWinToWsPrev": "Move Window to Previous Workspace",
    "kbMoveWinToWsSpecial": "Move Window to Special Workspace",
    "kbMoveWinFromWsSpecial": "Move Window from Special Workspace",
    "kbSpecialWs": "Toggle Special Workspace",
    "kbSystemMonitorWs": "Toggle System Monitor (btop)",
    "kbMusicWs": "Toggle Music Player Workspace",
    "kbCommunicationWs": "Toggle Communication Apps Workspace",
    "kbTodoWs": "Toggle Todo Workspace"
}

DISPATCHER_DESCS = {
    "caelestia:launcher": "Toggle Caelestia Launcher",
    "caelestia:session": "Toggle Session Menu",
    "caelestia:sidebar": "Toggle Sidebar",
    "caelestia:clearNotifs": "Clear All Notifications",
    "caelestia:showall": "Toggle All Panels (Launcher / Dash / OSD)",
    "caelestia:lock": "Lock Screen",
    "caelestia:screenshotFreeze": "Take Screenshot (Freeze Screen)",
    "caelestia:screenshot": "Take Region Screenshot",
    "caelestia:screenshotClip": "Take Screenshot to Clipboard",
    "caelestia:screenshotFreezeClip": "Take Screenshot (Freeze Mode to Clipboard)",
    "caelestia:brightnessUp": "Increase Monitor Brightness",
    "caelestia:brightnessDown": "Decrease Monitor Brightness",
    "caelestia:mediaToggle": "Play / Pause Media",
    "caelestia:mediaNext": "Next Media Track",
    "caelestia:mediaPrev": "Previous Media Track",
    "caelestia:mediaStop": "Stop Media Playback"
}


def read_theme_colors() -> dict:
    """Read Caelestia's active theme colors from current.lua."""
    colors = {
        "surface": "073642",
        "surfaceContainerHigh": "0D4250",
        "onSurface": "FDF6E3",
        "onSurfaceVariant": "93A1A1",
        "primary": "268BD2",
        "secondary": "2AA198",
        "tertiary": "6C71C4",
        "outline": "586E75",
        "error": "DC322F",
    }
    if not SCHEME_FILE.exists():
        return colors

    try:
        with open(SCHEME_FILE, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                for key in colors.keys():
                    if line.startswith(f"{key} ="):
                        val = line.split("=")[1].strip().strip('",\'')
                        if val:
                            colors[key] = val
    except Exception:
        pass
    return colors


def get_fzf_color_args(colors: dict) -> list[str]:
    """Generate fzf color theme arguments matching Caelestia's theme."""
    bg = f"#{colors['surface']}"
    bg_high = f"#{colors['surfaceContainerHigh']}"
    fg = f"#{colors['onSurface']}"
    fg_dim = f"#{colors['onSurfaceVariant']}"
    primary = f"#{colors['primary']}"
    secondary = f"#{colors['secondary']}"
    outline = f"#{colors['outline']}"

    color_spec = (
        f"bg:{bg},fg:{fg},hl:{primary},"
        f"bg+:{bg_high},fg+:{fg},hl+:{secondary},"
        f"pointer:{primary},prompt:{primary},info:{fg_dim},"
        f"border:{outline},header:{secondary},spinner:{secondary}"
    )
    return ["--color", color_spec]


def load_keybinds() -> list[dict]:
    """Run extractor.lua and enrich keybind objects with human-readable descriptions."""
    if not EXTRACTOR_LUA.exists():
        raise FileNotFoundError(f"Extractor not found at {EXTRACTOR_LUA}")

    env = os.environ.copy()
    proc = subprocess.run(
        ["lua", str(EXTRACTOR_LUA)],
        capture_output=True,
        text=True,
        check=True,
        env=env
    )
    raw_binds = json.loads(proc.stdout)

    enriched = []
    for idx, item in enumerate(raw_binds):
        desc = item.get("desc", "").strip()
        var_name = item.get("var_name", "").strip()
        act_detail = item.get("act_detail", "").strip()
        act_type = item.get("act_type", "").strip()
        key = item.get("key", "").strip()
        cat = item.get("category", "").strip() or "General"

        # Resolve human-readable descriptions
        if not desc:
            if var_name in VAR_DESCS:
                desc = VAR_DESCS[var_name]
            elif act_detail in DISPATCHER_DESCS:
                desc = DISPATCHER_DESCS[act_detail]
            elif act_type == "exec_cmd":
                desc = f"Execute: {act_detail}"
            elif "focus" in act_type:
                desc = f"Focus {act_detail}"
            elif "window.move" in act_type:
                desc = f"Move Window {act_detail}"
            elif "window.close" in act_type:
                desc = "Close Active Window"
            elif "window.float" in act_type:
                desc = "Toggle Floating Window"
            elif "window.pin" in act_type:
                desc = "Pin Window Across Workspaces"
            elif "window.fullscreen" in act_type:
                desc = f"Toggle Fullscreen ({act_detail})"
            elif "group.toggle" in act_type:
                desc = "Toggle Window Group"
            elif "group.lock_active" in act_type:
                desc = "Lock Active Group"
            elif "group.next" in act_type:
                desc = "Next Window in Group"
            elif "group.prev" in act_type:
                desc = "Previous Window in Group"
            elif "window.cycle_next" in act_type:
                desc = "Cycle Window"
            elif "window.drag" in act_type:
                desc = "Drag / Move Window (Mouse)"
            elif "window.resize" in act_type:
                desc = "Resize Window"
            elif "pass" in act_type:
                desc = f"Pass event to {act_detail}"
            else:
                desc = act_detail or act_type

        # Polish category classification
        if not cat or cat == "General":
            if "XF86Audio" in key or "Volume" in desc:
                cat = "Volume"
            elif "XF86MonBrightness" in key or "Brightness" in desc:
                cat = "Brightness"
            elif "caelestia kill" in act_detail or "caelestia shell" in act_detail:
                cat = "Caelestia Shell"
            elif "Workspace" in desc or "ws" in var_name.lower():
                cat = "Workspaces"
            elif "Window" in desc or "win" in var_name.lower():
                cat = "Window Actions"

        # Determine action execution strategy
        action_kind = "unknown"
        if act_type == "exec_cmd" or (not item.get("act_eval") and act_detail.startswith(("caelestia", "wpctl", "foot", "pkill", "notify-send", "hyprpicker", "sleep"))):
            action_kind = "exec"
        elif item.get("act_eval"):
            action_kind = "lua"
        elif "mouse" in act_type or "drag" in act_type or "mouse" in key:
            action_kind = "mouse"

        enriched.append({
            "id": idx,
            "key": key,
            "category": cat,
            "description": desc,
            "action_kind": action_kind,
            "act_type": act_type,
            "act_detail": act_detail,
            "act_eval": item.get("act_eval", ""),
            "source": item.get("source", "default"),
            "var_name": var_name
        })

    return enriched


def trigger_action(bind: dict) -> None:
    """Execute the action corresponding to the selected bind."""
    action_kind = bind.get("action_kind")
    act_eval = bind.get("act_eval")
    act_detail = bind.get("act_detail", "")
    key = bind.get("key", "")
    desc = bind.get("description", "")

    if action_kind == "lua" and act_eval:
        subprocess.run(["hyprctl", "eval", act_eval], check=False)
    elif action_kind == "exec" and act_detail:
        subprocess.Popen(act_detail, shell=True, start_new_session=True)
    elif action_kind == "mouse":
        # Inform the user via notification
        msg = f"{key}: {desc} (Use mouse with modifier key)"
        subprocess.run(["caelestia", "shell", "toaster", "info", "Keybind Hint", msg, "mouse"], check=False)
    elif act_eval:
        subprocess.run(["hyprctl", "eval", act_eval], check=False)
    elif act_detail:
        subprocess.Popen(act_detail, shell=True, start_new_session=True)


def format_preview(bind: dict) -> str:
    """Generate a clean ANSI formatted preview card for fzf."""
    colors = read_theme_colors()
    # ANSI color codes
    CYAN = "\033[38;2;38;139;210m"
    TEAL = "\033[38;2;42;161;152m"
    YELLOW = "\033[38;2;181;137;0m"
    GRAY = "\033[38;2;147;161;161m"
    WHITE = "\033[1;37m"
    BOLD = "\033[1m"
    RESET = "\033[0m"

    source_label = (
        f"{YELLOW}User Custom (~/.config/caelestia/hypr-user.lua){RESET}"
        if bind.get("source") == "user"
        else f"{GRAY}Default Config (~/.config/hypr/){RESET}"
    )

    action_summary = bind.get("act_eval") or bind.get("act_detail") or bind.get("act_type") or "N/A"

    card = f"""
{BOLD}{CYAN}󰌌  KEYBIND DETAILS{RESET}
────────────────────────────────────────────────────
{BOLD}{WHITE}Key Combination:{RESET}  {TEAL}{bind['key']}{RESET}
{BOLD}{WHITE}Category:{RESET}         {YELLOW}[{bind['category']}]{RESET}
{BOLD}{WHITE}Description:{RESET}      {WHITE}{bind['description']}{RESET}
{BOLD}{WHITE}Source:{RESET}           {source_label}

{BOLD}{CYAN}⚙  ACTION{RESET}
────────────────────────────────────────────────────
{BOLD}{WHITE}Type:{RESET}             {bind['action_kind'].upper()} ({bind['act_type']})
{BOLD}{WHITE}Command / Eval:{RESET}
{GRAY}{action_summary}{RESET}

────────────────────────────────────────────────────
{GRAY}Press {WHITE}Enter{GRAY} to trigger this keybind action.{RESET}
"""
    return card.strip()


def run_fzf(binds: list[dict]) -> None:
    """Launch interactive fzf picker."""
    colors = read_theme_colors()
    color_args = get_fzf_color_args(colors)

    # Format list lines: KEY | [CATEGORY] | DESCRIPTION | ID
    # Delimiter is tab (\t)
    lines = []
    for b in binds:
        key_col = f"{b['key']:<26}"
        cat_col = f"[{b['category']}]"
        cat_col = f"{cat_col:<20}"
        desc_col = b['description']
        idx_col = str(b['id'])
        lines.append(f"{key_col}\t{cat_col}\t{desc_col}\t{idx_col}")

    input_text = "\n".join(lines)
    script_path = os.path.abspath(__file__)

    fzf_cmd = [
        "fzf",
        *color_args,
        "--delimiter=\t",
        "--with-nth=1,2,3",
        "--prompt=󰌌 Keybinds > ",
        "--header=Enter: Trigger Action | Esc: Exit | /: Search",
        "--header-first",
        "--layout=reverse",
        "--border=rounded",
        "--preview", f"python3 {script_path} --preview {{4}}",
        "--preview-window=right:45%:wrap:border-rounded",
        "--info=inline",
        "--bind=ctrl-/:toggle-preview"
    ]

    try:
        res = subprocess.run(
            fzf_cmd,
            input=input_text,
            capture_output=True,
            text=True
        )
    except FileNotFoundError:
        print("Error: fzf is not installed or not in PATH.", file=sys.stderr)
        sys.exit(1)

    if res.returncode == 0 and res.stdout.strip():
        selected_line = res.stdout.strip()
        parts = selected_line.split("\t")
        if len(parts) >= 4:
            selected_id = int(parts[3])
            matched = next((b for b in binds if b["id"] == selected_id), None)
            if matched:
                trigger_action(matched)


def ensure_terminal_and_run(binds: list[dict]) -> None:
    """If running in a GUI context without a TTY, launch in foot floating terminal."""
    if sys.stdin.isatty():
        run_fzf(binds)
    else:
        script_path = os.path.abspath(__file__)
        term_cmd = [
            "foot",
            "--app-id=caelestia-keybinds",
            "-T", "Caelestia Keybinds",
            "python3", script_path, "--run"
        ]
        subprocess.Popen(term_cmd, start_new_session=True)


def main():
    parser = argparse.ArgumentParser(description="Caelestia Shell Keybinds fzf Plugin")
    parser.add_argument("--run", action="store_true", help="Launch interactive fzf picker")
    parser.add_argument("--list", action="store_true", help="List all keybinds formatted")
    parser.add_argument("--json", action="store_true", help="Output all keybinds as JSON")
    parser.add_argument("--preview", type=int, metavar="ID", help="Output preview card for a keybind ID")
    parser.add_argument("--trigger", type=int, metavar="ID", help="Trigger action of keybind ID")

    args = parser.parse_args()

    try:
        binds = load_keybinds()
    except Exception as e:
        print(f"Error loading keybinds: {e}", file=sys.stderr)
        sys.exit(1)

    if args.json:
        print(json.dumps(binds, indent=2))
        return

    if args.list:
        for b in binds:
            print(f"{b['key']:<26} [{b['category']:<18}] {b['description']}")
        return

    if args.preview is not None:
        matched = next((b for b in binds if b["id"] == args.preview), None)
        if matched:
            print(format_preview(matched))
        else:
            print(f"Keybind ID {args.preview} not found.")
        return

    if args.trigger is not None:
        matched = next((b for b in binds if b["id"] == args.trigger), None)
        if matched:
            trigger_action(matched)
            print(f"Triggered: {matched['key']} -> {matched['description']}")
        else:
            print(f"Keybind ID {args.trigger} not found.", file=sys.stderr)
            sys.exit(1)
        return

    if args.run:
        run_fzf(binds)
    else:
        ensure_terminal_and_run(binds)


if __name__ == "__main__":
    main()

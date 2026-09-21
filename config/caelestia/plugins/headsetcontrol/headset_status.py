#!/usr/bin/env python3
"""
Caelestia HeadsetControl CLI Tool
Provides command-line status and desktop notifications for headset battery.
"""

import argparse
import json
import shutil
import subprocess
import sys


def get_headset_data():
    cmd = ["headsetcontrol", "-o", "json"]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, check=True)
        return json.loads(proc.stdout)
    except FileNotFoundError:
        print("Error: 'headsetcontrol' binary not found in PATH.", file=sys.stderr)
        return None
    except subprocess.CalledProcessError as e:
        print(f"Error executing headsetcontrol: {e}", file=sys.stderr)
        return None
    except json.JSONDecodeError as e:
        print(f"Error parsing headsetcontrol output: {e}", file=sys.stderr)
        return None


def format_minutes(minutes):
    if not minutes or minutes <= 0:
        return ""
    h = minutes // 60
    m = minutes % 60
    return f"{h}h {m}m" if h > 0 else f"{m}m"


def make_bar(percent, width=15):
    if percent < 0:
        return "━" * width
    filled = int(round(width * (percent / 100.0)))
    filled = max(0, min(width, filled))
    return "█" * filled + "░" * (width - filled)


def main():
    parser = argparse.ArgumentParser(description="Query headset battery status via headsetcontrol")
    parser.add_argument("--json", action="store_true", help="Output raw JSON")
    parser.add_argument("--notify", action="store_true", help="Send a Caelestia desktop notification")
    args = parser.parse_args()

    data = get_headset_data()
    if not data:
        sys.exit(1)

    if args.json:
        print(json.dumps(data, indent=2))
        return

    devices = data.get("devices", [])
    if not devices:
        msg = "No supported headset detected."
        if args.notify:
            subprocess.run(["notify-send", "-a", "caelestia-shell", "-i", "headset_off", "Headset Offline", msg])
        else:
            print(msg)
        return

    dev = devices[0]
    dev_name = dev.get("product") or dev.get("device") or "Headset"
    battery = dev.get("battery", {})
    level = battery.get("level", -1)
    status = battery.get("status", "BATTERY_UNAVAILABLE")
    time_left = battery.get("time_to_empty_min", -1)
    chatmix = dev.get("chatmix", -1)

    is_charging = status == "BATTERY_CHARGING"

    if args.notify:
        if is_charging:
            status_text = f"Charging ({level}%)" if level >= 0 else "Charging"
            icon = "battery_charging_full"
        elif level >= 0:
            time_str = f" (~{format_minutes(time_left)} left)" if time_left > 0 else ""
            status_text = f"{level}% remaining{time_str}"
            icon = "headphones"
        else:
            status_text = "Battery level unknown"
            icon = "headset_off"

        subprocess.run([
            "notify-send",
            "-a", "caelestia-shell",
            "-i", icon,
            dev_name,
            status_text
        ])
    else:
        print(f"\033[1m🎧 {dev_name}\033[0m")
        if is_charging:
            print(f"Status:   ⚡ Charging ({level}%)")
        elif level >= 0:
            bar = make_bar(level)
            time_str = f" (~{format_minutes(time_left)} remaining)" if time_left > 0 else ""
            print(f"Battery:  [{bar}] {level}%{time_str}")
        else:
            print(f"Status:   {status}")

        if chatmix >= 0:
            if chatmix == 64:
                print("ChatMix:  Balanced (Game 50% / Chat 50%)")
            else:
                game = round(((128 - chatmix) / 128.0) * 100)
                chat = 100 - game
                print(f"ChatMix:  Game {game}% / Chat {chat}%")


if __name__ == "__main__":
    main()

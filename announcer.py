#!/usr/bin/env python3
"""
================================================================================
ECCO HUB V3 - DISCORD ANNOUNCEMENT & SCRIPT PANEL SYSTEM
================================================================================
Handles broadcast announcements, script updates, script releases, new game
launches, and script panel status embeds across official Discord webhooks.

Channels:
  1. Announcements : https://discord.com/api/webhooks/1523161896650412173/...
  2. Games (New/Rel): https://discord.com/api/webhooks/1547448533161086988/...
  3. Updates       : https://discord.com/api/webhooks/1529901887535579145/...
  4. Script Panel  : https://discord.com/api/webhooks/1529908563630358679/...
================================================================================
"""

import argparse
import json
import sys
import urllib.request
from datetime import datetime, timezone

WEBHOOKS = {
    "announcement": "https://discord.com/api/webhooks/1523161896650412173/-9Z8hYj_YTmOi0I0zX8GAa568338xhCT_FJdqmKlQ2WVvkV5nbpIrRhiTrJ0seCIB5aj",
    "games": "https://discord.com/api/webhooks/1547448533161086988/PseUayhm66qHcHL_8tIAc-kgtwnzW_tgPRkadPL0oKQ5SzqRZ4PSOq3E7eFdK0oIXjz1",
    "updates": "https://discord.com/api/webhooks/1529901887535579145/LPbJ6exFnyrGsmNe_2gxN8rx5kOBHmGhP79PreTBgM-jmdA103wIUy4ZensNEY16kKGE",
    "panel": "https://discord.com/api/webhooks/1529908563630358679/PbqY6vqfgFBsVX1hRdcdkcPTtVLCyqqRhMgvPyHISp6Ep7bC-B3z84a-5yC5rNKvzZp5",
}

ICON_URL = "https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/ecco_symbol.png"
LOADSTRING_OBF = 'loadstring(game:HttpGet("https://raw.githubusercontent.com/eridtpdiscord-cloud/ecco-loader/main/loader_obfuscated.lua"))()'
LOADSTRING_GW = 'loadstring(game:HttpGet("https://eccohub.xyz/loader.lua"))()'
DISCORD_INVITE = "https://discord.gg/hN9QpA3HA"
TIKTOK_LINK = "https://www.tiktok.com/@_ecc00_?is_from_webapp=1&sender_device=pc"

COLORS = {
    "announcement": 0x00C8FF,  # Cyan
    "update": 0x00FFAA,        # Neon Mint Green
    "release": 0xFFD700,       # Gold
    "newgame": 0xA855F7,       # Neon Purple
    "panel": 0x00E5FF          # Electric Cyan
}

def send_webhook(webhook_url, payload):
    data = json.dumps(payload).encode('utf-8')
    req = urllib.request.Request(
        webhook_url,
        data=data,
        headers={
            'Content-Type': 'application/json',
            'User-Agent': 'EccoHub-Announcer/3.0'
        }
    )
    try:
        with urllib.request.urlopen(req) as response:
            if response.status in (200, 204):
                print("[SUCCESS] Dispatched to Discord successfully.")
                return True
            else:
                print(f"[STATUS] Response code: {response.status}")
                return True
    except urllib.error.HTTPError as e:
        print(f"[ERROR] HTTP Error {e.code}: {e.read().decode('utf-8')}")
        return False
    except Exception as e:
        print(f"[ERROR] Failed to send: {e}")
        return False

def make_footer():
    return {
        "text": "Ecco Hub V3 • The Premier Script Hub • eccohub.xyz",
        "icon_url": ICON_URL
    }

def make_author():
    return {
        "name": "ECCO HUB V3",
        "url": "https://eccohub.xyz",
        "icon_url": ICON_URL
    }

# 1. ANNOUNCEMENT
def post_announcement(title, message, ping=None):
    webhook_url = WEBHOOKS["announcement"]
    content_ping = ""
    if ping == "everyone":
        content_ping = "@everyone"
    elif ping == "here":
        content_ping = "@here"

    embed = {
        "author": make_author(),
        "title": f"📢  {title.upper()}",
        "description": message,
        "color": COLORS["announcement"],
        "fields": [
            {
                "name": "🚀 Get Script (Universal Loader)",
                "value": f"```lua\n{LOADSTRING_OBF}\n```",
                "inline": False
            },
            {
                "name": "🌐 Community & Links",
                "value": f"[Discord Server]({DISCORD_INVITE})  •  [Official TikTok]({TIKTOK_LINK})  •  [Website](https://eccohub.xyz)",
                "inline": False
            }
        ],
        "footer": make_footer(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    payload = {
        "username": "Ecco Hub Announcements",
        "avatar_url": ICON_URL,
        "content": content_ping if content_ping else None,
        "embeds": [embed]
    }
    return send_webhook(webhook_url, payload)

# 2. SCRIPT UPDATE
def post_script_update(game_name, version, changelog, ping=None):
    webhook_url = WEBHOOKS["updates"]
    content_ping = ""
    if ping == "everyone":
        content_ping = "@everyone"
    elif ping == "here":
        content_ping = "@here"

    embed = {
        "author": make_author(),
        "title": f"⚡  SCRIPT UPDATE — {game_name.upper()} [{version}]",
        "description": f"A new version of **{game_name}** has been published and is live immediately across all loaders.",
        "color": COLORS["update"],
        "fields": [
            {
                "name": "📝 Changelog & Improvements",
                "value": changelog,
                "inline": False
            },
            {
                "name": "🚀 Execute Script",
                "value": f"```lua\n{LOADSTRING_OBF}\n```",
                "inline": False
            },
            {
                "name": "🔗 Links",
                "value": f"[Join Discord]({DISCORD_INVITE})  •  [TikTok]({TIKTOK_LINK})",
                "inline": False
            }
        ],
        "footer": make_footer(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    payload = {
        "username": "Ecco Hub Updates",
        "avatar_url": ICON_URL,
        "content": content_ping if content_ping else None,
        "embeds": [embed]
    }
    return send_webhook(webhook_url, payload)

# 3. SCRIPT RELEASE
def post_script_release(game_name, version, description, features, ping=None):
    webhook_url = WEBHOOKS["games"]
    content_ping = ""
    if ping == "everyone":
        content_ping = "@everyone"
    elif ping == "here":
        content_ping = "@here"

    embed = {
        "author": make_author(),
        "title": f"🎉  NEW SCRIPT RELEASE — {game_name.upper()} [{version}]",
        "description": description or f"The official **{game_name}** script for Ecco Hub V3 has dropped!",
        "color": COLORS["release"],
        "fields": [
            {
                "name": "🔥 Key Features",
                "value": features,
                "inline": False
            },
            {
                "name": "🔑 Access Type",
                "value": "✅ **100% KEYLESS / FREE ACCESS**",
                "inline": True
            },
            {
                "name": "🛡️ Status",
                "value": "🟢 **UNDETECTED / SAFE**",
                "inline": True
            },
            {
                "name": "🚀 Execution Loadstring",
                "value": f"```lua\n{LOADSTRING_OBF}\n```",
                "inline": False
            },
            {
                "name": "🔗 Community",
                "value": f"[Discord Server]({DISCORD_INVITE})  •  [TikTok]({TIKTOK_LINK})",
                "inline": False
            }
        ],
        "footer": make_footer(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    payload = {
        "username": "Ecco Hub Releases",
        "avatar_url": ICON_URL,
        "content": content_ping if content_ping else None,
        "embeds": [embed]
    }
    return send_webhook(webhook_url, payload)

# 4. NEW GAME ADDED
def post_new_game(game_name, place_info, description, features, ping=None):
    webhook_url = WEBHOOKS["games"]
    content_ping = ""
    if ping == "everyone":
        content_ping = "@everyone"
    elif ping == "here":
        content_ping = "@here"

    embed = {
        "author": make_author(),
        "title": f"🎮  NEW GAME SUPPORTED — {game_name.upper()}",
        "description": description or f"Ecco Hub V3 now officially supports **{game_name}**! Auto-detected upon injection.",
        "color": COLORS["newgame"],
        "fields": [
            {
                "name": "🕹️ Target Game",
                "value": game_name,
                "inline": True
            },
            {
                "name": "📍 Game / Place Details",
                "value": place_info or "Auto-routed via PlaceId",
                "inline": True
            },
            {
                "name": "✨ Script Highlights",
                "value": features,
                "inline": False
            },
            {
                "name": "🚀 Run via Universal Loader",
                "value": f"```lua\n{LOADSTRING_OBF}\n```",
                "inline": False
            },
            {
                "name": "🔗 Connect With Us",
                "value": f"[Discord Invite]({DISCORD_INVITE})  •  [TikTok Showcase]({TIKTOK_LINK})",
                "inline": False
            }
        ],
        "footer": make_footer(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    payload = {
        "username": "Ecco Hub New Games",
        "avatar_url": ICON_URL,
        "content": content_ping if content_ping else None,
        "embeds": [embed]
    }
    return send_webhook(webhook_url, payload)

# 5. SCRIPT PANEL
def post_script_panel(custom_note=None, ping=None):
    webhook_url = WEBHOOKS["panel"]
    content_ping = ""
    if ping == "everyone":
        content_ping = "@everyone"
    elif ping == "here":
        content_ping = "@here"

    desc = (
        "**Welcome to the official Ecco Hub V3 Master Script Panel.**\n"
        "Copy and run the verified loadstring below inside any supported Roblox executor "
        "(Volt, Synapse, Wave, Celery, Delta, Codex, Hydrogen, Fluxus)."
    )
    if custom_note:
        desc += f"\n\n**Notice:** {custom_note}"

    embed = {
        "author": make_author(),
        "title": "⚡  ECCO HUB V3 — MASTER SCRIPT PANEL",
        "description": desc,
        "color": COLORS["panel"],
        "fields": [
            {
                "name": "📜 Primary Loadstring (Obfuscated Production)",
                "value": f"```lua\n{LOADSTRING_OBF}\n```",
                "inline": False
            },
            {
                "name": "🌐 Gateway Loadstring (eccohub.xyz)",
                "value": f"```lua\n{LOADSTRING_GW}\n```",
                "inline": False
            },
            {
                "name": "🟢 Network Status",
                "value": "ONLINE & OPERATIONAL",
                "inline": True
            },
            {
                "name": "🔑 Key Mode",
                "value": "KEYLESS (FREE)",
                "inline": True
            },
            {
                "name": "📦 Supported Games",
                "value": "14 Dedicated + 319 Universal",
                "inline": True
            },
            {
                "name": "🎮 Popular Games",
                "value": (
                    "• Storage Hunters: Open World\n"
                    "• Saber Simulator\n"
                    "• Pickaxe Tycoon\n"
                    "• Survive Zombie Arena\n"
                    "• Axe RNG & Click Simulator"
                ),
                "inline": True
            },
            {
                "name": "💎 Features Included",
                "value": (
                    "• Sleek 5-Stage Stepper Loader\n"
                    "• In-Game Announcements Bell\n"
                    "• Fast Rejoin & Server Tools\n"
                    "• Auto-Farm & ESP Utilities"
                ),
                "inline": True
            },
            {
                "name": "📱 Official Socials",
                "value": f"[Discord Community]({DISCORD_INVITE})\n[Official TikTok]({TIKTOK_LINK})\n[Website](https://eccohub.xyz)",
                "inline": True
            }
        ],
        "footer": make_footer(),
        "timestamp": datetime.now(timezone.utc).isoformat()
    }

    payload = {
        "username": "Ecco Hub Script Panel",
        "avatar_url": ICON_URL,
        "content": content_ping if content_ping else None,
        "embeds": [embed]
    }
    return send_webhook(webhook_url, payload)

def interactive_menu():
    while True:
        print("\n" + "=" * 60)
        print("         ECCO HUB V3 — DISCORD ANNOUNCEMENT PANEL         ")
        print("=" * 60)
        print("  [1] Announcement       (General Community Broadcast)")
        print("  [2] Script Update      (Changelog & Bug Fixes)")
        print("  [3] Script Release     (New Script Drop & Highlights)")
        print("  [4] New Game           (New Game Catalog Addition)")
        print("  [5] Script Panel       (Master Loadstring & Status Embed)")
        print("  [0] Exit")
        print("=" * 60)

        choice = input("Select an option (0-5): ").strip()
        if choice == "0":
            print("Exiting panel. Stay precise.")
            break
        elif choice == "1":
            print("\n--- NEW ANNOUNCEMENT ---")
            title = input("Title: ").strip() or "Community Announcement"
            print("Message (enter text, press enter):")
            msg = input("> ").strip() or "Ecco Hub V3 is online and operational."
            ping = input("Ping (everyone / here / none) [none]: ").strip().lower()
            post_announcement(title, msg, ping)
        elif choice == "2":
            print("\n--- SCRIPT UPDATE ---")
            game_name = input("Game Name: ").strip() or "Storage Hunters"
            version = input("Version [e.g. v3.1.2]: ").strip() or "v3.1.0"
            print("Changelog (bullet points or description):")
            changelog = input("> ").strip() or "• Performance optimizations\n• Fixed auto-farm loop\n• Updated anti-detection"
            ping = input("Ping (everyone / here / none) [none]: ").strip().lower()
            post_script_update(game_name, version, changelog, ping)
        elif choice == "3":
            print("\n--- SCRIPT RELEASE ---")
            game_name = input("Game Name: ").strip() or "Axe RNG"
            version = input("Version [v1.0.0]: ").strip() or "v1.0.0"
            desc = input("Description: ").strip() or f"Official {game_name} script released on Ecco Hub V3!"
            features = input("Features list: ").strip() or "• Auto-Roll\n• Infinite Luck Boost\n• Instant Leveling\n• Clean GUI"
            ping = input("Ping (everyone / here / none) [everyone]: ").strip().lower() or "everyone"
            post_script_release(game_name, version, desc, features, ping)
        elif choice == "4":
            print("\n--- NEW GAME ADDED ---")
            game_name = input("Game Name: ").strip() or "Survive Zombie Arena"
            place_info = input("Place Link / ID: ").strip() or "PlaceId routing active"
            desc = input("Description: ").strip() or f"{game_name} is now supported in Ecco Hub V3!"
            features = input("Highlights: ").strip() or "• Kill Aura\n• God Mode\n• Infinite Ammo\n• Auto-Wave Clear"
            ping = input("Ping (everyone / here / none) [everyone]: ").strip().lower() or "everyone"
            post_new_game(game_name, place_info, desc, features, ping)
        elif choice == "5":
            print("\n--- SCRIPT PANEL EMBED ---")
            custom_note = input("Custom Note (optional, press enter to skip): ").strip()
            ping = input("Ping (everyone / here / none) [none]: ").strip().lower()
            post_script_panel(custom_note if custom_note else None, ping)
        else:
            print("Invalid option. Enter 0-5.")

def main():
    parser = argparse.ArgumentParser(description="Ecco Hub V3 Discord Announcement & Script Panel")
    parser.add_argument("--type", choices=["announcement", "update", "release", "newgame", "panel"], help="Type of post to send")
    parser.add_argument("--title", help="Title of announcement")
    parser.add_argument("--message", help="Message content")
    parser.add_argument("--game", help="Game name")
    parser.add_argument("--version", default="v3.0.0", help="Version string")
    parser.add_argument("--changelog", help="Changelog text")
    parser.add_argument("--features", help="Features list")
    parser.add_argument("--place", help="Place info / ID")
    parser.add_argument("--ping", choices=["everyone", "here", "none"], default="none", help="Mention ping")
    parser.add_argument("--interactive", action="store_true", help="Launch interactive terminal wizard")

    args = parser.parse_args()

    if args.interactive or (len(sys.argv) == 1 and not args.type):
        interactive_menu()
        return

    if args.type == "announcement":
        post_announcement(args.title or "Announcement", args.message or "Ecco Hub V3 is operational.", args.ping)
    elif args.type == "update":
        post_script_update(args.game or "Ecco Hub", args.version, args.changelog or "Bug fixes and stability updates.", args.ping)
    elif args.type == "release":
        post_script_release(args.game or "New Script", args.version, args.message, args.features or "• Fully featured\n• 100% Free", args.ping)
    elif args.type == "newgame":
        post_new_game(args.game or "New Game", args.place, args.message, args.features or "• Instant execution\n• Clean GUI", args.ping)
    elif args.type == "panel":
        post_script_panel(args.message, args.ping)

if __name__ == "__main__":
    main()

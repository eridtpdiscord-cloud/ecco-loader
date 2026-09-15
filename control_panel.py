#!/usr/bin/env python3
"""
================================================================================
ECCO HUB V3 — ULTIMATE PYTHON MASS CONFIGURATION & CLOUD CONTROL PANEL
================================================================================
Comprehensive management suite for Ecco Hub:
  • Mass Game Configuration & Patching (330+ games)
  • Cloud State & Emergency Killswitch Controls
  • Licensing Matrix & Keyless / Key-Gate Automation
  • Push Broadcast Notification Dispatcher & Manager
  • Discord Webhook Integration & Announcement Broadcasting
  • GitHub Remote Synchronizer via REST API
================================================================================
"""

import argparse
import base64
import glob
import json
import os
import re
import sys
import time
import urllib.error
import urllib.request
from datetime import datetime

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')
if hasattr(sys.stderr, 'reconfigure'):
    sys.stderr.reconfigure(encoding='utf-8', errors='replace')

import announcer

CONFIG_PATHS = [
    'deploy_eccohub/public/api/v3/config.json',
    'deploy_eccohub/public/config.json'
]
GAMES_DIR = 'deploy_eccohub/public/games'
GITHUB_REPO = 'eridtpdiscord-cloud/ecco-loader'


def get_github_token():
    if 'ECCO_GITHUB_TOKEN' in os.environ:
        return os.environ['ECCO_GITHUB_TOKEN']
    for p in ['.github_token', '../.github_token', 'tools/.github_token']:
        if os.path.exists(p):
            with open(p, 'r', encoding='utf-8') as f:
                return f.read().strip()
    return ''


GITHUB_TOKEN = get_github_token()


def load_config():
    for p in CONFIG_PATHS:
        if os.path.exists(p):
            try:
                with open(p, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except Exception as e:
                print(f"[WARN] Error reading {p}: {e}")
    return {}


def save_config(cfg):
    for p in CONFIG_PATHS:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, 'w', encoding='utf-8') as f:
            json.dump(cfg, f, indent=4)
    print(f"\033[92m[LOCAL]\033[0m Synced local config to {len(CONFIG_PATHS)} targets.")


def push_file_to_github(remote_path, local_path, message):
    if not GITHUB_TOKEN:
        print("\033[93m[WARN]\033[0m No GitHub token found in .github_token or ECCO_GITHUB_TOKEN. Skipping remote sync.")
        return False
    if not os.path.exists(local_path):
        print(f"\033[93m[WARN]\033[0m Local file {local_path} not found.")
        return False
    try:
        url_endpoint = f'https://api.github.com/repos/{GITHUB_REPO}/contents/{remote_path}'
        headers = {
            'Authorization': f'token {GITHUB_TOKEN}',
            'User-Agent': 'EccoHub-ControlPanel/3.5',
            'Accept': 'application/vnd.github.v3+json'
        }
        sha = None
        try:
            req = urllib.request.Request(url_endpoint, headers=headers)
            with urllib.request.urlopen(req) as resp:
                data = json.loads(resp.read().decode('utf-8'))
                sha = data.get('sha')
        except Exception:
            pass

        with open(local_path, 'rb') as f:
            content_bytes = f.read()

        payload = {
            'message': message,
            'content': base64.b64encode(content_bytes).decode('utf-8')
        }
        if sha:
            payload['sha'] = sha

        req = urllib.request.Request(
            url_endpoint,
            data=json.dumps(payload).encode('utf-8'),
            headers={**headers, 'Content-Type': 'application/json'},
            method='PUT'
        )
        with urllib.request.urlopen(req) as resp:
            res = json.loads(resp.read().decode('utf-8'))
            commit_sha = res.get('commit', {}).get('sha', 'unknown')[:8]
            print(f"\033[92m[GITHUB]\033[0m Pushed {remote_path} -> Commit: \033[96m{commit_sha}\033[0m")
            return True
    except Exception as e:
        print(f"\033[91m[FAIL]\033[0m Failed to push {remote_path} to GitHub: {e}")
        return False


def push_all_updates():
    print("\n\033[94m[PUSH]\033[0m Pushing full repository updates to GitHub CDN...")
    # 1. Config
    push_file_to_github(
        'config.json',
        CONFIG_PATHS[0],
        f"feat(config): mass panel sync at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
    )
    # 2. Obsidian.lua
    obs_path = 'deploy_eccohub/public/lib/Obsidian.lua'
    if os.path.exists(obs_path):
        push_file_to_github(
            'lib/Obsidian.lua',
            obs_path,
            'feat(lib): modern circular toggles, circular sliders, and topbar notification dropdown'
        )
    # 3. Library.lua
    lib_path = 'deploy_eccohub/public/lib/Library.lua'
    if os.path.exists(lib_path):
        push_file_to_github(
            'lib/Library.lua',
            lib_path,
            'feat(lib): upstream sync of modern circular UI & notification dropdown'
        )
    # 4. Games manifest
    generate_games_manifest()
    manifest_path = 'deploy_eccohub/public/games_manifest.json'
    if os.path.exists(manifest_path):
        push_file_to_github(
            'games_manifest.json',
            manifest_path,
            'chore: update games manifest with registered 327 games'
        )
    print("\033[92m[SUCCESS]\033[0m Push complete.\n")
    return True


def sync_to_github():
    return push_all_updates()


# ==============================================================================
# MASS GAME SCRIPT CONFIGURATION ENGINE
# ==============================================================================
def scan_all_games():
    if not os.path.isdir(GAMES_DIR):
        print(f"\033[91m[ERROR]\033[0m Games directory {GAMES_DIR} not found.")
        return []
    files = glob.glob(os.path.join(GAMES_DIR, "*.*"))
    game_files = [f for f in files if f.endswith(('.lua', '.luau', '')) and not os.path.isdir(f)]
    return sorted(game_files)


def mass_patch_games(target_str, replace_str, dry_run=False):
    games = scan_all_games()
    print(f"\033[94m[SCAN]\033[0m Found {len(games)} game scripts in registry.")
    modified_count = 0
    for gpath in games:
        fname = os.path.basename(gpath)
        try:
            with open(gpath, 'r', encoding='utf-8', errors='ignore') as f:
                content = f.read()
            if target_str in content:
                count = content.count(target_str)
                new_content = content.replace(target_str, replace_str)
                if not dry_run:
                    with open(gpath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                modified_count += 1
                print(f"  \033[92m•\033[0m [{fname}] Replaced {count} match(es).")
        except Exception as e:
            print(f"  \033[91m✖\033[0m [{fname}] Failed to process: {e}")
    status = "DRY-RUN COMPLETE" if dry_run else "PATCH COMPLETE"
    print(f"\033[96m[{status}]\033[0m Modified {modified_count} of {len(games)} files.")


def list_games_catalog(query=None, limit=25, page=1):
    games = scan_all_games()
    catalog = []
    for gpath in games:
        fname = os.path.basename(gpath)
        size_kb = os.path.getsize(gpath) / 1024
        fw = "Ecco Custom"
        try:
            with open(gpath, 'r', encoding='utf-8', errors='ignore') as fp:
                snippet = fp.read(49152)
            if 'Obsidian' in snippet or 'deividcomsono/Obsidian' in snippet:
                fw = "Obsidian Reborn"
            elif 'Luna' in snippet:
                fw = "Luna UI"
            elif 'Linoria' in snippet or 'LinoriaLib' in snippet:
                fw = "LinoriaLib"
            elif 'Fluent' in snippet:
                fw = "Fluent"
        except Exception:
            pass

        if query and (query.lower() not in fname.lower() and query.lower() not in fw.lower()):
            continue

        catalog.append({
            "filename": fname,
            "size_kb": size_kb,
            "framework": fw,
            "path": gpath
        })

    total = len(catalog)
    total_pages = max(1, (total + limit - 1) // limit)
    page = max(1, min(page, total_pages))
    start_idx = (page - 1) * limit
    end_idx = min(start_idx + limit, total)

    header_title = f"ECCO HUB V3 GAME CATALOG ({total} matches" + (f" for '{query}')" if query else ")")
    print("\n" + "═" * 80)
    print(f" {header_title}")
    print("═" * 80)
    print(f" {'#':<4} {'Game Script Name':<38} {'Size (KB)':<12} {'UI Framework':<18}")
    print("─" * 80)
    for i in range(start_idx, end_idx):
        item = catalog[i]
        fw_color = "\033[96m" if "Obsidian" in item['framework'] else ("\033[92m" if "Luna" in item['framework'] else "\033[93m")
        print(f" \033[90m{i+1:<4}\033[0m {item['filename']:<38} {item['size_kb']:<12.1f} {fw_color}{item['framework']:<18}\033[0m")
    print("═" * 80)
    print(f" Page {page}/{total_pages} (Showing {end_idx - start_idx} of {total} scripts)\n")
    return catalog


def generate_games_manifest():
    games = scan_all_games()
    manifest = {
        "generated_at": datetime.now().isoformat(),
        "total_games": len(games),
        "games": []
    }
    for gpath in games:
        fname = os.path.basename(gpath)
        size = os.path.getsize(gpath)
        manifest["games"].append({
            "filename": fname,
            "size_bytes": size,
            "path": gpath.replace('\\', '/')
        })
    out_path = 'deploy_eccohub/public/games_manifest.json'
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(manifest, f, indent=4)
    print(f"\033[92m[MANIFEST]\033[0m Generated games registry with {len(games)} scripts -> {out_path}")


# ==============================================================================
# NOTIFICATION & BROADCAST MANAGEMENT
# ==============================================================================
def add_notification(cfg, title, message, badge="UPDATE"):
    badge_clean = badge.upper() if badge else "UPDATE"
    new_notif = {
        "id": f"noti-{int(datetime.now().timestamp())}",
        "title": title,
        "content": message,
        "date": datetime.now().strftime("%Y-%m-%d"),
        "badge": badge_clean
    }
    notifs = cfg.setdefault("notifications", [])
    notifs.insert(0, new_notif)
    print(f"\033[92m[NOTIF ADDED]\033[0m [{badge_clean}] {title}: {message}")
    return True


def remove_notification(cfg, identifier):
    notifs = cfg.get("notifications", [])
    if not notifs:
        print("\033[93m[INFO]\033[0m No notifications to remove.")
        return False
    try:
        idx = int(identifier) - 1
        if 0 <= idx < len(notifs):
            removed = notifs.pop(idx)
            print(f"\033[92m[NOTIF REMOVED]\033[0m Removed notice: {removed.get('title')}")
            return True
    except ValueError:
        pass
    for i, n in enumerate(notifs):
        if n.get("id") == identifier or identifier.lower() in n.get("title", "").lower():
            removed = notifs.pop(i)
            print(f"\033[92m[NOTIF REMOVED]\033[0m Removed notice: {removed.get('title')}")
            return True
    print(f"\033[91m[WARN]\033[0m No notification matching '{identifier}' found.")
    return False


# ==============================================================================
# INTERACTIVE TERMINAL PANEL
# ==============================================================================
def print_banner():
    banner = r"""
\033[96m╔══════════════════════════════════════════════════════════════════════════════════╗
║  ███████╗ ██████╗ ██████╗ ██████╗     ██╗  ██╗██╗   ██╗██████╗     ██╗   ██╗██████╗  ║
║  ██╔════╝██╔════╝██╔════╝██╔═══██╗    ██║  ██║██║   ██║██╔══██╗    ██║   ██║╚════██╗ ║
║  █████╗  ██║     ██║     ██║   ██║    ███████║██║   ██║██████╔╝    ██║   ██║ █████╔╝ ║
║  ██╔══╝  ██║     ██║     ██║   ██║    ██╔══██║██║   ██║██╔══██╗    ╚██╗ ██╔╝ ╚═══██╗ ║
║  ███████╗╚██████╗╚██████╗╚██████╔╝    ██║  ██║╚██████╔╝██████╔╝     ╚████╔╝ ██████╔╝ ║
║  ╚══════╝ ╚═════╝ ╚═════╝ ╚═════╝     ╚═╝  ╚═╝ ╚═════╝ ╚═════╝       ╚═══╝  ╚═════╝  ║
║                    MASS CONFIGURATION & CLOUD ORCHESTRATOR                       ║
╚══════════════════════════════════════════════════════════════════════════════════╝\033[0m
"""
    print(banner)


def show_status(cfg):
    status_str = cfg.get('status', 'unknown').upper()
    status_color = "\033[92m" if status_str == "ONLINE" else "\033[91m"
    key_mode = cfg.get('key_system', {}).get('mode', 'unknown').upper()
    key_color = "\033[93m" if key_mode == "KEY_REQUIRED" else "\033[92m"
    notifs = cfg.get('notifications', [])

    print("\n" + "═" * 70)
    print("                      ECCO HUB CLOUD METRICS")
    print("═" * 70)
    print(f" • Hub Operational State : {status_color}{status_str}\033[0m")
    if status_str == "SHUTDOWN":
        print(f" • Maintenance Message   : \033[93m{cfg.get('shutdown_message', 'None')}\033[0m")
    print(f" • Key System Licensing  : {key_color}{key_mode}\033[0m")
    print(f" • Active Version        : \033[96m{cfg.get('version', '3.5.0')}\033[0m")
    print(f" • Total Game Scripts    : \033[95m{len(scan_all_games())} registered\033[0m")
    print(f" • Broadcast Notices     : \033[94m{len(notifs)} active\033[0m")
    for i, n in enumerate(notifs):
        badge = n.get('badge', 'NOTICE')
        print(f"    \033[96m[{i+1}]\033[0m [\033[93m{badge}\033[0m] {n.get('title')} ({n.get('date')}): {n.get('content')[:60]}...")
    print("═" * 70 + "\n")


def interactive_menu():
    while True:
        cfg = load_config()
        print_banner()
        show_status(cfg)

        print("\033[96m[OPERATIONS MENU]\033[0m")
        print("  \033[92m1.\033[0m Set Hub ONLINE")
        print("  \033[91m2.\033[0m Set Hub EMERGENCY SHUTDOWN / MAINTENANCE")
        print("  \033[93m3.\033[0m Toggle KEYLESS Mode (Instant Access)")
        print("  \033[93m4.\033[0m Toggle KEY SYSTEM Mode (LootLabs Gate)")
        print("  \033[94m5.\033[0m Add Broadcast Notification")
        print("  \033[94m6.\033[0m Remove Broadcast Notification")
        print("  \033[94m7.\033[0m Clear All Notifications")
        print("  \033[95m8.\033[0m Mass Scan & Rebuild Games Manifest (330+ Games)")
        print("  \033[95m9.\033[0m Mass String Find & Replace Across All Game Scripts")
        print("  \033[96m10.\033[0m Dispatch Discord Announcement")
        print("  \033[96m11.\033[0m Dispatch Master Script Panel to Discord")
        print("  \033[92m12.\033[0m Sync Config to GitHub Remote Now")
        print("  \033[93m13.\033[0m Browse & Search All 327+ Games Catalog")
        print("  \033[90m0.\033[0m Exit Panel\n")

        try:
            choice = input("\033[93mEnter Selection (0-13): \033[0m").strip()
        except (EOFError, KeyboardInterrupt):
            print("\n\033[96m[ECCO]\033[0m Exiting control panel.")
            break

        if choice == '0':
            print("\033[96m[ECCO]\033[0m Exiting control panel.")
            break

        modified = False

        if choice == '1':
            cfg['status'] = 'online'
            modified = True
            print("\033[92m[CHANGE]\033[0m Hub status set to ONLINE.")

        elif choice == '2':
            msg = input("\033[93mEnter custom shutdown/maintenance message (leave blank for default): \033[0m").strip()
            cfg['status'] = 'shutdown'
            cfg['shutdown_message'] = msg or "Ecco Hub V3 is currently offline for scheduled maintenance."
            modified = True
            print(f"\033[91m[CHANGE]\033[0m Hub status set to SHUTDOWN: {cfg['shutdown_message']}")

        elif choice == '3':
            cfg.setdefault('key_system', {})['mode'] = 'keyless'
            modified = True
            print("\033[92m[CHANGE]\033[0m Key system mode set to KEYLESS.")

        elif choice == '4':
            cfg.setdefault('key_system', {})['mode'] = 'key_required'
            modified = True
            print("\033[93m[CHANGE]\033[0m Key system mode set to KEY_REQUIRED.")

        elif choice == '5':
            title = input("\033[93mNotification Title: \033[0m").strip()
            msg = input("\033[93mNotification Message: \033[0m").strip()
            badge = input("\033[93mBadge [UPDATE/NEW/ALERT/HOTFIX] (Default: UPDATE): \033[0m").strip() or "UPDATE"
            if title and msg:
                add_notification(cfg, title, msg, badge)
                modified = True

        elif choice == '6':
            ident = input("\033[93mEnter Notification Index or Title to Remove: \033[0m").strip()
            if ident and remove_notification(cfg, ident):
                modified = True

        elif choice == '7':
            cfg['notifications'] = []
            modified = True
            print("\033[91m[CHANGE]\033[0m Wiped all broadcast notifications.")

        elif choice == '8':
            generate_games_manifest()

        elif choice == '9':
            target = input("\033[93mEnter exact string to search across all games: \033[0m").strip()
            replacement = input("\033[93mEnter replacement string: \033[0m").strip()
            dry = input("\033[93mDry run only? (y/n, default: y): \033[0m").strip().lower() != 'n'
            if target:
                mass_patch_games(target, replacement, dry_run=dry)

        elif choice == '10':
            title = input("\033[93mAnnouncement Title: \033[0m").strip()
            msg = input("\033[93mAnnouncement Message: \033[0m").strip()
            ping = input("\033[93mPing (@everyone / @here / none): \033[0m").strip().lower()
            if title and msg:
                announcer.post_announcement(title, msg, ping=ping if ping in ['everyone', 'here'] else None)

        elif choice == '11':
            announcer.post_script_panel()

        elif choice == '12':
            sync_to_github()

        elif choice == '13':
            q = input("\033[93mSearch filter (leave blank to list all): \033[0m").strip()
            list_games_catalog(query=q if q else None, limit=30, page=1)

        if modified:
            save_config(cfg)
            auto_sync = input("\033[93mPush changes to GitHub remote now? (y/n, default: y): \033[0m").strip().lower()
            if auto_sync != 'n':
                sync_to_github()

        input("\n\033[90mPress Enter to continue...\033[0m")


# ==============================================================================
# CLI ARGUMENT PARSER
# ==============================================================================
def main():
    parser = argparse.ArgumentParser(description="Ecco Hub V3 Master Mass Configuration Panel")
    parser.add_argument('--status', action='store_true', help="Show current cloud configuration status")
    parser.add_argument('--menu', action='store_true', help="Launch interactive full-featured TUI dashboard")
    parser.add_argument('--games', '--list-games', action='store_true', help="List all registered games in the catalog")
    parser.add_argument('--search', type=str, help="Search game catalog by keyword")
    parser.add_argument('--keyless', action='store_true', help="Enable Keyless mode (no key prompt)")
    parser.add_argument('--keysystem', action='store_true', help="Enable Key System mode (key gate required)")
    parser.add_argument('--shutdown', type=str, nargs='?', const="Ecco Hub V3 is offline for maintenance.", help="Set emergency shutdown with optional message")
    parser.add_argument('--online', action='store_true', help="Restore hub to online state")
    parser.add_argument('--notify', nargs='+', help="Broadcast a notification: TITLE MESSAGE [BADGE]")
    parser.add_argument('--remove-notif', type=str, help="Remove notification by index (1-based) or ID/title")
    parser.add_argument('--clear-notifs', action='store_true', help="Clear all existing notifications")
    parser.add_argument('--sync', action='store_true', help="Force sync cloud config to GitHub remote")
    parser.add_argument('--no-sync', action='store_true', help="Do not push changes to GitHub remote")
    parser.add_argument('--build-manifest', action='store_true', help="Scan and build complete 330+ game manifest")
    parser.add_argument('--mass-replace', nargs=2, metavar=('TARGET', 'REPLACE'), help="Mass find and replace across all 330+ game scripts")
    parser.add_argument('--announce', nargs=2, metavar=('TITLE', 'MESSAGE'), help="Post announcement to Discord webhook")
    parser.add_argument('--discord-panel', action='store_true', help="Post Master Script Panel embed to Discord webhook")

    args = parser.parse_args()
    cfg = load_config()

    if not cfg:
        print("\033[91m[ERROR]\033[0m Could not load config.json")
        return

    if args.games or args.search:
        list_games_catalog(query=args.search, limit=50, page=1)
        return

    if args.menu:
        interactive_menu()
        return

    modified = False

    if args.status or len(sys.argv) == 1:
        show_status(cfg)
        if len(sys.argv) == 1:
            return

    if args.keyless:
        cfg.setdefault('key_system', {})['mode'] = 'keyless'
        print("\033[92m[CHANGE]\033[0m Set key_system.mode to 'keyless'.")
        modified = True

    if args.keysystem:
        cfg.setdefault('key_system', {})['mode'] = 'key_required'
        print("\033[93m[CHANGE]\033[0m Set key_system.mode to 'key_required'.")
        modified = True

    if args.shutdown is not None:
        cfg['status'] = 'shutdown'
        cfg['shutdown_message'] = args.shutdown
        print(f"\033[91m[CHANGE]\033[0m Set status to 'shutdown' with message: '{args.shutdown}'.")
        modified = True

    if args.online:
        cfg['status'] = 'online'
        print("\033[92m[CHANGE]\033[0m Set status to 'online'.")
        modified = True

    if args.clear_notifs:
        cfg['notifications'] = []
        print("\033[91m[CHANGE]\033[0m Cleared all broadcast notifications.")
        modified = True

    if args.remove_notif:
        if remove_notification(cfg, args.remove_notif):
            modified = True

    if args.notify:
        if len(args.notify) >= 2:
            title = args.notify[0]
            msg = args.notify[1]
            badge = args.notify[2] if len(args.notify) > 2 else "UPDATE"
            add_notification(cfg, title, msg, badge)
            modified = True
        else:
            print("\033[91m[ERROR]\033[0m --notify requires at least TITLE and MESSAGE.")

    if args.build_manifest:
        generate_games_manifest()

    if args.mass_replace:
        target, replace_with = args.mass_replace
        mass_patch_games(target, replace_with, dry_run=False)

    if args.announce:
        title, msg = args.announce
        announcer.post_announcement(title, msg)

    if args.discord_panel:
        announcer.post_script_panel()

    if modified:
        save_config(cfg)
        if not args.no_sync:
            sync_to_github()

    if args.sync and not modified:
        sync_to_github()


if __name__ == '__main__':
    main()

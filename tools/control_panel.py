#!/usr/bin/env python3
"""
================================================================================
ECCO HUB V3 — REMOTE CLOUD CONTROL PANEL
================================================================================
Manage Keyless mode, Key System, Remote Killswitch / Shutdown, and Push
Broadcast Notifications directly to all in-game scripts and loaders.
================================================================================
"""

import argparse
import json
import os
import sys
import base64
import urllib.request
from datetime import datetime

CONFIG_PATHS = [
    'deploy_eccohub/public/api/v3/config.json',
    'deploy_eccohub/public/config.json'
]

def get_github_token():
    if 'ECCO_GITHUB_TOKEN' in os.environ:
        return os.environ['ECCO_GITHUB_TOKEN']
    for p in ['.github_token', '../.github_token', 'tools/.github_token']:
        if os.path.exists(p):
            with open(p, 'r') as f:
                return f.read().strip()
    return ''

GITHUB_TOKEN = get_github_token()
GITHUB_REPO = 'eridtpdiscord-cloud/ecco-loader'

def load_config():
    target = CONFIG_PATHS[0]
    if os.path.exists(target):
        with open(target, 'r', encoding='utf-8') as f:
            return json.load(f)
    return {}

def save_config(cfg):
    for p in CONFIG_PATHS:
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, 'w', encoding='utf-8') as f:
            json.dump(cfg, f, indent=4)
    print("[LOCAL] Updated local config files successfully.")

def sync_to_github():
    try:
        url_endpoint = f'https://api.github.com/repos/{GITHUB_REPO}/contents/config.json'
        headers = {
            'Authorization': f'token {GITHUB_TOKEN}',
            'User-Agent': 'Mozilla/5.0',
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

        with open(CONFIG_PATHS[0], 'rb') as f:
            content_bytes = f.read()

        payload = {
            'message': f"chore(config): cloud sync at {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
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
            print(f"[GITHUB] Cloud config synced to GitHub -> commit {res['commit']['sha'][:8]}")
    except Exception as e:
        print(f"[WARN] Failed to sync to GitHub: {e}")

def main():
    parser = argparse.ArgumentParser(description="Ecco Hub V3 Remote Control Panel")
    parser.add_argument('--status', action='store_true', help="Show current cloud configuration status")
    parser.add_argument('--keyless', action='store_true', help="Enable Keyless mode (no key prompt)")
    parser.add_argument('--keysystem', action='store_true', help="Enable Key System (LootLabs key gate required)")
    parser.add_argument('--shutdown', type=str, nargs='?', const="Ecco Hub V3 is currently offline for maintenance.", help="Trigger emergency shutdown with custom message")
    parser.add_argument('--online', action='store_true', help="Restore hub to online state")
    parser.add_argument('--notify', nargs=2, metavar=('TITLE', 'MESSAGE'), help="Broadcast a notification to all active in-game menus")
    parser.add_argument('--clear-notifs', action='store_true', help="Clear all existing notifications")
    parser.add_argument('--no-sync', action='store_true', help="Do not push changes to GitHub remote")

    args = parser.parse_args()
    cfg = load_config()

    if not cfg:
        print("[ERROR] Could not load config.json")
        return

    modified = False

    if args.status or len(sys.argv) == 1:
        print("\n==================================================")
        print("         ECCO HUB V3 — CLOUD CONFIG STATUS         ")
        print("==================================================")
        print(f"Network Status    : {cfg.get('status', 'unknown').upper()}")
        if cfg.get('status') == 'shutdown':
            print(f"Shutdown Message  : {cfg.get('shutdown_message')}")
        key_mode = cfg.get('key_system', {}).get('mode', 'unknown')
        print(f"Key System Mode   : {key_mode.upper()}")
        print(f"Active Notices    : {len(cfg.get('notifications', []))}")
        for idx, n in enumerate(cfg.get('notifications', [])):
            print(f"  [{idx+1}] ({n.get('date')}) {n.get('title')}: {n.get('content')[:50]}...")
        print(f"Discord Link      : {cfg.get('discord')}")
        print(f"TikTok Link       : {cfg.get('tiktok')}")
        print("==================================================\n")
        if len(sys.argv) == 1:
            return

    if args.keyless:
        cfg.setdefault('key_system', {})['mode'] = 'keyless'
        print("[CHANGE] Set key_system.mode to 'keyless'.")
        modified = True

    if args.keysystem:
        cfg.setdefault('key_system', {})['mode'] = 'key_required'
        print("[CHANGE] Set key_system.mode to 'key_required'.")
        modified = True

    if args.shutdown:
        cfg['status'] = 'shutdown'
        cfg['shutdown_message'] = args.shutdown
        print(f"[CHANGE] Set status to 'shutdown' with message: '{args.shutdown}'.")
        modified = True

    if args.online:
        cfg['status'] = 'online'
        print("[CHANGE] Set status to 'online'.")
        modified = True

    if args.clear_notifs:
        cfg['notifications'] = []
        print("[CHANGE] Cleared all broadcast notifications.")
        modified = True

    if args.notify:
        title, msg = args.notify
        new_notice = {
            'id': f"noti-{int(datetime.now().timestamp())}",
            'title': title,
            'content': msg,
            'date': datetime.now().strftime('%Y-%m-%d'),
            'badge': 'UPDATE'
        }
        cfg.setdefault('notifications', []).insert(0, new_notice)
        print(f"[CHANGE] Added broadcast notification: '{title}'.")
        modified = True

    if modified:
        save_config(cfg)
        if not args.no_sync:
            sync_to_github()

if __name__ == '__main__':
    main()

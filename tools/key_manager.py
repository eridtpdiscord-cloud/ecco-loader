import os
import json
import random
import string
import urllib.request
from datetime import datetime, timedelta

# Configuration paths
JSON_FILE = "keys.json"
JSONBLOB_API = "https://jsonblob.com/api/jsonBlob"

headers = {
    'Content-Type': 'application/json',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

def clear_screen():
    os.system('cls' if os.name == 'nt' else 'clear')

def generate_key(prefix="ECCO_", length=10):
    chars = string.ascii_uppercase + string.digits
    return prefix + ''.join(random.choice(chars) for _ in range(length))

def djb2_hash(str_val):
    h = 5381
    for char in str_val:
        h = ((h << 5) + h) + ord(char)
        h &= 0xFFFFFFFF
    return str(h)

def load_local_db():
    if os.path.exists(JSON_FILE):
        try:
            with open(JSON_FILE, 'r') as f:
                db = json.load(f)
                if "blob_id" not in db:
                    db["blob_id"] = ""
                if "raw_keys_dont_share" not in db:
                    db["raw_keys_dont_share"] = {}
                return db
        except Exception as e:
            print(f"Error reading {JSON_FILE}: {e}")
            input("Press Enter to start a fresh database...")
    
    # Default structure
    return {
        "blob_id": "",
        "keyless": False,
        "key_link": "https://lootlink.org/s?xxxx",
        "keys": {},
        "raw_keys_dont_share": {}
    }

def save_local_db(db):
    try:
        with open(JSON_FILE, 'w') as f:
            json.dump(db, f, indent=2)
    except Exception as e:
        print(f"Error saving to {JSON_FILE}: {e}")

def sync_to_cloud(db):
    # Prepare clean DB for the cloud (do not upload blob_id or raw keys)
    cloud_db = {
        "keyless": db["keyless"],
        "key_link": db["key_link"],
        "keys": db["keys"]
    }
    
    data_bytes = json.dumps(cloud_db).encode('utf-8')
    
    if not db["blob_id"]:
        # Create a new blob
        req = urllib.request.Request(JSONBLOB_API, data=data_bytes, headers=headers)
        try:
            with urllib.request.urlopen(req) as response:
                loc = response.getheader('Location')
                db["blob_id"] = loc.split('/')[-1]
                save_local_db(db)
                print(f"\n[+] Created new cloud database: {db['blob_id']}")
                return True
        except Exception as e:
            print(f"\n[-] Error creating cloud database: {e}")
            return False
    else:
        # Update existing blob
        url = f"{JSONBLOB_API}/{db['blob_id']}"
        req = urllib.request.Request(url, data=data_bytes, headers=headers, method='PUT')
        try:
            with urllib.request.urlopen(req) as response:
                if response.status == 200:
                    print("\n[+] Cloud database synced successfully!")
                    return True
                else:
                    print(f"\n[-] Sync failed with status: {response.status}")
                    return False
        except Exception as e:
            print(f"\n[-] Sync error: {e}")
            return False

def show_banner():
    print("=" * 60)
    print("      ECCO HUB - CLOUD KEY DATABASE MANAGER      ")
    print("=" * 60)

def main():
    db = load_local_db()
    
    # Auto-create if first time
    if not db["blob_id"]:
        print("[*] No cloud database detected. Creating one now...")
        if sync_to_cloud(db):
            print("[+] Successfully initialized database!")
            input("Press Enter to continue to Manager...")
        else:
            print("[-] Initialization failed. Check internet connection.")
            input("Press Enter to retry...")
            return

    while True:
        clear_screen()
        show_banner()
        print(f" Cloud Blob ID : {db['blob_id']}")
        print(f" Keyless Mode  : {'[ ON ] (Free access)' if db['keyless'] else '[ OFF ] (Locked)'}")
        print(f" Key Link      : {db['key_link']}")
        print(f" Total Keys    : {len(db['raw_keys_dont_share'])}")
        print("=" * 60)
        print(" [1] Generate Temporary Key")
        print(" [2] Generate Permanent Key")
        print(" [3] List Active Keys")
        print(" [4] Revoke / Delete a Key")
        print(" [5] Toggle Keyless Mode")
        print(" [6] Edit Key Link")
        print(" [7] Sync Changes to Cloud")
        print(" [0] Exit")
        print("=" * 60)
        
        choice = input("Select an option: ").strip()
        
        if choice == "1":
            clear_screen()
            show_banner()
            try:
                days = int(input("Enter key duration in days (e.g. 1, 7, 30): "))
                expiry_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
                new_key = generate_key("ECCO_TEMP_")
                hashed = djb2_hash(new_key)
                
                db["keys"][hashed] = expiry_date
                db["raw_keys_dont_share"][new_key] = expiry_date
                save_local_db(db)
                
                print("\n" + "=" * 40)
                print(f"[+] Key Generated: {new_key}")
                print(f"[+] Expiration Date: {expiry_date}")
                print("=" * 40)
            except ValueError:
                print("\n[-] Invalid number of days.")
            input("\nPress Enter to return...")
            
        elif choice == "2":
            clear_screen()
            show_banner()
            new_key = generate_key("ECCO_PERM_")
            hashed = djb2_hash(new_key)
            
            db["keys"][hashed] = "permanent"
            db["raw_keys_dont_share"][new_key] = "permanent"
            save_local_db(db)
            
            print("\n" + "=" * 40)
            print(f"[+] Key Generated: {new_key}")
            print(f"[+] Type: Permanent / Lifetime")
            print("=" * 40)
            input("\nPress Enter to return...")
            
        elif choice == "3":
            clear_screen()
            show_banner()
            print("ACTIVE KEYS (DO NOT SHARE EXPIRATION/RAW DATABASE):")
            print("-" * 60)
            if not db["raw_keys_dont_share"]:
                print("No active keys in database.")
            else:
                for k, exp in db["raw_keys_dont_share"].items():
                    status = "Permanent" if exp == "permanent" else f"Expires: {exp}"
                    print(f" Key: {k:<20} | {status}")
            print("-" * 60)
            input("\nPress Enter to return...")
            
        elif choice == "4":
            clear_screen()
            show_banner()
            print("ACTIVE KEYS:")
            keys_list = list(db["raw_keys_dont_share"].keys())
            if not keys_list:
                print("No keys available to delete.")
            else:
                for idx, k in enumerate(keys_list, 1):
                    print(f" [{idx}] {k} ({db['raw_keys_dont_share'][k]})")
                print("-" * 60)
                try:
                    del_idx = int(input("Select key number to revoke: ")) - 1
                    if 0 <= del_idx < len(keys_list):
                        key_to_del = keys_list[del_idx]
                        hashed_del = djb2_hash(key_to_del)
                        
                        del db["keys"][hashed_del]
                        del db["raw_keys_dont_share"][key_to_del]
                        save_local_db(db)
                        print(f"\n[+] Successfully revoked: {key_to_del}")
                    else:
                        print("\n[-] Invalid selection.")
                except ValueError:
                    print("\n[-] Invalid input.")
            input("\nPress Enter to return...")
            
        elif choice == "5":
            db["keyless"] = not db["keyless"]
            save_local_db(db)
            print(f"\n[+] Keyless Mode toggled to: {'ON' if db['keyless'] else 'OFF'}")
            input("\nPress Enter to return...")
            
        elif choice == "6":
            clear_screen()
            show_banner()
            print(f"Current Key Link: {db['key_link']}")
            new_link = input("Enter new Linkvertise/LootLabs link (or press Enter to cancel): ").strip()
            if new_link:
                db["key_link"] = new_link
                save_local_db(db)
                print("\n[+] Key link updated!")
            input("\nPress Enter to return...")
            
        elif choice == "7":
            clear_screen()
            show_banner()
            print("[*] Uploading changes to cloud...")
            if sync_to_cloud(db):
                print("\n[+] Cloud sync complete! Database is up to date.")
            else:
                print("\n[-] Cloud sync failed. Try again.")
            input("\nPress Enter to return...")
            
        elif choice == "0":
            # Auto sync on exit just in case
            print("\n[*] Saving and syncing before exit...")
            sync_to_cloud(db)
            break

if __name__ == "__main__":
    main()

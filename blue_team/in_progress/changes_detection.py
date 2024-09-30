import os
import hashlib
import shutil
import time

# Directories to monitor
directories_to_monitor = ["/etc", "/var/www", "/home/user/important_files"]
backup_dir = "/backup"

def hash_file(filepath):
    """
    Generate SHA-256 hash of a file.
    """
    with open(filepath, 'rb') as f:
        return hashlib.sha256(f.read()).hexdigest()

def create_backup():
    """
    Create a backup of monitored directories.
    """
    for directory in directories_to_monitor:
        for root, _, files in os.walk(directory):
            for file in files:
                filepath = os.path.join(root, file)
                backup_path = os.path.join(backup_dir, os.path.relpath(filepath, "/"))

                os.makedirs(os.path.dirname(backup_path), exist_ok=True)
                shutil.copy2(filepath, backup_path)

def detect_and_revert_changes():
    """
    Monitor and revert unauthorized changes.
    """
    print("[+] Monitoring for unauthorized changes...")
    while True:
        for directory in directories_to_monitor:
            for root, _, files in os.walk(directory):
                for file in files:
                    filepath = os.path.join(root, file)
                    backup_path = os.path.join(backup_dir, os.path.relpath(filepath, "/"))

                    if not os.path.exists(filepath) or not os.path.exists(backup_path):
                        continue

                    # Check if the file has been modified
                    current_hash = hash_file(filepath)
                    backup_hash = hash_file(backup_path)

                    if current_hash != backup_hash:
                        print(f"[ALERT] Unauthorized change detected in {filepath}. Reverting...")
                        shutil.copy2(backup_path, filepath)

        time.sleep(60)  # Check every 60 seconds

if __name__ == "__main__":
    create_backup()
    detect_and_revert_changes()
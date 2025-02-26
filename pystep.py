import os
import subprocess

def install_packages():
    subprocess.run(["sudo", "apt", "install", "-y", "nfs-common", "ntfs-3g"], check=True)

def list_partitions():
    print("\n\033[1;34mAvailable NTFS partitions:\033[0m")
    partitions = []
    result = subprocess.run(["lsblk", "-o", "NAME,FSTYPE,SIZE,LABEL", "-nr"], capture_output=True, text=True)
    for count, line in enumerate(result.stdout.splitlines(), start=1):
        fields = line.split()
        if len(fields) >= 4 and fields[1] == "ntfs":
            partition = f"/dev/{fields[0]}"
            print(f"{count}- {partition} ({fields[3]} - {fields[2]})")
            partitions.append(partition)
    return partitions

def mount_partition(partition):
    mount_point = "/mnt/ntfs_drive"
    os.makedirs(mount_point, exist_ok=True)
    print(f"\033[1;32mMounting {partition} to {mount_point}...\033[0m")
    result = subprocess.run(["sudo", "mount", "-o", "defaults,exec,uid={},gid={}".format(os.getuid(), os.getgid()), partition, mount_point])
    if result.returncode == 0:
        print("\033[1;32mSuccessfully mounted at {}.\033[0m".format(mount_point))
    else:
        print("\033[1;31mMount failed. Try mounting manually.\033[0m")

def fix_partition(partition):
    print(f"\033[1;32mFixing partition: {partition}\033[0m")
    subprocess.run(["sudo", "ntfsfix", "-b", "-d", partition], check=True)

def main():
    install_packages()
    while True:
        partitions = list_partitions()
        if not partitions:
            print("\033[1;31mNo NTFS partitions found. Exiting.\033[0m")
            return
        user_input = input("\033[1;33mEnter the number of the NTFS partition you want to fix & mount (or type 'exit' to quit):\033[0m ")
        if user_input.lower() == "exit":
            print("\033[1;34mExiting.\033[0m")
            break
        if not user_input.isdigit() or not (1 <= int(user_input) <= len(partitions)):
            print("\033[1;31mInvalid selection. Try again.\033[0m")
            continue
        selected_partition = partitions[int(user_input) - 1]
        fix_partition(selected_partition)
        mount_partition(selected_partition)
        print("\033[1;34mDone. You may need to reboot if issues persist.\033[0m")

if __name__ == "__main__":
    main()

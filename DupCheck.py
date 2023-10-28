import os
import shutil
import hashlib

# Check the operating system
# OS = os.name  # Not needed as it's not used in the script.

# Or specify multiple folders manually
folders = [
    r"/volume1/Media/Audiobooks",
    r"/volume1/Media/Books",
    r"/volume1/Media/Other Videos",
    r"/volume1/Home",
    r"/volume1/Download"
]

# Create an empty dictionary to store file hashes
hashes = {}

# Traverse all child folders and calculate file hashes
print("Getting file list...")
filecount = 0
dupcount = 0
subfiles = []
for folder in folders:
    for dirpath, dirnames, filenames in os.walk(folder):
        for filename in filenames:
            subfiles.append(os.path.join(dirpath, filename))
totalfiles = len(subfiles)
print("Calculating file hashes...")
for filepath in subfiles:
    with open(filepath, "rb") as file:
        file_content = file.read()
        file_hash = hashlib.md5(file_content).hexdigest()
    if file_hash in hashes:
        # move current file to temp directory
        tempdir = "/tmp"
        if not os.path.exists(tempdir):
            os.makedirs(tempdir)
        temp_filepath = os.path.join(tempdir, os.path.basename(filepath))
        print(f"\nRemoving duplicate file: {filepath}")
        os.remove(filepath)
        dupcount += 1
    else:
        hashes[file_hash] = [filepath]
    filecount += 1
    # calculate the percentage of files hashed
    percent = round((filecount / totalfiles) * 100, 4)
    print(f"\r{percent}% - {filecount} files hashed of {totalfiles} - {dupcount} duplicates.", end="", flush=True)

# Delete empty directories below each folder
print("\nDeleting empty directories...")
for folder in folders:
    for dirpath, dirnames, filenames in os.walk(folder, topdown=False):
        for dirname in dirnames:
            dir_to_remove = os.path.join(dirpath, dirname)
            if not os.listdir(dir_to_remove):
                os.rmdir(dir_to_remove)

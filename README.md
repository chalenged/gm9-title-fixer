# gm9-title-fixer
## Usage
1. Download the `y_title_fixer.firm` file from the Releases to the right
2. place it in your `luma/payloads` folder of your sd card
3. put the SD back into the 3ds
4. hold the Y button and turn it on while holding Y
5. The script should guide you through the process, make sure to read what it says carefully. 

After it's done your 3ds will restart, and (hopefully) your titles will be there (except the ones that were deleted). You can delete the `y_title_fixer.firm` afterwards, to not get confused with gm9. 

If you end up on the home menu instead of the script, make sure the file is in the correct folder, your sd card is inserted properly, you were actually holding the Y button (not the X button), and your Y button works. If you have issues, or this script doesn't help with the issue, ask for help in the [Nintendo Homebrew discord](https://discord.gg/C29hYvh) and give them the log file at `gm9/out/title-fixer_log.txt` if the script was able to run.

## Info
A gm9lua script to fix the "missing titles" issue where all installed titles are missing from the home menu, but they still appear normally in the system settings data management. If you get an error in data management, there are X's on titles, titles appear as question marks or black boxes, or the name of a title(s) is wrong, this script will likely make things worse, or do nothing.

There is a bug in the current pre-release version of godmode9 that can cause the script to fail, so this script's release will be packaged together with a version of GM9 that has the bug fixed, until the bug is fixed in the main GM9 release.

It's recommended to backup your sd card before using this script. While the script itself is set to backup data, and only deletes titles that have file issues, unforeseen issues (particularly corruption) can cause data loss. 

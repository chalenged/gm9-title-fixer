local log = ""
local ver = "1.1.0"
local encTitle = ""
local scan = false
local asked = false
local allowed = false
local function L(s) --Simple log function
  log = log.."\n"..s
  print("\n"..s)
  return s
end
local function sleep (a) 
    local sec = tonumber(os.time() + a); 
    while (os.time() < sec) do 
    end 
end
local function trim_addr (str)
  return string.gsub(str, "/*.*title", "title")
end

local function delete_title(str, data)
  str = string.gsub(str, "/*.*title", "A:/title")
  if allowed and not scan then
    local su, re = pcall(fs.list_dir, str.."/content")
    if not su then return L("legit no idea how this happened. Error: "..re) end
    
    for lk, lv in pairs(re) do
      if (string.match(lv.name, ".tmd")) then  --there should only ever be 1 tmd file i think.
        local su, re = pcall(ui.show_game_info, str
.."/content/"..lv.name) --Show title information from the A drive, where it is unencrypted, so the user knows what game/app to deal with specifically. 
        if not su then L("Failed showing game info: "..re) end
        
      end
    end
    if (not ui.ask("Broken title found: "..trim_addr(str).."\nWould you like it deleted for you?\n (If you don't, you must delete/uninstall/reinstall \nit manually.\nDeny and try to backup your save first if\nyou care!)")) then return L("user denied deletion of "..trim_addr(str)..". Deal with it manually, or run the script again.") end --the file path always gets cut-off here, maybe make a wrapping function that checks length of the string and adds a line break?
    data_backup = true
    if (data) then 
      L("data found, attempting to back it up")
      local sd, rd = pcall(fs.copy, str.."/data", GM9OUT.."/fixer_backup/"..trim_addr(str).."/data", {recursive=true, overwrite=true})
      if not sd then 
      data_backup = false
        L("Failed to backup data folder: "..rd)
      else
        L("Data backed up to "..GM9OUT.."/fixer_backup/data!")
      end
    end
    if not data_backup then
      if not ui.ask("Data folder found but was not backed up!\nContinue deletion? (save data might be lost!)") then return L("User denied deletion because failed data backup") end
    end
    L("Deleting "..str.." folder..")
    local suc, res = pcall(fs.remove, str, {recursive=true})
    if not suc then return L("Error deleting folder "..trim_addr(str)..": "..res) end
  else
    L("Broken title found: "..trim_addr(str)..". Deal with it manually, or run this script in standard mode.")
  end
end
local function test_title(str) --ran for every folder in title
  --Checks if there is at least one file in the content/cmd folder (this is generally what is used to determine what folder should be deleted, maybe we should check for other things too?)
  --check for a .ctx file, indicating a title was not properly installed from eshop, as well as a data folder, to backup saves (proper checkpoint backups should still be done if possible)
  local failed = false
  local so, ro = pcall(fs.list_dir, str)
  data = nil
  if not so then return L("Failed checking in folder: "..ro) end
  for lk, lv in pairs(ro) do
    if (string.match(lv.name, ".ctx")) then 
      failed = true 
      L("ctx file found in "..trim_addr(str))
    end
    if (string.match(lv.name, "data")) then data = str.."/data" end
  end
  if not failed then 
    so, ro = pcall(fs.list_dir, str.."/content")
    if not so then return L("Failed checking in content folder: "..ro) end
    local appCount = 0
    for lk, lv in pairs(ro) do
      if (string.match(lv.name, ".app")) then appCount = appCount+1 end
    end
    if appCount == 0 then 
      failed = true
      L("No .app files in "..trim_addr(str).."/content!")
    end
  end
  if not failed then
    local success, cmd = pcall(fs.list_dir, str .. "/content/cmd")
    if not success then
      return "Failed to get content/cmd folder: "..content
    end
    if #cmd == 0 then 
      failed = true 
      L("No cmd files found in "..trim_addr(str).."!")
    end
  end
  if failed then
    delete_title(str, data)
    return 1
  end
  
  return 0
end

local function verify_folder(str) --recursive function to verify all files/folders in path str
  local success, result = pcall(fs.list_dir, str)
  if not success then
    L("Failed listing folder: "..result)
    return 1
  end
  local failCount = 0
  for ik, iv in pairs(result) do
    if iv.type == "dir" then
      failCount = failCount + verify_folder(str.."/"..iv.name)
    else
      if not (string.match(iv.name, ".cmd") or string.match(iv.name, ".sav")) then --cmd and sav don't verify. In gm9 you can verify with the cmac, but I don't think it's scriptable
        local suc, res = pcall(ui.show_game_info, str.."/"..iv.name)
        if not suc then L("Failed showing game info: "..res) end
        if not fs.verify(str.."/"..iv.name) then 
          failCount = failCount+ 1 
          L(str.."/"..iv.name.." failed verification!")
        end
      end
    end
  end
  return failCount
end

local function verify_title(str)
  local failed = false
  local failures = verify_folder(str)
  if failures > 0 then 
    failed = true
    L(tostring(failures).." files failed to verify in "..str)
    delete_title(str)
    return 1
  end
  return 0
end

local function ask_perms(force)
  force = force or false
  if asked == true and force == false then return
  elseif asked == true and force == true and allowed == true then 
    scan = not scan
    
    return
  end
  asked = true
  ui.show_text("To fix titles, you must allow permission\nIf you decline, the script will run in \"scan\" mode\nand will only log broken titles, you will\nhave to deal with them yourself")
  allowed = fs.allow("A:/title/", {opts="ask_all"})
  scan = not allowed
end

local function get_option()
  local opts = {
    "Quick test (Recommended)",
    "Verification test",
    "Toggle scan mode",
    "Exit"
  }
  local scanText = "standard"
  if scan then scanText = "scan" end
  ui.show_text("gm9-title-fixer ver "..ver.."\nRunning in "..scanText.." mode\nSelect an option\n\nQuick is recommended. If it doesn't solve\nor find the issue, run the verification test\nNote: The verification test may take a while,\nespecially if you have a lot of titles!")
  return ui.ask_selection("Choose an option:", opts)
end

local function show_text(str)
  local scanText = "standard"
  if scan then scanText = "scan" end
  ui.show_text("gm9-title-fixer ver "..ver.."\nRunning in "..scanText.." mode\nTesting "..str)
end

local function main()
  --we will need permission to delete things, otherwise run in scan mode
  ask_perms()
  local choice = get_option()
  if choice == nil or choice == 4 then return 0 end
  if choice == 3 then 
    ask_perms(true)
    return 1
  end
  
  if scan then L("Running in scan mode.") else L("Running in standard mode") end
  --simply getting into the id1
  local id0dir = "0:/Nintendo 3DS/"..sys.sys_id0
  local id1 = id0dir
  local successy, id1list = pcall(fs.list_dir, id0dir)
  if not successy then
    return L("Failed to initialize id0! Erorr: "..idlist)
  end
  if (#id1list > 1) then return L("Multiple folders/files in id0! (maybe you have multiple id1, or forgot to remove mset9?)") end --id1 check
  for ik,iv in pairs(id1list) do
      id1 = id1.."/"..iv["name"]
  end
  L("Running in folder "..id1)
  encTitle = id1.."/title" --the other folders in id1 aren't relevant i think
  local success, tidH = pcall(fs.list_dir, encTitle)
  if (not success) then
    return L("Failed getting folders in title:"..tidH)
  end
  --Go through the folders in title (the tid highs)
  local failures = 0
  for ik, iv in pairs(tidH) do
    if (iv.type ~= "dir") then
      return L(trim_addr(iv.name).." in title is not a folder!")
    end
    local suc, tidL = pcall(fs.list_dir, encTitle.."/"..iv.name)
    if (not suc) then
      return L("Error getting directory list from "..trim_addr(encTitle).."/"..iv.name)
    end
    --test each tid low
    for jk, jv in pairs(tidL) do
      if choice == 1 then
        local str = encTitle.."/"..iv.name.."/"..jv.name 
        show_text(str)
        failures = failures + test_title(str)
      elseif choice == 2 then
        local str = string.gsub(encTitle, "/*.*title", "A:/title").."/"..iv.name.."/"..jv.name 
        show_text(str)
        failures = failures + verify_title(str)        
      end
    end
  end
  if failures == 0 then
    L("No broken titles found.")
    if choice == 1 then ui.echo("Test found no broken titles!\nConsider running a verification test\n")
    else ui.echo("Test found no broken titles!\nAsk in the Nintendo Homebrew Discord\nfor help, and send them the log.") end
  else
    if scan then ui.echo("Test encountered "..tostring(failures).." broken titles.\nDeal with them manually.\nCheck the log for details")
    else ui.echo("Test encountered "..tostring(failures).." broken titles.\nAny you didn't have the script delete\n must be manually dealt with.\nCheck the log for details") end
  end
  return 1 --loops
end

--instead of gotos i use the return of the main function to determine if the script failed or succeeded
local result = 1
while result == 1 do
  result = main()
end 
if result == 0 then
  L("Process exited without error.")
  --ui.echo("Process ran without error!")
else
  L("Process exited with error: "..result)
  ui.echo("An error was encountered during operation: \n"..result.."\nCheck the log or send it to someone to check!")
end
log = "Date and Time: "..os.date().."\nVersion "..ver.."\n---\n"..log
local success, res = pcall(fs.write_file, GM9OUT.."/title-fixer_log.txt", "end", log) --append the log file, then ask to show the user
if not success then
  L("Failed to open log file! Error: "..res)
  if (ui.ask("Log write failed! (is your sd locked?)\nWould you like to view the log? \n(it was not saved!")) then
    ui.show_text_viewer(log)
  end
else
  if (ui.ask("Log written to "..GM9OUT.."/title-fixer_log.txt! \nWould you like to view it now?")) then
    ui.show_text_viewer(log)
  end
end
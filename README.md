# "Damage Numbers" Mod for Resident Evil 4 Remake

Mod for Resident Evil 4 Remake that draws Floating Damage Numbers. 

![damage_numbers_2](https://user-images.githubusercontent.com/30152047/233308742-36664886-d310-4c1c-a0de-c4821dc6be5d.png)

# Links
* **[Nexus Mods](https://www.nexusmods.com/residentevil42023/mods/757)**

# Requirements
1. [REFramework](https://www.nexusmods.com/residentevil42023/mods/12) (v1.460 or above);
2. [REFramework Direct2D](https://www.nexusmods.com/residentevil42023/mods/83) (v0.4.0 or above).

# How to install:
1. Install [REFramework](https://www.nexusmods.com/residentevil42023/mods/12);
2. (Optionally) Install [REFramework Direct2D](https://www.nexusmods.com/residentevil42023/mods/83);
3. Download the mod:
    * Official release can be downloaded from [Nexus Mods](https://www.nexusmods.com/residentevil42023/mods/84);
    * Nightly builds are available in [this repo](https://github.com/GreenComfyTea/RE4-Health-Bars) and can contain broken functionality, debugging info on screen, bugs and might require the latest [nightly build](https://github.com/praydog/REFramework-nightly/releases) of [REFramework](https://www.nexusmods.com/residentevil42023/mods/12). Use with caution!
4. Extract the mod from the archive and place it in Resident Evil 4 folder. Final path should look like this: `/RESIDENT EVIL 4  BIOHAZARD RE4/reframework/autorun/Damage_Numbers.lua`

# How to compile?
**Prerequisites:**
+ [lua-amalg](https://github.com/siffiejoe/lua-amalg)    
+ [Lua 5.4+](https://www.lua.org/)  

**Example compilation command (replace the paths to `lua54.exe`, `amalg.lua` and `Damage_Numbers.lua` to yours):**

`"D:\Programs\Lua Amalg\lua54.exe" "D:\Programs\Lua Amalg\amalg.lua" -o Damage_Numbers_precompiled.lua -d -s "E:\GitHub\RE4-Damage-Numbers\reframework\autorun\Damage_Numbers.lua" Damage_Numbers.config Damage_Numbers.customization_menu Damage_Numbers.drawing Damage_Numbers.keyframe_customization Damage_Numbers.keyframe_handler Damage_Numbers.label_customization  Damage_Numbers.screen Damage_Numbers.singletons Damage_Numbers.time Damage_Numbers.utils Damage_Numbers.player_handler Damage_Numbers.gui_handler Damage_Numbers.damage_handler`

# Credits
**GreenComfyTea** - creator of the mod and it's main contributor.
  
***
# Support

You can support me by donating! I would appreciate it! But anyway, thank you for using this mod!

 <a href="https://streamelements.com/greencomfytea/tip">
  <img alt="Qries" src="https://panels.twitch.tv/panel-48897356-image-c6155d48-b689-4240-875c-f3141355cb56">
</a>
<a href="https://ko-fi.com/greencomfytea">
  <img alt="Qries" src="https://panels.twitch.tv/panel-48897356-image-c2fcf835-87e4-408e-81e8-790789c7acbc">
</a>


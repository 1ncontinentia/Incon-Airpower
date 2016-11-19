# INC_airpower

Script package for Arma 3 mission makers that allows players to call in air support for target tracking and air strikes. 
Unlike other CAS scripts, Incon Airpower simulates high-altitude strikes where the aircraft is neither visible nor audible from the ground. 
The aicraft itself is not spawned, only simulated. 
Ideal for single player and low-player-count COOP (lots of players using tracking may cause considerable server lag). 


Features:

* Optional unit tracking on map, with accuracy that degrades with overhead cover, weather etc. (only shows targets that would be visible from overhead).
* Call in guided airstrikes with the radio menu. 
* Mark targets with laser, smoke, chemlights or IR strobes (night only for chemlights and strobes). 
* Missiles and bombs will track their targets (thanks to a slightly modified version of kylania's awesome guided missile script).
* Aircraft can lock on to and track vehicles, infantry etc if they are detected near the target mark and the player chooses. 
* Optional collateral damage assesment by pilot - checks for nearby friendlies, civilians and sensitive targets and will automatically disengage if collateral damage is deemed too high
* If using a laser designator, the player can mark multiple targets at once and give clearance for a simultaneaous strike
 - mark 2 tanks and an infantry patrol, and the aircraft will track and engage those targets simultaneously, even if they move
 - repeat your last mark if in doubt
 - if your final target is a laser mark, the aircraft will engage your laser mark while it is active, and revert to your original mark position if it looses your laser mark
* Realistic air speeds of ordnance 
 - the higher the altitude of the aircraft (recommended at least 3000m), the longer the ordnance will take to hit the target
 - missiles will travel faster than bombs
* No need for map with airstrip or adding in any aircraft
* Restrict JTAC capabilities to units with certain items in their inventory


### Usage

1. Place "INC_airpower" folder into your mission root folder. 
2. If you have no description.ext, place that into your mission root folder too. Otherwise, add the lines from this file into your mission's description.ext. 
3. Open the "APW_setup.sqf" file and configure the settings to your liking. 
4. In the init of the object you want players to call air support from (including players themselves), write:

    this addaction ["Request air support","INC_airpower\scripts\airpowerSpawn.sqf",[],1,false,true,"","!(missionNamespace getVariable ['APW_airAssetRequested',false])"];

5. Call air support using radio Charlie. 
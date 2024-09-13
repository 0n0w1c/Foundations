![red-black](https://github.com/0n0w1c/Foundations/blob/main/graphics/screenshots/red-black.png?raw=true)  
A [demo](https://drive.google.com/file/d/1HhUQe3d0-JM2_g1sDUhMwH2XuVyj-mB4/view?usp=drive_link) of tile placement and a [demo](https://drive.google.com/file/d/1-Q80DSgyIuHM7wrxrbzyDSqme0gMSsAz/view?usp=drive_link) showing some of the selection tools in action.  
Note: These links will redirect you to the videos hosted on Google Drive.

With the Foundations button, you can disable the placement of foundation tiles or select the tile of your choice.  
You can also enable the available selection based tools by:  

| Key + Mouse-click       | Tool    | Effect                            |
| :---------------------- | :------ | :-------------------------------- |
| *[Ctrl]+[Left-click]*   | Fill    | Places tiles on open positions    |
| *[Shift]+[Left-click]*  | Unfill  | Removes tiles from open positions |
| *[Ctrl]+[Right-click]*  | Place   | Places tiles under entities       |
| *[Shift]+[Right-click]* | Unplace | Removes tiles from under entities |

Startup setting to select the tile mining time (default = 0.1).  
Startup setting to clean sweep (remove ground decorations), when tiles are placed.  
Startup setting for the number of rows to add to the player inventory size.

Startup settings to change the [layering order](https://mods.factorio.com/mod/Foundations/faq), higher numbers layer on top of lower numbers.  
Tiles assigned with the same number, merge rather than layer.  
If Alien Biomes is active, settings for layering the painted refined concretes are not available.  
If Dectorio is active, this mod will utilize the provided painted refined concrete.  
Otherwise, if the startup setting is enabled, this mod will supply the painted refined concrete.  

A runtime setting for each tile, allows you to limit the selections available for the Foundations button,  
to create a "palatte" of tiles for quick selection.  
Dectorio users should visit the runtime settings (Map tab), most of the Dectorio tiles are not selected by default.  

Runtime settings to exclude small/medium electric poles, inserters, and belts, splitters, and loaders.  

Settings for the various supported mods are only visible when the supported mod is active.  

Attempts to build without the required number of foundation tiles in the player inventory, will be halted.  
Make sure to have enough of the selected foundation tiles in your inventory, or disable foundation tile placement.  

Foundations is compatible with personal logistics for construction and deconstruction.  

#### Limitations:  
Tiles placed or removed with the selection tools are not "Undo"-able, use them with some caution.  
Not compatible with multi-player mode, single-player mode only.  

#### Supported:
[AAI Industry](https://mods.factorio.com/mod/aai-industry)  
[Dectorio](https://mods.factorio.com/mod/Dectorio)  
[Industrial Revolution 3](https://mods.factorio.com/mod/IndustrialRevolution3)  
[Krastorio 2](https://mods.factorio.com/mod/Krastorio2)  
[Picker Dollies](https://mods.factorio.com/mod/PickerDollies)  

# PaperBoat
*Port of Paper Mario 64 for Nintendo Switch*

# Quick Start

PaperBoat does not include any copyrighted assets.  You are required to provide a supported copy of the game.

### 1. Verify your ROM dump
US SHA1 Hash: `3837f44cda784b466c9a2d99df70d77c322b97a0`
You can verify you have dumped a supported copy of the game by using the compatibility checker at https://paperboat.equipment/.

### 2. Download PaperBoat from [Releases](https://github.com/CypherNoodle/PaperBoat/releases)

### 3. Launch the Game!
* #### Nintendo Switch
* Extract the zip
* Copy the folder `paperboat` to `sdmc:/switch/`
* Generate `pm64.o2r` using the matching PaperBoat desktop version and your own supported ROM, then put it in `sdmc:/switch/paperboat/`
* Launch `paperboat.nro`

### 4. Play!

Congratulations, you are now sailing with PaperBoat! Have fun!

# Configuration

### Default gamepad configuration
| N64 | A | B | L | R | Z | Start | Analog stick | C buttons | D-Pad |
| - | - | - | - | - | - | - | - | - | - |
| JoyCon | A | B | LB | RT | LT | + | Left Stick | Right Stick | D-Pad |

### Graphics Backends
Currently, rendering APIs supported: OpenGL (Zink).

# Custom Assets

Custom assets are packed in `.o2r` or `.otr` files. To use custom assets, place them in the `mods` folder.

If you're interested in creating and/or packing your own custom asset `.o2r`/`.otr` files, check out the following tools:
* [**retro - OTR and O2R generator**](https://github.com/HarbourMasters64/retro)
* [**fast64 - Blender plugin (Note that PM64 is not fully supported at this time)**](https://github.com/HarbourMasters/fast64)

# Development

### Building
If you want to manually compile PaperBoat, please consult the [building instructions](docs/BUILDING.md).

### Playtesting
If you want to playtest a continuous integration build, you can find them at the links below. Keep in mind that these are for playtesting only, and you will likely encounter bugs and possibly crashes.

* [Windows](https://nightly.link/HarbourMasters/PaperBoat/workflows/build/develop/Paperboat-windows.zip)
* [macOS](https://nightly.link/HarbourMasters/PaperBoat/workflows/build/develop/Paperboat-mac.zip)
* [Linux](https://nightly.link/HarbourMasters/PaperBoat/workflows/build/develop/Paperboat-linux.zip)

<a href="https://github.com/Kenix3/libultraship/">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="./docs/poweredbylus.darkmode.png">
    <img alt="Powered by libultraship" src="./docs/poweredbylus.lightmode.png">
  </picture>
</a>

# Special Thanks:

This wouldn't have been possible without your amazing work:

* [The Paper Mario decomp team](https://github.com/pmret/papermario)
* [The Paper Mario DX team](https://github.com/bates64/papermario-dx)

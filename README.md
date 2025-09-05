# 📚 Enigma Escape

A psychological horror visual novel built in Godot 4, focusing on family dynamics and mysterious events in a small town.

## 👥 **Team Members**
- [Surya Nandeesh] - Lead Developer
- [Felipe Gonzales] - Lead Artist (not AI)

## 📸 **Screenshots**
![Main Menu](screenshots/main_menu.png)
*Main menu interface with modern design*

![Game World](screenshots/game_world.png)
*In-game dialogue system with character portraits*

![Settings](screenshots/settings.png)
*Settings menu with customizable options*

**Note:** To add screenshots, create a `screenshots` directory and add your game screenshots there.

## 🌟 **Key Features**

### 📖 **Visual Novel System**
- Rich character dialogue and interactions
- Character portraits that appear during conversations
- Dialogue box that can be hidden with the "H" key
- Multiple dialogue paths for each character

### 💾 **Complete Save/Load System**
- Multi-slot save system (5 slots)
- JSON-based save files with comprehensive game state
- Quick save/load with F5/F9 keys
- Delete save functionality

### ⚙️ **Settings System**
- Audio and graphics options
- Real-time settings application
- Persistent configuration storage

### 🎯 **Enhanced Menu System**
- Clean, modern main menu design
- Save slot information display
- Seamless scene transitions
- Content warning splash screen

## 🚀 **Installation & Setup**

### **Prerequisites**
- [Godot 4.x](https://godotengine.org/download) (4.0 or higher)
- Basic understanding of GDScript (for development)
- 2GB RAM minimum
- Graphics card with OpenGL 3.3 / OpenGL ES 3.0 support

### **Installation Steps**
1. Download and install Godot 4.x from [godotengine.org](https://godotengine.org/download)
2. Clone this repository:
   ```bash
   git clone https://github.com/[your-username]/godot-horror-game.git
   ```
3. Open Godot Engine
4. Click "Import" and navigate to the downloaded project folder
5. Select the `project.godot` file
6. Click "Import & Edit"
7. Press F5 or click the "Play" button to run the game

### **Controls**
- **M/ESC**: Toggle pause menu
- **H**: Toggle dialogue box visibility
- **F5**: Quick save
- **F9**: Quick load
- **Mouse**: Navigate UI and make selections

## 🎭 **Characters**

### **Family Members**
- **Daughter**: Strong exterior but vulnerable inside
- **Brother**: College student dealing with past mistakes
- **Mother**: Mysterious past she won't discuss
- **Father**: Hardworking farmer trying to keep family together
- **Shopkeeper**: Enigmatic figure with knowledge of the town's history

## 🏗️ **Technical Architecture**

### **Core Systems**
- **CharacterManager**: Manages character dialogue and interactions
- **NovelManager**: Handles visual novel flow and UI
- **SaveSystem**: Multi-slot save/load functionality
- **SettingsSystem**: Config file-based settings management

### **Scene Structure**
- `splash.tscn` - Content warning screen
- `main_menu.tscn` - Main menu with save management
- `game_world.tscn` - Main game interface
- `settings_scene.tscn` - Settings menu
- `visual_novel.tscn` - Story progression system

## 📁 **File Structure**

```
godot-horror-game/
├── scenes/
│   ├── splash.tscn            # Content warning screen
│   ├── main_menu.tscn        # Main menu
│   ├── game_world.tscn       # Main game interface
│   ├── settings_scene.tscn   # Settings menu
│   └── visual_novel.tscn     # Story system
├── scripts/
│   ├── character_manager.gd  # Character interactions
│   ├── novel_manager.gd      # Visual novel system
│   ├── game_world.gd         # Main world
│   ├── main_menu.gd         # Menu system
│   ├── splash.gd            # Splash screen
│   ├── save_system.gd       # Save/load functionality
│   └── settings_system.gd   # Settings management
└── project.godot            # Project configuration
```

## 🎵 **Credits**

### **Music**
- Dark despair guitar vibe by NomisYlad -- https://freesound.org/s/822772/ -- License: Attribution 4.0

## 🔮 **Future Enhancements**

### **Planned Features**
- **Branching Dialogue**: Multiple story paths
- **Character Expressions**: More portrait variations
- **Background Transitions**: Smooth scene changes
- **Sound Effects**: Enhanced audio experience

## 📝 **Contributing**
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 **License**
This project is licensed under the [LICENSE] - see the LICENSE file for details.

---

**Note**: This game focuses on psychological horror through storytelling rather than combat or action elements. The visual novel format allows for deep character development and atmospheric storytelling.

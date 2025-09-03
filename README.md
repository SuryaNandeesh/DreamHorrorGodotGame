# 📚 Visual Novel Horror Game

A psychological horror visual novel built in Godot 4, focusing on family dynamics and mysterious events in a small town.

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

### ⌨️ **Menu Controls**
- Press **M** or **ESC** key to toggle pause menu
- Hide dialogue with **H** key
- Game pauses when menu is open

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

### **Key Scripts**
- `character_manager.gd` - Character dialogue and interactions
- `novel_manager.gd` - Visual novel system
- `game_world.gd` - Main game world
- `main_menu.gd` - Menu system with save management
- `splash.gd` - Splash screen with fade transitions

## 🚀 **Getting Started**

### **Prerequisites**
- Godot 4.x
- Basic understanding of GDScript

### **Installation**
1. Clone or download the project
2. Open in Godot 4.x
3. Run the project

### **Controls**
- **M/ESC**: Toggle pause menu
- **H**: Toggle dialogue box visibility
- **F5**: Quick save
- **F9**: Quick load
- **Mouse**: Navigate UI and make selections

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

## 🎭 **Story Elements**

### **Character Interactions**
- Deep, meaningful conversations with family members
- Each character has unique dialogue paths
- Personal and casual conversation options
- Rich character backgrounds and personalities

### **Dialogue System**
- Clean, modern dialogue box design
- Character portraits appear during conversations
- Option to hide dialogue box for better immersion
- Random dialogue variation for replayability

## 🔮 **Future Enhancements**

### **Planned Features**
- **Branching Dialogue**: Multiple story paths
- **Character Expressions**: More portrait variations
- **Background Transitions**: Smooth scene changes
- **Sound Effects**: Enhanced audio experience

### **Modding Support**
- **Character Creation**: Easy addition of new characters
- **Story Expansion**: Modular dialogue system
- **Custom Backgrounds**: Support for new locations
- **Translation Support**: Easy localization

## 📝 **Development Notes**

### **Key Design Decisions**
- **Visual Novel Focus**: Pure storytelling experience
- **Modern UI**: Clean, intuitive interface
- **Save System**: Flexible multi-slot system
- **Character Design**: Deep, complex personalities

### **Technical Considerations**
- **System Integration**: Seamless component interaction
- **Performance**: Efficient resource management
- **Scalability**: Easy content addition
- **Maintainability**: Clear code structure

## 🎉 **Conclusion**

This visual novel creates an immersive horror experience through storytelling and character interaction. The focus on narrative and atmosphere, combined with modern UI design and robust save system, provides players with an engaging and memorable experience.

## **CREDIT FOR MUSIC**
---
Dark despair guitar vibe by NomisYlad -- https://freesound.org/s/822772/ -- License: Attribution 4.0

**Note**: This game focuses on psychological horror through storytelling rather than combat or action elements. The visual novel format allows for deep character development and atmospheric storytelling.

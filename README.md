# 🎮 Horror Game - Turn-Based Combat & Story System

A psychological horror game built in Godot 4 with a unique turn-based combat system that only becomes available when the player's sanity drops below 3% and they're alone with a character.

## 🌟 **Key Features**

### 🧠 **Psychological Horror Combat System**
- **Combat Unlock Condition**: Combat only becomes available when player sanity drops below **3%**
- **Isolation Requirement**: Must be alone with a character (no other characters nearby)
- **Mental Breakdown Mechanic**: Combat represents the player's psychological breakdown
- **5 Unique Opponents**: Daughter, Brother, Mother, Father, and Mysterious Shopkeeper

### 💾 **Complete Save/Load System**
- JSON-based save files with comprehensive game state
- Player stats, story progress, character relationships, and sanity tracking
- Quick save/load with F5/F9 keys
- Auto-save functionality (configurable)

### ⚙️ **Comprehensive Settings System**
- Audio, graphics, gameplay, and accessibility options
- Real-time settings application
- Persistent configuration storage
- Horror intensity and difficulty controls

### 🎯 **Enhanced Main Menu & Navigation**
- Dynamic combat button that shows availability status
- Save file information display
- Seamless scene transitions
- Character relationship overview

### ⌨️ **M Key Menu Toggle**
- Press **M** key at any time outside of combat
- In-game menu with resume, settings, save/load options
- ESC key alternative
- Game pause when menu is open

## 🎮 **How Combat Works**

### **Combat Availability Requirements**
1. **Sanity Threshold**: Player sanity must be below **3%**
2. **Isolation**: Must be alone with the target character
3. **Location**: Must be in a location where combat can occur

### **Combat Mechanics**
- **Turn-Based System**: Speed-based turn order
- **Player Actions**: Attack, Special Attack, Defend, Use Item
- **Character Stats**: Each family member has unique abilities
- **Experience System**: Gain XP and level up through combat
- **Psychological Element**: Combat represents mental breakdown

### **Character Combat Profiles**

| Character | Health | Attack | Defense | Speed | Special Ability |
|-----------|--------|--------|---------|-------|-----------------|
| **Daughter** | 120 | 25 | 15 | 18 | Needle Storm (40 dmg) |
| **Brother** | 100 | 20 | 10 | 20 | Reckless Charge (35 dmg) |
| **Mother** | 90 | 18 | 20 | 12 | Hidden Weapon (45 dmg) |
| **Father** | 150 | 30 | 25 | 10 | Farm Strength (50 dmg) |
| **Shopkeeper** | 80 | 22 | 8 | 25 | Dark Magic (60 dmg) |

## 🏗️ **Technical Architecture**

### **Core Systems**
- **CombatManager**: Handles combat logic and availability checks
- **CharacterManager**: Manages character locations, isolation, and dialogue
- **SanitySystem**: Tracks player mental state
- **SaveSystem**: JSON-based save/load functionality
- **SettingsSystem**: Config file-based settings management

### **Scene Structure**
- `main_menu.tscn` - Main menu with dynamic combat button
- `game_world.tscn` - Main game interface with sanity tracking
- `combat_scene.tscn` - Turn-based combat arena
- `settings_scene.tscn` - Comprehensive settings menu
- `visual_novel.tscn` - Story progression system

### **Key Scripts**
- `combat_manager.gd` - Combat logic and availability checking
- `character_manager.gd` - Character isolation and combat initiation
- `novel_manager.gd` - Story system with combat integration
- `game_world.gd` - Main game world with sanity-based combat access
- `main_menu.gd` - Dynamic menu with combat availability

## 🚀 **Getting Started**

### **Prerequisites**
- Godot 4.x
- Basic understanding of GDScript

### **Installation**
1. Clone or download the project
2. Open in Godot 4.x
3. Run the project

### **Controls**
- **M Key**: Toggle in-game menu
- **ESC**: Alternative menu toggle
- **F5**: Quick save
- **F9**: Quick load
- **Mouse**: Navigate UI and make selections

## 🎯 **Game Progression**

### **Normal Gameplay**
1. **Start Game**: Begin with 50% sanity
2. **Explore Story**: Interact with family members
3. **Build Relationships**: Develop character connections
4. **Maintain Sanity**: Keep mental state above 3%

### **Combat Unlock Process**
1. **Sanity Drops**: Experience story events that reduce sanity
2. **Isolation**: Find yourself alone with a character
3. **Combat Option**: Red "Attack" button appears in dialogue
4. **Enter Combat**: Transition to turn-based combat arena

### **Combat Strategy**
- **Speed Management**: Higher speed means more turns
- **Defense Timing**: Use defend strategically
- **Special Attacks**: Save for critical moments
- **Item Usage**: Heal when health is low

## 🔧 **System Integration**

### **Sanity System Integration**
- Combat availability tied to sanity percentage
- Dynamic UI updates based on mental state
- Story progression affects sanity levels

### **Character Location Tracking**
- Real-time character position monitoring
- Isolation detection for combat availability
- Dynamic relationship updates

### **Save System Integration**
- Combat progress saved automatically
- Character relationships preserved
- Sanity levels maintained between sessions

## 📁 **File Structure**

```
godot-horror-game/
├── scenes/
│   ├── main_menu.tscn          # Main menu with combat button
│   ├── game_world.tscn         # Main game interface
│   ├── combat_scene.tscn       # Combat arena
│   ├── settings_scene.tscn     # Settings menu
│   └── visual_novel.tscn       # Story system
├── scripts/
│   ├── combat_manager.gd       # Combat logic & availability
│   ├── character_manager.gd    # Character isolation & combat
│   ├── novel_manager.gd        # Story with combat integration
│   ├── game_world.gd           # Main world with sanity tracking
│   ├── main_menu.gd            # Dynamic menu system
│   ├── save_system.gd          # Save/load functionality
│   └── settings_system.gd      # Settings management
└── project.godot               # Project configuration
```

## 🎭 **Psychological Horror Elements**

### **Combat as Mental Breakdown**
- Combat represents psychological deterioration
- Only available at extremely low sanity (below 3%)
- Isolation requirement emphasizes psychological vulnerability
- Family members become combat opponents in mental state

### **Sanity-Based Story Progression**
- Different dialogue options based on mental state
- Character behavior changes with sanity levels
- Story paths unlock based on psychological state
- Combat becomes a manifestation of mental illness

## 🔮 **Future Enhancements**

### **Planned Features**
- **Dynamic Character AI**: Characters respond to player actions
- **Environmental Storytelling**: Location-based sanity effects
- **Multiple Endings**: Based on combat choices and sanity
- **Advanced Combat Mechanics**: Status effects and combos

### **Modding Support**
- **Character Creation**: Easy addition of new family members
- **Story Expansion**: Modular story system
- **Combat Balancing**: Configurable difficulty settings
- **Custom Sanity Effects**: Player-defined psychological elements

## 📝 **Development Notes**

### **Key Design Decisions**
- **Combat Lock**: Prevents combat from being the primary gameplay
- **Isolation Mechanic**: Ensures psychological vulnerability
- **Sanity Threshold**: Creates meaningful progression gates
- **Family Opponents**: Subverts expectations and creates horror

### **Technical Considerations**
- **System Integration**: All systems work together seamlessly
- **Performance**: Efficient character location tracking
- **Scalability**: Easy to add new characters and locations
- **Maintainability**: Clear separation of concerns

## 🎉 **Conclusion**

This horror game creates a unique psychological experience where combat represents mental breakdown rather than traditional gameplay. The 3% sanity threshold and isolation requirement ensure that combat is a rare, meaningful event that players must work towards through story progression and psychological deterioration.

The integrated systems provide a cohesive experience where every element works together to create an immersive horror atmosphere. Players must balance their mental state while exploring the story, with combat becoming available only when they've reached their psychological breaking point.

---

**Note**: This system creates a psychological horror experience where combat is not the goal but rather a consequence of mental deterioration. Players who maintain high sanity will never see combat, while those who explore darker story paths will eventually unlock this disturbing gameplay element. 

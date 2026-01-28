import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class SeekFindGameScreen extends StatefulWidget {
  const SeekFindGameScreen({super.key});

  @override
  State<SeekFindGameScreen> createState() => _SeekFindGameScreenState();
}

class _SeekFindGameScreenState extends State<SeekFindGameScreen> {
  final FlutterTts _tts = FlutterTts();
  late ConfettiController _confettiController;

  int _currentLevel = 0;
  int _score = 0;
  Set<String> _foundItems = {};
  Set<String> _circledItems = {};

  final List<SeekFindLevel> _levels = [
    // Level 1: Morning Time - Bedroom scene
    SeekFindLevel(
      title: 'Morning Time',
      instruction: 'Find: a pillow, a star, a bulb, an alarm clock, a window and a cloud',
      type: LevelType.findItems,
      backgroundColor: const Color(0xFF87CEEB),
      sceneWidgets: [
        // Background - Wall
        SceneWidget(emoji: '', x: 0, y: 0, size: 0, isBackground: true, bgColor: Color(0xFF6B8E9F)),
        // Floor
        SceneWidget(emoji: '', x: 0, y: 0.75, size: 0, isBackground: true, bgColor: Color(0xFFE8DCC8), height: 0.25),
      ],
      itemsToFind: ['Pillow', 'Star', 'Bulb', 'Clock', 'Window', 'Cloud'],
      allItems: [
        // Window with sunlight
        GameItem(emoji: '🪟', name: 'Window', x: 0.5, y: 0.12, size: 70, isTarget: true),
        // Cloud outside window
        GameItem(emoji: '☁️', name: 'Cloud', x: 0.35, y: 0.08, size: 35, isTarget: true),
        // Sun
        GameItem(emoji: '🌞', name: 'Sun', x: 0.85, y: 0.05, size: 60, isTarget: false),
        // Lamp/Bulb hanging
        GameItem(emoji: '💡', name: 'Bulb', x: 0.5, y: 0.22, size: 40, isTarget: true),
        // Globe on nightstand
        GameItem(emoji: '🌍', name: 'Globe', x: 0.78, y: 0.32, size: 45, isTarget: false),
        // Bed
        GameItem(emoji: '🛏️', name: 'Bed', x: 0.5, y: 0.5, size: 120, isTarget: false),
        // Boy in bed
        GameItem(emoji: '👦', name: 'Boy', x: 0.45, y: 0.38, size: 55, isTarget: false),
        // Pillow
        GameItem(emoji: '🛋️', name: 'Pillow', x: 0.32, y: 0.42, size: 45, isTarget: true),
        // Star on blanket
        GameItem(emoji: '⭐', name: 'Star', x: 0.55, y: 0.52, size: 30, isTarget: true),
        // Alarm clock
        GameItem(emoji: '⏰', name: 'Clock', x: 0.82, y: 0.45, size: 35, isTarget: true),
        // Teddy bear
        GameItem(emoji: '🧸', name: 'Teddy', x: 0.15, y: 0.62, size: 55, isTarget: false),
        // Blocks/toys
        GameItem(emoji: '🧱', name: 'Blocks', x: 0.25, y: 0.72, size: 35, isTarget: false),
        // Basketball
        GameItem(emoji: '🏀', name: 'Ball', x: 0.38, y: 0.75, size: 40, isTarget: false),
        // ABC blocks
        GameItem(emoji: '🔤', name: 'ABC', x: 0.55, y: 0.78, size: 35, isTarget: false),
        // Backpack
        GameItem(emoji: '🎒', name: 'Bag', x: 0.72, y: 0.68, size: 45, isTarget: false),
        // Racket
        GameItem(emoji: '🏸', name: 'Racket', x: 0.68, y: 0.75, size: 35, isTarget: false),
      ],
    ),

    // Level 2: Family Picnic scene
    SeekFindLevel(
      title: 'Family Picnic',
      instruction: 'Find: a glass of juice, a watermelon, a mouse, a cat, a yacht and a toothbrush',
      type: LevelType.findItems,
      backgroundColor: const Color(0xFF87CEEB),
      sceneWidgets: [
        // Sky
        SceneWidget(emoji: '', x: 0, y: 0, size: 0, isBackground: true, bgColor: Color(0xFF87CEEB)),
        // Water/Lake
        SceneWidget(emoji: '', x: 0, y: 0.25, size: 0, isBackground: true, bgColor: Color(0xFF4FC3F7), height: 0.15),
        // Grass
        SceneWidget(emoji: '', x: 0, y: 0.4, size: 0, isBackground: true, bgColor: Color(0xFF7CB342), height: 0.6),
      ],
      itemsToFind: ['Juice', 'Watermelon', 'Mouse', 'Cat', 'Yacht', 'Toothbrush'],
      allItems: [
        // Sun
        GameItem(emoji: '🌅', name: 'Sunset', x: 0.5, y: 0.1, size: 80, isTarget: false),
        // Yacht/Sailboat
        GameItem(emoji: '⛵', name: 'Yacht', x: 0.5, y: 0.28, size: 40, isTarget: true),
        // Trees
        GameItem(emoji: '🌳', name: 'Tree', x: 0.08, y: 0.35, size: 60, isTarget: false),
        GameItem(emoji: '🌳', name: 'Tree2', x: 0.92, y: 0.38, size: 55, isTarget: false),
        GameItem(emoji: '🌿', name: 'Bush', x: 0.2, y: 0.42, size: 40, isTarget: false),
        GameItem(emoji: '🌿', name: 'Bush2', x: 0.8, y: 0.45, size: 40, isTarget: false),
        // Mom
        GameItem(emoji: '👩', name: 'Mom', x: 0.35, y: 0.48, size: 50, isTarget: false),
        // Dad
        GameItem(emoji: '👨', name: 'Dad', x: 0.65, y: 0.48, size: 50, isTarget: false),
        // Kids
        GameItem(emoji: '👦', name: 'Boy', x: 0.25, y: 0.62, size: 45, isTarget: false),
        GameItem(emoji: '👧', name: 'Girl', x: 0.75, y: 0.65, size: 40, isTarget: false),
        // Picnic basket
        GameItem(emoji: '🧺', name: 'Basket', x: 0.5, y: 0.55, size: 45, isTarget: false),
        // Picnic blanket items
        GameItem(emoji: '🧃', name: 'Juice', x: 0.42, y: 0.62, size: 30, isTarget: true),
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.55, y: 0.65, size: 40, isTarget: true),
        GameItem(emoji: '🥪', name: 'Sandwich', x: 0.7, y: 0.72, size: 30, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.35, y: 0.7, size: 25, isTarget: false),
        GameItem(emoji: '🍐', name: 'Pear', x: 0.45, y: 0.72, size: 25, isTarget: false),
        GameItem(emoji: '🍓', name: 'Strawberry', x: 0.6, y: 0.75, size: 25, isTarget: false),
        // Mouse
        GameItem(emoji: '🐭', name: 'Mouse', x: 0.18, y: 0.72, size: 30, isTarget: true),
        // Cat
        GameItem(emoji: '🐱', name: 'Cat', x: 0.5, y: 0.82, size: 45, isTarget: true),
        // Toothbrush (hidden)
        GameItem(emoji: '🪥', name: 'Toothbrush', x: 0.62, y: 0.58, size: 22, isTarget: true),
        // Flowers
        GameItem(emoji: '🌼', name: 'Flower', x: 0.85, y: 0.85, size: 25, isTarget: false),
        GameItem(emoji: '🌸', name: 'Flower2', x: 0.15, y: 0.88, size: 25, isTarget: false),
      ],
    ),

    // Level 3: Farmer - Related Objects
    SeekFindLevel(
      title: 'Related Objects',
      instruction: 'Choose the correct objects that relate to the farmer',
      type: LevelType.relatedObjects,
      backgroundColor: const Color(0xFFF5F5F5),
      sceneWidgets: [],
      itemsToFind: ['Watering Can', 'Shovel', 'Boots', 'Hat', 'Bucket', 'Gloves', 'Wheelbarrow', 'Fork', 'Seeds', 'Seedlings'],
      allItems: [
        // Top row
        GameItem(emoji: '🧹', name: 'Broom', x: 0.12, y: 0.12, size: 50, isTarget: false),
        GameItem(emoji: '🥣', name: 'Mixer', x: 0.3, y: 0.1, size: 45, isTarget: false),
        GameItem(emoji: '🚿', name: 'Watering Can', x: 0.5, y: 0.1, size: 50, isTarget: true),
        GameItem(emoji: '🪏', name: 'Shovel', x: 0.7, y: 0.12, size: 45, isTarget: true),
        GameItem(emoji: '🏐', name: 'Ball', x: 0.88, y: 0.1, size: 40, isTarget: false),

        // Second row
        GameItem(emoji: '🪴', name: 'Shovel2', x: 0.1, y: 0.28, size: 45, isTarget: true),
        GameItem(emoji: '🕶️', name: 'Glasses', x: 0.25, y: 0.3, size: 40, isTarget: false),
        GameItem(emoji: '🥾', name: 'Boots', x: 0.85, y: 0.28, size: 50, isTarget: true),

        // Farmer in center
        GameItem(emoji: '🧑‍🌾', name: 'Farmer', x: 0.5, y: 0.42, size: 90, isTarget: false),

        // Seedlings
        GameItem(emoji: '🌱', name: 'Seedlings', x: 0.82, y: 0.45, size: 45, isTarget: true),

        // Third row
        GameItem(emoji: '🧯', name: 'Extinguisher', x: 0.12, y: 0.48, size: 45, isTarget: false),
        GameItem(emoji: '💉', name: 'Syringe', x: 0.85, y: 0.58, size: 40, isTarget: false),

        // Bottom area
        GameItem(emoji: '👒', name: 'Hat', x: 0.2, y: 0.65, size: 50, isTarget: true),
        GameItem(emoji: '🪣', name: 'Bucket', x: 0.1, y: 0.82, size: 50, isTarget: true),
        GameItem(emoji: '🍴', name: 'Fork', x: 0.28, y: 0.78, size: 45, isTarget: true),
        GameItem(emoji: '🌰', name: 'Seeds', x: 0.18, y: 0.92, size: 35, isTarget: true),

        // Wheelbarrow area
        GameItem(emoji: '🛒', name: 'Wheelbarrow', x: 0.6, y: 0.78, size: 55, isTarget: true),
        GameItem(emoji: '🧤', name: 'Gloves', x: 0.85, y: 0.85, size: 45, isTarget: true),

        // Wrong items
        GameItem(emoji: '🧵', name: 'Thread', x: 0.72, y: 0.62, size: 35, isTarget: false),
      ],
    ),

    // Level 4: So Many Ducklings - Farm scene
    SeekFindLevel(
      title: 'So Many Ducklings',
      instruction: 'Look at the picture and encircle all the ducklings',
      type: LevelType.findAll,
      backgroundColor: const Color(0xFF8BC34A),
      sceneWidgets: [
        // Sky
        SceneWidget(emoji: '', x: 0, y: 0, size: 0, isBackground: true, bgColor: Color(0xFF87CEEB), height: 0.3),
        // Grass
        SceneWidget(emoji: '', x: 0, y: 0.3, size: 0, isBackground: true, bgColor: Color(0xFF7CB342), height: 0.45),
        // Pond
        SceneWidget(emoji: '', x: 0.1, y: 0.75, size: 0, isBackground: true, bgColor: Color(0xFF4FC3F7), height: 0.25, width: 0.8, isOval: true),
      ],
      itemsToFind: ['Duckling'],
      allItems: [
        // Horse
        GameItem(emoji: '🐴', name: 'Horse', x: 0.12, y: 0.18, size: 55, isTarget: false),
        // Tree
        GameItem(emoji: '🌳', name: 'Tree', x: 0.4, y: 0.15, size: 70, isTarget: false),
        // Barn
        GameItem(emoji: '🏠', name: 'Barn', x: 0.85, y: 0.12, size: 60, isTarget: false),
        // Hay
        GameItem(emoji: '🌾', name: 'Hay', x: 0.75, y: 0.25, size: 40, isTarget: false),
        // Fence
        GameItem(emoji: '🚧', name: 'Fence', x: 0.5, y: 0.38, size: 120, isTarget: false),

        // Ducklings scattered around
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.2, y: 0.32, size: 35, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.35, y: 0.35, size: 32, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.7, y: 0.3, size: 30, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.82, y: 0.38, size: 32, isTarget: true),

        // Mother duck
        GameItem(emoji: '🦆', name: 'Mother Duck', x: 0.65, y: 0.52, size: 55, isTarget: false),

        // More ducklings near mother
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.55, y: 0.55, size: 30, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.75, y: 0.58, size: 32, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.45, y: 0.6, size: 28, isTarget: true),

        // Ducklings in pond
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.2, y: 0.72, size: 32, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.35, y: 0.78, size: 35, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.5, y: 0.82, size: 38, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.65, y: 0.85, size: 30, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.8, y: 0.8, size: 32, isTarget: true),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.25, y: 0.88, size: 30, isTarget: true),

        // Reeds
        GameItem(emoji: '🌿', name: 'Reeds', x: 0.9, y: 0.78, size: 40, isTarget: false),
      ],
    ),

    // Level 5: Liquid Containers
    SeekFindLevel(
      title: 'Liquid Container',
      instruction: 'Encircle the items in which liquid can be stored',
      type: LevelType.relatedObjects,
      backgroundColor: const Color(0xFFF8F8F8),
      sceneWidgets: [],
      itemsToFind: ['Bottle', 'Barrel', 'Tub', 'Bucket'],
      allItems: [
        // Top row
        GameItem(emoji: '🍶', name: 'Bottle', x: 0.15, y: 0.15, size: 60, isTarget: true),
        GameItem(emoji: '🛢️', name: 'Barrel', x: 0.4, y: 0.12, size: 65, isTarget: true),
        GameItem(emoji: '🪣', name: 'Tub', x: 0.7, y: 0.15, size: 60, isTarget: true),

        // Second row
        GameItem(emoji: '📦', name: 'Box', x: 0.6, y: 0.32, size: 55, isTarget: false),
        GameItem(emoji: '🧺', name: 'Basket', x: 0.18, y: 0.38, size: 55, isTarget: false),

        // Middle row
        GameItem(emoji: '☂️', name: 'Umbrella', x: 0.38, y: 0.48, size: 50, isTarget: false),
        GameItem(emoji: '🥄', name: 'Spoon', x: 0.7, y: 0.5, size: 45, isTarget: false),

        // Bottom rows
        GameItem(emoji: '👒', name: 'Hat', x: 0.15, y: 0.62, size: 55, isTarget: false),
        GameItem(emoji: '🪣', name: 'Bucket', x: 0.75, y: 0.68, size: 65, isTarget: true),
        GameItem(emoji: '🥾', name: 'Boots', x: 0.2, y: 0.82, size: 55, isTarget: false),
      ],
    ),

    // Level 6: Fruits and Vegetables - Count
    SeekFindLevel(
      title: 'Fruits and Vegetables',
      instruction: 'Find and count all the apples. Tap each apple you find!',
      type: LevelType.countItems,
      backgroundColor: const Color(0xFFFFF8E1),
      sceneWidgets: [
        SceneWidget(emoji: '', x: 0.05, y: 0.1, size: 0, isBackground: true, bgColor: Color(0xFFFFF8E1), height: 0.7, width: 0.9, hasBorder: true),
      ],
      itemsToFind: ['Apple'],
      correctCount: 6,
      allItems: [
        // Row 1
        GameItem(emoji: '🍋', name: 'Lemon', x: 0.15, y: 0.18, size: 45, isTarget: false),
        GameItem(emoji: '🍆', name: 'Eggplant', x: 0.35, y: 0.15, size: 48, isTarget: false),
        GameItem(emoji: '🌶️', name: 'Chili', x: 0.52, y: 0.18, size: 40, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.7, y: 0.15, size: 45, isTarget: true),
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.85, y: 0.18, size: 50, isTarget: false),

        // Row 2
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.12, y: 0.32, size: 50, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.3, y: 0.35, size: 45, isTarget: true),
        GameItem(emoji: '🍋', name: 'Lemon', x: 0.48, y: 0.32, size: 45, isTarget: false),
        GameItem(emoji: '🍆', name: 'Eggplant', x: 0.68, y: 0.35, size: 48, isTarget: false),
        GameItem(emoji: '🌶️', name: 'Chili', x: 0.85, y: 0.32, size: 40, isTarget: false),

        // Row 3
        GameItem(emoji: '🌶️', name: 'Chili', x: 0.15, y: 0.48, size: 40, isTarget: false),
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.32, y: 0.5, size: 50, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.5, y: 0.48, size: 45, isTarget: true),
        GameItem(emoji: '🍆', name: 'Eggplant', x: 0.7, y: 0.5, size: 48, isTarget: false),
        GameItem(emoji: '🍋', name: 'Lemon', x: 0.88, y: 0.48, size: 45, isTarget: false),

        // Row 4
        GameItem(emoji: '🍆', name: 'Eggplant', x: 0.12, y: 0.65, size: 48, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.28, y: 0.62, size: 45, isTarget: true),
        GameItem(emoji: '🌶️', name: 'Chili', x: 0.45, y: 0.65, size: 40, isTarget: false),
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.62, y: 0.62, size: 50, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.8, y: 0.65, size: 45, isTarget: true),

        // Row 5
        GameItem(emoji: '🍋', name: 'Lemon', x: 0.18, y: 0.78, size: 45, isTarget: false),
        GameItem(emoji: '🍉', name: 'Watermelon', x: 0.38, y: 0.8, size: 50, isTarget: false),
        GameItem(emoji: '🍎', name: 'Apple', x: 0.58, y: 0.78, size: 45, isTarget: true),
        GameItem(emoji: '🍆', name: 'Eggplant', x: 0.78, y: 0.8, size: 48, isTarget: false),
      ],
    ),

    // Level 7: At the Pond
    SeekFindLevel(
      title: 'At the Pond',
      instruction: 'Find: one yellow fish, one boat, one shower, one carrot and one lock',
      type: LevelType.findItems,
      backgroundColor: const Color(0xFF87CEEB),
      sceneWidgets: [
        // Sky
        SceneWidget(emoji: '', x: 0, y: 0, size: 0, isBackground: true, bgColor: Color(0xFF87CEEB), height: 0.45),
        // Grass
        SceneWidget(emoji: '', x: 0, y: 0.45, size: 0, isBackground: true, bgColor: Color(0xFF7CB342), height: 0.15),
        // Pond
        SceneWidget(emoji: '', x: 0, y: 0.6, size: 0, isBackground: true, bgColor: Color(0xFF4FC3F7), height: 0.4),
      ],
      itemsToFind: ['Fish', 'Boat', 'Shower', 'Carrot', 'Lock'],
      allItems: [
        // Sun
        GameItem(emoji: '🌞', name: 'Sun', x: 0.12, y: 0.08, size: 50, isTarget: false),
        // Clouds
        GameItem(emoji: '☁️', name: 'Cloud', x: 0.7, y: 0.05, size: 40, isTarget: false),
        GameItem(emoji: '☁️', name: 'Cloud2', x: 0.85, y: 0.1, size: 35, isTarget: false),
        // Tree
        GameItem(emoji: '🌳', name: 'Tree', x: 0.88, y: 0.25, size: 60, isTarget: false),
        // Lock (hidden in tree)
        GameItem(emoji: '🔒', name: 'Lock', x: 0.85, y: 0.32, size: 25, isTarget: true),

        // Boy fishing
        GameItem(emoji: '🧑', name: 'Boy', x: 0.4, y: 0.38, size: 60, isTarget: false),
        // Fishing rod
        GameItem(emoji: '🎣', name: 'Rod', x: 0.5, y: 0.3, size: 45, isTarget: false),
        // Fish on line
        GameItem(emoji: '🐟', name: 'Fish', x: 0.38, y: 0.42, size: 35, isTarget: true),

        // Carrot (hidden in grass)
        GameItem(emoji: '🥕', name: 'Carrot', x: 0.08, y: 0.52, size: 30, isTarget: true),

        // Pond items
        GameItem(emoji: '🦆', name: 'Duck', x: 0.5, y: 0.68, size: 45, isTarget: false),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.62, y: 0.65, size: 28, isTarget: false),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.7, y: 0.68, size: 26, isTarget: false),
        GameItem(emoji: '🐥', name: 'Duckling', x: 0.78, y: 0.65, size: 28, isTarget: false),

        // Paper boat
        GameItem(emoji: '🚣', name: 'Boat', x: 0.35, y: 0.72, size: 40, isTarget: true),

        // Fish in pond
        GameItem(emoji: '🐠', name: 'OrangeFish', x: 0.25, y: 0.78, size: 30, isTarget: false),

        // Shower (hidden)
        GameItem(emoji: '🚿', name: 'Shower', x: 0.15, y: 0.35, size: 28, isTarget: true),

        // Dragonfly
        GameItem(emoji: '🪰', name: 'Dragonfly', x: 0.88, y: 0.55, size: 30, isTarget: false),

        // Reeds
        GameItem(emoji: '🌿', name: 'Reeds', x: 0.92, y: 0.75, size: 45, isTarget: false),
      ],
    ),

    // Level 8: Playground
    SeekFindLevel(
      title: 'Playground Fun',
      instruction: 'Find: a swing, a slide, a bird, a bat, and a duck',
      type: LevelType.findItems,
      backgroundColor: const Color(0xFF87CEEB),
      sceneWidgets: [
        // Sky
        SceneWidget(emoji: '', x: 0, y: 0, size: 0, isBackground: true, bgColor: Color(0xFFB3E5FC), height: 0.35),
        // City silhouette area
        SceneWidget(emoji: '', x: 0, y: 0.25, size: 0, isBackground: true, bgColor: Color(0xFFE0E0E0), height: 0.1),
        // Grass
        SceneWidget(emoji: '', x: 0, y: 0.35, size: 0, isBackground: true, bgColor: Color(0xFF8BC34A), height: 0.65),
      ],
      itemsToFind: ['Swing', 'Slide', 'Bird', 'Bat', 'Duck'],
      allItems: [
        // Bird flying
        GameItem(emoji: '🦜', name: 'Bird', x: 0.15, y: 0.08, size: 40, isTarget: true),
        // Bat flying
        GameItem(emoji: '🦇', name: 'Bat', x: 0.55, y: 0.1, size: 35, isTarget: true),
        // Buildings
        GameItem(emoji: '🏙️', name: 'City', x: 0.5, y: 0.22, size: 80, isTarget: false),

        // Trees
        GameItem(emoji: '🌲', name: 'Tree', x: 0.1, y: 0.4, size: 50, isTarget: false),
        GameItem(emoji: '🌳', name: 'Tree2', x: 0.25, y: 0.38, size: 55, isTarget: false),

        // Slide
        GameItem(emoji: '🛝', name: 'Slide', x: 0.22, y: 0.52, size: 60, isTarget: true),
        // Kids on slide
        GameItem(emoji: '👦', name: 'Boy1', x: 0.18, y: 0.48, size: 35, isTarget: false),
        GameItem(emoji: '👦', name: 'Boy2', x: 0.28, y: 0.55, size: 35, isTarget: false),

        // Center - boy with book
        GameItem(emoji: '🧑', name: 'BigBoy', x: 0.5, y: 0.45, size: 55, isTarget: false),
        GameItem(emoji: '📕', name: 'Book', x: 0.45, y: 0.48, size: 25, isTarget: false),

        // Swing set
        GameItem(emoji: '🎠', name: 'Swing', x: 0.82, y: 0.42, size: 65, isTarget: true),
        // Girl on swing
        GameItem(emoji: '👧', name: 'Girl', x: 0.82, y: 0.5, size: 40, isTarget: false),

        // Duck
        GameItem(emoji: '🦆', name: 'Duck', x: 0.35, y: 0.62, size: 35, isTarget: true),

        // More kids playing
        GameItem(emoji: '👧', name: 'Girl2', x: 0.55, y: 0.65, size: 40, isTarget: false),
        GameItem(emoji: '👦', name: 'Boy3', x: 0.72, y: 0.68, size: 38, isTarget: false),
        GameItem(emoji: '👧', name: 'Girl3', x: 0.85, y: 0.72, size: 35, isTarget: false),

        // Seesaw
        GameItem(emoji: '⚖️', name: 'Seesaw', x: 0.15, y: 0.78, size: 50, isTarget: false),

        // Kid with glasses
        GameItem(emoji: '🧒', name: 'Kid', x: 0.12, y: 0.72, size: 35, isTarget: false),

        // Tunnel
        GameItem(emoji: '🌈', name: 'Tunnel', x: 0.75, y: 0.82, size: 45, isTarget: false),

        // Bushes
        GameItem(emoji: '🌿', name: 'Bush', x: 0.9, y: 0.88, size: 40, isTarget: false),
        GameItem(emoji: '🌿', name: 'Bush2', x: 0.05, y: 0.9, size: 35, isTarget: false),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _initTts();
    Future.delayed(const Duration(milliseconds: 500), _speakInstruction);
  }

  void _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.4);
    await _tts.setPitch(1.1);
  }

  void _speakInstruction() {
    final level = _levels[_currentLevel];
    _tts.speak('${level.title}. ${level.instruction}');
  }

  void _onItemTapped(GameItem item, int index) {
    final level = _levels[_currentLevel];
    String itemKey = '${item.name}_$index';

    if (_circledItems.contains(itemKey)) return;

    setState(() {
      _circledItems.add(itemKey);
    });

    if (item.isTarget) {
      _tts.speak('Great! You found the ${item.name}!');
      setState(() {
        _foundItems.add(itemKey);
        _score += 5;
      });

      int targetCount = level.allItems.where((i) => i.isTarget).length;
      int foundCount = _foundItems.length;

      if (foundCount >= targetCount) {
        _onLevelComplete();
      }
    } else {
      _tts.speak('That\'s a ${item.name}. Try again!');
    }
  }

  void _onLevelComplete() {
    _confettiController.play();
    _tts.speak('Wonderful! You found all the items!');

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentLevel < _levels.length - 1) {
        setState(() {
          _currentLevel++;
          _foundItems.clear();
          _circledItems.clear();
        });
        _speakInstruction();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.pink.shade50,
        title: const Column(
          children: [
            Text('🎉', style: TextStyle(fontSize: 50)),
            SizedBox(height: 10),
            Text('Amazing Explorer!', style: TextStyle(color: Colors.pink)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You completed all ${_levels.length} levels!', style: const TextStyle(fontSize: 18), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text('Score: $_score', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
                Icon(Icons.star, color: Colors.amber, size: 40),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentLevel = 0;
                _score = 0;
                _foundItems.clear();
                _circledItems.clear();
              });
              _speakInstruction();
            },
            child: const Text('Play Again'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            child: const Text('Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = _levels[_currentLevel];
    final targetCount = level.allItems.where((i) => i.isTarget).length;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: level.backgroundColor,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 26),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade600,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              level.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                          child: Text('${_currentLevel + 1}/${_levels.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),

                  // Instruction bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            level.instruction,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade800, fontStyle: FontStyle.italic),
                          ),
                        ),
                        GestureDetector(
                          onTap: _speakInstruction,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.blue.shade100, shape: BoxShape.circle),
                            child: Icon(Icons.volume_up, color: Colors.blue.shade700, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        Text('Found: ${_foundItems.length}/$targetCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _foundItems.length / targetCount,
                              backgroundColor: Colors.grey.shade300,
                              valueColor: const AlwaysStoppedAnimation(Colors.green),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white, size: 14),
                              const SizedBox(width: 2),
                              Text('$_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Game Scene
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: level.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.brown.shade300, width: 3),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              children: [
                                // Background layers
                                ...level.sceneWidgets.map((widget) {
                                  if (widget.isBackground) {
                                    return Positioned(
                                      left: widget.x * constraints.maxWidth,
                                      top: widget.y * constraints.maxHeight,
                                      child: Container(
                                        width: (widget.width ?? 1.0) * constraints.maxWidth,
                                        height: (widget.height ?? 0.5) * constraints.maxHeight,
                                        decoration: BoxDecoration(
                                          color: widget.bgColor,
                                          borderRadius: widget.isOval ? BorderRadius.circular(100) : null,
                                          border: widget.hasBorder ? Border.all(color: Colors.red.shade200, width: 2) : null,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                }),

                                // Game items
                                ...level.allItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;
                                  final itemKey = '${item.name}_$index';
                                  final isCircled = _circledItems.contains(itemKey);
                                  final isFound = _foundItems.contains(itemKey);

                                  return Positioned(
                                    left: item.x * constraints.maxWidth - (item.size / 2),
                                    top: item.y * constraints.maxHeight - (item.size / 2),
                                    child: GestureDetector(
                                      onTap: () => _onItemTapped(item, index),
                                      child: SizedBox(
                                        width: item.size + 20,
                                        height: item.size + 20,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Circle drawing
                                            if (isCircled)
                                              CustomPaint(
                                                size: Size(item.size + 15, item.size + 15),
                                                painter: CirclePainter(
                                                  color: isFound ? Colors.green : Colors.red,
                                                  strokeWidth: 3,
                                                ),
                                              ),
                                            // Emoji
                                            Text(
                                              item.emoji,
                                              style: TextStyle(fontSize: item.size * 0.7),
                                            ),
                                            // Checkmark
                                            if (isFound)
                                              Positioned(
                                                right: 0,
                                                bottom: 0,
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                                                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [Colors.pink, Colors.purple, Colors.blue, Colors.green, Colors.yellow, Colors.orange],
            ),
          ),
        ],
      ),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  CirclePainter({required this.color, this.strokeWidth = 3});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height / 2), width: size.width, height: size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum LevelType { findItems, relatedObjects, findAll, countItems }

class SceneWidget {
  final String emoji;
  final double x;
  final double y;
  final double size;
  final bool isBackground;
  final Color? bgColor;
  final double? height;
  final double? width;
  final bool isOval;
  final bool hasBorder;

  SceneWidget({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    this.isBackground = false,
    this.bgColor,
    this.height,
    this.width,
    this.isOval = false,
    this.hasBorder = false,
  });
}

class SeekFindLevel {
  final String title;
  final String instruction;
  final LevelType type;
  final Color backgroundColor;
  final List<SceneWidget> sceneWidgets;
  final List<String> itemsToFind;
  final List<GameItem> allItems;
  final int? correctCount;

  SeekFindLevel({
    required this.title,
    required this.instruction,
    required this.type,
    required this.backgroundColor,
    required this.sceneWidgets,
    required this.itemsToFind,
    required this.allItems,
    this.correctCount,
  });
}

class GameItem {
  final String emoji;
  final String name;
  final double x;
  final double y;
  final double size;
  final bool isTarget;

  GameItem({
    required this.emoji,
    required this.name,
    required this.x,
    required this.y,
    this.size = 40,
    this.isTarget = false,
  });
}
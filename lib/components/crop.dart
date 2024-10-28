import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'package:uuid/uuid.dart';
import 'package:virtual_farm/components/building.dart';

// Define an enum for crop types
enum CropType {
    wheat,
    corn,
    potatoes,
    carrots,
    // Add more crop types as needed
}

class Crop extends PositionComponent implements Building {
    static final _paint = Paint()..color = Colors.white;
    @override
    final String uuid = Uuid().v4();
    final textRenderer = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.black.color),);
    CropType type;
    final VoidCallback? onHarvest; // Callback for notifying when harvested
    int growthStage = 0;
    bool isHarvestable = false;

    double _growthTimer = 0.0;       // Timer to track crop growth
    final double growthDuration = 5; // Duration for each stage (in seconds)
    final int maxGrowthStage = 3;    // Maximum number of growth stages

    SpriteSheet? growthStages;

    Crop({
        required this.type,
        this.onHarvest,
    });

    @override
    Future<void> onLoad() async {
        // Load crop-specific assets
        // TODO: Implement spritesheets for other crops
        final defaultSpriteSheet = await Flame.images.load("default_crop_spritesheet.png");
        final spriteSheet = SpriteSheet(image: defaultSpriteSheet, srcSize: Vector2(680, 340));
        growthStages = spriteSheet;

      add(TextComponent(
          text: type.name,
          textRenderer: textRenderer,
          anchor: Anchor.center,
          position: Vector2(size.x / 2, size.y / 2),
          ),
        );
    }

    // Method to update the town state each frame
    @override
    void update(double dt) {
        super.update(dt);

        // Increment the growth timer with the delta time
        _growthTimer += dt;

        // Check if the timer exceeds the growth duration for the current stage
        if (_growthTimer >= growthDuration) {
            grow();                 // Progress to the next growth stage
            _growthTimer = 0.0;     // Reset the timer for the next stage
        }
    }

    // Method to render the crop
    @override
    void render(Canvas canvas) {
        super.render(canvas);

        growthStages!.getSprite(0, growthStage).render(canvas, size: size);
    }

    @override
    void onTap() {
        tryHarvest();
    }

    void grow() {
        if (growthStage < maxGrowthStage) {
            growthStage++;
            isHarvestable = (growthStage == maxGrowthStage);
        }
    }

    void tryHarvest() {
        if (isHarvestable) {
            onHarvest?.call();

            removeFromParent();
        }
    }

    static String cropTypeToName(CropType type) {
        return type.name[0].toUpperCase() + type.name.substring(1);
    }
}
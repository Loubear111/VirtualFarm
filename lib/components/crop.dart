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
    Vector2 maxSize;
    late final Vector2 cropImgSize;
    late final Vector2 scaledImgSize;
    final VoidCallback? onHarvest; // Callback for notifying when harvested
    int growthStage = 0;

    double _growthTimer = 0.0;       // Timer to track crop growth
    final double growthDuration = 5; // Duration for each stage (in seconds)
    final int maxGrowthStage = 3;    // Maximum number of growth stages

    SpriteSheet? growthStages;

    Crop({
        required this.type,
        required this.maxSize,
        this.onHarvest,
        this.growthStage = 0,
    }) {
        if (type == CropType.wheat) {
            cropImgSize = Vector2(64, 64);
        } else {
            cropImgSize = Vector2(680, 340);
        }
        double multiplier = maxSize.x / cropImgSize.x;
        scaledImgSize = cropImgSize * multiplier;
        size = scaledImgSize;
    }

    @override
    Future<void> onLoad() async {
        // Load crop-specific assets
        if (type == CropType.wheat) {
            final wheatSpriteSheet = await Flame.images.load("wheat_spritesheet.png");
            final spriteSheet = SpriteSheet(image: wheatSpriteSheet, srcSize: cropImgSize);
            growthStages = spriteSheet;
        } else {
            // TODO: Implement spritesheets for other crops
            final defaultSpriteSheet = await Flame.images.load("default_crop_spritesheet.png");
            final spriteSheet = SpriteSheet(image: defaultSpriteSheet, srcSize: cropImgSize);
            growthStages = spriteSheet;

            add(TextComponent(
                text: type.name,
                textRenderer: textRenderer,
                anchor: Anchor.center,
                position: Vector2(size.x / 2, size.y / 2),
                ),
            );
        }
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

        size = scaledImgSize;

        growthStages!.getSprite(0, growthStage).render(canvas, size: scaledImgSize);
    }

    @override
    void onTap() {
        tryHarvest();
    }

    void grow() {
        if (growthStage < maxGrowthStage) {
            growthStage++;
        }
    }

    void tryHarvest() {
        if (isHarvestable()) {
            onHarvest?.call();

            removeFromParent();
        }
    }

    bool isHarvestable() {
        return (growthStage == maxGrowthStage);
    }

    static String cropTypeToName(CropType type) {
        return type.name[0].toUpperCase() + type.name.substring(1);
    }
}
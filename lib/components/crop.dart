import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';

// Define an enum for crop types
enum CropType {
    wheat,
    corn,
    potatoes,
    carrots,
    // Add more crop types as needed
}

class Crop extends PositionComponent {
    static final _paint = Paint()..color = Colors.white;
    CropType type;
    int growthStage = 0;
    bool isHarvestable = false;

    double _growthTimer = 0.0;       // Timer to track crop growth
    final double growthDuration = 5; // Duration for each stage (in seconds)
    final int maxGrowthStage = 3;    // Maximum number of growth stages

    SpriteSheet? growthStages;

    Crop({
        required this.type,
    });

    @override
    Future<void> onLoad() async {
        // Load crop-specific assets
        if (type == CropType.wheat) {
            final wheatSpriteSheet = await Flame.images.load("wheat_spritesheet.png");
            final spriteSheet = SpriteSheet(image: wheatSpriteSheet, srcSize: Vector2.all(340));
            growthStages = spriteSheet;
        } else {
            // TODO: Implement spritesheets for other crops
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

        if (growthStages == null) {
            // Generate color based on growth stage
            // Assuming 3 growth stages (0 to 3)
            switch (growthStage) {
                case 0: 
                    _paint.color = Colors.brown; // Seed or freshly planted
                    break;
                case 1: 
                    _paint.color = const Color.fromARGB(255, 151, 119, 13); // Early growth
                    break;
                case 2: 
                    _paint.color = Colors.green[600]!; // Mid-growth
                    break;
                case 3: 
                    _paint.color = Colors.green[900]!; // Fully grown, ready to harvest
                    break;
                default: 
                    _paint.color = Colors.white; // Fallback color
            }

            canvas.drawRect(size.toRect(), _paint);
        } else {
            growthStages!.getSprite(0, growthStage).render(canvas, size: size);
        }
    }

    void grow() {
        if (growthStage < maxGrowthStage) {
            growthStage++;
            isHarvestable = (growthStage == maxGrowthStage);
        }
    }
}
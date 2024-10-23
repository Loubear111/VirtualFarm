import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'crop.dart';

class Town extends PositionComponent {
    List<PositionComponent> buildings; // List of buildings in the town

    Town({
        this.buildings = const [],
    });

    @override
    Future<void> onLoad() async {
        // Load town-specific assets (e.g., buildings, decorations)
        await super.onLoad();

        add(
            Crop(type: CropType.wheat)
            ..position = Vector2(size.x / 2, size.y / 2)
            ..width = 50
            ..height = 50
            ..anchor = Anchor.center,
            );
    }

    // Method to update the town state each frame
    @override
    void update(double dt) {
        super.update(dt);
        // Update town logic, such as resource generation, building statuses, etc.
    }

    // Method to render the town
    @override
    void render(Canvas canvas) {
        super.render(canvas);
        // Draw town-specific elements like background, borders, etc.
    }
}
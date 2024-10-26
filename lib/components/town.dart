import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'crop.dart';

class Town extends PositionComponent {
    final Vector2 tileSize = Vector2(100, 50);
    late final double xStart;
    late final double yStart;
    List<PositionComponent> buildings; // List of buildings in the town

    Town({
        this.buildings = const [],
    });

    @override
    Future<void> onLoad() async {
        // Load town-specific assets (e.g., buildings, decorations)
        await super.onLoad();

        xStart = size.x / 2;
        yStart = tileSize.y;

        add(
            Crop(type: CropType.potatoes)
            ..position = calcTile(0, 0)
            ..width = tileSize.x
            ..height = tileSize.y
            ..anchor = Anchor.center,
            );

        add(
            Crop(type: CropType.potatoes)
            ..position = calcTile(1, 0)
            ..width = tileSize.x
            ..height = tileSize.y
            ..anchor = Anchor.center,
            );

        add(
            Crop(type: CropType.wheat)
            ..position = calcTile(1, 1)
            ..width = tileSize.x
            ..height = tileSize.y
            ..anchor = Anchor.center,
            );

        add(
            Crop(type: CropType.carrots)
            ..position = calcTile(2, 0)
            ..width = tileSize.x
            ..height = tileSize.y
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

    Vector2 calcTile(int x, int y) {
        double xScreen = xStart + (x - y) * (tileSize.x / 2);
        double yScreen = yStart + (x + y) * (tileSize.y / 2);
        return Vector2(xScreen, yScreen);
    }
}
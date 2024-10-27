import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart' as flame_events;
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'crop.dart';

class Town extends PositionComponent with flame_events.TapCallbacks, flame_events.PointerMoveCallbacks {
    final Vector2 tileSize = Vector2(100, 50);
    late final double xStart;
    late final double yStart;
    List<PositionComponent> buildings; // List of buildings in the town
    final textRenderer = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color),);
    // Dictionary to track the count of each crop type
    final Map<CropType, int> cropCounts = {
        CropType.wheat: 0,
        CropType.corn: 0,
        CropType.carrots: 0,
        CropType.potatoes: 0,
    };

    final Map<CropType, TextComponent> cropCountText = {};
    Point<int>? hoveredTile; // To keep track of the currently hovered tile

    Town({
        this.buildings = const [],
    });

    @override
    Future<void> onLoad() async {
        // Load town-specific assets (e.g., buildings, decorations)
        await super.onLoad();

        xStart = size.x / 2;
        yStart = tileSize.y;

        double offsetX = 0.0; // Starting position for horizontal alignment
        double spacing = 20.0; // Space between text components
        CropType.values.forEach((crop) {
            cropCountText[crop] = TextComponent(
                text: "${Crop.cropTypeToName(crop)}: 0",
                textRenderer: textRenderer,
                anchor: Anchor.topCenter,
                position: Vector2(size.x / 2 + offsetX, 0),
            );

            add(cropCountText[crop]!);
            offsetX += cropCountText[crop]!.size.x + spacing;
        });
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
        if (hoveredTile != null) {
            // Draw outline for the hovered tile
            //drawHoveredTileOutline(canvas, hoveredTile!);
        }
    }

    @override
    void onTapDown(flame_events.TapDownEvent event) {
        Point<int> gridCoords = calcGrid(event.canvasPosition.x, event.canvasPosition.y);

        // TODO: There's a bug where the click event doesn't get captured by the right box, so we need to handle draw order
        add(
        Crop(type: CropType.carrots, onHarvest: () {handleHarvest(CropType.carrots);})
            ..position = calcTile(gridCoords.x, gridCoords.y)
            ..width = tileSize.x
            ..height = tileSize.y
            ..anchor = Anchor.center,
        );
    }

    @override
    void onPointerMove(flame_events.PointerMoveEvent event) {
        // Do something in response to the mouse move (e.g. update coordinates)
        // Get the mouse position in screen space
        double xScreen = event.canvasPosition.x;
        double yScreen = event.canvasPosition.y;

        // Convert to grid coordinates
        hoveredTile = calcGrid(xScreen, yScreen);
    }

    /// Calculates the screen space coordinates of a tile based on its grid coordinates.
    /// 
    /// This function converts a tile's grid coordinates `(x, y)` into screen space
    /// coordinates `(xScreen, yScreen)` based on the provided offsets and tile size.
    /// 
    /// - Parameters:
    ///   - x: The x-coordinate of the tile in grid space.
    ///   - y: The y-coordinate of the tile in grid space.
    /// 
    /// - Returns: A `Vector2` containing the x and y screen coordinates of the tile.
    Vector2 calcTile(int x, int y) {
        double xScreen = xStart + (x - y) * (tileSize.x / 2);
        double yScreen = yStart + (x + y) * (tileSize.y / 2);
        return Vector2(xScreen, yScreen);
    }

    /// Calculates the grid coordinates of a tile based on screen space coordinates.
    /// 
    /// This function converts screen space coordinates `(xScreen, yScreen)` back to
    /// the tile’s grid coordinates `(x, y)` by reversing the transformation applied
    /// in `calcTile()`. This is useful for detecting which tile a user tapped.
    /// 
    /// - Parameters:
    ///   - xScreen: The x-coordinate in screen space.
    ///   - yScreen: The y-coordinate in screen space.
    /// 
    /// - Returns: A `Point<int>` representing the tile’s grid coordinates.
    Point<int> calcGrid(double xScreen, double yScreen) {
        double x = ((xScreen - xStart) / tileSize.x + (yScreen - yStart) / tileSize.y);
        double y = ((yScreen - yStart) / tileSize.y - (xScreen - xStart) / tileSize.x);
        return Point<int>(x.round(), y.round());
    }

    void drawHoveredTileOutline(Canvas canvas, Point<int> tile) {
        final Paint paint = Paint()
            ..color = Colors.red // Set the color of the outline
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0; // Set the outline width

        Vector2 screenTile = calcTile(tile.x, tile.y);
        // Calculate the position of the tile
        double x = screenTile.x - tileSize.x / 2;
        double y = screenTile.y - tileSize.y / 2;
        

        // Draw the rectangle outline
        canvas.drawRect(
            Rect.fromLTWH(x, y, tileSize.x, tileSize.y),
            paint,
        );
    }

    void handleHarvest(CropType type) {
        cropCounts[type] = (cropCounts[type] ?? 0) + 1;

        cropCountText[type]!.text = "${Crop.cropTypeToName(type)}: ${cropCounts[type]}"; 
    }
}
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart' as flame_events;
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:virtual_farm/components/building.dart';
import 'crop.dart';

class Town extends PositionComponent with flame_events.TapCallbacks, flame_events.PointerMoveCallbacks {
    // TODO: Can we implement the tiling in its own class to help slim down the Town object?
    final Vector2 tileSize = Vector2(100, 50);
    final Vector2 maxTileSize = Vector2(100, 200);
    late final double xStart;
    late final double yStart;
    final textRenderer = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color),);
    // Dictionary to track the count of each crop type
    final Map<CropType, int> cropCounts = {
        CropType.wheat: 0,
        CropType.corn: 0,
        CropType.carrots: 0,
        CropType.potatoes: 0,
    };

    // A dictionary which holds all the different buildings in the town
    final Map<Point<int>, Building> buildings = {};

    final Map<CropType, TextComponent> cropCountText = {};
    Point<int>? hoveredTile; // To keep track of the currently hovered tile

    Town();

    @override
    Future<void> onLoad() async {
        // Load town-specific assets (e.g., buildings, decorations)
        await super.onLoad();

        xStart = size.x / 2;
        yStart = tileSize.y;

        // Add a text interface displaying crop score at the top of the town (this should probably be in `game.dart`...?)
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

        // Define the paint for the outline
        final outlinePaint = Paint()
            ..color = Colors.blue // Choose the color for the outline
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0; // Adjust the thickness of the outline

        // Draw the rectangle outline around the entire Town component
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.x, size.y),
            outlinePaint,
        );
    }

    @override
    void onTapDown(flame_events.TapDownEvent event) {
        Point<int> gridCoords = calcGrid(event.localPosition.x, event.localPosition.y);

        if (buildings[gridCoords] == null) {
            Random random = Random();

            // TODO: Allow planting of other crops
            Crop newCrop;
            newCrop = Crop(type: CropType.wheat, maxSize: maxTileSize, onHarvest: () {handleHarvest(CropType.wheat);});
            buildings[gridCoords] = newCrop
                ..position = calcTile(gridCoords.x, gridCoords.y, newCrop.scaledImgSize.y)
                ..anchor = Anchor.bottomCenter; 

            add(buildings[gridCoords]!);
        } else {
            buildings[gridCoords]!.onTap();
        }
    }

    @override
    void onPointerMove(flame_events.PointerMoveEvent event) {
        // Do something in response to the mouse move (e.g. update coordinates)
        // Get the mouse position in screen space
        double xScreen = event.localPosition.x;
        double yScreen = event.localPosition.y;

        // Convert to grid coordinates
        hoveredTile = calcGrid(xScreen, yScreen);
    }

    /// Update any required children when they are updated since we keep references to all buildings
    @override
    void onChildrenChanged(Component child, ChildrenChangeType type) {
        for (var entry in buildings.entries) {
            // Set priority based on isometric grid position.
            // Higher y should be rendered on top, so we combine y and x to create a unique priority.
            // The formula ensures tiles with larger y values have higher priority.
            entry.value.priority = entry.key.y * 1000 + entry.key.x;
        }

        if (type == ChildrenChangeType.removed) {
            if (child is Crop) {
                Crop crop = child as Crop;
                var buildingRemovedPoint = buildings.entries.firstWhere((element) => element.value.uuid == crop.uuid).key;
                buildings.remove(buildingRemovedPoint);
            }
        }
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
    Vector2 calcTile(int x, int y, double imgHeight) {
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
        return Point<int>(x.ceil(), y.ceil());
    }

    /// TODO: Is there a better way we can do this so we don't have to pass CropType as a parameter...?
    /// Updates the crop count and display for a harvested crop.
    ///
    /// This function is called whenever a crop of the specified `type` is harvested.
    /// It increments the count for that crop type in the `cropCounts` map and updates
    /// the corresponding text display to reflect the new count.
    ///
    /// - Parameters:
    ///   - type: The `CropType` of the harvested crop.
    ///
    /// Updates:
    /// - `cropCounts[type]`: Increments the count for the specified crop type.
    /// - `cropCountText[type].text`: Updates the on-screen text to show the new crop count.
    void handleHarvest(CropType type) {
        cropCounts[type] = (cropCounts[type] ?? 0) + 1;

        cropCountText[type]!.text = "${Crop.cropTypeToName(type)}: ${cropCounts[type]}"; 
    }
}
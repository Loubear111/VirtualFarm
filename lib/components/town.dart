import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart' as flame_events;
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:virtual_farm/components/interactive_object.dart';
import 'crops/crop.dart';
import 'package:virtual_farm/tile_grid.dart';
import 'crops/crop_zone.dart';

class Town extends PositionComponent with flame_events.TapCallbacks, flame_events.PointerMoveCallbacks {
    final Vector2 tileSize = Vector2(100, 50);
    final Vector2 maxTileSize = Vector2(100, 200);
    final textRenderer = TextPaint(style: TextStyle(fontSize: 12, color: BasicPalette.white.color),);
    late final TileGrid tileGrid;
    late CropZone cropZone;

    // Dictionary to track the count of each crop type
    final Map<CropType, int> cropCounts = {
        CropType.wheat: 0,
        CropType.corn: 0,
        CropType.carrots: 0,
        CropType.potatoes: 0,
    };

    // A dictionary which holds all the different buildings in the town
    final Map<Point<int>, InteractiveObject> buildings = {};

    final Map<CropType, TextComponent> cropCountText = {};
    Point<int>? hoveredTile; // To keep track of the currently hovered tile

    Town();

    @override
    Future<void> onLoad() async {
        // Load town-specific assets (e.g., buildings, decorations)
        await super.onLoad();

        double xStart = size.x / 2;
        double yStart = tileSize.y;
        tileGrid = TileGrid(tileSize: tileSize, xStart: xStart, yStart: yStart);

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

        Point<int> cropZoneLocation = const Point<int>(2, 2);
        cropZone = CropZone(
            topLeft: cropZoneLocation, 
            tileSize: tileSize,
            maxTileSize: maxTileSize,
            onHarvest: (CropType type, int quantity) {
                // Update storage count in a dedicated storage zone or SiloZone
                cropCounts[type] = (cropCounts[type] ?? 0) + quantity;

                cropCountText[type]!.text = "${Crop.cropTypeToName(type)}: ${cropCounts[type]}"; 
                // For example, if we had a storage zone:
                // storageZone.addCrop(type, quantity);
            });

        // Register each tile covered by the CropZone in the buildings dictionary
        for (int x = cropZone.topLeft.x; x < cropZone.topLeft.x + cropZone.gridSize.x; x++) {
            for (int y = cropZone.topLeft.y; y < cropZone.topLeft.y + cropZone.gridSize.y; y++) {
                buildings[Point<int>(x, y)] = cropZone;
            }
        }

        add(cropZone
            ..anchor = Anchor.center
            ..size = Vector2(tileSize.x * cropZone.gridSize.x, tileSize.y * cropZone.gridSize.y)
            ..position = tileGrid.calcTile(cropZoneLocation.x, cropZoneLocation.y));
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
        Point<int> gridCoords = tileGrid.calcGrid(event.localPosition.x, event.localPosition.y);

        if (buildings[gridCoords] == null) {
            // TODO: Allow planting of other buildings
        } else {
            buildings[gridCoords]!.onTap(event.localPosition);
        }
    }

    @override
    void onPointerMove(flame_events.PointerMoveEvent event) {
        // Do something in response to the mouse move (e.g. update coordinates)
        // Get the mouse position in screen space
        double xScreen = event.localPosition.x;
        double yScreen = event.localPosition.y;

        // Convert to grid coordinates
        hoveredTile = tileGrid.calcGrid(xScreen, yScreen);
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
            // Remove any children if needed
        }
    }
}
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart' as flame_events;
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:virtual_farm/components/interactive_object.dart';
import 'crop.dart';
import 'package:uuid/uuid.dart';
import 'package:virtual_farm/tile_grid.dart';

class CropZone extends PositionComponent implements InteractiveObject {
    @override
    final String uuid = Uuid().v4();
    final Vector2 tileSize;
    final Vector2 maxTileSize;
    int level;
    Point<int> topLeft; // Starting point in the grid for this zone
    Point<int> gridSize = const Point<int>(2,2); // Width/Height of the current crop area (4 for 4x4, 6 for 6x6, etc.)
    int maxCropTypes = 2;
    int maxWorkers = 0;
    late final TileGrid tileGrid;

    // A dictionary which holds all the different crops in the CropZone
    final Map<Point<int>, Crop> crops = {};

    // Callback for when a crop is harvested
    final void Function(CropType type, int quantity) onHarvest;

    CropZone({
        required this.topLeft, 
        required this.onHarvest, // Initialize with a harvest callback 
        required this.tileSize, 
        required this.maxTileSize,
        this.level = 1
        }) {
        tileGrid = TileGrid(tileSize: tileSize, xStart: 0, yStart: 0);

        // Initialize based on level 1
        updateZoneProperties();
    }

    // Update properties based on level
    void updateZoneProperties() {
        if (level == 1) {
            gridSize = const Point<int>(2,2);
            maxCropTypes = 2;
            maxWorkers = 0;
        } else if (level == 2) {
            gridSize = const Point<int>(3,3);
            maxCropTypes = 3;
            maxWorkers = 1;
        }
        // Add more levels if needed
    }

    @override
    void onTap(Vector2 tapPosition) {
        // Convert the tap position to CropZone's local space
        Vector2 tapPositionInZone = tapPosition - this.position;

        // Convert the local tap position to grid coordinates within CropZone
        Point<int> tile = tileGrid.calcGrid(tapPositionInZone.x, tapPositionInZone.y);

        // Check if there is a crop on the tapped tile
        Crop? tappedCrop = crops[tile];
        if (tappedCrop != null) {
            tappedCrop.onTap(tapPositionInZone); // Pass the tap to the crop
        } else {
            Crop newCrop;
            newCrop = Crop(type: CropType.wheat, maxSize: maxTileSize, onHarvest: onHarvest);
            crops[tile] = newCrop
                ..position = tileGrid.calcTile(tile.x, tile.y)
                ..anchor = Anchor.bottomCenter; 

            add(crops[tile]!);
        }
    }

    /// Update any required children when they are updated since we keep references to all crops
    @override
    void onChildrenChanged(Component child, ChildrenChangeType type) {
        for (var entry in crops.entries) {
            // Set priority based on isometric grid position.
            // Higher y should be rendered on top, so we combine y and x to create a unique priority.
            // The formula ensures tiles with larger y values have higher priority.
            entry.value.priority = entry.key.y * 1000 + entry.key.x;
        }

        if (type == ChildrenChangeType.removed) {
            if (child is Crop) {
                Crop crop = child as Crop;
                var cropRemovedPoint = crops.entries.firstWhere((element) => element.value.uuid == crop.uuid).key;
                crops.remove(cropRemovedPoint);
            }
        }
    }

    @override
    void render(Canvas canvas) {
        super.render(canvas);
        // Define the paint for the outline
        final outlinePaint = Paint()
            ..color = Colors.orange // Choose the color for the outline
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4.0; // Adjust the thickness of the outline

        // Draw the rectangle outline around the entire Town component
        canvas.drawRect(
            Rect.fromLTWH(0, 0, size.x, size.y),
            outlinePaint,
        );
    }

    void upgrade() {
        level++;
        updateZoneProperties();
    }
}
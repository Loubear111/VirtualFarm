// tile_grid.dart
import 'dart:math';
import 'package:flame/components.dart';

class TileGrid {
    final Vector2 tileSize;
    final double xStart;
    final double yStart;

    TileGrid({
        required this.tileSize,
        required this.xStart,
        required this.yStart,
    });

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
        return Point<int>(x.ceil(), y.ceil());
    }
}

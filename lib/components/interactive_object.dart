import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

/// An abstract class defining an interactive component within the game.
///
/// Any class implementing `InteractiveObject` should extend `PositionComponent`, 
/// allowing it to be positioned within the game world. This interface 
/// provides a basic protocol for game objects, including user interaction.
abstract class InteractiveObject extends PositionComponent {
    final String uuid = Uuid().v4();
    void onTap(Vector2 tapPosition);
}
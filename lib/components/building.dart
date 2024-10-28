import 'package:flame/components.dart';
import 'package:uuid/uuid.dart';

/// An abstract class defining a building component within the game.
///
/// Any class implementing `Building` should extend `PositionComponent`, 
/// allowing it to be positioned within the game world. This interface 
/// provides a basic protocol for game buildings, including user interaction.
abstract class Building extends PositionComponent {
    final String uuid = Uuid().v4();
    void onTap();
}
import 'package:flame/game.dart';
import 'components/town.dart';

class VirtualFarmGame extends FlameGame {
    late Town town;

    @override
    Future<void> onLoad() async {
        // Load assets, initialize components, etc.
        await super.onLoad();

        // For now, make the town the size of the entire canvas
        town = Town()..size = size;
        add(town);
    }
}

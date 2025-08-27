import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Obstacle extends FlxSprite {
    public function new(x:Float, y:Float, speed:Float) {
        super(x, y);

        // Pick a random obstacle type
        var rand = FlxG.random.int(0, 1);

        switch (rand) {
            case 0:
                loadGraphic("assets/images/obstacle1.png"); // saw
            case 1:
                loadGraphic("assets/images/obstacle2.png"); // spike
            default: // AS A FALLBACK WHEN THE RANDOMIZER (SOMEHOW) GETS OUT OF RANGE
                makeGraphic(24, 24, FlxColor.fromRGB(255, 80, 80));
        }
		scale.set(2, 2);
        velocity.set(0, speed);

        // optional safety flags
        exists = true;
        alive = true;
        immovable = false; // allow it to be impacted if needed
    }
}

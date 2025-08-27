import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WebState extends FlxState {
    override public function create():Void {
        super.create();
    
        // Show some "Press SPACE to start" text
        var prompt = new FlxText(0, FlxG.height - 40, FlxG.width, "Press SPACE to start");
        prompt.setFormat(null, 16, FlxColor.WHITE, CENTER);
        add(prompt);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        // Wait for SPACE (or mouse click) before starting game + music
        if (FlxG.keys.justPressed.SPACE) {
            // Music will now play because it's triggered by a gesture
            FlxG.sound.playMusic(Paths.sound("bread"));

            // Switch to your PlayState (or wherever gameplay starts)
            FlxG.switchState(() -> new PlayState());
        }
    }
}
import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite
{
    private var currentAnim:String = "";

    public function new(x:Float, y:Float)
    {
        super(x, y);

        var g = Paths.image("player"); // expects assets/shared/images/player.png
        if (g != null)
        {
            // we expect exactly 3 frames laid out horizontally
            var frameCount:Int = 3;
            var frameW:Int = Std.int(Math.floor(g.width / frameCount));
            var frameH:Int = Std.int(g.height);

            loadGraphic(g, true, frameW, frameH);

            // Add single-frame animations for clarity
            animation.add("idle", [0], 0, true);        // single-frame idle
            animation.add("move_left", [2], 0, true);   // single-frame left
            animation.add("move_right", [1], 0, true);  // single-frame right

            // start idle once
            playAnimIfNeeded("idle");
		    scale.set(2, 2);
        }
        else
        {
            // fallback
            makeGraphic(16, 16, 0xff00ccff);
        }

        // defaults
        immovable = true;
        // antialiasing = false; // uncomment if pixel-art
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Fallback visual logic: if PlayState doesn't drive visuals, we detect input here
        // (You can skip this and call setMovementDirection from PlayState instead)
        if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
            setMovementDirection(-1);
        else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
            setMovementDirection(1);
        else if (FlxG.mouse.pressed) {
            // click/touch: left/right of player center
            var mx = FlxG.mouse.viewX;
            if (mx < x + width/2) setMovementDirection(-1);
            else setMovementDirection(1);
        }
        else
            setMovementDirection(0);
    }

    /**
     * dir: -1 = left, 0 = idle, 1 = right
     * Call this from PlayState after you update player position (recommended)
     */
    public function setMovementDirection(dir:Int):Void
    {
        switch (dir)
        {
            case -1: playAnimIfNeeded("move_left");
            case 1:  playAnimIfNeeded("move_right");
            default: playAnimIfNeeded("idle");
        }
    }

    private function playAnimIfNeeded(name:String):Void
    {
        if (name == currentAnim) return; // do nothing — avoids twitching
        currentAnim = name;
        animation.play(name);
    }

    public function setActive(active:Bool):Void
    {
        exists = active;
        alive = active;
    }
}

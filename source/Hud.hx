import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class Hud extends FlxGroup {
    private var timeText:FlxText;
    private var helpText:FlxText;
    private var finalText:FlxText;
    private var overlay:FlxSprite;

    public function new() {
        super();

        // regular HUD (these will be added first so the overlay can cover them)
        timeText = new FlxText(8, 8, FlxG.width, "Time: 0");
        timeText.setFormat(null, 16, FlxColor.WHITE);
        add(timeText);

        helpText = new FlxText(8, 28, FlxG.width, "Move: ← →  |  Survive 60s");
        helpText.setFormat(null, 12, 0xFFA9A9A9);
        add(helpText);

        // full-screen gray overlay (hidden by default)
        overlay = new FlxSprite(0, 0);
        overlay.makeGraphic(FlxG.width, FlxG.height, 0x88000000); // AARRGGBB -> semi-transparent black/gray
        overlay.visible = false;
        overlay.exists = true;
        add(overlay);

        // final message on top of the overlay
        finalText = new FlxText(0, FlxG.height/2 - 20, FlxG.width, "");
        finalText.setFormat(null, 20, FlxColor.WHITE, "center");
        finalText.visible = false;
        add(finalText);
    }

    public function updateDisplay(elapsedTime:Float):Void {
        timeText.text = "Time: " + Std.string(Std.int(elapsedTime));
    }

    public function showGameOver():Void {
        overlay.visible = true;
        overlay.alpha = 0.6;
        finalText.text = "Game Over - Press R to Restart";
        finalText.visible = true;
    }

    public function showWin():Void {
        overlay.visible = true;
        overlay.alpha = 0.6;
        finalText.text = "You Survived!  (Press R to Restart)";
        finalText.visible = true;
    }

    public function hideOverlay():Void {
        overlay.visible = false;
        finalText.visible = false;
    }
}
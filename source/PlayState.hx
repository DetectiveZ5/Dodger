package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if debug
import flixel.system.debug.log.LogStyle;
#end

class PlayState extends FlxState
{
	public var player:Player;
	public var obstacles:FlxTypedGroup<FlxSprite>;
	public var spawnTimer:Float = 0;
	public var spawnInterval:Float = 0.6;
	public var elapsedTime:Float = 0;
	public var gameOver:Bool = false;
	public var hud:Hud;
	public var background:FlxSprite;
	public var platform:FlxSprite;

	// config
	public var playerSpeed:Float = 220; // current effective speed (updated each frame)
	public var playerBaseSpeed:Float = 220; // base speed used for scaling
	public var spawnIntervalStart:Float = 0.8;
	public var spawnIntervalMin:Float = 0.25;
	public var spawnIntervalRampTo:Float = 60;

	public var obstacleBaseSpeedStart:Float = 80;
	public var obstacleBaseSpeedMax:Float = 320;
	public var obstacleSpeedRampTo:Float = 60;

	public var debugShow:Bool = false;
	public var debugTimeScale:Float = 1.0;

	override public function create()
	{
		super.create();

		background = new FlxSprite();
		var bg = Paths.image("sky");
		if (bg != null) {
		    background.loadGraphic(bg);
		} else {
		    background.makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(247, 245, 241));
		}

		platform = new FlxSprite(200);
		var p = Paths.image("platform");
		if (p != null) {
		    platform.loadGraphic(p);
		} else {
		    // Freak you, I'm not making a platform here, the image MUST exist.
		}
		platform.scale.set(2, 1);
		platform.y = FlxG.height - platform.height;

		player = new Player(FlxG.width / 2 - 16, FlxG.height - 60);
		obstacles = new FlxTypedGroup<FlxSprite>();
		hud = new Hud();

		add(background);
		add(platform);
		add(player);
		add(obstacles);
		add(hud);

		spawnTimer = 0;
		elapsedTime = 0;
		gameOver = false;

		FlxG.sound.playMusic(Paths.music('bread'), 1, false);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// If game is over, allow restart (R) and otherwise freeze
		if (gameOver)
		{
			// detect single key press to restart
			if (FlxG.keys.justPressed.R)
			{
				// optional: hide overlay immediately (not required when resetting state)
				hud.hideOverlay();

				// clear cache before restart
				Paths.clearCache();

				// clean, idiomatic restart
				FlxG.resetState();
				return;
			}

			// freeze other gameplay while showing overlay/text
			return;
		}

		// Normal gameplay update
	    var scaledElapsed = FlxG.elapsed * debugTimeScale;
		#if debug
    	elapsedTime += scaledElapsed;
		#else
		elapsedTime += FlxG.elapsed;
		#end
		hud.updateDisplay(elapsedTime);

		// --- STEP-BASED DIFFICULTY (every 10s) ---
		var stepDuration:Float = 10.0;
		var steps:Int = Std.int(Math.floor(elapsedTime / stepDuration));
		var maxSteps:Int = Std.int(Math.ceil(obstacleSpeedRampTo / stepDuration));
		var stepSize:Float = (obstacleBaseSpeedMax - obstacleBaseSpeedStart) / Math.max(1, maxSteps);

		var currentObstacleBaseSpeed:Float = obstacleBaseSpeedStart + stepSize * steps;
		if (currentObstacleBaseSpeed > obstacleBaseSpeedMax) currentObstacleBaseSpeed = obstacleBaseSpeedMax;

		// scale player speed proportionally to obstacle base speed so both ramp together
		playerSpeed = playerBaseSpeed * (currentObstacleBaseSpeed / obstacleBaseSpeedStart);

	    // PLAYER movement (use scaled playerSpeed)
    	if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A) player.x -= playerSpeed * scaledElapsed;
    	if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D) player.x += playerSpeed * scaledElapsed;
	    player.x = FlxMath.bound(player.x, 0, FlxG.width - player.width);

		// Spawn interval (linear ramp down)
	    var t = Math.min(elapsedTime, spawnIntervalRampTo) / spawnIntervalRampTo; // 0..1
    	var spawnInterval = spawnIntervalStart + (spawnIntervalMin - spawnIntervalStart) * t;
		#if debug
	    spawnTimer += scaledElapsed;
		#else
		spawnTimer += FlxG.elapsed;
		#end
		if (spawnTimer >= spawnInterval)
		{
			spawnTimer -= spawnInterval;
			spawnObstacle();
		}

		// iterate obstacles safely (cast to FlxSprite)
		for (i in 0...obstacles.length)
		{
			var o = cast(obstacles.members[i], FlxSprite);
			if (o == null || !o.exists)
				continue;

			// remove off-screen obstacles
			if (o.y > FlxG.height + 50)
			{
				o.kill();
			}
			else if (o.overlaps(player))
			{
				onGameOver();
				break;
			}
		}

		// win condition
		if (elapsedTime >= 60)
		{
			onWin();
		}

		#if debug
		// debug toggle: press K to toggle debug overlay, L to increase timeScale, O to decrease, then H to show hitboxes of the sprites
	    if (FlxG.keys.justPressed.K) debugShow = !debugShow;
    	if (FlxG.keys.justPressed.L) debugTimeScale += 1.0; // speed up time for testing
	    if (FlxG.keys.justPressed.O) debugTimeScale = Math.max(0.1, debugTimeScale - 1.0);
		if (FlxG.keys.justPressed.H) if (FlxG.debugger != null) FlxG.debugger.drawDebug = !FlxG.debugger.drawDebug;
		
    	if (debugShow) {
		    FlxG.log.advanced(
    		    't=${elapsedTime} spawnInt=${Math.round(spawnInterval * 100) / 100} debugScale=${debugTimeScale}',
	        	LogStyle.NOTICE, // style (color/icon)
	        	false            // fireOnce: false so it logs every frame
	    	);
		}
		#end
	}

	// --- spawnObstacle (uses 10s step speed + variance) ---
	function spawnObstacle():Void {
    	var w = 24;
	    var ox:Float = FlxG.random.float(0, Math.max(0, FlxG.width - w));

    	// step-based base speed (every 10s)
	    var stepDuration:Float = 10.0;
	    var steps:Int = Std.int(Math.floor(elapsedTime / stepDuration));
	    var maxSteps:Int = Std.int(Math.ceil(obstacleSpeedRampTo / stepDuration));
	    var stepSize:Float = (obstacleBaseSpeedMax - obstacleBaseSpeedStart) / Math.max(1, maxSteps);
	    var baseSpeed:Float = obstacleBaseSpeedStart + stepSize * steps;
	    if (baseSpeed > obstacleBaseSpeedMax) baseSpeed = obstacleBaseSpeedMax;

	    // small random variance so not all obstacles same speed
    	var speed = baseSpeed + FlxG.random.float(-12, 12);

	    var o = new Obstacle(ox, -w, speed);
    	// safety: if Obstacle doesn't set graphic/velocity, force it
	    if (o.width <= 0 || o.height <= 0) o.makeGraphic(w, w, 0xffff0000);
    	if (o.velocity.y == 0) o.velocity.set(0, speed);

	    obstacles.add(o);
    	// trace("spawn: x=" + Std.string(ox) + " speed=" + Std.string(Math.round(speed)));
	}

	function onGameOver():Void
	{
		FlxG.sound.destroy(true);
		gameOver = true;
		hud.showGameOver();
		player.setActive(false);

		for (i in 0...obstacles.length)
		{
			var o = cast(obstacles.members[i], FlxSprite);
			if (o != null)
				o.velocity.set(0, 0);
		}
		FlxG.sound.play(Paths.sound('game-over'), 1);
	}

	function onWin():Void
	{
		gameOver = true;
		hud.showWin();

		for (i in 0...obstacles.length)
		{
			var o = cast(obstacles.members[i], FlxSprite);
			if (o != null)
			{
				o.exists = false;
				o.alive = false;
			}
		}
		FlxG.sound.play(Paths.sound('game-win'), 1);
	}
}

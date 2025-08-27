package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.media.Sound;
import haxe.ds.StringMap;
import lime.utils.Assets;
import flixel.system.FlxAssets;
#if sys
import sys.FileSystem;
#end

/**
 * Minimal asset-paths helper for small HaxeFlixel projects. Universal (Can be used in your other projects) and is easy-to-use
 * - expects images at assets/images/<key>.png
 * - expects sounds at assets/sounds/<key>.<SOUND_EXT>
 * - expects music at assets/music/<key>.<SOUND_EXT>
 * - caches loaded FlxGraphic instances
 */
class Paths
{
    inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

    // simple cache keyed by full asset path
    public static var _cache:StringMap<FlxGraphic> = new StringMap<FlxGraphic>();

    /**
     * Shared folder helper - use when you don't have per-level assets.
     */
    inline public static function getPath(file:String = ""):String
        return 'assets/' + file;

    /**
     * Load (and cache) a FlxGraphic for a shared image key.
     * Example: Paths.image("player") -> loads assets/shared/images/player.png
     */
    public static function image(key:String):FlxGraphic
    {
        var path = getPath('images/' + key + '.png');

        if (_cache.exists(path)) return _cache.get(path);

        if (OpenFlAssets.exists(path, AssetType.IMAGE))
        {
            var bmp:BitmapData = OpenFlAssets.getBitmapData(path);
            if (bmp == null)
            {
                trace('Paths.image: bitmap null for ' + path);
                return null;
            }
            var g:FlxGraphic = FlxGraphic.fromBitmapData(bmp, false, path);
            // keep it in our app-level cache so repeated calls are fast
            _cache.set(path, g);
            return g;
        }

        trace('Paths.image not found: ' + path);
        return null;
    }

    /**
     * Return an OpenFL Sound for a shared sound key (not cached here;
     * OpenFL will usually cache sounds internally). Example: Paths.sound("hit")
     */
    inline static public function sound(key:String):Sound
		return returnSound('$key', 'sounds');

	inline static public function music(key:String):Sound
		return returnSound('$key', 'music');

    public static var currentTrackedSounds:Map<String, Sound> = [];
    public static function returnSound(key:String, ?path:String, ?beepOnNull:Bool = true)
	{
		var file:String = getPath('$path/' + key + '.$SOUND_EXT');

		//trace('precaching sound: $file');
		if(!currentTrackedSounds.exists(file))
		{
			#if sys
			if(FileSystem.exists(file))
				currentTrackedSounds.set(file, Sound.fromFile(file));
			#else
			if(OpenFlAssets.exists(file, SOUND))
				currentTrackedSounds.set(file, OpenFlAssets.getSound(file));
			#end
			else if(beepOnNull)
			{
				trace('SOUND NOT FOUND: $key, PATH: $path');
				FlxG.log.error('SOUND NOT FOUND: $key, PATH: $path');
                return FlxAssets.getSoundAddExtension('flixel/sounds/beep');
			}
		}
		return currentTrackedSounds.get(file);
	}

    /**
     * Clear our FlxGraphic cache (useful before restart/export or to force reload).
     */
    public static function clearCache():Void
    {
        for (k in _cache.keys())
        {
            var g = _cache.get(k);
            if (g != null) FlxG.bitmap.remove(g);
        }

        // clear all sounds that are cached
		for (key => asset in currentTrackedSounds)
		{
			if (asset != null)
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
        _cache = new StringMap<FlxGraphic>();
        currentTrackedSounds = [];
        trace("Paths: cleared asset cache");
    }
}

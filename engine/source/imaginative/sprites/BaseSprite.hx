package imaginative.sprites;

import flixel.math.FlxPoint;
import imaginative.backend.data.TextureType;

/**
 * Tells you what a sprites current animation is supposed to mean.
 *
 * Idea from Codename Engine.
 */
enum abstract AnimationContext(String) from String to String {
	/**
	 * States that the sprite animation is related to dancing.
	 */
	var IsDancing;

	/**
	 * States that the sprite animation is related to singing.
	 */
	var IsSinging;
	/**
	 * States that the sprite animation is related to missing a note.
	 */
	var HasMissed;

	/**
	 * States that the sprite animation can't go back to dancing.
	 */
	var NoDancing;
	/**
	 * States that the sprite animation can't go back to singing.
	 */
	var NoSinging;

	/**
	 * States that the sprite animation is unclear.
	 */
	var Unclear;
}

typedef AnimationMapEntry = {
	var offset:FlxPoint;
	var extra:Map<String, Dynamic>;
}

class BaseSprite extends #if Animate_Atlas animate.FlxAnimate #else flixel.FlxSprite #end {
	public var animations:Map<String, AnimationMapEntry> = new Map<String, AnimationMapEntry>();
	public var animationContext:AnimationContext = Unclear;

	public function new(x:Float = 0, y:Float = 0, ?sprite:ModPath) {
		super(x, y);
		if (sprite != null)
			loadTexture(sprite, true);
	}

	/**
	 * Loads a graphic texture for the sprite to use.
	 * @param path The mod path.
	 * @param width The image grid width.
	 * @param height The image gird height.
	 * @param displayWarning If true, a warning message will appear.
	 * @return The class itself.
	 */
	public function loadImage(path:ModPath, width:Int = 0, height:Int = 0, displayWarning:Bool = false):BaseSprite {
		var _path:ModPath = Paths.image(path);
		if (_path.isFile)
			try {
				loadGraphic(Assets.image(path), !(width < 1 || height < 1), width, height);
			} catch(error:haxe.Exception)
				if (displayWarning) trace('The image failed to load. (path: "${_path.format().ifBlankReplace(_path)}", error: "${error.message}")');
		return this;
	}
	/**
	 * Loads sheet data for the sprite to use.
	 * @param path The mod path.
	 * @param type The wanted texture type.
	 * @param displayWarning If true, a warning message will appear.
	 * @return The class itself.
	 */
	public function loadSheet(path:ModPath, type:TextureType = IsUnknown, displayWarning:Bool = false):BaseSprite {
		var _path:ModPath = Paths.image(path);
		var _sheet_path:ModPath = Paths.spritesheet(path);
		var _type:TextureType = type == IsUnknown ? TextureType.getTypeFromExt(_sheet_path, true) : type;
		if (_path.isFile)
			if (_sheet_path.isFile)
				try {
					frames = Assets.frames(path, _type);
				} catch(error:haxe.Exception)
					try {
						if (displayWarning)
							trace('The spritesheet failed to load, using whole image. (path: "${_path.format().ifBlankReplace(_path)}", type: "$_type", error: "${error.message}")');
						loadImage(path, displayWarning);
					} catch(error:haxe.Exception)
						if (displayWarning) trace('The spritesheet failed to load. (path: "${_path.format().ifBlankReplace(_path)}", type: "$_type", error: "${error.message}")');
			else loadImage(path, displayWarning);
		return this;
	}
	#if Animate_Atlas
	/**
	 * Loads an animate atlas for the sprite to use.
	 * @param path The mod path.
	 * @param settings The animate atlas settings.
	 * @param displayWarning If true, a warning message will appear.
	 * @return The class itself.
	 */
	public function loadAtlas(path:ModPath, ?settings:animate.FlxAnimateFrames.FlxAnimateSettings, displayWarning:Bool = false):BaseSprite {
		var _atlas_path:ModPath = Paths.spritesheet(path, IsAnimateAtlas);
		if (_atlas_path.isFile) {
			try {
				frames = Assets.frames(path, IsAnimateAtlas, settings);
			} catch(error:haxe.Exception)
				try {
					if (displayWarning)
						trace('The atlas failed to load, using first spritemap image. (path: "${_atlas_path.format().ifBlankReplace(_atlas_path)}", type: "$IsAnimateAtlas", error: "${error.message}")');
					loadImage(_atlas_path + 'Animation/spritemap1');
				} catch(error:haxe.Exception)
					if (displayWarning) trace('The atlas failed to load. (path: "${_atlas_path.format().ifBlankReplace(_atlas_path)}", type: "$IsAnimateAtlas", error: "${error.message}")');
		}
		return this;
	}
	/**
	 * Loads a sheet, atlas or graphic for the sprite to use based on checks.
	 * @param path The mod path.
	 * @param settings The animate atlas settings.
	 * @param displayWarning If true, a warning message will appear.
	 * @return The class itself.
	 */
	#else
	/**
	 * Loads a sheet or graphic for the sprite to use based on checks.
	 * @param path The mod path.
	 * @param displayWarning If true, a warning message will appear.
	 * @return The class itself.
	 */
	#end
	public function loadTexture(path:ModPath, #if Animate_Atlas ?settings:animate.FlxAnimateFrames.FlxAnimateSettings, #end displayWarning:Bool = false):BaseSprite {
		var _path:ModPath = Paths.image(path);
		var _sheet_path:ModPath = Paths.spritesheet(path);
		var type:TextureType = TextureType.getTypeFromExt(_sheet_path, true);
		if (_path.isFile) {
			try {
				if (_sheet_path.extension != 'png' && _sheet_path.isFile && type != IsAnimateAtlas) loadSheet(path, type, displayWarning);
				#if Animate_Atlas else if (_sheet_path.isFile && type == IsAnimateAtlas) loadAtlas(path, settings, displayWarning); #end
				else loadImage(path, displayWarning);
			} catch(error:haxe.Exception) {
				try {
					if (displayWarning)
						trace('The asset failed to load, using whole image. (path: "${_path.format().ifBlankReplace(_path)}", type: "$type", error: "${error.message}")');
					loadImage(path, displayWarning);
				} catch(error:haxe.Exception)
					if (displayWarning) trace('The asset failed to load. (path: "${_path.format().ifBlankReplace(_path)}", type: "$type", error: "${error.message}")');
			}
		}
		return this;
	}

	override function initVars():Void {
		super.initVars();
	}

	override function destroy():Void {
		super.destroy();
	}
}
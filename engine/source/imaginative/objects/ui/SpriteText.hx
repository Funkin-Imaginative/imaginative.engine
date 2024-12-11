package imaginative.objects.ui;

import flixel.addons.effects.FlxSkewedSprite;

/**
 * The character typing for SpriteTextCharacter's.
 */
enum abstract SpriteTextCharacterType(String) from String to String {
	/**
	 * Normal type text.
	 */
	var NormalText = 'normal';
	/**
	 * Bold type text.
	 */
	var BoldText = 'bold';
	/**
	 * Italic type text.
	 */
	var ItalicText = 'italic';
	/**
	 * Bold and italic type text.
	 */
	var BoldAndItalic = 'both';
}

typedef SpriteTextCharacterSetup = {
	/**
	 * The character name.
	 */
	var name:String;
	/**
	 * Animation key on data method.
	 */
	var tag:String;
	/**
	 * The offset for the set character.
	 */
	@:default({x: 0, y: 0}) var offset:Position;
	/**
	 * The character type.
	 */
	@:default(NormalText) var type:SpriteTextCharacterType;
}

typedef SpriteTextSetup = {
	/**
	 * The display name.
	 * Mostly for the editor.
	 */
	var ?name:String;
	/**
	 * The framerate of the animation.
	 */
	@:default(24) var fps:Int;
	/**
	 * The character setup information
	 */
	var characters:Array<SpriteTextCharacterSetup>;
	/**
	 * The width for spaces.
	 * Is ignored if space is assigned in the characters array.
	 */
	@:default(50) var spaceWidth:Float;
}

/**
 * SpriteText is this engines version of the alphabet class.
 */
class SpriteText extends FlxTypedSpriteGroup<SpriteTextLine> {
	/**
	 * The field size for the width and height of the text.
	 */
	public var fieldSize(default, null):Position;

	/**
	 * The generalized font for this sprite text instance.
	 */
	public var font:String;
	/**
	 * What this text says.
	 */
	public var text(default, set):String;
	inline function set_text(value:String):String {
		for (member in members) {
			member.kill();
			member.set_id(-1);
		}

		if (value.trim() != '')
			for (i => line in value.split('\n')) {
				var instance:SpriteTextLine = recycle(SpriteTextLine, () -> return new SpriteTextLine(this, line, fieldSize.y, fieldSize.x, font));
				instance.set_id(i);
				if (!members.contains(instance))
					add(instance);
			}
		return text = value;
	}

	inline override public function new(x:Float = 0, y:Float = 0, width:Float = 0, height:Float = 0, text:String = '', size:Int = 1, font:String = 'funkin') {
		super(x, y);
		fieldSize = new Position(width, height);
		this.font = Paths.spriteSheetExists('ui/alphabets/$font') ? font : 'funkin';

		this.text = text;
	}
}

/**
 * SpriteTextLine is used for each new line of text in a SpriteText.
 */
class SpriteTextLine extends FlxTypedSpriteGroup<SpriteTextCharacter> {
	/**
	 * The text lines parent.
	 */
	public var parent(default, null):SpriteText;
	/**
	 * The index of the line.
	 */
	public var id(default, null):Int = -1;
	/**
	 * Allow's the parent to set the id.
	 * @param value The new id.
	 * @return `Int` The new id.
	 */
	@:allow(imaginative.objects.ui.SpriteText)
	inline function set_id(value:Int):Int
		return id = value;

	/**
	 * The general character field width.
	 */
	public var charWidth:Float;
	/**
	 * The field height of this line.
	 */
	public var fieldHeight:Float;

	/**
	 * The generalized font for this sprite text instance.
	 */
	public var font:String;
	/**
	 * What this line says.
	 */
	public var line(default, set):String;
	function set_line(value:String):String {
		for (member in members) {
			member.kill();
			member.set_id(-1);
		}

		if (value.trim() != '') {
			var start:Array<String> = value.split('');

			var result:Array<String> = [];
			var key:Array<String> = [];

			var forceStop:Bool = false;
			var cancelSymbol:Bool = false;
			var doingSymbol:Bool = false;

			for (i => character in start) {
				if (start[i - 1] != '/' && character == '/' && start[i + 1] == '[')
					cancelSymbol = true;
				else if (start[i - 1] == '/' && character == '/' && start[i + 1] == '[')
					forceStop = true;

				if (character == '[')
					doingSymbol = true;

				if (doingSymbol && !cancelSymbol)
					if (character == '[' || character == ']') {} else
						key.push(character);
				else if (!forceStop)
					result.push(character);
				forceStop = false;

				if (doingSymbol && character == ']') {
					doingSymbol = false;
					if (!cancelSymbol) {
						result.push(key.join(''));
						key = [];
					} else
						cancelSymbol = false;
				}
			}
			for (i => character in result) {
				var instance:SpriteTextCharacter = recycle(SpriteTextCharacter, () -> return new SpriteTextCharacter(this, character, charWidth, font));
				instance.set_id(i);
				if (!members.contains(instance))
					add(instance);
			}
		}

		return line = value;
	}

	@:allow(imaginative.objects.ui.SpriteText)
	inline override function new(parent:SpriteText, line:String = '', height:Float = 0, characterWidth:Float = 0, font:String = 'funkin') {
		super();
		this.parent = parent;
		fieldHeight = height;

		charWidth = characterWidth;
		this.font = font;

		this.line = line;
	}

	/**
	 * Get's the parent SpriteText's fieldSize.y.
	 * @return `Float` The parent field height.
	 */
	inline public function getParentHeight():Float
		return parent.fieldSize.y;
}

/**
 * SpriteTextCharacter's are the individual characters of a SpriteText.
 */
class SpriteTextCharacter extends FlxSkewedSprite {
	/**
	 * The characters parent.
	 */
	public var parent(default, null):SpriteTextLine;
	/**
	 * The index of the character on the line.
	 */
	public var id(default, null):Int = -1;
	/**
	 * Allow's the parent to set the id.
	 * @param value The new id.
	 * @return `Int` The new id.
	 */
	@:allow(imaginative.objects.ui.SpriteTextLine)
	inline function set_id(value:Int):Int
		return id = value;

	/**
	 * The field width of this character.
	 */
	public var fieldWidth:Float;

	/**
	 * What this character is.
	 */
	public var character:String;
	/**
	 * If true, the character sprite is bold.
	 */
	public var isBold(default, set):Bool = false;
	inline function set_isBold(value:Bool):Bool {
		return isBold = value;
	}
	/**
	 * If true, the character sprite is italic.
	 */
	public var isItalic(default, set):Bool = false;
	inline function set_isItalic(value:Bool):Bool {
		return isItalic = value;
	}

	@:allow(imaginative.objects.ui.SpriteTextLine)
	inline override function new(parent:SpriteTextLine, character:String = '', width:Float = 0, font:String = 'funkin') {
		super();
		this.parent = parent;
		fieldWidth = width;
		this.character = character;
	}

	/**
	 * Get's the parent SpriteText's fieldSize.y.
	 * @return `Float` The parent field height.
	 */
	inline public function getParentWidth():Float
		return parent.parent.fieldSize.x;
}
package;
 
import flash.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxBasePreloader;
import openfl.display.Sprite;

class Preloader extends FlxBasePreloader {
    public function new(MinDisplayTime:Float=3, ?AllowedURLs:Array<String>) {
        super(MinDisplayTime, AllowedURLs);
    }
     
    var logo:FlxSprite;
     
    override function create() {
        this._width = Lib.current.stage.stageWidth;
        this._height = Lib.current.stage.stageHeight;
         
        var ratio:Float = this._width / 2560; //This allows us to scale assets depending on the size of the screen.
         
        logo = new FlxSprite(0, 0, 'art');
        logo.addChild(new Bitmap(new LogoImage(0,0))); //Sets the graphic of the sprite to a Bitmap object, which uses our embedded BitmapData class.
        logo.scale.x = logo.scale.y = ratio;
        logo.x = ((this._width) / 2) - ((logo.width) / 2);
        logo.y = (this._height / 2) - ((logo.height) / 2);
        addChild(logo); //Adds the graphic to the NMEPreloader's buffer.
         
        super.create();
    }
     
    override function update(Percent:Float) {
        if(Percent < 69)
        {
            logo.scale.x += Percent / 1920;
            logo.scale.y += Percent / 1920;
            logo.x -= Percent * 0.6;
            logo.y -= Percent / 2;
        }else{
            logo.scale.x = this._width / 1280;
            logo.scale.y = this._width / 1280;
            logo.x = ((this._width) / 2) - ((logo.width) / 2);
            logo.y = (this._height / 2) - ((logo.height) / 2);
        }
        
        super.update(Percent);
    }
}
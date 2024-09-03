# ../content/states/
This is where you store your script files for custom states or for editing pre-existing ones!

vVv simple script example vVv
```haxe
var huh:FlxSprite;

function create() {
    huh = new FlxSprite(135, 273, getAsset('combo/sick'));
    huh.scale.set(0.8, 0.8);
    huh.updateHitbox();
    add(huh);
}
```
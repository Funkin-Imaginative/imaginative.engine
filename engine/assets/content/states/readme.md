# ../content/states/
This is where you store your script files for custom states or for editing pre-existing ones!

example below
```haxe
var huh:BaseSprite;

function create() {
    huh = new BaseSprite(135, 273, 'gameplay/combo/sick');
    huh.scale.set(0.8, 0.8);
    huh.updateHitbox();
    add(huh);
}
```
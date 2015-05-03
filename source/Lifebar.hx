package;

import flixel.FlxSprite;
import flixel.FlxG;

class Lifebar extends FlxSprite{
	var _state:PlayState;
	var _life:FlxSprite;
	public function new(X:Float, Y:Float, state:PlayState){
		super(X, Y);
		_state = state;
		_life = new FlxSprite();
		loadGraphic("assets/images/vida-borde.png");
		_life.loadGraphic("assets/images/vida-fill.png");
		_life.origin.set(0, 0);
		_state.add(_life);
		_state.add(this);
	}

	public function updateBar(X:Float, Y:Float, life:Int){
		x = X-FlxG.width/2+10;
		if(x<0){
			x = 0;
		}
		y = Y-FlxG.height/2+10;
		_life.x = x;
		_life.y = y;
		var scale:Float = life/Constants.playerLife;
		_life.scale.set(scale, 1);
	}
}

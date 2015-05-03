package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;

class Bullet extends FlxSprite{
	var _state:PlayState;
	var _direction:Float;
	public function new(X:Float, Y:Float, direction:Float, state:PlayState){
		super(X, Y);
		_state = state;
		loadGraphic("assets/images/bullet.png");
		_state.add(this);
		_state.addBullet(this);
		_direction = direction;
		angle = direction*360/(Math.PI*2);
	}

	public function updateBullet(time:Float){
		x += time*Constants.bulletSpeed*FlxG.elapsed*Math.cos(_direction);
		y += time*Constants.bulletSpeed*FlxG.elapsed*Math.sin(_direction);
	}
}

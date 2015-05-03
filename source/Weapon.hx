package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.system.FlxSound;

class Weapon extends FlxSprite{
	var _facingRight:Bool;
	var _lastShoot:Float;
	var _state:PlayState;
	var _shootSound:FlxSound;
	public function new(X:Float, Y:Float, facingRight:Bool, state:PlayState){
		super(X, Y);
		_lastShoot = 0;
		_facingRight = facingRight;
		flipX = !_facingRight;
		loadGraphic("assets/images/gun.png");
		if(!_facingRight){
			origin.set(width, height/2);
		}
		else{
			origin.set(0, height/2);
		}
		state.add(this);
		_shootSound = FlxG.sound.load("assets/sounds/shoot.wav");
		_state = state;
	}

	public function updateWeapon(X:Float, Y:Float){
		x = X-10;
		y = Y+32;
		if(!_facingRight){
			x += 54;
		}
	}

	public function shoot(actualTime:Float, direction:Float):Void{
		if(_lastShoot+Constants.enemyReload<actualTime){
			//shoot
			_lastShoot = actualTime;
			_shootSound.play();
			var bullet:Bullet = new Bullet(x, y, direction, _state);
		}
		if(!_facingRight)
			angle = direction*360/(Math.PI*2);
		else
			angle = direction*360/(Math.PI*2)-180;
	}

	public function viewsPlayer(actualTime:Float):Void{
		_lastShoot = actualTime-Constants.enemyReload-0.1;
	}

	public function stopViewsPlayer():Void{
		angle = 0;
	}

	public function setFacingRight(facingRight:Bool):Void{
		_facingRight = facingRight;
		flipX = !_facingRight;
		if(_facingRight){
			origin.set(width, height/2);
		}
		else{
			origin.set(0, height/2);
		}
	}

	public function killWeapon():Void{
		_state.remove(this);
	}
}

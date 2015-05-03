package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxAngle;
import flixel.system.FlxSound;
import flixel.group.FlxTypedGroup;

enum State{
	walking;
	iddle;
	attacking;
	dead;
}
	
class Enemy extends FlxSprite{
	var _facingRight:Bool;
	var _actualstate:State;
	var _iddleTime:Float;
	var _state:PlayState;
	var _weapon:Weapon;
	var _admir:FlxSprite;
	var _interr:FlxSprite; //TODO
	var _isAdmir:Bool;
	var _isInterr:Bool;
	var _scream1:FlxSound;
	var _scream2:FlxSound;
	var _scream3:FlxSound;


	public function new(X:Float, Y:Float, state:PlayState){
		super(X, Y);
		_actualstate = State.iddle;
		_iddleTime = 0;
		_state = state;
		loadGraphic("assets/images/militar.png");
		_state.add(this);
		_facingRight = true;
		_weapon = new Weapon(x, y, _facingRight, _state);
		_admir = new FlxSprite();
		_admir.loadGraphic("assets/images/admiracion.png");
		_interr = new FlxSprite();
		_interr.loadGraphic("assets/images/interrogacion.png");
		_isAdmir = false;
		_isInterr = false;
		_scream1 = FlxG.sound.load("assets/sounds/scream1.wav");
		_scream2 = FlxG.sound.load("assets/sounds/scream2.wav");
		_scream3 = FlxG.sound.load("assets/sounds/scream3.wav");
	}

	public function enemyUpdate(time:Float, actualTime:Float, player:Player, floor:FlxGroup):Void{
		flipX = !_facingRight;
		switch(_actualstate){
			case walking:
				var aux:FlxObject = new FlxObject(x, y);
				aux.width = width;
				aux.height = height;
				if(_facingRight){
					x -= time*FlxG.elapsed*Constants.enemyWalkSpeed;
					aux.x-= width;
					aux.y+= height;
					if(!FlxG.collide(aux, floor)){ // comprobamos que no se vaya a caer
						_actualstate = State.iddle;
						_iddleTime = actualTime;
					}
					aux.x+=width;
					aux.y-=height;
				}
				else{
					x += time*FlxG.elapsed*Constants.enemyWalkSpeed;
					aux.x+= width;
					aux.y+= height;
					if(!FlxG.collide(aux, floor)){ // comprobamos que no se vaya a caer
						_actualstate = State.iddle;
						_iddleTime = actualTime;
					}
					aux.x-=width;
					aux.y-=height;
				}

				if((FlxMath.distanceBetween(this, player)<200)){
					if(((_facingRight && player.x < x) || (!_facingRight && player.x > x)) && _state.seesPlayer(this)){
						_actualstate = State.attacking;
						addAdmir();					}
				}
			case iddle:
				if((_iddleTime + 3) < actualTime){
					_actualstate = State.walking;
					removeInterr();
					_facingRight = !_facingRight;
				}
				if((FlxMath.distanceBetween(this, player)<200)){
					if(((_facingRight && player.x < x) || (player.x > x)) && _state.seesPlayer(this)){
						_actualstate = State.attacking;
						removeInterr();
						addAdmir();
					}
			}
			case attacking:
				if(player.x < x){
					_facingRight = true;
				}
				else{
					_facingRight = false;
				}
				if(FlxMath.distanceBetween(this, player)>300 || !_state.seesPlayer(this)){
					_actualstate = State.iddle;
					_iddleTime = actualTime;
					removeAdmir();
					addInterr();
				}
				else{
					_weapon.shoot(actualTime, FlxAngle.angleBetween(this, player));
				}
			case dead:
		}
		_weapon.setFacingRight(_facingRight);
		_weapon.updateWeapon(x, y);
	}

	public function killEnemy():Void{
		if(_actualstate != State.dead){
			_actualstate = State.dead;
			loadGraphic("assets/images/militar-muerto.png");
			removeAdmir();
			_weapon.killWeapon();
			switch(Std.random(2)){
				case 0:
					_scream1.play();
				case 1:
					_scream2.play();
				case 2:
					_scream3.play();
			}
		}
	}

	public function collideWall():Void{
		_facingRight = !_facingRight;
	}

	public function isDead():Bool{
		if(_actualstate == State.dead){
			return true;
		}
		else{
			return false;
		}
	}

	private function removeAdmir():Void{
		if(_isAdmir){
			_state.remove(_admir);
			_isAdmir = false;
			_weapon.stopViewsPlayer();
		}
	}

	private function addAdmir():Void{
		if(!_isAdmir){
			_admir.x = x;
			_admir.y = y-64;
			_state.add(_admir);
			_isAdmir = true;
		}
	}

	private function removeInterr():Void{
		if(_isInterr){
			_state.remove(_interr);
			_isInterr = false;
		}
	}

	private function addInterr():Void{
		if(!_isInterr){
			_interr.x = x;
			_interr.y = y-64;
			_state.add(_interr);
			_isInterr = true;
		}
	}


}

package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.util.FlxAngle;
import flixel.system.FlxSound;

class Player extends FlxSprite{
	private var _state:PlayState;
	private var _vectorSalto:FlxPoint;
	private var _vectorApuntado:FlxPoint;
	private var _posArrow:Float; //variable para dibujar la flecha de salto de forma "dinámica"
	private var _floor:FlxGroup;
	private var _groupArrow:FlxGroup;
	private var _isArrowColliding:Bool;
	private var _life:Int;
	private var _legs:Legs;
	private var _lastVelocity:FlxPoint;
	private var _jumpSound:FlxSound;
	public function new(state:PlayState, X:Float = 0, Y:Float = 0, floor:FlxGroup) : Void {
		super(X, Y);
		_state = state;
		_state.add(this);
		_vectorSalto = new FlxPoint();
		_vectorApuntado = new FlxPoint();
		_floor = floor;
		acceleration.y = Constants.gravity;
		loadGraphic("assets/images/head.png");
		_posArrow = 0;
		_groupArrow = new FlxGroup();
		_isArrowColliding = false;
		_life = Constants.playerLife;
		flipX = true;
		_legs = new Legs(_state, x, y);
		_lastVelocity = new FlxPoint(0,0);
		_jumpSound = FlxG.sound.load("assets/sounds/Jump.wav");
	}

	public function updatePlayer(time:Float) : Bool{
		for(g in _groupArrow){
			_state.remove(g);
		}
		_groupArrow.clear();
		if(_life>0){
			if(time>0.1){
				velocity.y += acceleration.y*FlxG.elapsed;
				y += velocity.y;
				x += velocity.x;
				_legs.updateLegs(time, x, y, FlxAngle.getAngle(new FlxPoint(0,0), velocity));
				if(velocity.x > 0){
					flipX = true;
				}
				else{
					flipX = false;
				}
				_lastVelocity.x = velocity.x;
				_lastVelocity.y = velocity.y;
			}
			else{
				velocity.y = 0;
				velocity.x = 0;
				_legs.updateLegs(time, x, y, 0);
				return controles();
			}
			return false;
		}
		else{
			velocity.y += acceleration.y * FlxG.elapsed;
			x += velocity.x;
			y += velocity.y;
			if(time == 0.1){
				velocity.x = 0;
				velocity.y = 0;
			}
		}
		return true;
	}

	private function controles():Bool{
		//controles en ordenador
#if !mobile
		if (FlxG.mouse.justPressed){
#else
			var touch = FlxG.touches.getFirst();
			if(touch!=null){
			if(touch.justPressed){
#end
			_posArrow = 0;
		}
#if !mobile
		if (FlxG.mouse.pressed){
			_vectorSalto.x = _vectorApuntado.x = FlxG.mouse.screenX-FlxG.width/2;
			_vectorSalto.y = _vectorApuntado.y = FlxG.mouse.screenY-FlxG.height/2;
#else
		if(touch.pressed){
				_vectorSalto.x = _vectorApuntado.x = touch.screenX-FlxG.width/2;
				_vectorSalto.y = _vectorApuntado.y = touch.screenY-FlxG.height/2;
#end
			if(_vectorSalto.x > 0){
					flipX = true;
			}
			else{
					flipX = false;
			}
			var aux = Math.sqrt(_vectorSalto.x*_vectorSalto.x + _vectorSalto.y*_vectorSalto.y);
			if(aux>Constants.jumpSpeed){
				_vectorApuntado.x = _vectorSalto.x /= aux / Constants.jumpSpeed;
				_vectorApuntado.y = _vectorSalto.y /= aux / Constants.jumpSpeed;
			}
			_isArrowColliding = false;
			var auxX:Float = x;
			var auxY:Float = y-4;
			var auxVY:Float = _vectorSalto.y;
			var auxArrow:FlxObject = null;
			var auxArrowSprite:FlxSprite = null;
			var auxvelX:Float = 0;
			var auxvelY:Float = 0;
			var auxIterat:Int = 0;
			while(!_isArrowColliding){
				var arrow:FlxObject = new FlxObject(auxX, auxY);
				auxvelX = -auxX;
				auxvelY = -auxY;
				auxX = arrow.x += _vectorSalto.x*FlxG.elapsed*2;
				auxY = arrow.y += auxVY*FlxG.elapsed*2;
				auxVY += acceleration.y/1.95*0.2;
				arrow.width = 64;
				arrow.height = 64;
				FlxG.collide(arrow, _floor, collides);
				if(auxIterat>=10 || _isArrowColliding){
					var arrowSprite:FlxSprite = new FlxSprite(arrow.x, arrow.y);
					arrowSprite.loadGraphic("assets/images/trozo-flecha.png");
					_groupArrow.add(arrowSprite);
					_state.add(arrowSprite);
					auxArrowSprite = arrowSprite;
					auxIterat = 0;
				}
				auxArrow = arrow;
				auxIterat++;
			}
			auxvelX+=auxX;
			auxvelY+=auxY;
			auxArrowSprite.loadGraphic("assets/images/punta-flecha.png");
			auxArrowSprite.angle = 90-(Math.atan2(auxvelX, auxvelY)*360/(Math.PI*2));
			_posArrow += FlxG.elapsed*5;
		}
#if !mobile
		if (FlxG.mouse.justReleased){
#else
		if(touch.justReleased){
#end
			if(_lastVelocity.y>0){
				y-=4; // arregla el bug de quedarse enganchado al suelo (la velocidad no queda a 0)
			}
			velocity.x = _vectorSalto.x/10;
			velocity.y = _vectorSalto.y/10;
			_vectorApuntado.x = 0;
			_vectorApuntado.y = 0;
			_jumpSound.play();
			return true;
		}
#if mobile
		}
#end
		return false;
	}

	private function collides(a:FlxSprite, b:FlxSprite):Void{
		 _isArrowColliding = true;
	}

	public function getVectorApuntado():FlxPoint{
		return _vectorApuntado;
	}

	public function addLife(number:Int):Void{
		_life = _life + number > Constants.playerLife ? Constants.playerLife : _life + number;
	}

	public function substractLife(number:Int):Void{
		if(_life>0){
			_life -= number;
			if(_life<=0){
				_life = 0;
				_state.killPlayer();
				loadGraphic("assets/images/jugador-muerto.png");
				_legs.killLegs();
			}
		}
	}
	public function setPosState(pos:Int):Void{
		_legs.setPosState(pos);
	}
	public function getVelX():Float{
		return _lastVelocity.x;
	}
	public function getVelY():Float{
		return _lastVelocity.y;
	}

	public function getLife():Int{
		return _life;
	}
}

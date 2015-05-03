package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.tile.FlxTilemap;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	var _player:Player;
	var _time:Float;
	var _level:TiledLevel;
	var _cameraHandler:CameraHandler;
	var _actualTime:Float;
	var _groupBullets:FlxTypedGroup<Bullet>;
	var _playerDead:Bool;
	var _lifeBar:Lifebar;
	var _gameOver:FlxSprite;
	var _groupButtons:FlxTypedGroup<FlxButton>;
	var _button1:FlxButton;
	var _button2:FlxButton;
	var _button3:FlxButton;
	var _background:FlxSprite;
	var _background1:FlxSprite;
	var _background2:FlxSprite;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_time = 1;
		_actualTime = 0;
		bgColor = FlxColor.WHITE;
		createStage();
		_cameraHandler = new CameraHandler(_player);
		_groupBullets = new FlxTypedGroup<Bullet>();
		_playerDead = false;
		_lifeBar = new Lifebar(_cameraHandler.getX(), _cameraHandler.getY(), this);
		super.create();
	}

	function createStage():Void{
		_level = new TiledLevel("assets/tiled/level"+Constants.level+".tmx");
		_background = new FlxSprite(0, 0);
		_background.loadGraphic("assets/tiled/colored_shroom.png");
		_background.origin.set(0,0);
		_background.scale.set(FlxG.width/_background.width, FlxG.height/_background.height);
		add(_background);
		_background1 = new FlxSprite(0, 0);
		_background1.loadGraphic("assets/tiled/colored_shroom.png");
		_background1.origin.set(0,0);
		_background1.scale.set(FlxG.width/_background.width, FlxG.height/_background.height);
		add(_background1);
		_background2 = new FlxSprite(0, 0);
		_background2.loadGraphic("assets/tiled/colored_shroom.png");
		_background2.origin.set(0,0);
		_background2.scale.set(FlxG.width/_background.width, FlxG.height/_background.height);
		add(_background2);
	add(_level.foregroundTiles);
	_level.loadObjects(this);
	}

	private function updateBackground():Void{
		_background.x = _cameraHandler.getX()-FlxG.width/2;
		_background.y = _cameraHandler.getY()-FlxG.height/2;
		_background1.x = _cameraHandler.getX()-FlxG.width/2-FlxG.width;
		_background1.y = _cameraHandler.getY()-FlxG.height/2;
		_background2.x = _cameraHandler.getX()-FlxG.width/2+FlxG.width;
		_background2.y = _cameraHandler.getY()-FlxG.height/2;
	}

	private function createButtons():Void{
		_button1 = new FlxButton(0, 0, "", retry);
		_button1.loadGraphic("assets/images/button-retry.png", false, 512, 110, true);
		_button1.scale.set(0.5, 0.5);
		_button1.x = FlxG.width/2 - _button1.width/2;
		_button1.y = FlxG.height/2;
		add(_button1);
		_button2 = new FlxButton(0, 0, "", mainMenu);
		_button2.loadGraphic("assets/images/button-mainmenu.png", false, 512, 110, true);
		_button2.scale.set(0.5, 0.5);
		_button2.x = FlxG.width/2 - _button1.width/2;
		_button2.y = FlxG.height/2 + 64;
		add(_button2);
#if !js
		_button3 = new FlxButton(0, 0, "", exit);
		_button3.loadGraphic("assets/images/button-exit.png", false, 512, 110, true);
		_button3.scale.set(0.5, 0.5);
		_button3.x = FlxG.width/2 - _button1.width/2;
		_button3.y = FlxG.height/2+ 128;
		add(_button3);
#end
	}

	public function setPlayer(player:Player):Void{
		_player = player;
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
		_actualTime += FlxG.elapsed*_time;
		if(_player.updatePlayer(_time) == true){
			_time = 1;
			if(_player.getLife()<=0){
				FlxG.collide(_player, _level.getForeground(), playerCollideWall);
			}
		}
		else{
			FlxG.collide(_player, _level.getForeground(), playerCollideWall);
		}
		for(e in _level.getEnemies()){
			e.enemyUpdate(_time, _actualTime, _player, _level.getForeground());
		}
		for(b in _groupBullets){
			b.updateBullet(_time);
		}
		FlxG.collide(_level.getForeground(), _level.getEnemies(), enemyCollideWall);
		FlxG.overlap(_player, _level.getEnemies(), playerCollideEnemy);
		FlxG.overlap(_player, _groupBullets, playerOverlapBullet);
		FlxG.collide(_groupBullets, _level.getForeground(), floorOverlapBullet);
		_cameraHandler.update(_time, _actualTime);
		_lifeBar.updateBar(_cameraHandler.getX(), _cameraHandler.getY(), _player.getLife());
		if(_playerDead){
			_gameOver.x = _cameraHandler.getX()-_gameOver.width/2;
			_gameOver.y = _cameraHandler.getY()-FlxG.height + 10;
		}
		updateBackground();
		checkEnemies();
	}

	private function checkEnemies(){
		var boo = true;
		for(e in _level.enemies){
			if(!e.isDead()){
				boo = false;
			}
		}
		if(boo){
			if(Constants.level<4){
				Constants.level += 1;
				FlxG.switchState(new PlayState());
			}
			else{
				Constants.level = 2;
				FlxG.switchState(new MenuState());
			}
		}
	}

	private function playerCollideWall(P:Player, T:FlxTilemap):Void{
		_time = 0.1;
		if(P.y %32 == 0){
				if(P.getVelY()>0){
				P.setPosState(0);
			}
			else{
				P.setPosState(1);
			}
		}
		else if(P.x %32 == 0){
				if(P.getVelX()>0){
				P.setPosState(3);
			}
			else{
				P.setPosState(2);
			}
		}
	}

	private function playerCollideEnemy(P:Player, E:Enemy):Void{
		if(!E.isDead() && P.getLife()>0){
			E.killEnemy();
			P.addLife(1);
		}
	}

	private function enemyCollideWall(T:TiledTileSet, E:Enemy){
		E.collideWall();
	}

	public function seesPlayer(enemy:Enemy):Bool{
		return _level.seesPlayer(enemy, _player);
	}

	public function addBullet(bullet:Bullet):Void{
		_groupBullets.add(bullet);
	}

	public function playerOverlapBullet(p:Player, b:Bullet):Void{
		_cameraHandler.cameraShake(b.angle, _actualTime);
		_groupBullets.remove(b);
		remove(b);
		b.kill();
		p.substractLife(2);
	}

	public function floorOverlapBullet(b:Bullet, t:TiledTileSet):Void{
		_groupBullets.remove(b);
		remove(b);
		b.kill();
	}

	public function killPlayer():Void{
		_playerDead = true;
		_gameOver = new FlxSprite(0, 0);
		_gameOver.loadGraphic("assets/images/game-over.png");
			_gameOver.x = _cameraHandler.getX()-FlxG.width;
			_gameOver.y = _cameraHandler.getY()-(FlxG.height/(7/4));
			_gameOver.scale.set(0.5, 0.5);
		add(_gameOver);
		createButtons();
	}

	private function retry():Void{
		FlxG.switchState(new PlayState());
	}

	private function mainMenu():Void{
		FlxG.switchState(new MenuState());
	}
	
#if !js
	private function exit():Void{
		Sys.exit(0);
	}
#end
}

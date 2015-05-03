package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxMath;
import flixel.util.FlxDestroyUtil;

/**
 * A FlxState which can be used for the game's menu.
 */
class MenuState extends FlxState
{
	private var _width:Int;
	private var _height:Int;
	private var _btnPlay:FlxButton;
	private var _btnHow:FlxButton;
	private var _btnExit:FlxButton;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		_width = FlxG.width;
		_height = FlxG.height;
		_btnPlay = new FlxButton(0, 0, "", clickPlay);
		_btnPlay.loadGraphic("assets/images/button-play.png", false, 512, 108, true);
		_btnPlay.x = _width/2-_btnPlay.width/2;
		_btnPlay.y = _height/2-_btnPlay.height*3/2-10;
		add(_btnPlay);
		_btnHow = new FlxButton(0, 0, "", clickTutorial);
		_btnHow.loadGraphic("assets/images/button-how.png", false, 512, 108, true);
		_btnHow.x = _width/2-_btnPlay.width/2;
		_btnHow.y = _height/2-_btnPlay.height/2;
		add(_btnHow);
#if !js
		_btnExit = new FlxButton(0, 0, "", clickExit);
		_btnExit.loadGraphic("assets/images/button-exit.png", false, 512, 108, true);
		_btnExit.x = _width/2-_btnPlay.width/2;
		_btnExit.y = _height/2+_btnPlay.height/2+10;
		add(_btnExit);
		//
#else
		_btnPlay.y += _btnPlay.height/2;
		_btnHow.y += _btnHow.height/2;
#end
		super.create();
	}

	private function clickPlay():Void {
		FlxG.switchState(new PlayState());
	}

	private function clickTutorial():Void{
		FlxG.switchState(new TutorialState());
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
		_btnPlay = FlxDestroyUtil.destroy(_btnPlay);
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	

#if !js
	private function clickExit():Void {
		Sys.exit(0);
	}
#end
}

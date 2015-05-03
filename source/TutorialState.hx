package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxButton;

class TutorialState extends FlxState{
	private var _button:FlxButton;
	override public function create():Void{
		_button = new FlxButton(0, 0, "", back);
		_button.loadGraphic("assets/images/tutorial.png", false, 640, 480, true);
		_button.x = FlxG.width/2 - _button.width/2;
		add(_button);
		super.create();
	}

	override public function destroy():Void{
		super.destroy();
	}

	private function back():Void{
		FlxG.switchState(new MenuState());
	}
}

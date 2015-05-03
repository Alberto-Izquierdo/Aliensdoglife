package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;

enum Statelegs{
	up;
	down;
	left;
	right;
}

class Legs extends FlxSprite{
	var _position:Statelegs;
	var _state:FlxState;
	public function new(state:FlxState, X:Float = 0, Y:Float = 0) : Void {
		super(X,Y);
		loadGraphic("assets/images/leg.png", true, 64, 64);
		_position = Statelegs.down;
		_state = state;
		animation.add("s", [0], 0, false);
		animation.add("d", [0,1,2,3,4,5,6,7,8,9], 15, true);
		_state.add(this);
		origin.y -= 10;
	}

	public function updateLegs(time:Float, X:Float, Y:Float, angle_rot:Float):Void{
		x = X;
		y = Y+10;
		if(time>0.1){
			animation.play("d");
			angle = angle_rot;
		}
		else{
			animation.play("s");
			switch(_position){
				case Statelegs.down:
					angle = 0;
				case Statelegs.up:
					angle = 180;
				case Statelegs.right:
					angle = 90;
				case Statelegs.left:
					angle = 270;
			}
		}
	}

	public function setPosState(pos:Int):Void{
		switch(pos){
			case 0:
				_position = Statelegs.down;
			case 1:
				_position = Statelegs.up;
			case 2:
				_position = Statelegs.right;
			case 3:
				_position = Statelegs.left;
		}
	}

	public function killLegs():Void{
		_state.remove(this);
	}
}

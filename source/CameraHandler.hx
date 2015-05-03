package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxPoint;

class CameraHandler{
	var _posicionCamara:FlxObject;
	var _player:Player;
	var _dondeIr:FlxPoint;
	var _velCamara:FlxPoint;
	var _angleShake:Float;
	var _hitTime:Float;
	var _actualShake:Float;
	var _actualTime:Float;
	public function new(player:Player){
		_hitTime = 0;
		_player = player;
		_posicionCamara = new FlxObject(player.x, player.y);
		FlxG.camera.follow(_posicionCamara);
		_dondeIr = new FlxPoint();
		_velCamara = new FlxPoint();
		_angleShake = 0;
		_actualShake = 0;
		_actualTime = 0;
	}
	public function update(time:Float, actualTime:Float):Void{
		_actualTime += FlxG.elapsed;
		if(time==0.1){
			_dondeIr.x = _player.x + _player.getVectorApuntado().x;
			_dondeIr.y = _player.y + _player.getVectorApuntado().y;
		}
		else{
			_dondeIr.x = _player.x + _player.velocity.x*10;
			_dondeIr.y = _player.y + _player.velocity.y*10;
		}
		_velCamara.x = _dondeIr.x - _posicionCamara.x;
		_velCamara.y = _dondeIr.y - _posicionCamara.y;
			if(_actualShake > 0){
			_posicionCamara.x -= Math.cos(_angleShake)*_actualShake*Math.sin((_hitTime-_actualTime)*40);
			_posicionCamara.y -= Math.sin(_angleShake)*_actualShake*Math.sin((_hitTime-_actualTime)*40);
			_actualShake -= FlxG.elapsed*60;
		}
		_posicionCamara.x += _velCamara.x*FlxG.elapsed*20;
		_posicionCamara.y += _velCamara.y*FlxG.elapsed*20;
	}

	public function cameraShake(angle:Float, hitTime:Float):Void{
		_actualShake = Constants.cameraShake;
		_hitTime = _actualTime;
	}

	public function getX():Float{
		return _posicionCamara.x;
	}

	public function getY():Float{
		return _posicionCamara.y;
	}
}

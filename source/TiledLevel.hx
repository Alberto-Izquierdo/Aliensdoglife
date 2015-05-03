package;

import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;
import haxe.io.Path;
import flixel.tile.FlxTilemap;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectGroup;

class TiledLevel extends TiledMap {

	private inline static var c_PATH_LEVEL_TILESHEETS = "assets/tiled/";

	public var foregroundTiles:FlxGroup;
	public var backgroundTiles:FlxGroup;
	public var enemies:FlxTypedGroup<Enemy>;
	private var collidableTileLayers:Array<FlxTilemap>;
	private var privtilemap:FlxTilemap;

	public function new(tiledLevel:Dynamic)
	{
		super(tiledLevel);
		
		foregroundTiles = new FlxGroup();
		backgroundTiles = new FlxGroup();
		enemies = new FlxTypedGroup<Enemy>();
		
		FlxG.camera.setBounds(0, 0, fullWidth, fullHeight, true);
		
		// Load Tile Maps
		for (tileLayer in layers)
		{
			var tileSheetName:String = tileLayer.properties.get("tileset");
			
			if (tileSheetName == null)
				throw "'tileset' property not defined for the '" + tileLayer.name + "' layer. Please add the property to the layer.";
				
			var tileSet:TiledTileSet = null;
			for (ts in tilesets)
			{
				if (ts.name == tileSheetName)
				{
					tileSet = ts;
					break;
				}
			}
			
			if (tileSet == null)
				throw "Tileset '" + tileSheetName + " not found. Did you mispell the 'tilesheet' property in " + tileLayer.name + "' layer?";
				
			var imagePath 		= new Path(tileSet.imageSource);
			var processedPath 	= c_PATH_LEVEL_TILESHEETS + imagePath.file + "." + imagePath.ext;
			
			var tilemap:FlxTilemap = new FlxTilemap();
			tilemap.widthInTiles = width;
			tilemap.heightInTiles = height;
			tilemap.loadMap(tileLayer.tileArray, processedPath, tileSet.tileWidth, tileSet.tileHeight, 0, 1, 1, 1);
			
			if (tileLayer.properties.contains("nocollide"))
			{
				backgroundTiles.add(tilemap);
			}
			else
			{
				if (collidableTileLayers == null)
					collidableTileLayers = new Array<FlxTilemap>();
				
				foregroundTiles.add(tilemap);
				collidableTileLayers.push(tilemap);
				privtilemap = tilemap;
			}
		}
	}

	public function loadObjects(state:PlayState){
		for(group in objectGroups){
			for(o in group.objects){
				loadObject(o, group, state);
			}
		}
	}

	private function loadObject(o:TiledObject, g:TiledObjectGroup, state:PlayState){
		var x:Int = o.x;
		var y:Int = o.y;
		if(o.gid != -1){
			y -= g.map.getGidOwner(o.gid).tileHeight;
		}
		switch(o.type.toLowerCase()){
			case "player":
				var player = new Player(state, x, y, foregroundTiles);
				state.setPlayer(player);

			case "enemy":
				var enemy = new Enemy(x, y, state);
				enemies.add(enemy);
		}
	}

	public function getForeground():FlxGroup{
		return foregroundTiles;
	}

	public function getEnemies():FlxTypedGroup<Enemy>{
		return enemies;
	}

	public function getFullWidth():Float{
		return fullWidth;
	}

	public function getFullHeight():Float{
		return fullHeight;
	}

	public function seesPlayer(e:Enemy, p:Player):Bool{
		if(privtilemap.ray(e.getMidpoint(), p.getMidpoint())){
			return true;
		}
		else{
			return false;
		}
	}

}

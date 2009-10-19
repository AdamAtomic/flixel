package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	//@desc		This is a traditional tilemap display and collision class
	public class FlxTilemap extends FlxCore
	{
		private var widthInTiles:uint;
		private var heightInTiles:uint;
		private var _pixels:BitmapData;
		private var _data:FlxArray;
		private var _rects:FlxArray;
		private var _tileSize:uint;
		private var _p:Point;
		private var _block:FlxBlock;
		private var _ci:uint;
		
		private var _screenRows:uint;
		private var _screenCols:uint;
		
		//@desc		Constructor
		//@param	MapData			A string of comma and line-return delineated indices indicating what order the tiles should go in
		//@param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData
		//@param	CollisionIndex	The index of the first tile that should be treated as a hard surface
		//@param	DrawIndex		The index of the first tile that should actually be drawn
		public function FlxTilemap(MapData:String, TileGraphic:Class, CollisionIndex:uint=1, DrawIndex:uint=1)
		{
			super();
			_ci = CollisionIndex;
			widthInTiles = 0;
			heightInTiles = 0;
			_data = new FlxArray();
			var c:uint;
			var cols:Array;
			var rows:Array = MapData.split("\n");
			heightInTiles = rows.length;
			for(var r:uint = 0; r < heightInTiles; r++)
			{
				cols = rows[r].split(",");
				if(cols.length <= 1)
				{
					heightInTiles--;
					continue;
				}
				if(widthInTiles == 0)
					widthInTiles = cols.length;
				for(c = 0; c < widthInTiles; c++)
					_data.push(uint(cols[c]));
			}

			_pixels = FlxG.addBitmap(TileGraphic);
			_rects = new FlxArray();
			_p = new Point();
			_tileSize = _pixels.height;
			width = widthInTiles*_tileSize;
			height = heightInTiles*_tileSize;
			var numTiles:uint = widthInTiles*heightInTiles;
			for(var i:uint = 0; i < numTiles; i++)
			{
				if(_data[i] >= DrawIndex)
					_rects.push(new Rectangle(_tileSize*_data[i],0,_tileSize,_tileSize));
				else
					_rects.push(null);
			}
			
			_block = new FlxBlock(0,0,_tileSize,_tileSize,null);
			
			_screenRows = Math.ceil(FlxG.height/_tileSize)+1;
			if(_screenRows > heightInTiles)
				_screenRows = heightInTiles;
			_screenCols = Math.ceil(FlxG.width/_tileSize)+1;
			if(_screenCols > widthInTiles)
				_screenCols = widthInTiles;
		}
		
		//@desc		Draws the tilemap
		override public function render():void
		{
			//NOTE: While this will only draw the tiles that are actually on screen, it will ALWAYS draw one screen's worth of tiles
			super.render();
			getScreenXY(_p);
			var tx:int = Math.floor(-_p.x/_tileSize);
			var ty:int = Math.floor(-_p.y/_tileSize);
			if(tx < 0) tx = 0;
			if(tx > widthInTiles-_screenCols) tx = widthInTiles-_screenCols;
			if(ty < 0) ty = 0;
			if(ty > heightInTiles-_screenRows) ty = heightInTiles-_screenRows;
			var ri:int = ty*widthInTiles+tx;
			_p.x += tx*_tileSize;
			_p.y += ty*_tileSize;
			var opx:int = _p.x;
			var c:uint;
			var cri:uint;
			for(var r:uint = 0; r < _screenRows; r++)
			{
				cri = ri;
				for(c = 0; c < _screenCols; c++)
				{
					if(_rects[cri] != null)
						FlxG.buffer.copyPixels(_pixels,_rects[cri],_p,null,null,true);
					cri++;
					_p.x += _tileSize;
				}
				ri += widthInTiles;
				_p.x = opx;
				_p.y += _tileSize;
			}
		}
		
		//@desc		Collides a FlxSprite against the tilemap
		//@param	Spr		The FlxSprite you want to collide
		override public function collide(Spr:FlxSprite):void
		{
			var ix:uint = Math.floor((Spr.x - x)/_tileSize);
			var iy:uint = Math.floor((Spr.y - y)/_tileSize);
			var iw:uint = Math.ceil(Spr.width/_tileSize)+1;
			var ih:uint = Math.ceil(Spr.height/_tileSize)+1;
			var c:uint;
			for(var r:uint = 0; r < ih; r++)
			{
				if((r < 0) || (r >= heightInTiles)) continue;
				for(c = 0; c < iw; c++)
				{
					if((c < 0) || (c >= widthInTiles)) continue;
					if(_data[(iy+r)*widthInTiles+ix+c] >= _ci)
					{
						_block.x = x+(ix+c)*_tileSize;
						_block.y = y+(iy+r)*_tileSize;
						_block.collide(Spr);
					}
				}
			}
		}
	}
}
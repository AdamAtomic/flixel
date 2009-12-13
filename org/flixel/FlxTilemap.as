package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	//@desc		This is a traditional tilemap display and collision class
	public class FlxTilemap extends FlxCore
	{
		public var widthInTiles:uint;
		public var heightInTiles:uint;
		protected var _pixels:BitmapData;
		protected var _data:Array;
		protected var _rects:Array;
		protected var _tileSize:uint;
		protected var _p:Point;
		protected var _block:FlxCore;
		protected var _ci:uint;
		protected var _di:uint;
		protected var _callbacks:Array;
		protected var _screenRows:uint;
		protected var _screenCols:uint;
		
		//@desc		Constructor
		//@param	MapData			A string of comma and line-return delineated indices indicating what order the tiles should go in
		//@param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData
		//@param	CollisionIndex	The index of the first tile that should be treated as a hard surface
		//@param	DrawIndex		The index of the first tile that should actually be drawn
		public function FlxTilemap(MapData:String, TileGraphic:Class, TileSize:uint, CollisionIndex:uint=1, DrawIndex:uint=1)
		{
			super();
			_ci = CollisionIndex;
			_di = DrawIndex;
			widthInTiles = 0;
			heightInTiles = 0;
			_data = new Array();
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

			_p = new Point();
			_tileSize = TileSize;
			width = widthInTiles*_tileSize;
			height = heightInTiles*_tileSize;
			_pixels = FlxG.addBitmap(TileGraphic);
			var numTiles:uint = widthInTiles*heightInTiles;
			_rects = new Array(numTiles);
			for(var i:uint = 0; i < numTiles; i++)
				setTileByIndex(i,_data[i]);
			
			_block = new FlxCore();
			_block.width = _tileSize;
			_block.height = _tileSize;
			_block.fixed = true;
			
			_screenRows = Math.ceil(FlxG.height/_tileSize)+1;
			if(_screenRows > heightInTiles)
				_screenRows = heightInTiles;
			_screenCols = Math.ceil(FlxG.width/_tileSize)+1;
			if(_screenCols > widthInTiles)
				_screenCols = widthInTiles;
			
			_callbacks = new Array();
		}
		
		//@desc		Draws the tilemap
		override public function render():void
		{
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
		
		//@desc		Collides a FlxCore object against the tilemap
		//@param	Core		The FlxCore you want to collide against
		override public function collide(Core:FlxCore):Boolean
		{
			var c:uint;
			var d:uint;
			var i:uint;
			var dd:uint;
			var blocks:Array = new Array();
			
			//First make a list of all the blocks we'll use for collision
			var ix:uint = Math.floor((Core.x - x)/_tileSize);
			var iy:uint = Math.floor((Core.y - y)/_tileSize);
			var iw:uint = Math.ceil(Core.width/_tileSize)+1;
			var ih:uint = Math.ceil(Core.height/_tileSize)+1;
			for(var r:uint = 0; r < ih; r++)
			{
				if((r < 0) || (r >= heightInTiles)) break;
				d = (iy+r)*widthInTiles+ix;
				for(c = 0; c < iw; c++)
				{
					if((c < 0) || (c >= widthInTiles)) break;
					dd = _data[d+c];
					if(dd >= _ci)
						blocks.push({x:x+(ix+c)*_tileSize,y:y+(iy+r)*_tileSize,data:dd});
				}
			}
			
			//Then do all the X collisions
			var hx:Boolean = false;
			for(i = 0; i < blocks.length; i++)
			{
				_block.last.x = _block.x = blocks[i].x;
				_block.last.y = _block.y = blocks[i].y;
				if(_block.collideX(Core))
				{
					d = blocks[i].data;
					if(_callbacks[d] != null)
						_callbacks[d](Core,_block.x/_tileSize,_block.y/_tileSize,d);
					hx = true;
				}
			}
			
			//Then do all the Y collisions
			var hy:Boolean = false;
			for(i = 0; i < blocks.length; i++)
			{
				_block.last.x = _block.x = blocks[i].x;
				_block.last.y = _block.y = blocks[i].y;
				if(_block.collideY(Core))
				{
					d = blocks[i].data;
					if(_callbacks[d] != null)
						_callbacks[d](Core,_block.x/_tileSize,_block.y/_tileSize,d);
					hy = true;
				}
			}
			
			return hx || hy;
		}
		
		//@desc		Change the data and graphic of a tile in the tilemap
		//@param	X		The X coordinate of the tile (in tiles, not pixels)
		//@param	Y		The Y coordinate of the tile (in tiles, not pixels)
		//@param	Tile	The new integer data you wish to inject
		public function setTile(X:uint,Y:uint,Tile:uint):void
		{
			setTileByIndex(Y * widthInTiles + X,Tile);
		}
		
		//@desc		Change the data and graphic of a tile in the tilemap
		//@param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored
		//@param	Tile	The new integer data you wish to inject
		public function setTileByIndex(Index:uint,Tile:uint):void
		{
			_data[Index] = Tile;
			var rx:uint = Tile*_tileSize;
			var ry:uint = 0;
			if(rx >= _pixels.width)
			{
				ry = uint(rx/_pixels.width)*_tileSize;
				rx %= _pixels.width;
			}
			if(Tile >= _di)
				_rects[Index] = (new Rectangle(rx,ry,_tileSize,_tileSize));
			else
				_rects[Index] = (null);
		}
		
		//@desc		Bind a function Callback(Core:FlxCore,X:uint,Y:uint,Tile:uint) to a range of tiles
		//@param	Tile		The tile to trigger the callback
		//@param	Callback	The function to trigger - parameters are (Core:FlxCore,X:uint,Y:uint,Tile:uint)
		//@param	Range		If you want this callback to work for a bunch of different tiles, input the range here (default = 1)
		public function setTileCallback(Tile:uint,Callback:Function,Range:uint=1):void
		{
			if(Range <= 0) return;
			for(var i:uint = Tile; i < Tile+Range; i++)
				_callbacks[i] = Callback;
		}
		
		//@desc		Call this function to lock the automatic camera to the map's edges
		public function follow():void
		{
			FlxG.followBounds(x,y,width,height);
		}
		
		//@desc		Converts a one-dimensional array of tile data to a comma-separated string
		//@param	Data		An array full of integer tile references
		//@param	Width		The number of tiles in each row
		//@return	A comma-separated string containing the level data in a FlxTilemap-constructor-friendly format
		static public function arrayToCSV(Data:Array,Width:int):String
		{
			var csv:String;
			var Height:int = Data.length / Width;
			for(var r:int = 0; r < Height; r++)
			{
				for(var c:int = 0; c < Width; c++)
				{
					if(c == 0)
					{
						if(r == 0)
							csv += Data[0];
						else
							csv += "\n"+Data[r*Width];
					}
					else
						csv += ", "+Data[r*Width+c];
				}
			}
			return csv;
		}
	}
}

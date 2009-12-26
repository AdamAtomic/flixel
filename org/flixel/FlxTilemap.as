package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	//@desc		This is a traditional tilemap display and collision class
	public class FlxTilemap extends FlxCore
	{
		[Embed(source="data/autotiles.png")] static public var ImgAuto:Class;
		[Embed(source="data/autotiles_alt.png")] static public var ImgAutoAlt:Class;
		
		static public const OFF:uint = 0;
		static public const AUTO:uint = 1;
		static public const ALT:uint = 2;
		
		//@desc		What tile index will you start colliding with (default: 1)
		public var collideIndex:uint;
		//@desc		The first index of your tile sheet (default: 0) If you want to change it, do so before calling loadMap()
		public var startingIndex:uint;
		//@desc		What tile index will you start drawing with (default: 1)  NOTE: should always be >= startingIndex. If you want to change it, do so before calling loadMap()
		public var drawIndex:uint;
		//@desc		Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT)
		public var auto:uint;
		
		//@desc		Read-only variables, do not recommend changing them after the map is loaded!
		public var widthInTiles:uint;
		public var heightInTiles:uint;
		public var totalTiles:uint;
		
		protected var _pixels:BitmapData;
		protected var _data:Array;
		protected var _rects:Array;
		protected var _tileWidth:uint;
		protected var _tileHeight:uint;
		protected var _p:Point;
		protected var _block:FlxCore;
		protected var _callbacks:Array;
		protected var _screenRows:uint;
		protected var _screenCols:uint;
		
		//@desc		The tilemap constructor just initializes some basic variables
		public function FlxTilemap()
		{
			super();
			auto = OFF;
			collideIndex = 1;
			startingIndex = 0;
			drawIndex = 1;
			widthInTiles = 0;
			heightInTiles = 0;
			totalTiles = 0;
			_data = new Array();
			_p = new Point();
			_tileWidth = 0;
			_tileHeight = 0;
			_rects = null;
			_pixels = null;
			_block = new FlxCore();
			_block.width = _block.height = 0;
			_block.fixed = true;			
			_callbacks = new Array();
		}
		
		//@desc		Load the tilemap with string data and a tile graphic
		//@param	MapData			A string of comma and line-return delineated indices indicating what order the tiles should go in
		//@param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData
		//@param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified
		//@param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified
		//@return	A pointer this instance of FlxTilemap, for chaining as usual :)
		public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint=0, TileHeight:uint=0):FlxTilemap
		{
			//Figure out the map dimensions based on the data string
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
			
			//Pre-process the map data if it's auto-tiled
			var i:uint;
			totalTiles = widthInTiles*heightInTiles;
			if(auto > OFF)
			{
				collideIndex = startingIndex = drawIndex = 1;
				for(i = 0; i < totalTiles; i++)
					autoTile(i);
			}

			//Figure out the size of the tiles
			_pixels = FlxG.addBitmap(TileGraphic);
			_tileWidth = TileWidth;
			if(_tileWidth == 0)
				_tileWidth = _pixels.height;
			_tileHeight = TileHeight;
			if(_tileHeight == 0)
				_tileHeight = _tileWidth;
			_block.width = _tileWidth;
			_block.height = _tileHeight;
			
			//Then go through and create the actual map
			width = widthInTiles*_tileWidth;
			height = heightInTiles*_tileHeight;
			_rects = new Array(totalTiles);
			for(i = 0; i < totalTiles; i++)
				updateTile(i);

			//Pre-set some helper variables for later
			_screenRows = Math.ceil(FlxG.height/_tileHeight)+1;
			if(_screenRows > heightInTiles)
				_screenRows = heightInTiles;
			_screenCols = Math.ceil(FlxG.width/_tileWidth)+1;
			if(_screenCols > widthInTiles)
				_screenCols = widthInTiles;
			
			return this;
		}
		
		//@desc		Draws the tilemap
		override public function render():void
		{
			super.render();
			getScreenXY(_p);
			var tx:int = Math.floor(-_p.x/_tileWidth);
			var ty:int = Math.floor(-_p.y/_tileHeight);
			if(tx < 0) tx = 0;
			if(tx > widthInTiles-_screenCols) tx = widthInTiles-_screenCols;
			if(ty < 0) ty = 0;
			if(ty > heightInTiles-_screenRows) ty = heightInTiles-_screenRows;
			var ri:int = ty*widthInTiles+tx;
			_p.x += tx*_tileWidth;
			_p.y += ty*_tileHeight;
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
					_p.x += _tileWidth;
				}
				ri += widthInTiles;
				_p.x = opx;
				_p.y += _tileHeight;
			}
		}
		
		//@desc		Checks for overlaps between the provided object and any tiles above the collision index
		//@param	Core		The FlxCore you want to check against
		override public function overlaps(Core:FlxCore):Boolean
		{
			var c:uint;
			var d:uint;
			var i:uint;
			var dd:uint;
			var blocks:Array = new Array();
			
			//First make a list of all the blocks we'll use for collision
			var ix:uint = Math.floor((Core.x - x)/_tileWidth);
			var iy:uint = Math.floor((Core.y - y)/_tileHeight);
			var iw:uint = Math.ceil(Core.width/_tileWidth)+1;
			var ih:uint = Math.ceil(Core.height/_tileHeight)+1;
			for(var r:uint = 0; r < ih; r++)
			{
				if((r < 0) || (r >= heightInTiles)) break;
				d = (iy+r)*widthInTiles+ix;
				for(c = 0; c < iw; c++)
				{
					if((c < 0) || (c >= widthInTiles)) break;
					dd = _data[d+c];
					if(dd >= collideIndex)
						blocks.push({x:x+(ix+c)*_tileWidth,y:y+(iy+r)*_tileHeight,data:dd});
				}
			}
			
			//Then check for overlaps
			var bl:uint = blocks.length;
			var hx:Boolean = false;
			for(i = 0; i < bl; i++)
			{
				_block.last.x = _block.x = blocks[i].x;
				_block.last.y = _block.y = blocks[i].y;
				if(_block.overlaps(Core))
					return true;
			}
			return false;
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
			var ix:uint = Math.floor((Core.x - x)/_tileWidth);
			var iy:uint = Math.floor((Core.y - y)/_tileHeight);
			var iw:uint = Math.ceil(Core.width/_tileWidth)+1;
			var ih:uint = Math.ceil(Core.height/_tileHeight)+1;
			for(var r:uint = 0; r < ih; r++)
			{
				if((r < 0) || (r >= heightInTiles)) break;
				d = (iy+r)*widthInTiles+ix;
				for(c = 0; c < iw; c++)
				{
					if((c < 0) || (c >= widthInTiles)) break;
					dd = _data[d+c];
					if(dd >= collideIndex)
						blocks.push({x:x+(ix+c)*_tileWidth,y:y+(iy+r)*_tileHeight,data:dd});
				}
			}
			
			//Then do all the X collisions
			var bl:uint = blocks.length;
			var hx:Boolean = false;
			for(i = 0; i < bl; i++)
			{
				_block.last.x = _block.x = blocks[i].x;
				_block.last.y = _block.y = blocks[i].y;
				if(_block.collideX(Core))
				{
					d = blocks[i].data;
					if(_callbacks[d] != null)
						_callbacks[d](Core,_block.x/_tileWidth,_block.y/_tileHeight,d);
					hx = true;
				}
			}
			
			//Then do all the Y collisions
			var hy:Boolean = false;
			for(i = 0; i < bl; i++)
			{
				_block.last.x = _block.x = blocks[i].x;
				_block.last.y = _block.y = blocks[i].y;
				if(_block.collideY(Core))
				{
					d = blocks[i].data;
					if(_callbacks[d] != null)
						_callbacks[d](Core,_block.x/_tileWidth,_block.y/_tileHeight,d);
					hy = true;
				}
			}
			
			return hx || hy;
		}
		
		//@desc		Check the value of a particular tile
		//@param	X		The X coordinate of the tile (in tiles, not pixels)
		//@param	Y		The Y coordinate of the tile (in tiles, not pixels)
		public function getTile(X:uint,Y:uint):uint
		{
			return getTileByIndex(Y * widthInTiles + X);
		}
		
		//@desc		Get the value of a tile in the tilemap by index
		//@param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored
		//@return	A uint containing the value of the tile at this spot in the array
		public function getTileByIndex(Index:uint):uint
		{
			return _data[Index];
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
			
			if(auto == OFF)
			{
				updateTile(Index);
				return;
			}

			//If this map is autotiled and it changes, locally update the arrangement
			var i:uint;
			var r:int = int(Index/widthInTiles) - 1;
			var rl:int = r+3;
			var c:int = Index%widthInTiles - 1;
			var cl:int = c+3;
			for(r = r; r < rl; r++)
			{
				for(c = cl - 3; c < cl; c++)
				{
					if((r >= 0) && (r < heightInTiles) && (c >= 0) && (c < widthInTiles))
					{
						i = r*widthInTiles+c;
						autoTile(i);
						updateTile(i);
					}
				}
			}
		}
		
		//@desc		Bind a function Callback(Core:FlxCore,X:uint,Y:uint,Tile:uint) to a range of tiles
		//@param	Tile		The tile to trigger the callback
		//@param	Callback	The function to trigger - parameters are (Core:FlxCore,X:uint,Y:uint,Tile:uint)
		//@param	Range		If you want this callback to work for a bunch of different tiles, input the range here (default = 1)
		public function setCallback(Tile:uint,Callback:Function,Range:uint=1):void
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
			var r:uint;
			var c:uint;
			var csv:String;
			var Height:int = Data.length / Width;
			for(r = 0; r < Height; r++)
			{
				for(c = 0; c < Width; c++)
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
		
		static public function pngToCSV(PNGFile:Class,Invert:Boolean=false,Scale:uint=1):String
		{
			//Import and scale image if necessary
			var layout:Bitmap;
			if(Scale <= 1)
				layout = new PNGFile;
			else
			{
				var tmp:Bitmap = new PNGFile;
				layout = new Bitmap(new BitmapData(tmp.width*Scale,tmp.height*Scale));
				var mtx:Matrix = new Matrix();
				mtx.scale(Scale,Scale);
				layout.bitmapData.draw(tmp,mtx);
			}
			var bd:BitmapData = layout.bitmapData;
			
			//Walk image and export pixel values
			var r:uint;
			var c:uint;
			var p:uint;
			var csv:String;
			var w:uint = layout.width;
			var h:uint = layout.height;
			for(r = 0; r < h; r++)
			{
				for(c = 0; c < w; c++)
				{
					//Decide if this pixel/tile is solid (1) or not (0)
					p = bd.getPixel(c,r);
					if((Invert && (p > 0)) || (!Invert && (p == 0)))
						p = 1;
					else
						p = 0;
					
					//Write the result to the string
					if(c == 0)
					{
						if(r == 0)
							csv += p;
						else
							csv += "\n"+p;
					}
					else
						csv += ", "+p;
				}
			}
			return csv;
		}
		
		//@desc		An internal function used by the binary auto-tilers
		//@param	Index		The index of the tile you want to analyze
		protected function autoTile(Index:uint):void
		{
			if(_data[Index] == 0) return;
			_data[Index] = 0;
			if((Index-widthInTiles < 0) || (_data[Index-widthInTiles] > 0)) 		//UP
				_data[Index] += 1;
			if((Index%widthInTiles >= widthInTiles-1) || (_data[Index+1] > 0)) 		//RIGHT
				_data[Index] += 2;
			if((Index+widthInTiles >= totalTiles) || (_data[Index+widthInTiles] > 0)) //DOWN
				_data[Index] += 4;
			if((Index%widthInTiles <= 0) || (_data[Index-1] > 0)) 					//LEFT
				_data[Index] += 8;
			if((auto == ALT) && (_data[Index] == 15))	//The alternate algo checks for interior corners
			{
				if((Index%widthInTiles > 0) && (Index+widthInTiles < totalTiles) && (_data[Index+widthInTiles-1] <= 0))
					_data[Index] = 1;		//BOTTOM LEFT OPEN
				if((Index%widthInTiles > 0) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles-1] <= 0))
					_data[Index] = 2;		//TOP LEFT OPEN
				if((Index%widthInTiles < widthInTiles) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
					_data[Index] = 4;		//TOP RIGHT OPEN
				if((Index%widthInTiles < widthInTiles) &&(Index+widthInTiles < totalTiles) && (_data[Index+widthInTiles+1] <= 0))
					_data[Index] = 8; 		//BOTTOM RIGHT OPEN
			}
			_data[Index] += 1;
		}
		
		//@desc		Internal function used in setTileByIndex() and the constructor to update the map
		//@param	Index		The index of the tile you want to update
		protected function updateTile(Index:uint):void
		{
			if(_data[Index] < drawIndex)
			{
				_rects[Index] = null;
				return;
			}
			var rx:uint = (_data[Index]-startingIndex)*_tileWidth;
			var ry:uint = 0;
			if(rx >= _pixels.width)
			{
				ry = uint(rx/_pixels.width)*_tileHeight;
				rx %= _pixels.width;
			}
			_rects[Index] = (new Rectangle(rx,ry,_tileWidth,_tileHeight));
		}
	}
}

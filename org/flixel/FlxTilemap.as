package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;

	/**
	 * This is a traditional tilemap display and collision class.
	 * It takes a string of comma-separated numbers and then associates
	 * those values with tiles from the sheet you pass in.
	 * It also includes some handy static parsers that can convert
	 * arrays or PNG files into strings that can be successfully loaded.
	 */
	public class FlxTilemap extends FlxObject
	{
		[Embed(source="data/autotiles.png")] static public var ImgAuto:Class;
		[Embed(source="data/autotiles_alt.png")] static public var ImgAutoAlt:Class;
		
		/**
		 * No auto-tiling.
		 */
		static public const OFF:uint = 0;
		/**
		 * Platformer-friendly auto-tiling.
		 */
		static public const AUTO:uint = 1;
		/**
		 * Top-down auto-tiling.
		 */
		static public const ALT:uint = 2;
		
		/**
		 * What tile index will you start colliding with (default: 1).
		 */
		public var collideIndex:uint;
		/**
		 * The first index of your tile sheet (default: 0) If you want to change it, do so before calling loadMap().
		 */
		public var startingIndex:uint;
		/**
		 * What tile index will you start drawing with (default: 1)  NOTE: should always be >= startingIndex.
		 * If you want to change it, do so before calling loadMap().
		 */
		public var drawIndex:uint;
		/**
		 * Set this flag to use one of the 16-tile binary auto-tile algorithms (OFF, AUTO, or ALT).
		 */
		public var auto:uint;
		/**
		 * Set this flag to true to force the tilemap buffer to refresh on the next render frame.
		 */
		public var refresh:Boolean;
		
		/**
		 * Read-only variable, do NOT recommend changing after the map is loaded!
		 */
		public var widthInTiles:uint;
		/**
		 * Read-only variable, do NOT recommend changing after the map is loaded!
		 */
		public var heightInTiles:uint;
		/**
		 * Read-only variable, do NOT recommend changing after the map is loaded!
		 */
		public var totalTiles:uint;
		/**
		 * Rendering helper.
		 */
		protected var _flashRect:Rectangle;
		protected var _flashRect2:Rectangle;
		
		protected var _pixels:BitmapData;
		protected var _bbPixels:BitmapData;
		protected var _buffer:BitmapData;
		protected var _bufferLoc:FlxPoint;
		protected var _bbKey:String;
		protected var _data:Array;
		protected var _rects:Array;
		protected var _tileWidth:uint;
		protected var _tileHeight:uint;
		protected var _block:FlxObject;
		protected var _callbacks:Array;
		protected var _screenRows:uint;
		protected var _screenCols:uint;
		protected var _boundsVisible:Boolean;
		
		/**
		 * The tilemap constructor just initializes some basic variables.
		 */
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
			_buffer = null;
			_bufferLoc = new FlxPoint();
			_flashRect2 = new Rectangle();
			_flashRect = _flashRect2;
			_data = null;
			_tileWidth = 0;
			_tileHeight = 0;
			_rects = null;
			_pixels = null;
			_block = new FlxObject();
			_block.width = _block.height = 0;
			_block.fixed = true;
			_callbacks = new Array();
			fixed = true;
		}
		
		/**
		 * Load the tilemap with string data and a tile graphic.
		 * 
		 * @param	MapData			A string of comma and line-return delineated indices indicating what order the tiles should go in.
		 * @param	TileGraphic		All the tiles you want to use, arranged in a strip corresponding to the numbers in MapData.
		 * @param	TileWidth		The width of your tiles (e.g. 8) - defaults to height of the tile graphic if unspecified.
		 * @param	TileHeight		The height of your tiles (e.g. 8) - defaults to width if unspecified.
		 * 
		 * @return	A pointer this instance of FlxTilemap, for chaining as usual :)
		 */
		public function loadMap(MapData:String, TileGraphic:Class, TileWidth:uint=0, TileHeight:uint=0):FlxTilemap
		{
			refresh = true;
			
			//Figure out the map dimensions based on the data string
			var cols:Array;
			var rows:Array = MapData.split("\n");
			heightInTiles = rows.length;
			_data = new Array();
			var r:uint = 0;
			var c:uint;
			while(r < heightInTiles)
			{
				cols = rows[r++].split(",");
				if(cols.length <= 1)
				{
					heightInTiles = heightInTiles - 1;
					continue;
				}
				if(widthInTiles == 0)
					widthInTiles = cols.length;
				c = 0;
				while(c < widthInTiles)
					_data.push(uint(cols[c++]));
			}
			
			//Pre-process the map data if it's auto-tiled
			var i:uint;
			totalTiles = widthInTiles*heightInTiles;
			if(auto > OFF)
			{
				collideIndex = startingIndex = drawIndex = 1;
				i = 0;
				while(i < totalTiles)
					autoTile(i++);
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
			i = 0;
			while(i < totalTiles)
				updateTile(i++);
			
			//Also need to allocate a buffer to hold the rendered tiles
			var bw:uint = (FlxU.ceil(FlxG.width / _tileWidth) + 1)*_tileWidth;
			var bh:uint = (FlxU.ceil(FlxG.height / _tileHeight) + 1)*_tileHeight;
			_buffer = new BitmapData(bw,bh,true,0);

			//Pre-set some helper variables for later
			_screenRows = Math.ceil(FlxG.height/_tileHeight)+1;
			if(_screenRows > heightInTiles)
				_screenRows = heightInTiles;
			_screenCols = Math.ceil(FlxG.width/_tileWidth)+1;
			if(_screenCols > widthInTiles)
				_screenCols = widthInTiles;
			
			_bbKey = String(TileGraphic);
			generateBoundingTiles();
			refreshHulls();
			
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = _buffer.width;
			_flashRect.height = _buffer.height;
			
			return this;
		}
		
		/**
		 * Generates a bounding box version of the tiles, flixel should call this automatically when necessary.
		 */
		protected function generateBoundingTiles():void
		{
			refresh = true;
			
			if((_bbKey == null) || (_bbKey.length <= 0))
				return;
			
			//Check for an existing version of this bounding boxes tilemap
			var bbc:uint = getBoundingColor();
			var key:String = _bbKey + ":BBTILES" + bbc;
			var skipGen:Boolean = FlxG.checkBitmapCache(key);
			_bbPixels = FlxG.createBitmap(_pixels.width, _pixels.height, 0, true, key);
			if(!skipGen)
			{
				//Generate a bounding boxes tilemap for this color
				_flashRect.width = _pixels.width;
				_flashRect.height = _pixels.height;
				_flashPoint.x = 0;
				_flashPoint.y = 0;
				
				_bbPixels.copyPixels(_pixels,_flashRect,_flashPoint);
				_flashRect.width = _tileWidth;
				_flashRect.height = _tileHeight;
				
				//Check for an existing non-collide bounding box stamp
				var ov:Boolean = _solid;
				_solid = false;
				bbc = getBoundingColor();
				key = "BBTILESTAMP"+_tileWidth+"X"+_tileHeight+bbc;
				skipGen = FlxG.checkBitmapCache(key);
				var stamp1:BitmapData = FlxG.createBitmap(_tileWidth, _tileHeight, 0, true, key);
				if(!skipGen)
				{
					//Generate a bounding boxes stamp for this color
					stamp1.fillRect(_flashRect,bbc);
					_flashRect.x = _flashRect.y = 1;
					_flashRect.width = _flashRect.width - 2;
					_flashRect.height = _flashRect.height - 2;
					stamp1.fillRect(_flashRect,0);
					_flashRect.x = _flashRect.y = 0;
					_flashRect.width = _tileWidth;
					_flashRect.height = _tileHeight;
				}
				_solid = ov;
				
				//Check for an existing collide bounding box
				bbc = getBoundingColor();
				key = "BBTILESTAMP"+_tileWidth+"X"+_tileHeight+bbc;
				skipGen = FlxG.checkBitmapCache(key);
				var stamp2:BitmapData = FlxG.createBitmap(_tileWidth, _tileHeight, 0, true, key);
				if(!skipGen)
				{
					//Generate a bounding boxes stamp for this color
					stamp2.fillRect(_flashRect,bbc);
					_flashRect.x = _flashRect.y = 1;
					_flashRect.width = _flashRect.width - 2;
					_flashRect.height = _flashRect.height - 2;
					stamp2.fillRect(_flashRect,0);
					_flashRect.x = _flashRect.y = 0;
					_flashRect.width = _tileWidth;
					_flashRect.height = _tileHeight;
				}
				
				//Stamp the new tile bitmap with the bounding box border
				var r:uint = 0;
				var c:uint;
				var i:uint = 0;
				while(r < _bbPixels.height)
				{
					c = 0;
					while(c < _bbPixels.width)
					{
						_flashPoint.x = c;
						_flashPoint.y = r;
						if(i++ < collideIndex)
							_bbPixels.copyPixels(stamp1,_flashRect,_flashPoint,null,null,true);
						else
							_bbPixels.copyPixels(stamp2,_flashRect,_flashPoint,null,null,true);
						c += _tileWidth;
					}
					r += _tileHeight;
				}
				
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = _buffer.width;
				_flashRect.height = _buffer.height;
			}
		}
		
		/**
		 * Internal function that actually renders the tilemap to the tilemap buffer.  Called by render().
		 */
		protected function renderTilemap():void
		{
			_buffer.fillRect(_flashRect,0);
			
			//Bounding box display options
			var tileBitmap:BitmapData;
			if(FlxG.showBounds)
			{
				tileBitmap = _bbPixels;
				_boundsVisible = true;
			}
			else
			{
				tileBitmap = _pixels;
				_boundsVisible = false;
			}

			//Copy tile images into the tile buffer
			getScreenXY(_point);
			_flashPoint.x = _point.x;
			_flashPoint.y = _point.y;
			var tx:int = Math.floor(-_flashPoint.x/_tileWidth);
			var ty:int = Math.floor(-_flashPoint.y/_tileHeight);
			if(tx < 0) tx = 0;
			if(tx > widthInTiles-_screenCols) tx = widthInTiles-_screenCols;
			if(ty < 0) ty = 0;
			if(ty > heightInTiles-_screenRows) ty = heightInTiles-_screenRows;
			var ri:int = ty*widthInTiles+tx;
			_flashPoint.y = 0;
			var r:uint = 0;
			var c:uint;
			var cri:uint;
			while(r < _screenRows)
			{
				cri = ri;
				c = 0;
				_flashPoint.x = 0;
				while(c < _screenCols)
				{
					_flashRect = _rects[cri++] as Rectangle;
					if(_flashRect != null)
						_buffer.copyPixels(tileBitmap,_flashRect,_flashPoint,null,null,true);
					_flashPoint.x += _tileWidth;
					c++;
				}
				ri += widthInTiles;
				_flashPoint.y += _tileHeight;
				r++;
			}
			_flashRect = _flashRect2;
			_bufferLoc.x = tx*_tileWidth;
			_bufferLoc.y = ty*_tileHeight;
		}
		
		/**
		 * Checks to see if the tilemap needs to be refreshed or not.
		 */
		override public function update():void
		{
			super.update();
			getScreenXY(_point);
			_point.x += _bufferLoc.x;
			_point.y += _bufferLoc.y;
			if((_point.x > 0) || (_point.y > 0) || (_point.x + _buffer.width < FlxG.width) || (_point.y + _buffer.height < FlxG.height))
				refresh = true;
		}
		
		/**
		 * Draws the tilemap.
		 */
		override public function render():void
		{
			if(FlxG.showBounds != _boundsVisible)
				refresh = true;
			
			//Redraw the tilemap buffer if necessary
			if(refresh)
			{
				renderTilemap();
				refresh = false;
			}
			
			//Render the buffer no matter what
			getScreenXY(_point);
			_flashPoint.x = _point.x + _bufferLoc.x;
			_flashPoint.y = _point.y + _bufferLoc.y;
			FlxG.buffer.copyPixels(_buffer,_flashRect,_flashPoint,null,null,true);
		}
		
		/**
		 * @private
		 */
		override public function set solid(Solid:Boolean):void
		{
			var os:Boolean = _solid;
			_solid = Solid;
			if(os != _solid)
				generateBoundingTiles();
		}
		
		/**
		 * @private
		 */
		override public function set fixed(Fixed:Boolean):void
		{
			var of:Boolean = _fixed;
			_fixed = Fixed;
			if(of != _fixed)
				generateBoundingTiles();
		}
		
		/**
		 * Checks for overlaps between the provided object and any tiles above the collision index.
		 * 
		 * @param	Core		The <code>FlxCore</code> you want to check against.
		 */
		override public function overlaps(Core:FlxObject):Boolean
		{
			var d:uint;
			
			var dd:uint;
			var blocks:Array = new Array();
			
			//First make a list of all the blocks we'll use for collision
			var ix:uint = Math.floor((Core.x - x)/_tileWidth);
			var iy:uint = Math.floor((Core.y - y)/_tileHeight);
			var iw:uint = Math.ceil(Core.width/_tileWidth)+1;
			var ih:uint = Math.ceil(Core.height/_tileHeight)+1;
			var r:uint = 0;
			var c:uint;
			while(r < ih)
			{
				if(r >= heightInTiles) break;
				d = (iy+r)*widthInTiles+ix;
				c = 0;
				while(c < iw)
				{
					if(c >= widthInTiles) break;
					dd = _data[d+c] as uint;
					if(dd >= collideIndex)
						blocks.push({x:x+(ix+c)*_tileWidth,y:y+(iy+r)*_tileHeight,data:dd});
					c++;
				}
				r++;
			}
			
			//Then check for overlaps
			var bl:uint = blocks.length;
			var hx:Boolean = false;
			var i:uint = 0;
			while(i < bl)
			{
				_block.x = blocks[i].x;
				_block.y = blocks[i++].y;
				if(_block.overlaps(Core))
					return true;
			}
			return false;
		}
		
		/**
		 * Checks to see if a point in 2D space overlaps a solid tile.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	PerPixel	Not available in <code>FlxTilemap</code>, ignored.
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		override public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			return getTile(uint((X-x)/_tileWidth),uint((Y-y)/_tileHeight)) >= this.collideIndex;
		}
		
		/**
		 * Called by <code>FlxObject.updateMotion()</code> and some constructors to
		 * rebuild the basic collision data for this object.
		 */
		override public function refreshHulls():void
		{
			colHullX.x = 0;
			colHullX.y = 0;
			colHullX.width = _tileWidth;
			colHullX.height = _tileHeight;
			colHullY.x = 0;
			colHullY.y = 0;
			colHullY.width = _tileWidth;
			colHullY.height = _tileHeight;
		}
		
		/**
		 * <code>FlxU.collide()</code> (and thus <code>FlxObject.collide()</code>) call
		 * this function each time two objects are compared to see if they collide.
		 * It doesn't necessarily mean these objects WILL collide, however.
		 * 
		 * @param	Object	The <code>FlxObject</code> you're about to run into.
		 */
		override public function preCollide(Object:FlxObject):void
		{
			//Collision fix, in case updateMotion() is called
			colHullX.x = 0;
			colHullX.y = 0;
			colHullY.x = 0;
			colHullY.y = 0;
			
			var r:uint;
			var c:uint;
			var rs:uint;
			var col:uint = 0;
			var ix:int = FlxU.floor((Object.x - x)/_tileWidth);
			var iy:int = FlxU.floor((Object.y - y)/_tileHeight);
			var iw:uint = ix + FlxU.ceil(Object.width/_tileWidth)+1;
			var ih:uint = iy + FlxU.ceil(Object.height/_tileHeight)+1;
			if(ix < 0)
				ix = 0;
			if(iy < 0)
				iy = 0;
			if(iw > widthInTiles)
				iw = widthInTiles;
			if(ih > heightInTiles)
				ih = heightInTiles;
			rs = iy*widthInTiles;
			r = iy;
			while(r < ih)
			{
				c = ix;
				while(c < iw)
				{
					if((_data[rs+c] as uint) >= collideIndex)
						colOffsets[col++] = new FlxPoint(x+c*_tileWidth, y+r*_tileHeight);
					c++;
				}
				rs += widthInTiles;
				r++;
			}
			if(colOffsets.length != col)
				colOffsets.length = col;
		}
		
		/**
		 * Check the value of a particular tile.
		 * 
		 * @param	X		The X coordinate of the tile (in tiles, not pixels).
		 * @param	Y		The Y coordinate of the tile (in tiles, not pixels).
		 * 
		 * @return	A uint containing the value of the tile at this spot in the array.
		 */
		public function getTile(X:uint,Y:uint):uint
		{
			return getTileByIndex(Y * widthInTiles + X);
		}
		
		/**
		 * Get the value of a tile in the tilemap by index.
		 * 
		 * @param	Index	The slot in the data array (Y * widthInTiles + X) where this tile is stored.
		 * 
		 * @return	A uint containing the value of the tile at this spot in the array.
		 */
		public function getTileByIndex(Index:uint):uint
		{
			return _data[Index] as uint;
		}
		
		/**
		 * Change the data and graphic of a tile in the tilemap.
		 * 
		 * @param	X				The X coordinate of the tile (in tiles, not pixels).
		 * @param	Y				The Y coordinate of the tile (in tiles, not pixels).
		 * @param	Tile			The new integer data you wish to inject.
		 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
		 * 
		 * @return	Whether or not the tile was actually changed.
		 */ 
		public function setTile(X:uint,Y:uint,Tile:uint,UpdateGraphics:Boolean=true):Boolean
		{
			if((X >= widthInTiles) || (Y >= heightInTiles))
				return false;
			return setTileByIndex(Y * widthInTiles + X,Tile,UpdateGraphics);
		}
		
		/**
		 * Change the data and graphic of a tile in the tilemap.
		 * 
		 * @param	Index			The slot in the data array (Y * widthInTiles + X) where this tile is stored.
		 * @param	Tile			The new integer data you wish to inject.
		 * @param	UpdateGraphics	Whether the graphical representation of this tile should change.
		 * 
		 * @return	Whether or not the tile was actually changed.
		 */
		public function setTileByIndex(Index:uint,Tile:uint,UpdateGraphics:Boolean=true):Boolean
		{
			if(Index >= _data.length)
				return false;
			
			var ok:Boolean = true;
			_data[Index] = Tile;
			
			if(!UpdateGraphics)
				return ok;
			
			refresh = true;
			
			if(auto == OFF)
			{
				updateTile(Index);
				return ok;
			}

			//If this map is autotiled and it changes, locally update the arrangement
			var i:uint;
			var r:int = int(Index/widthInTiles) - 1;
			var rl:int = r + 3;
			var c:int = Index%widthInTiles - 1;
			var cl:int = c + 3;
			while(r < rl)
			{
				c = cl - 3;
				while(c < cl)
				{
					if((r >= 0) && (r < heightInTiles) && (c >= 0) && (c < widthInTiles))
					{
						i = r*widthInTiles+c;
						autoTile(i);
						updateTile(i);
					}
					c++;
				}
				r++;
			}
			
			return ok;
		}
		
		/**
		 * Bind a function Callback(Core:FlxCore,X:uint,Y:uint,Tile:uint) to a range of tiles.
		 * 
		 * @param	Tile		The tile to trigger the callback.
		 * @param	Callback	The function to trigger.  Parameters should be <code>(Core:FlxCore,X:uint,Y:uint,Tile:uint)</code>.
		 * @param	Range		If you want this callback to work for a bunch of different tiles, input the range here.  Default value is 1.
		 */
		public function setCallback(Tile:uint,Callback:Function,Range:uint=1):void
		{
			FlxG.log("WARNING: FlxTilemap.setCallback()\nhas been temporarily deprecated.");
			//if(Range <= 0) return;
			//for(var i:uint = Tile; i < Tile+Range; i++)
			//	_callbacks[i] = Callback;
		}
		
		/**
		 * Call this function to lock the automatic camera to the map's edges.
		 * 
		 * @param	Border		Adjusts the camera follow boundary by whatever number of tiles you specify here.  Handy for blocking off deadends that are offscreen, etc.  Use a negative number to add padding instead of hiding the edges.
		 */
		public function follow(Border:int=0):void
		{
			FlxG.followBounds(x+Border*_tileWidth,y+Border*_tileHeight,width-Border*_tileWidth,height-Border*_tileHeight);
		}
		
		/**
		 * Shoots a ray from the start point to the end point.
		 * If/when it passes through a tile, it stores and returns that point.
		 * 
		 * @param	StartX		The X component of the ray's start.
		 * @param	StartY		The Y component of the ray's start.
		 * @param	EndX		The X component of the ray's end.
		 * @param	EndY		The Y component of the ray's end.
		 * @param	Result		A <code>Point</code> object containing the first wall impact.
		 * @param	Resolution	Defaults to 1, meaning check every tile or so.  Higher means more checks!
		 * @return	Whether or not there was a collision between the ray and a colliding tile.
		 */
		public function ray(StartX:Number, StartY:Number, EndX:Number, EndY:Number, Result:FlxPoint, Resolution:Number=1):Boolean
		{
			var step:Number = _tileWidth;
			if(_tileHeight < _tileWidth)
				step = _tileHeight;
			step /= Resolution;
			var dx:Number = EndX - StartX;
			var dy:Number = EndY - StartY;
			var distance:Number = Math.sqrt(dx*dx + dy*dy);
			var steps:uint = Math.ceil(distance/step);
			var stepX:Number = dx/steps;
			var stepY:Number = dy/steps;
			var curX:Number = StartX - stepX;
			var curY:Number = StartY - stepY;
			var tx:uint;
			var ty:uint;
			var i:uint = 0;
			while(i < steps)
			{
				curX += stepX;
				curY += stepY;
				
				if((curX < 0) || (curX > width) || (curY < 0) || (curY > height))
				{
					i++;
					continue;
				}
				
				tx = curX/_tileWidth;
				ty = curY/_tileHeight;
				if((_data[ty*widthInTiles+tx] as uint) >= collideIndex)
				{
					//Some basic helper stuff
					tx *= _tileWidth;
					ty *= _tileHeight;
					var rx:Number = 0;
					var ry:Number = 0;
					var q:Number;
					var lx:Number = curX-stepX;
					var ly:Number = curY-stepY;
					
					//Figure out if it crosses the X boundary
					q = tx;
					if(dx < 0)
						q += _tileWidth;
					rx = q;
					ry = ly + stepY*((q-lx)/stepX);
					if((ry > ty) && (ry < ty + _tileHeight))
					{
						if(Result == null)
							Result = new FlxPoint();
						Result.x = rx;
						Result.y = ry;
						return true;
					}
					
					//Else, figure out if it crosses the Y boundary
					q = ty;
					if(dy < 0)
						q += _tileHeight;
					rx = lx + stepX*((q-ly)/stepY);
					ry = q;
					if((rx > tx) && (rx < tx + _tileWidth))
					{
						if(Result == null)
							Result = new FlxPoint();
						Result.x = rx;
						Result.y = ry;
						return true;
					}
					return false;
				}
				i++;
			}
			return false;
		}
		
		/**
		 * Converts a one-dimensional array of tile data to a comma-separated string.
		 * 
		 * @param	Data		An array full of integer tile references.
		 * @param	Width		The number of tiles in each row.
		 * 
		 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
		 */
		static public function arrayToCSV(Data:Array,Width:int):String
		{
			var r:uint = 0;
			var c:uint;
			var csv:String;
			var Height:int = Data.length / Width;
			while(r < Height)
			{
				c = 0;
				while(c < Width)
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
					c++;
				}
				r++;
			}
			return csv;
		}
		
		/**
		 * Converts a <code>BitmapData</code> object to a comma-separated string.
		 * Black pixels are flagged as 'solid' by default,
		 * non-black pixels are set as non-colliding.
		 * Black pixels must be PURE BLACK.
		 * 
		 * @param	PNGFile		An embedded graphic, preferably black and white.
		 * @param	Invert		Load white pixels as solid instead.
		 * 
		 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
		 */
		static public function bitmapToCSV(bitmapData:BitmapData,Invert:Boolean=false,Scale:uint=1):String
		{
			//Import and scale image if necessary
			if(Scale > 1)
			{
				var bd:BitmapData = bitmapData;
				bitmapData = new BitmapData(bitmapData.width*Scale,bitmapData.height*Scale);
				var mtx:Matrix = new Matrix();
				mtx.scale(Scale,Scale);
				bitmapData.draw(bd,mtx);
			}
			
			//Walk image and export pixel values
			var r:uint = 0;
			var c:uint;
			var p:uint;
			var csv:String;
			var w:uint = bitmapData.width;
			var h:uint = bitmapData.height;
			while(r < h)
			{
				c = 0;
				while(c < w)
				{
					//Decide if this pixel/tile is solid (1) or not (0)
					p = bitmapData.getPixel(c,r);
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
					c++;
				}
				r++;
			}
			return csv;
		}
		
		/**
		 * Converts a resource image file to a comma-separated string.
		 * Black pixels are flagged as 'solid' by default,
		 * non-black pixels are set as non-colliding.
		 * Black pixels must be PURE BLACK.
		 * 
		 * @param	PNGFile		An embedded graphic, preferably black and white.
		 * @param	Invert		Load white pixels as solid instead.
		 * 
		 * @return	A comma-separated string containing the level data in a <code>FlxTilemap</code>-friendly format.
		 */
		static public function imageToCSV(ImageFile:Class,Invert:Boolean=false,Scale:uint=1):String
		{
			return bitmapToCSV((new ImageFile).bitmapData,Invert,Scale);
		}
		
		/**
		 * An internal function used by the binary auto-tilers.
		 * 
		 * @param	Index		The index of the tile you want to analyze.
		 */
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
				if((Index%widthInTiles < widthInTiles-1) && (Index-widthInTiles >= 0) && (_data[Index-widthInTiles+1] <= 0))
					_data[Index] = 4;		//TOP RIGHT OPEN
				if((Index%widthInTiles < widthInTiles-1) && (Index+widthInTiles < totalTiles) && (_data[Index+widthInTiles+1] <= 0))
					_data[Index] = 8; 		//BOTTOM RIGHT OPEN
			}
			_data[Index] += 1;
		}
		
		/**
		 * Internal function used in setTileByIndex() and the constructor to update the map.
		 * 
		 * @param	Index		The index of the tile you want to update.
		 */
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

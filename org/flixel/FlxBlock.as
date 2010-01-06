package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * This is the basic "environment object" class, used to create simple walls and floors.
	 * It can be filled with a random selection of tiles to quickly add detail.
	 */
	public class FlxBlock extends FlxCore
	{
		/**
		 * Stores the tile strip from which the tiles are loaded.
		 */
		protected var _pixels:BitmapData;
		/**
		 * Array of rectangles used to quickly blit the tiles to the screen.
		 */
		protected var _rects:Array;
		/**
		 * The size of the tiles (e.g. 8 means 8x8).
		 */
		protected var _tileSize:uint;
		/**
		 * Helper variable used during rendering.
		 */
		protected var _p:Point;
		
		/**
		 * Creates a new <code>FlxBlock</code> object with the specified position and size.
		 * 
		 * @param	X			The X position of the block.
		 * @param	Y			The Y position of the block.
		 * @param	Width		The width of the block.
		 * @param	Height		The height of the block.
		 */
		public function FlxBlock(X:int,Y:int,Width:uint,Height:uint)
		{
			super();
			last.x = x = X;
			last.y = y = Y;
			width = Width;
			height = Height;
			fixed = true;
		}
		
		/**
		 * Fills the block with a randomly arranged selection of graphics from the image provided.
		 * 
		 * @param	TileGraphic The graphic class that contains the tiles that should fill this block.
		 * @param	Empties		The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
		 */
		public function loadGraphic(TileGraphic:Class,Empties:uint=0):void
		{
			if(TileGraphic == null)
				return;

			_pixels = FlxG.addBitmap(TileGraphic);
			_rects = new Array();
			_p = new Point();
			_tileSize = _pixels.height;
			var widthInTiles:uint = Math.ceil(width/_tileSize);
			var heightInTiles:uint = Math.ceil(height/_tileSize);
			width = widthInTiles*_tileSize;
			height = heightInTiles*_tileSize;
			var numTiles:uint = widthInTiles*heightInTiles;
			var numGraphics:uint = _pixels.width/_tileSize;
			for(var i:uint = 0; i < numTiles; i++)
			{
				if(FlxG.random()*(numGraphics+Empties) > Empties)
					_rects.push(new Rectangle(_tileSize*Math.floor(FlxG.random()*numGraphics),0,_tileSize,_tileSize));
				else
					_rects.push(null);
			}
		}
		
		/**
		 * Draws this block.
		 */
		override public function render():void
		{
			super.render();
			getScreenXY(_p);
			var opx:int = _p.x;
			var rl:uint = _rects.length;
			for(var i:uint = 0; i < rl; i++)
			{
				if(_rects[i] != null) FlxG.buffer.copyPixels(_pixels,_rects[i],_p,null,null,true);
				_p.x += _tileSize;
				if(_p.x >= opx + width)
				{
					_p.x = opx;
					_p.y += _tileSize;
				}
			}
		}
	}
}
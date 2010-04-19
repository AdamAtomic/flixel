package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * This is the basic "environment object" class, used to create simple walls and floors.
	 * It can be filled with a random selection of tiles to quickly add detail.
	 */
	public class FlxTileblock extends FlxObject
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
		 * Rendering helper.
		 */
		protected var _flashRect:Rectangle;
		/**
		 * Bounding box rendering helper.
		 */
		protected var _bbRect:Rectangle;
		
		/**
		 * Creates a new <code>FlxBlock</code> object with the specified position and size.
		 * 
		 * @param	X			The X position of the block.
		 * @param	Y			The Y position of the block.
		 * @param	Width		The width of the block.
		 * @param	Height		The height of the block.
		 */
		public function FlxTileblock(X:int,Y:int,Width:uint,Height:uint)
		{
			super();
			x = X;
			y = Y;
			width = Width;
			height = Height;
			fixed = true;
			_bbRect = new Rectangle(width,height);
			refreshHulls();
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
			_tileSize = _pixels.height;
			var widthInTiles:uint = Math.ceil(width/_tileSize);
			var heightInTiles:uint = Math.ceil(height/_tileSize);
			width = widthInTiles*_tileSize;
			height = heightInTiles*_tileSize;
			var numTiles:uint = widthInTiles*heightInTiles;
			var numGraphics:uint = _pixels.width/_tileSize;
			for(var i:uint = 0; i < numTiles; i++)
			{
				if(FlxU.random()*(numGraphics+Empties) > Empties)
					_rects.push(new Rectangle(_tileSize*Math.floor(FlxU.random()*numGraphics),0,_tileSize,_tileSize));
				else
					_rects.push(null);
			}
		}
		
		/**
		 * Draws this block.
		 */
		override public function render():void
		{
			renderBlock();
		}
		
		/**
		 * Internal function to draw this block
		 */
		protected function renderBlock():void
		{
			getScreenXY(_point);
			var opx:int = _point.x;
			var rl:uint = _rects.length;
			_flashPoint.x = _point.x;
			_flashPoint.y = _point.y;
			for(var i:uint = 0; i < rl; i++)
			{
				_flashRect = _rects[i] as Rectangle;
				if(_flashRect != null) FlxG.buffer.copyPixels(_pixels,_flashRect,_flashPoint,null,null,true);
				_flashPoint.x += _tileSize;
				if(_flashPoint.x >= opx + width)
				{
					_flashPoint.x = opx;
					_flashPoint.y += _tileSize;
				}
			}
			
			//Draw bounding box if necessary
			if(FlxG.showBounds)
			{
				var bbc:uint = getBoundingColor();
				
				//Draw top of box
				_bbRect.x = _point.x;
				_bbRect.y = _point.y;
				_bbRect.width = width;
				_bbRect.height = 1;
				FlxG.buffer.fillRect(_bbRect,bbc);
				
				//Draw bottom of box
				_bbRect.y += height-1;
				FlxG.buffer.fillRect(_bbRect,bbc);
				
				//Draw left side of box
				_bbRect.y = _point.y + 1;
				_bbRect.width = 1;
				_bbRect.height = height-2;
				FlxG.buffer.fillRect(_bbRect,bbc);
				
				//Draw right side of box
				_bbRect.x += width-1;
				FlxG.buffer.fillRect(_bbRect,bbc);
			}
		}
	}
}
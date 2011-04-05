package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	/**
	 * This is the basic "environment object" class, used to create simple walls and floors.
	 * It can be filled with a random selection of tiles to quickly add detail.
	 */
	public class FlxTileblock extends FlxSprite
	{		
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
			super(X,Y);
			makeGraphic(Width,Height,0,true);
			active = false;
			immovable = true;
		}
		
		/**
		 * Fills the block with a randomly arranged selection of graphics from the image provided.
		 * 
		 * @param	TileGraphic The graphic class that contains the tiles that should fill this block.
		 * @param	Empties		The number of "empty" tiles to add to the auto-fill algorithm (e.g. 8 tiles + 4 empties = 1/3 of block will be open holes).
		 */
		public function loadTiles(TileGraphic:Class,TileWidth:uint=0,TileHeight:uint=0,Empties:uint=0):FlxTileblock
		{
			if(TileGraphic == null)
				return this;
			
			//First create a tile brush
			var s:FlxSprite = new FlxSprite().loadGraphic(TileGraphic,true,false,TileWidth,TileHeight);
			var sw:uint = s.width;
			var sh:uint = s.height;
			var total:uint = s.frames + Empties;
			
			//Then prep the "canvas" as it were (just doublechecking that the size is on tile boundaries)
			var regen:Boolean = false;
			if(width % s.width != 0)
			{
				width = uint(width/sw+1)*sw;
				regen = true;
			}
			if(height % s.height != 0)
			{
				height = uint(height/sh+1)*sh;
				regen = true;
			}
			if(regen)
				makeGraphic(width,height,0,true);
			else
				this.fill(0);
			
			//Stamp random tiles onto the canvas
			var r:uint = 0;
			var c:uint;
			var ox:uint;
			var oy:uint = 0;
			var widthInTiles:uint = width/sw;
			var heightInTiles:uint = height/sh;
			while(r < heightInTiles)
			{
				ox = 0;
				c = 0;
				while(c < widthInTiles)
				{
					if(FlxG.random()*total > Empties)
					{
						s.randomFrame();
						s.drawFrame();
						stamp(s,ox,oy);
					}
					ox += sw;
					c++;
				}
				oy += sh;
				r++;
			}
			
			return this;
		}
	}
}

package org.flixel.system
{
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxU;

	public class FlxTilemapBuffer
	{
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		public var dirty:Boolean;
		public var screenRows:uint;
		public var screenCols:uint;

		protected var _pixels:BitmapData;	
		protected var _flashRect:Rectangle;

		public function FlxTilemapBuffer(TileWidth:Number,TileHeight:Number,WidthInTiles:uint,HeightInTiles:uint,Camera:FlxCamera=null)
		{
			if(Camera == null)
				Camera = FlxG.camera;

			screenCols = FlxU.ceil(Camera.width/TileWidth)+1;
			if(screenCols > WidthInTiles)
				screenCols = WidthInTiles;
			screenRows = FlxU.ceil(Camera.height/TileHeight)+1;
			if(screenRows > HeightInTiles)
				screenRows = HeightInTiles;
			
			_pixels = new BitmapData(screenCols*TileWidth,screenRows*TileHeight,true,0);
			width = _pixels.width;
			height = _pixels.height;			
			_flashRect = new Rectangle(0,0,width,height);
			dirty = true;
		}
		
		public function destroy():void
		{
			_pixels = null;
		}
		
		public function fill(Color:uint=0):void
		{
			_pixels.fillRect(_flashRect,Color);
		}
		
		public function get pixels():BitmapData
		{
			return _pixels;
		}
		
		public function draw(Camera:FlxCamera,FlashPoint:Point):void
		{
			Camera.buffer.copyPixels(_pixels,_flashRect,FlashPoint,null,null,true);
		}
	}
}
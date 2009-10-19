package org.flixel.data
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;

	//@desc		This automates the color-rotation effect on the 'f' logo during game launch, not used in actual game code
	public class FlxLogoPixel extends Sprite
	{
		private var _layers:Array;
		private var _curLayer:uint;
		
		public function FlxLogoPixel(xPos:int,yPos:int,pixelSize:uint,index:uint,finalColor:uint)
		{
			super();
			x = xPos;
			y = yPos;
			
			//Build up the color layers
			_layers = new Array();
			var colors:Array = new Array( 0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFF00, 0xFF00FFFF );
			_layers.push(addChild(new Bitmap(new BitmapData(pixelSize,pixelSize,true,finalColor))));
			for(var i:uint = 0; i < colors.length; i++)
			{
				_layers.push(addChild(new Bitmap(new BitmapData(pixelSize,pixelSize,true,colors[index]))));
				if(++index >= colors.length) index = 0;
			}
			_curLayer = _layers.length-1;
		}
		
		public function update():void
		{
			if(_curLayer == 0)
				return;

			if(_layers[_curLayer].alpha >= 0.1)
				_layers[_curLayer].alpha -= 0.1;
			else
			{
				_layers[_curLayer].alpha = 0;
				_curLayer--;
			}
			
		}
	}
}
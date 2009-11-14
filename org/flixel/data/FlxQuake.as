package org.flixel.data
{
	import org.flixel.FlxG;
	
	//@desc		This is a special effects utility class to help FlxGame do the 'quake' or screenshake effect
	public class FlxQuake
	{
		protected var _zoom:uint;
		protected var _intensity:Number;
		protected var _length:Number;
		protected var _timer:Number;
		
		public var x:int;
		public var y:int;
		
		public function FlxQuake(Zoom:uint)
		{
			_zoom = Zoom;
			reset(0);
		}
		
		//@desc		Reset and trigger this special effect
		//@param	Intensity	Percentage of screen size representing the maximum distance that the screen can move during the 'quake'
		//@param	Duration	The length in seconds that the "quake" should last
		public function reset(Intensity:Number,Duration:Number=0.5):void
		{
			x = 0;
			y = 0;
			_intensity = Intensity;
			if(_intensity == 0)
			{
				_length = 0;
				_timer = 0;
				return;
			}
			_length = Duration;
			_timer = 0.01;
		}
		
		//@desc		Updates and/or animates this special effect
		public function update():void
		{
			if(_timer > 0)
			{
				_timer += FlxG.elapsed;
				if(_timer > _length)
				{
					_timer = 0;
					x = 0;
					y = 0;
				}
				else
				{
					x = (Math.random()*_intensity*FlxG.width*2-_intensity*FlxG.width)*_zoom;
					y = (Math.random()*_intensity*FlxG.height*2-_intensity*FlxG.height)*_zoom;
				}
			}
		}
	}
}
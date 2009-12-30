package org.flixel.data
{
	import org.flixel.FlxG;
	
	/**
	 * This is a special effects utility class to help FlxGame do the 'quake' or screenshake effect.
	 */
	public class FlxQuake
	{
		/**
		 * The game's level of zoom.
		 */
		protected var _zoom:uint;
		/**
		 * The intensity of the quake effect: a percentage of the screen's size.
		 */
		protected var _intensity:Number;
		/**
		 * Set to countdown the quake time.
		 */
		protected var _timer:Number;
		
		/**
		 * The amount of X distortion to apply to the screen.
		 */
		public var x:int;
		/**
		 * The amount of Y distortion to apply to the screen.
		 */
		public var y:int;
		
		/**
		 * Constructor.
		 */
		public function FlxQuake(Zoom:uint)
		{
			_zoom = Zoom;
			reset(0);
		}
		
		/**
		 * Reset and trigger this special effect.
		 * 
		 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move during the 'quake'.
		 * @param	Duration	The length in seconds that the "quake" should last.
		 */
		public function reset(Intensity:Number,Duration:Number=0.5):void
		{
			x = 0;
			y = 0;
			_intensity = Intensity;
			if(_intensity == 0)
			{
				_timer = 0;
				return;
			}
			_timer = Duration;
		}
		
		/**
		 * Updates and/or animates this special effect.
		 */
		public function update():void
		{
			if(_timer > 0)
			{
				_timer -= FlxG.elapsed;
				if(_timer <= 0)
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
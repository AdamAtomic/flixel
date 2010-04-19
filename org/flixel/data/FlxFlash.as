package org.flixel.data
{
	import org.flixel.*;
	
	/**
	 * This is a special effects utility class to help FlxGame do the 'flash' effect
	 */
	public class FlxFlash extends FlxSprite
	{
		/**
		 * How long the effect should last.
		 */
		protected var _delay:Number;
		/**
		 * Callback for when the effect is finished.
		 */
		protected var _complete:Function;
		
		/**
		 * Constructor for this special effect
		 */
		public function FlxFlash()
		{
			super();
			createGraphic(FlxG.width,FlxG.height,0,true);
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			exists = false;
			solid = false;
			fixed = true;
		}
		
		/**
		 * Reset and trigger this special effect
		 * 
		 * @param	Color			The color you want to use
		 * @param	Duration		How long it takes for the flash to fade
		 * @param	FlashComplete	A function you want to run when the flash finishes
		 * @param	Force			Force the effect to reset
		 */
		public function start(Color:uint=0xffffffff, Duration:Number=1, FlashComplete:Function=null, Force:Boolean=false):void
		{
			if(!Force && exists) return;
			fill(Color);
			_delay = Duration;
			_complete = FlashComplete;
			alpha = 1;
			exists = true;
		}
		
		/**
		 * Stops and hides this screen effect.
		 */
		public function stop():void
		{
			exists = false;
		}
		
		/**
		 * Updates and/or animates this special effect
		 */
		override public function update():void
		{
			alpha -= FlxG.elapsed/_delay;
			if(alpha <= 0)
			{
				exists = false;
				if(_complete != null)
					_complete();
			}
		}
	}
}

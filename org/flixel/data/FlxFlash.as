package org.flixel.data
{
	import org.flixel.*;
	
	//@desc		This is a special effects utility class to help FlxGame do the 'flash' effect
	public class FlxFlash extends FlxSprite
	{
		protected var _delay:Number;
		protected var _complete:Function;
		protected var _helper:Number;
		
		//@desc		Constructor for this special effect
		public function FlxFlash()
		{
			super();
			createGraphic(FlxG.width,FlxG.height,0,true);
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			visible = false;
		}
		
		//@desc		Reset and trigger this special effect
		//@param	Color			The color you want to use
		//@param	Duration		How long it takes for the flash to fade
		//@param	FlashComplete	A function you want to run when the flash finishes
		//@param	Force			Force the effect to reset
		public function restart(Color:uint=0xffffffff, Duration:Number=1, FlashComplete:Function=null, Force:Boolean=false):void
		{
			if(Duration == 0)
			{
				visible = false;
				return;
			}
			if(!Force && visible) return;
			fill(Color);
			_delay = Duration;
			_complete = FlashComplete;
			_helper = 1;
			alpha = 1;
			visible = true;
		}
		
		//@desc		Updates and/or animates this special effect
		override public function update():void
		{
			if(visible)
			{
				_helper -= FlxG.elapsed/_delay;
				alpha = _helper;
				if(alpha <= 0)
				{
					visible = false;
					if(_complete != null)
						_complete();
				}
			}
		}
	}
}

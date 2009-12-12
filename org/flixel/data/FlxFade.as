package org.flixel.data
{
	import org.flixel.*;
	
	//@desc		This is a special effects utility class to help FlxGame do the 'fade' effect
	public class FlxFade extends FlxSprite
	{
		protected var _delay:Number;
		protected var _complete:Function;
		protected var _helper:Number;
		
		//@desc		Constructor initializes the fade object
		public function FlxFade()
		{
			super();
			createGraphic(FlxG.width,FlxG.height,0,true);
			scrollFactor.x = 0;
			scrollFactor.y = 0;
			visible = false;
		}
		
		//@desc		Reset and trigger this special effect
		//@param	Color			The color you want to use
		//@param	Duration		How long it should take to fade the screen out
		//@param	FadeComplete	A function you want to run when the fade finishes
		//@param	Force			Force the effect to reset
		public function restart(Color:uint=0, Duration:Number=1, FadeComplete:Function=null, Force:Boolean=false):void
		{
			if(Duration == 0)
			{
				visible = false;
				return;
			}
			if(!Force && visible) return;
			fill(Color);
			_delay = Duration;
			_complete = FadeComplete;
			_helper = 0;
			alpha = 0;
			visible = true;
		}
		
		//@desc		Updates and/or animates this special effect
		override public function update():void
		{
			if(visible && (alpha != 1))
			{
				_helper += FlxG.elapsed/_delay;
				alpha = _helper;
				if(alpha >= 1)
				{
					alpha = 1;
					if(_complete != null)
						_complete();
				}
			}
		}
	}
}

package org.flixel.plugin
{
	import org.flixel.*;
	
	public class TimerManager extends FlxBasic
	{
		protected var _timers:Array;
		
		public function TimerManager()
		{
			_timers = new Array();
		}
		
		override public function destroy():void
		{
			clear();
			_timers = null;
		}
		
		override public function update():void
		{
			var i:int = _timers.length-1;
			var timer:FlxTimer;
			while(i >= 0)
			{
				timer = (_timers[i--] as FlxTimer);
				if((timer != null) && !timer.paused && !timer.finished)
					timer.update();
			}
		}
		
		override public function draw():void
		{
			
		}
		
		public function add(Timer:FlxTimer):void
		{
			_timers.push(Timer);
		}
		
		public function remove(Timer:FlxTimer):void
		{
			var index:int = _timers.indexOf(Timer);
			if(index >= 0)
				_timers.splice(index,1);
		}
		
		public function clear():void
		{
			var i:int = _timers.length-1;
			var timer:FlxTimer;
			while(i >= 0)
			{
				timer = (_timers[i--] as FlxTimer);
				if(timer != null)
					timer.destroy();
			}
			_timers.length = 0;
		}
	}
}
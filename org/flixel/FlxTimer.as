package org.flixel
{
	import org.flixel.plugin.TimerManager;
	
	public class FlxTimer
	{
		public var time:Number;
		public var loops:uint;
		protected var _callback:Function;
		protected var _timeCounter:Number;
		protected var _loopsCounter:uint;

		public var paused:Boolean;
		public var finished:Boolean;
		
		public function FlxTimer()
		{
			time = 0;
			loops = 0;
			_callback = null;
			_timeCounter = 0;
			_loopsCounter = 0;

			paused = false;
			finished = false;
			
			var plugin:TimerManager = FlxG.getPlugin(TimerManager) as TimerManager;
			if(plugin != null)
				plugin.add(this);
		}
		
		public function destroy():void
		{
			stop();
			_callback = null;
		}
		
		public function update():void
		{
			if(paused || finished)
				return;
			
			_timeCounter += FlxG.elapsed;
			while((_timeCounter >= time) && !paused && !finished)
			{
				_timeCounter -= time;
				
				_loopsCounter++;
				if(_loopsCounter >= loops)
					stop();
				
				if(_callback != null)
					_callback(this);
			}
		}
		
		//NOTE: callback takes one parameter, a reference to this FlxTimer object 
		public function start(Time:Number=1,Loops:uint=1,Callback:Function=null):FlxTimer
		{
			if(paused)
			{
				paused = false;
				return this;
			}
			
			time = Time;
			loops = Loops;
			_callback = Callback;
			_timeCounter = 0;
			_loopsCounter = 0;
			return this;
		}
		
		public function pause(Pause:Boolean):void
		{
			paused = Pause;
		}
		
		public function stop():void
		{
			finished = true;
			var plugin:TimerManager = FlxG.getPlugin(TimerManager) as TimerManager;
			if(plugin != null)
				plugin.remove(this);
		}
		
		public function get loopsLeft():int
		{
			return loops-_loopsCounter;
		}
		
		public function get timeLeft():Number
		{
			return time-_timeCounter;
		}
	}
}
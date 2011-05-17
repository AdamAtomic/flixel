package org.flixel.plugin
{
	import org.flixel.*;
	
	/**
	 * A simple manager for tracking and updating game timer objects.
	 * 
	 * @author	Adam Atomic
	 */
	public class TimerManager extends FlxBasic
	{
		protected var _timers:Array;
		
		/**
		 * Instantiates a new timer manager.
		 */
		public function TimerManager()
		{
			_timers = new Array();
			visible = false; //don't call draw on this plugin
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void
		{
			clear();
			_timers = null;
		}
		
		/**
		 * Called by <code>FlxG.updatePlugins()</code> before the game state has been updated.
		 * Cycles through timers and calls <code>update()</code> on each one.
		 */
		override public function update():void
		{
			var i:int = _timers.length-1;
			var timer:FlxTimer;
			while(i >= 0)
			{
				timer = _timers[i--] as FlxTimer;
				if((timer != null) && !timer.paused && !timer.finished && (timer.time > 0))
					timer.update();
			}
		}
		
		/**
		 * Add a new timer to the timer manager.
		 * Usually called automatically by <code>FlxTimer</code>'s constructor.
		 * 
		 * @param	Timer	The <code>FlxTimer</code> you want to add to the manager.
		 */
		public function add(Timer:FlxTimer):void
		{
			_timers.push(Timer);
		}
		
		/**
		 * Remove a timer from the timer manager.
		 * Usually called automatically by <code>FlxTimer</code>'s <code>stop()</code> function.
		 * 
		 * @param	Timer	The <code>FlxTimer</code> you want to remove from the manager.
		 */
		public function remove(Timer:FlxTimer):void
		{
			var index:int = _timers.indexOf(Timer);
			if(index >= 0)
				_timers.splice(index,1);
		}
		
		/**
		 * Removes all the timers from the timer manager.
		 */
		public function clear():void
		{
			var i:int = _timers.length-1;
			var timer:FlxTimer;
			while(i >= 0)
			{
				timer = _timers[i--] as FlxTimer;
				if(timer != null)
					timer.destroy();
			}
			_timers.length = 0;
		}
	}
}
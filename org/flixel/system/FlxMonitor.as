package org.flixel.system
{
	/**
	 * FlxMonitor is a simple class that aggregates and averages data.
	 * Flixel uses this to display the framerate and profiling data
	 * in the developer console.  It's nice for keeping track of
	 * things that might be changing too fast from frame to frame.
	 */
	public class FlxMonitor
	{
		/**
		 * Stores the requested size of the monitor array.
		 */
		protected var _size:uint;
		/**
		 * Keeps track of where we are in the array.
		 */
		protected var _itr:uint;
		/**
		 * An array to hold all the data we are averaging.
		 */
		protected var _data:Array;
		/**
		 * Just stores the last number we added.
		 */
		protected var _last:Number;
		
		/**
		 * Shows whether the monitor has been filled all the way yet or not.
		 */
		public var full:Boolean;
		
		/**
		 * Creates the monitor array and sets the size.
		 * 
		 * @param	Size	The desired size - more entries means a longer window of averaging.
		 * @param	Default	The default value of the entries in the array (0 by default).
		 */
		public function FlxMonitor(Size:uint,Default:Number=0)
		{
			_size = Size;
			if(_size <= 0)
				_size = 1;
			_itr = 0;
			_data = new Array(_size);
			clear(Default);
		}
		
		/**
		 * Adds an entry to the array of data.
		 * 
		 * @param	Data	The value you want to track and average.
		 */
		public function add(Data:Number):void
		{
			_last = Data;
			_data[_itr++] = _last;
			if(_itr >= _size)
			{
				_itr = 0;
				full = true;
			}
		}
		
		/**
		 * Adds up all the values in the monitor window.
		 * 
		 * @return	The total value of all the entries in the monitor.
		 */
		public function total():Number
		{
			var sum:Number = 0;
			var i:uint = 0;
			while(i < _size)
				sum += _data[i++];
			return sum;
		}
		
		/**
		 * Averages the value of all the numbers in the monitor window.
		 * 
		 * @return	The average value of all the numbers in the monitor window.
		 */
		public function average():Number
		{
			return total()/_size;
		}
		
		/**
		 * Tells you if the monitor window is charting up or down.
		 * 
		 * @return	The difference between the oldest number in the monitor and the average.
		 */
		public function trend():Number
		{
			var i:uint = _itr+1;
			if(i >= _size)
				i = 0;
			return average() - _data[i];
		}
		
		/**
		 * Goes through and sets every entry in the monitor to Default (0).
		 * 
		 * @param	Default		The new value you want ever entry to have.
		 */
		public function clear(Default:Number = 0):void
		{
			_last = Default;
			var i:uint = 0;
			while(i < _size)
				_data[i++] = _last;
			full = false;
		}
		
		/**
		 * Retrieves the last value added to the monitor.
		 */
		public function last():Number
		{
			return _last;
		}
	}
}
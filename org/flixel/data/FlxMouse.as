package org.flixel.data
{
	import flash.events.MouseEvent;
	
	/**
	 * This class helps contain and track the mouse pointer in your game.
	 * Automatically accounts for parallax scrolling, etc.
	 */
	public class FlxMouse
	{
		/**
		 * Current X position of the mouse pointer in the game world.
		 */
		public var x:int;
		/**
		 * Current Y position of the mouse pointer in the game world.
		 */
		public var y:int;
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _current:int;
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _last:int;
		
		/**
		 * Constructor.
		 */
		public function FlxMouse()
		{
			x = 0;
			y = 0;
			_current = 0;
			_last = 0;
		}

		/**
		 * Called by the internal game loop to update the mouse pointer's position in the game world.
		 * Also updates the just pressed/just released flags.
		 * 
		 * @param	X	The desired X position of the mouse.
		 * @param	Y	The desired Y position of the mouse.
		 */
		public function update(X:int,Y:int):void
		{
			x = X;
			y = Y;
			if((_last == -1) && (_current == -1))
				_current = 0;
			else if((_last == 2) && (_last == 2))
				_current = 1;
			_last = _current;
		}
		
		/**
		 * Resets the just pressed/just released flags and sets mouse to not pressed.
		 */
		public function reset():void
		{
			_current = 0;
			_last = 0;
		}
		
		/**
		 * Check to see if the mouse is pressed.
		 * 
		 * @return	Whether the mouse is pressed.
		 */
		public function pressed():Boolean { return _current > 0; }
		
		/**
		 * Check to see if the mouse was just pressed.
		 * 
		 * @return Whether the mouse was just pressed.
		 */
		public function justPressed():Boolean { return _current == 2; }
		
		/**
		 * Check to see if the mouse was just released.
		 * 
		 * @return	Whether the mouse was just released.
		 */
		public function justReleased():Boolean { return _current == -1; }
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseDown(event:MouseEvent):void
		{
			if(_current > 0) _current = 1;
			else _current = 2;
		}
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseUp(event:MouseEvent):void
		{
			if(_current > 0) _current = -1;
			else _current = 0;
		}
	}
}
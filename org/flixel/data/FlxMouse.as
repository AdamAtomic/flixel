package org.flixel.data
{
	import flash.events.MouseEvent;
	
	public class FlxMouse
	{
		public var x:int;
		public var y:int;
		protected var _current:int;
		protected var _last:int;
		
		public function FlxMouse()
		{
			x = 0;
			y = 0;
			_current = 0;
			_last = 0;
		}

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
		
		public function reset():void
		{
			_current = 0;
			_last = 0;
		}
		
		//@desc		Check to see if this key is pressed
		//@param	Key		One of the key constants listed above (e.g. LEFT or A)
		//@return	Whether the key is pressed
		public function pressed():Boolean { return _current > 0; }
		
		//@desc		Check to see if this key was JUST pressed
		//@param	Key		One of the key constants listed above (e.g. LEFT or A)
		//@return	Whether the key was just pressed
		public function justPressed():Boolean { return _current == 2; }
		
		//@desc		Check to see if this key is NOT pressed
		//@param	Key		One of the key constants listed above (e.g. LEFT or A)
		//@return	Whether the key is not pressed
		public function justReleased():Boolean { return _current == -1; }
		
		public function handleMouseDown(event:MouseEvent):void
		{
			if(_current > 0) _current = 1;
			else _current = 2;
		}
		
		public function handleMouseUp(event:MouseEvent):void
		{
			if(_current > 0) _current = -1;
			else _current = 0;
		}
	}
}
package org.flixel
{
	public class FlxBasic
	{
		static internal var _ACTIVECOUNT:uint;
		static internal var _VISIBLECOUNT:uint;

		/**
		 * IDs seem like they could be pretty useful, huh?
		 */
		public var ID:int;
		/**
		 * Controls whether update() and draw() are automatically called by FlxState/FlxGroup.
		 */
		public var exists:Boolean;
		/**
		 * Controls whether update() is automatically called by FlxState/FlxGroup.
		 */
		public var active:Boolean;
		/**
		 * Controls whether draw() is automatically called by FlxState/FlxGroup.
		 */
		public var visible:Boolean;
		/**
		 * Useful state for many game objects - "dead" (!alive) vs alive.
		 * NOTE: kill() and revive() treat them as the same thing by default,
		 * but you can alter that by overriding, etc.
		 */
		public var alive:Boolean;
		
		public function FlxBasic()
		{
			ID = -1;
			exists = true;
			active = true;
			visible = true;
			alive = true;
		}

		/**
		 * Override this function to null out variables or manually call destroy() on class members if necessary.
		 * If you are extending a class more advanced than FlxBasic, don't forget to call super.destroy()!
		 */
		public function destroy():void {}
		
		/**
		 * Override this function to update your class's position and appearance.
		 * This is where most of your game rules and behavioral code will go.
		 * Don't forget to call super.update()!
		 */
		public function update():void
		{
			_ACTIVECOUNT++;
		}
		
		/**
		 * Override this function to control how the object is drawn.
		 * Overriding draw() is rarely necessary, but can be very useful.
		 * Don't forget to call super.draw()!
		 */
		public function draw():void
		{
			_VISIBLECOUNT++;
		}
		
		public function kill():void
		{
			alive = false;
			exists = false;
		}
		
		public function revive():void
		{
			alive = true;
			exists = true;
		}
		
		public function onScreen(Camera:FlxCamera=null):Boolean
		{
			return true;
		}
		
		/**
		 * Convert object to readable string name.  Useful for debugging, save games, etc.
		 */
		public function toString():String
		{
			return FlxU.getClassName(this,true);
		}
	}
}

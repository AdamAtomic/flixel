package org.flixel
{
	/**
	 * Stores a 2D floating point coordinate.
	 */
	public class FlxPoint
	{
		/**
		 * @default 0
		 */
		public var x:Number;
		/**
		 * @default 0
		 */
		public var y:Number;
		
		/**
		 * Instantiate a new point object.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 */
		public function FlxPoint(X:Number=0, Y:Number=0)
		{
			x = X;
			y = Y;
		}
		
		/**
		 * Convert object to readable string name.  Useful for debugging, save games, etc.
		 */
		public function toString():String
		{
			return FlxU.getClassName(this,true);
		}
		
		/**
		 * Calculate the distance between this point and another point.
		 * 
		 * @param Point		A <code>FlxPoint</code> object referring to the second location.
		 * 
		 * @return	The distance between the two points as a floating point <code>Number</code> object.
		 */
		public function getDistance(Point:FlxPoint):Number
		{
			var dx:Number = x - Point.x;
			var dy:Number = y - Point.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
	}
}
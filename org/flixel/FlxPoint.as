package org.flixel
{
	import flash.geom.Point;
	
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
		 * Instantiate a new point object.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 */
		public function make(X:Number=0, Y:Number=0):FlxPoint
		{
			x = X;
			y = Y;
			return this;
		}
		
		public function copyFrom(Point:FlxPoint):FlxPoint
		{
			x = Point.x;
			y = Point.y;
			return this;
		}
		
		public function copyTo(Point:FlxPoint):FlxPoint
		{
			Point.x = x;
			Point.y = y;
			return Point;
		}
		
		public function copyFromFlash(FlashPoint:Point):FlxPoint
		{
			x = FlashPoint.x;
			y = FlashPoint.y;
			return this;
		}
		
		public function copyToFlash(FlashPoint:Point):Point
		{
			FlashPoint.x = x;
			FlashPoint.y = y;
			return FlashPoint;
		}
	}
}

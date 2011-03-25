package org.flixel
{
	/**
	 * Stores a rectangle.
	 */
	public class FlxRect extends FlxPoint
	{
		/**
		 * @default 0
		 */
		public var width:Number;
		/**
		 * @default 0
		 */
		public var height:Number;
		
		/**
		 * Instantiate a new rectangle.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 * @param	Width	Desired width of the rectangle.
		 * @param	Height	Desired height of the rectangle.
		 */
		public function FlxRect(X:Number=0, Y:Number=0, Width:Number=0, Height:Number=0)
		{
			super(X,Y);
			width = Width;
			height = Height;
		}
		
		/**
		 * The X coordinate of the left side of the rectangle.  Read-only.
		 */
		public function get left():Number
		{
			return x;
		}
		
		/**
		 * The X coordinate of the right side of the rectangle.  Read-only.
		 */
		public function get right():Number
		{
			return x + width;
		}
		
		/**
		 * The Y coordinate of the top of the rectangle.  Read-only.
		 */
		public function get top():Number
		{
			return y;
		}
		
		/**
		 * The Y coordinate of the bottom of the rectangle.  Read-only.
		 */
		public function get bottom():Number
		{
			return y + height;
		}
		
		/**
		 * Checks to see if some <code>FlxObject</code> object overlaps this <code>FlxObject</code> object.
		 * 
		 * @param	Object	The object being tested.
		 * 
		 * @return	Whether or not the two objects overlap.
		 */
		public function overlaps(Rect:FlxRect):Boolean
		{
			if((Rect.x + Rect.width <= x) || (Rect.x >= x+width) || (Rect.y + Rect.height <= y) || (Rect.y >= y+height))
				return false;
			return true;
		}
		
		/**
		 * Calculate the distance between the midpoint of this rectangle and the midpoint of another rectangle.
		 * 
		 * @param Rect		A <code>FlxRect</code> object referring to the second rectangle.
		 * 
		 * @return	The distance between the two <code>FlxRect</code>s' midpoints as a floating point <code>Number</code> object.
		 */
		public function getDistanceMidpoints(Rect:FlxRect):Number
		{
			var dx:Number = (x + width/2) - (Rect.x + Rect.width/2);
			var dy:Number = (y + height/2) - (Rect.y + Rect.height/2);
			return Math.sqrt(dx * dx + dy * dy);
		}
	}
}
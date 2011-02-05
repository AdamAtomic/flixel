package org.flixel
{
	import org.flixel.FlxObject;
	import org.flixel.FlxPoint;
	import org.flixel.FlxU;
	
	/**
	 * ...
	 * @author Colin Alteveer (with much help from Keith Peters)
	 */
	public class FlxV extends FlxPoint
	{
		
		private static var min:Function = Math.min
		private static var sqrt:Function = Math.sqrt
		private static var sin:Function = Math.sin
		private static var cos:Function = Math.cos
		private static var acos:Function = Math.acos
		private static var atan2:Function = Math.atan2

		public static function clone(p:FlxPoint):FlxPoint {
			return new FlxPoint(p.x, p.y)
		}
		
		/**
		 * Sets / gets the length or magnitude of this vector. Changing the length will change the x and y but not the angle of this vector.
		 */
		public static function setLength(p:FlxPoint, value:Number):void
		{
			var a:Number = getAngle(p);
			p.x = cos(a) * value;
			p.y = sin(a) * value;
		}
		public static function getLength(p:FlxPoint):Number
		{
			return sqrt(getLengthSquared(p));
		}
		
		/**
		 * Gets the length of this vector, squared.
		 */
		public static function getLengthSquared(p:FlxPoint):Number
		{
			return p.x * p.x + p.y * p.y;
		}
		
		/**
		 * Gets / sets the angle of this vector. Changing the angle changes the x and y but retains the same length.
		 */
		public static function setAngle(p:FlxPoint, value:Number):void
		{
			var len:Number = getLength(p);
			p.x = cos(value) * len;
			p.y = sin(value) * len;
		}
		public static function getAngle(p:FlxPoint):Number
		{
			return atan2(p.y, p.x);
		}
		
		/**
		 * Normalizes this vector. Equivalent to setting the length to one, but more efficient.
		 */
		public static function normalize(p:FlxPoint):FlxPoint
		{
			var len:Number = getLength(p)
			if(len == 0)
			{
				p.x = 1;
				return p;
			}
			p.x /= len;
			p.y /= len;
			return p;
		}
		
		/**
		 * Ensures the length of the vector is no longer than the given value.
		 */
		public static function truncate(p:FlxPoint, max:Number):FlxPoint
		{
			setLength(p, min(max, getLength(p)));
			return p;
		}
		
		/**
		 * Reverses the direction of this vector.
		 */
		public static function reverse(p:FlxPoint):FlxPoint
		{
			p.x = -p.x;
			p.y = -p.y;
			return p;
		}
		
		/**
		 * Calculates the dot product of this vector and another given vector.
		 */
		public static function dotProd(v1:FlxPoint, v2:FlxPoint):Number
		{
			return v1.x * v2.x + v1.y * v2.y;
		}
		
		/**
		 * Calculates the cross product of this vector and another given vector.
		 */
		public static function crossProd(v1:FlxPoint, v2:FlxPoint):Number
		{
			return v1.x * v2.y - v1.y * v2.x;
		}
		
		/**
		 * Calculates the angle between two vectors.
		 */
		public static function angleBetween(v1:FlxPoint, v2:FlxPoint):Number
		{
			v1 = normalize(clone(v1));
			v2 = normalize(clone(v2));
			return acos(dotProd(v1, v2));
		}
		
		/**
		 * Determines if a given vector is to the right or left of this vector.
		 */
		public function sign(v1:FlxPoint, v2:FlxPoint):int
		{
			return dotProd(perp(v1), v2) < 0 ? -1 : 1;
		}
		
		/**
		 * Finds a vector that is perpendicular to this vector.
		 */
		public static function perp(p:FlxPoint):FlxPoint
		{
			return new FlxPoint(-p.y, p.x);
		}
		
		/**
		 * Calculates the distance from this vector to another given vector.
		 */
		public static function dist(v1:FlxPoint, v2:FlxPoint):Number
		{
			return sqrt(distSquared(v1, v2));
		}
		
		/**
		 * Calculates the distance squared from this vector to another given vector.
		 */
		public static function distSquared(v1:FlxPoint, v2:FlxPoint):Number
		{
			var dx:Number = v2.x - v1.x;
			var dy:Number = v2.y - v1.y;
			return dx * dx + dy * dy;
		}
		
		/**
		 * Adds a vector to this vector, creating a new FlxPoint instance to hold the result.
		 */
		public static function add(v1:FlxPoint, v2:FlxPoint):FlxPoint
		{
			return new FlxPoint(v1.x + v2.x, v1.y + v2.y);
		}
		
		/**
		 * Subtacts a vector to this vector, creating a new FlxPoint instance to hold the result.
		 */
		public static function subtract(v1:FlxPoint, v2:FlxPoint):FlxPoint
		{
			return new FlxPoint(v1.x - v2.x, v1.y - v2.y);
		}
		
		/**
		 * Multiplies this vector by a value, creating a new FlxPoint instance to hold the result.
		 */
		public static function multiply(p:FlxPoint, value:Number):FlxPoint
		{
			return new FlxPoint(p.x * value, p.y * value);
		}
		
		/**
		 * Divides this vector by a value, creating a new FlxPoint instance to hold the result.
		 */
		public static function divide(p:FlxPoint, value:Number):FlxPoint
		{
			return new FlxPoint(p.x / value, p.y / value);
		}
		
		/**
		 * Indicates whether this vector and another FlxPoint instance are equal in value.
		 */
		public static function equals(v1:FlxPoint, v2:FlxPoint):Boolean
		{
			return v1.x == v2.x && v1.y == v2.y;
		}
				
	}

}
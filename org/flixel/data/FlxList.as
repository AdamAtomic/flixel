package org.flixel.data
{
	import org.flixel.*;
	
	/**
	 * A linked list node. Create a head and tail FlxLists and loop through the list using a while loop.
	 * Useful for optimizing time-critical or highly repetitive tasks!
	 * See <code>FlxQuadTree</code> for how to use it, IF YOU DARE.
	 */
	public class FlxList
	{
		/**
		 * Stores a reference to a <code>FlxObject</code>.
		 */
		public var object:FlxObject;
		/**
		 * Stores a reference to the next link in the list.
		 */
		public var next:FlxList;
		
		/**
		 * Creates a new link, and sets <code>object</code> and <code>next</code> to <code>null</null>.
		 */
		public function FlxList()
		{
			object = null;
			next = null;
		}
	}
}
package org.flixel
{
	import org.flixel.system.FlxQuadTree;
	
	/**
	 * This is the basic game "state" object - e.g. in a simple game
	 * you might have a menu state and a play state.
	 * It is for all intents and purpose a glorified FlxGroup.
	 */
	public class FlxState extends FlxGroup
	{
		/**
		 * This function is called after the game engine successfully switches states.
		 * Override this function to initialize or set up your game state.
		 * Do NOT override the constructor, unless you want some crazy unpredictable things to happen!
		 */
		public function create():void
		{
			
		}
		
		/**
		 * Call this function to see if one <code>FlxObject</code> overlaps another.
		 * Can be called with one object and one group, or two groups, or two objects,
		 * whatever floats your boat!  It will put everything into a quad tree and then
		 * check for overlaps.  For maximum performance try bundling a lot of objects
		 * together using a <code>FlxGroup</code> (even bundling groups together!)
		 * NOTE: does NOT take objects' scrollfactor into account.
		 * 
		 * @param	ObjectOrGroup1	The first object or group you want to check.
		 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
		 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
		 * @param	ProcessCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
		 */
		public function overlap(ObjectOrGroup1:FlxBasic=null,ObjectOrGroup2:FlxBasic=null,NotifyCallback:Function=null,ProcessCallback:Function=null):Boolean
		{
			if(ObjectOrGroup1 == null)
				ObjectOrGroup1 = this;
			if(ObjectOrGroup2 === ObjectOrGroup1)
				ObjectOrGroup2 = null;
			FlxQuadTree.divisions = FlxG.worldDivisions;
			var quadTree:FlxQuadTree = new FlxQuadTree(FlxG.worldBounds.x,FlxG.worldBounds.y,FlxG.worldBounds.width,FlxG.worldBounds.height);
			quadTree.load(ObjectOrGroup1,ObjectOrGroup2,NotifyCallback,ProcessCallback);
			var result:Boolean = quadTree.execute();
			quadTree.destroy();
			return result;
		}
		
		/**
		 * Call this function to see if one <code>FlxObject</code> collides with another.
		 * Can be called with one object and one group, or two groups, or two objects,
		 * whatever floats your boat!  It will put everything into a quad tree and then
		 * check for collisions.  For maximum performance try bundling a lot of objects
		 * together using a <code>FlxGroup</code> (even bundling groups together!)
		 * NOTE: does NOT take objects' scrollfactor into account.
		 * 
		* @param	ObjectOrGroup1	The first object or group you want to check.
		 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
		 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
		 */
		public function collide(ObjectOrGroup1:FlxBasic=null, ObjectOrGroup2:FlxBasic=null, NotifyCallback:Function=null):Boolean
		{
			return overlap(ObjectOrGroup1,ObjectOrGroup2,NotifyCallback,FlxObject.separate);
		}
	}
}

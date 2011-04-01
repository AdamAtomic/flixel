package org.flixel
{
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
	}
}
package org.flixel
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	/**
	 * This is the basic game "state" object - e.g. in a simple game
	 * you might have a menu state and a play state.
	 * It acts as a kind of container for all your game objects.
	 * You can also access the game's background color
	 * and screen buffer through this object.
	 */
	public class FlxState extends FlxGroup
	{
		/**
		 * This static variable holds the screen buffer,
		 * so you can draw to it directly if you want.
		 */
		static public var screen:FlxSprite;
		/**
		 * This static variable indicates the "clear color"
		 * or default background color of the game.
		 * Change it at ANY time using <code>FlxState.bgColor</code>.
		 */
		static public var bgColor:uint;
		
		/**
		 * This function is called after the game engine successfully switches states.
		 * Override this function to initialize or set up your game state.
		 * Do NOT override the constructor, unless you want some crazy unpredictable things to happen!
		 */
		public function create():void
		{
			
		}
		
		/**
		 * Override this function to do special pre-processing FX like motion blur.
		 * You can use scaling or blending modes or whatever you want against
		 * <code>FlxState.screen</code> to achieve all sorts of cool FX.
		 */
		public function preProcess():void
		{
			screen.fill(bgColor);	//Default behavior - just overwrite buffer with background color
		}

		/**
		 * Override this function to do special pre-processing FX like light bloom.
		 * You can use scaling or blending modes or whatever you want against
		 * <code>FlxState.screen</code> to achieve all sorts of cool FX.
		 */
		public function postProcess():void
		{
			//no fx by default
		}
	}
}
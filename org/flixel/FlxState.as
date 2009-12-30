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
	public class FlxState extends Sprite
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
		 * Internal layer used to organize and display objects you add to this state.
		 */
		protected var _layer:FlxLayer;
		
		/**
		 * Creates a new <code>FlxState</code> object,
		 * instantiating <code>screen</code> if necessary.
		 */
		virtual public function FlxState()
		{
			super();
			_layer = new FlxLayer();
			FlxG.state = this;
			if(screen == null)
			{
				screen = new FlxSprite();
				screen.createGraphic(FlxG.width,FlxG.height,0,true);
				screen.origin.x = screen.origin.y = 0;
				screen.antialiasing = true;
			}
		}
		
		/**
		 * Adds a new FlxCore subclass (FlxSprite, FlxBlock, etc) to the game loop.
		 * 
		 * @param	Core	The object you want to add to the game loop.
		 */
		virtual public function add(Core:FlxCore):FlxCore
		{
			return _layer.add(Core);
		}
		
		/**
		 * Override this function to do special pre-processing FX like motion blur.
		 * You can use scaling or blending modes or whatever you want against
		 * <code>FlxState.screen</code> to achieve all sorts of cool FX.
		 */
		virtual public function preProcess():void
		{
			screen.fill(bgColor);	//Default behavior - just overwrite buffer with background color
		}
		
		/**
		 * Automatically goes through and calls update on everything you added to the game loop,
		 * override this function to handle custom input and perform collisions/
		 */
		virtual public function update():void
		{
			_layer.update();
		}
		
		/**
		 * Automatically goes through and calls render on everything you added to the game loop,
		 * override this loop to manually control the rendering process.
		 */
		virtual public function render():void
		{
			_layer.render();
		}

		/**
		 * Override this function to do special pre-processing FX like light bloom.
		 * You can use scaling or blending modes or whatever you want against
		 * <code>FlxState.screen</code> to achieve all sorts of cool FX.
		 */
		virtual public function postProcess():void { }
		
		/**
		 * Override this function to handle any deleting or "shutdown" type operations you
		 * might need (such as removing traditional Flash children like Sprite objects).
		 */
		virtual public function destroy():void
		{
			_layer.destroy();
		}
	}
}
package org.flixel
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;

	//@desc		This is the basic game "state" object - e.g. in a simple game you might have a menu state and a play state
	public class FlxState extends Sprite
	{
		//@desc		This variable holds the screen buffer, so you can draw to it directly if you want
		static public var screen:FlxSprite;
		//@desc		This variable indicates the "clear color" or default background color of the game
		static public var bgColor:uint;
		protected var _layer:FlxLayer;
		
		//@desc		Constructor		
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
		
		//@desc		Adds a new FlxCore subclass (FlxSprite, FlxBlock, etc) to the game loop
		//@param	Core	The object you want to add to the game loop
		virtual public function add(Core:FlxCore):FlxCore
		{
			return _layer.add(Core);
		}
		
		//@desc		Override this function to do special pre-processing FX on FlxG.buffer (like motion blur)
		virtual public function preProcess():void
		{
			screen.fill(bgColor);	//Default behavior - just overwrite buffer with background color
		}
		
		//@desc		Automatically goes through and calls update on everything you added to the game loop, override this function to handle custom input and perform collisions
		virtual public function update():void
		{
			_layer.update();
		}
		
		//@desc		Automatically goes through and calls render on everything you added to the game loop, override this loop to do crazy graphical stuffs I guess?
		virtual public function render():void
		{
			_layer.render();
		}
		
		//@desc		Override this function and use the 'screen' variable to do special post-processing FX (like light bloom)
		virtual public function postProcess():void { }
		
		//@desc		Override this function to handle any deleting or "shutdown" type operations you might need (such as removing traditional Flash children like Sprite objects)
		virtual public function destroy():void { _layer.destroy(); }
	}
}
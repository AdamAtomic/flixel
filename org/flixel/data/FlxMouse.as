package org.flixel.data
{
	import flash.events.MouseEvent;
	
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	
	/**
	 * This class helps contain and track the mouse pointer in your game.
	 * Automatically accounts for parallax scrolling, etc.
	 */
	public class FlxMouse
	{
		[Embed(source="cursor.png")] protected var ImgDefaultCursor:Class;
		
		/**
		 * Current X position of the mouse pointer in the game world.
		 */
		public var x:int;
		/**
		 * Current Y position of the mouse pointer in the game world.
		 */
		public var y:int;
		/**
		 * Current X position of the mouse pointer on the screen.
		 */
		public var screenX:int;
		/**
		 * Current Y position of the mouse pointer on the screen.
		 */
		public var screenY:int;
		/**
		 * Graphical representation of the mouse pointer.
		 */
		public var cursor:FlxSprite;
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _current:int;
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _last:int;
		/**
		 * Helper for mouse visibility.
		 */
		protected var _out:Boolean;
		
		/**
		 * Constructor.
		 */
		public function FlxMouse()
		{
			x = 0;
			y = 0;
			screenX = 0;
			screenY = 0;
			_current = 0;
			_last = 0;
			cursor = null;
			_out = false;
		}
		
		/**
		 * Either show an existing cursor or load a new one.
		 * 
		 * @param	Graphic		The image you want to use for the cursor.
		 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
		 * * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
		 */
		public function show(Graphic:Class=null,XOffset:int=0,YOffset:int=0):void
		{
			_out = true;
			if(Graphic != null)
				load(Graphic,XOffset,YOffset);
			else if(cursor != null)
				cursor.visible = true;
			else
				load(null);
		}
		
		/**
		 * Hides the mouse cursor
		 */
		public function hide():void
		{
			if(cursor != null)
			{
				cursor.visible = false;
				_out = false;
			}
		}
		
		/**
		 * Load a new mouse cursor graphic
		 * 
		 * @param	Graphic		The image you want to use for the cursor.
		 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
		 * * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
		 */
		public function load(Graphic:Class,XOffset:int=0,YOffset:int=0):void
		{
			if(Graphic == null)
				Graphic = ImgDefaultCursor;
			cursor = new FlxSprite(screenX,screenY,Graphic);
			cursor.offset.x = XOffset;
			cursor.offset.y = YOffset;
		}
		
		/**
		 * Unload the current cursor graphic.  If the current cursor is visible,
		 * then the default system cursor is loaded up to replace the old one.
		 */
		public function unload():void
		{
			if(cursor != null)
			{
				if(cursor.visible)
					load(null);
				else
					cursor = null;
			}
		}

		/**
		 * Called by the internal game loop to update the mouse pointer's position in the game world.
		 * Also updates the just pressed/just released flags.
		 * 
		 * @param	X			The current X position of the mouse in the window.
		 * @param	Y			The current Y position of the mouse in the window.
		 * @param	XScroll		The amount the game world has scrolled horizontally.
		 * @param	YScroll		The amount the game world has scrolled vertically.
		 */
		public function update(X:int,Y:int,XScroll:Number,YScroll:Number):void
		{
			screenX = X;
			screenY = Y;
			x = screenX-FlxU.floor(XScroll);
			y = screenY-FlxU.floor(YScroll);
			if(cursor != null)
			{
				cursor.x = x;
				cursor.y = y;
			}
			if((_last == -1) && (_current == -1))
				_current = 0;
			else if((_last == 2) && (_current == 2))
				_current = 1;
			_last = _current;
		}
		
		/**
		 * Resets the just pressed/just released flags and sets mouse to not pressed.
		 */
		public function reset():void
		{
			_current = 0;
			_last = 0;
		}
		
		/**
		 * Check to see if the mouse is pressed.
		 * 
		 * @return	Whether the mouse is pressed.
		 */
		public function pressed():Boolean { return _current > 0; }
		
		/**
		 * Check to see if the mouse was just pressed.
		 * 
		 * @return Whether the mouse was just pressed.
		 */
		public function justPressed():Boolean { return _current == 2; }
		
		/**
		 * Check to see if the mouse was just released.
		 * 
		 * @return	Whether the mouse was just released.
		 */
		public function justReleased():Boolean { return _current == -1; }
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseDown(event:MouseEvent):void
		{
			if(_current > 0) _current = 1;
			else _current = 2;
		}
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseUp(event:MouseEvent):void
		{
			if(_current > 0) _current = -1;
			else _current = 0;
		}
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseOut(event:MouseEvent):void
		{
			if(cursor != null)
			{
				_out = cursor.visible;
				cursor.visible = false;
			}
		}
		
		/**
		 * Event handler so FlxGame can toggle the mouse.
		 * 
		 * @param	event	A <code>MouseEvent</code> object.
		 */
		public function handleMouseOver(event:MouseEvent):void
		{
			if(cursor != null)
				cursor.visible = _out;
		}
	}
}
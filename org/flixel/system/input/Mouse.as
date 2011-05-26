package org.flixel.system.input
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import org.flixel.FlxCamera;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import org.flixel.FlxU;
	import org.flixel.system.replay.MouseRecord;
	
	/**
	 * This class helps contain and track the mouse pointer in your game.
	 * Automatically accounts for parallax scrolling, etc.
	 * 
	 * @author Adam Atomic
	 */
	public class Mouse extends FlxPoint
	{
		[Embed(source="../../data/cursor.png")] protected var ImgDefaultCursor:Class;

		/**
		 * Current "delta" value of mouse wheel.  If the wheel was just scrolled up, it will have a positive value.  If it was just scrolled down, it will have a negative value.  If it wasn't just scroll this frame, it will be 0.
		 */
		public var wheel:int;
		/**
		 * Current X position of the mouse pointer on the screen.
		 */
		public var screenX:int;
		/**
		 * Current Y position of the mouse pointer on the screen.
		 */
		public var screenY:int;
		
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _current:int;
		/**
		 * Helper variable for tracking whether the mouse was just pressed or just released.
		 */
		protected var _last:int;
		/**
		 * A display container for the mouse cursor.
		 * This container is a child of FlxGame and sits at the right "height".
		 */
		protected var _cursorContainer:Sprite;
		/**
		 * This is just a reference to the current cursor image, if there is one.
		 */
		protected var _cursor:Bitmap;
		/**
		 * Helper variables for recording purposes.
		 */
		protected var _lastX:int;
		protected var _lastY:int;
		protected var _lastWheel:int;
		protected var _point:FlxPoint;
		protected var _globalScreenPosition:FlxPoint;
		
		/**
		 * Constructor.
		 */
		public function Mouse(CursorContainer:Sprite)
		{
			super();
			_cursorContainer = CursorContainer;
			_lastX = screenX = 0;
			_lastY = screenY = 0;
			_lastWheel = wheel = 0;
			_current = 0;
			_last = 0;
			_cursor = null;
			_point = new FlxPoint();
			_globalScreenPosition = new FlxPoint();
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			_cursorContainer = null;
			_cursor = null;
			_point = null;
			_globalScreenPosition = null;
		}
		
		/**
		 * Either show an existing cursor or load a new one.
		 * 
		 * @param	Graphic		The image you want to use for the cursor.
		 * @param	Scale		Change the size of the cursor.  Default = 1, or native size.  2 = 2x as big, 0.5 = half size, etc.
		 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
		 * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
		 */
		public function show(Graphic:Class=null,Scale:Number=1,XOffset:int=0,YOffset:int=0):void
		{
			_cursorContainer.visible = true;
			if(Graphic != null)
				load(Graphic,Scale,XOffset,YOffset);
			else if(_cursor == null)
				load();
		}
		
		/**
		 * Hides the mouse cursor
		 */
		public function hide():void
		{
			_cursorContainer.visible = false;
		}
		
		/**
		 * Read only, check visibility of mouse cursor.
		 */
		public function get visible():Boolean
		{
			return _cursorContainer.visible;
		}
		
		/**
		 * Load a new mouse cursor graphic
		 * 
		 * @param	Graphic		The image you want to use for the cursor.
		 * @param	Scale		Change the size of the cursor.
		 * @param	XOffset		The number of pixels between the mouse's screen position and the graphic's top left corner.
		 * @param	YOffset		The number of pixels between the mouse's screen position and the graphic's top left corner. 
		 */
		public function load(Graphic:Class=null,Scale:Number=1,XOffset:int=0,YOffset:int=0):void
		{
			if(_cursor != null)
				_cursorContainer.removeChild(_cursor);

			if(Graphic == null)
				Graphic = ImgDefaultCursor;
			_cursor = new Graphic();
			_cursor.x = XOffset;
			_cursor.y = YOffset;
			_cursor.scaleX = Scale;
			_cursor.scaleY = Scale;
			
			_cursorContainer.addChild(_cursor);
		}
		
		/**
		 * Unload the current cursor graphic.  If the current cursor is visible,
		 * then the default system cursor is loaded up to replace the old one.
		 */
		public function unload():void
		{
			if(_cursor != null)
			{
				if(_cursorContainer.visible)
					load();
				else
				{
					_cursorContainer.removeChild(_cursor)
					_cursor = null;
				}
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
		public function update(X:int,Y:int):void
		{
			_globalScreenPosition.x = X;
			_globalScreenPosition.y = Y;
			updateCursor();
			if((_last == -1) && (_current == -1))
				_current = 0;
			else if((_last == 2) && (_current == 2))
				_current = 1;
			_last = _current;
		}
		
		/**
		 * Internal function for helping to update the mouse cursor and world coordinates.
		 */
		protected function updateCursor():void
		{
			//actually position the flixel mouse cursor graphic
			_cursorContainer.x = _globalScreenPosition.x;
			_cursorContainer.y = _globalScreenPosition.y;
			
			//update the x, y, screenX, and screenY variables based on the default camera.
			//This is basically a combination of getWorldPosition() and getScreenPosition()
			var camera:FlxCamera = FlxG.camera;
			screenX = (_globalScreenPosition.x - camera.x)/camera.zoom;
			screenY = (_globalScreenPosition.y - camera.y)/camera.zoom;
			x = screenX + camera.scroll.x;
			y = screenY + camera.scroll.y;
		}
		
		/**
		 * Fetch the world position of the mouse on any given camera.
		 * NOTE: Mouse.x and Mouse.y also store the world position of the mouse cursor on the main camera.
		 * 
		 * @param Camera	If unspecified, first/main global camera is used instead.
		 * @param Point		An existing point object to store the results (if you don't want a new one created). 
		 * 
		 * @return The mouse's location in world space.
		 */
		public function getWorldPosition(Camera:FlxCamera=null,Point:FlxPoint=null):FlxPoint
		{
			if(Camera == null)
				Camera = FlxG.camera;
			if(Point == null)
				Point = new FlxPoint();
			getScreenPosition(Camera,_point);
			Point.x = _point.x + Camera.scroll.x;
			Point.y = _point.y + Camera.scroll.y;
			return Point;
		}
		
		/**
		 * Fetch the screen position of the mouse on any given camera.
		 * NOTE: Mouse.screenX and Mouse.screenY also store the screen position of the mouse cursor on the main camera.
		 * 
		 * @param Camera	If unspecified, first/main global camera is used instead.
		 * @param Point		An existing point object to store the results (if you don't want a new one created). 
		 * 
		 * @return The mouse's location in screen space.
		 */
		public function getScreenPosition(Camera:FlxCamera=null,Point:FlxPoint=null):FlxPoint
		{
			if(Camera == null)
				Camera = FlxG.camera;
			if(Point == null)
				Point = new FlxPoint();
			Point.x = (_globalScreenPosition.x - Camera.x)/Camera.zoom;
			Point.y = (_globalScreenPosition.y - Camera.y)/Camera.zoom;
			return Point;
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
		 * Event handler so FlxGame can update the mouse.
		 * 
		 * @param	FlashEvent	A <code>MouseEvent</code> object.
		 */
		public function handleMouseDown(FlashEvent:MouseEvent):void
		{
			if(_current > 0) _current = 1;
			else _current = 2;
		}
		
		/**
		 * Event handler so FlxGame can update the mouse.
		 * 
		 * @param	FlashEvent	A <code>MouseEvent</code> object.
		 */
		public function handleMouseUp(FlashEvent:MouseEvent):void
		{
			if(_current > 0) _current = -1;
			else _current = 0;
		}
		
		/**
		 * Event handler so FlxGame can update the mouse.
		 * 
		 * @param	FlashEvent	A <code>MouseEvent</code> object.
		 */
		public function handleMouseWheel(FlashEvent:MouseEvent):void
		{
			wheel = FlashEvent.delta;
		}
		
		/**
		 * If the mouse changed state or is pressed, return that info now
		 * 
		 * @return	An array of key state data.  Null if there is no data.
		 */
		public function record():MouseRecord
		{
			if((_lastX == _globalScreenPosition.x) && (_lastY == _globalScreenPosition.y) && (_current == 0) && (_lastWheel == wheel))
				return null;
			_lastX = _globalScreenPosition.x;
			_lastY = _globalScreenPosition.y;
			_lastWheel = wheel;
			return new MouseRecord(_lastX,_lastY,_current,_lastWheel);
		}
		
		/**
		 * Part of the keystroke recording system.
		 * Takes data about key presses and sets it into array.
		 * 
		 * @param	KeyStates	Array of data about key states.
		 */
		public function playback(Record:MouseRecord):void
		{
			_current = Record.button;
			wheel = Record.wheel;
			_globalScreenPosition.x = Record.x;
			_globalScreenPosition.y = Record.y;
			updateCursor();
		}
	}
}
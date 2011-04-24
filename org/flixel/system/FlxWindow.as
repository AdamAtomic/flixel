package org.flixel.system
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;
	
	/**
	 * A generic, Flash-based window class, created for use in <code>FlxDebugger</code>.
	 * 
	 * @author Adam Atomic
	 */
	public class FlxWindow extends Sprite
	{
		[Embed(source="../data/handle.png")] protected var ImgHandle:Class;

		/**
		 * Minimum allowed X and Y dimensions for this window.
		 */
		public var minSize:Point;
		/**
		 * Maximum allowed X and Y dimensions for this window.
		 */
		public var maxSize:Point;
		
		/**
		 * Width of the window.  Using Sprite.width is super unreliable for some reason!
		 */
		protected var _width:uint;
		/**
		 * Height of the window.  Using Sprite.height is super unreliable for some reason!
		 */
		protected var _height:uint;
		/**
		 * Controls where the window is allowed to be positioned.
		 */
		protected var _bounds:Rectangle;
		
		/**
		 * Window display element.
		 */
		protected var _background:Bitmap;
		/**
		 * Window display element.
		 */
		protected var _header:Bitmap;
		/**
		 * Window display element.
		 */
		protected var _shadow:Bitmap;
		/**
		 * Window display element.
		 */
		protected var _title:TextField;
		/**
		 * Window display element.
		 */
		protected var _handle:Bitmap;
		
		/**
		 * Helper for interaction.
		 */
		protected var _overHeader:Boolean;
		/**
		 * Helper for interaction.
		 */
		protected var _overHandle:Boolean;
		/**
		 * Helper for interaction.
		 */
		protected var _drag:Point;
		/**
		 * Helper for interaction.
		 */
		protected var _dragging:Boolean;
		/**
		 * Helper for interaction.
		 */
		protected var _resizing:Boolean;
		/**
		 * Helper for interaction.
		 */
		protected var _resizable:Boolean;
		
		/**
		 * Creates a new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
		 * 
		 * @param Title			The name of the window, displayed in the header bar.
		 * @param Width			The initial width of the window.
		 * @param Height		The initial height of the window.
		 * @param Resizable		Whether you can change the size of the window with a drag handle.
		 * @param Bounds		A rectangle indicating the valid screen area for the window.
		 * @param BGColor		What color the window background should be, default is gray and transparent.
		 * @param TopColor		What color the window header bar should be, default is black and transparent.
		 */
		public function FlxWindow(Title:String,Width:Number,Height:Number,Resizable:Boolean=true,Bounds:Rectangle=null,BGColor:uint=0x7f7f7f7f, TopColor:uint=0x7f000000)
		{
			super();
			_width = Width;
			_height = Height;
			_bounds = Bounds;
			minSize = new Point(50,30);
			if(_bounds != null)
				maxSize = new Point(_bounds.width,_bounds.height);
			else
				maxSize = new Point(Number.MAX_VALUE,Number.MAX_VALUE);
			_drag = new Point();
			_resizable = Resizable;
			
			_shadow = new Bitmap(new BitmapData(1,2,true,0xff000000));
			addChild(_shadow);
			_background = new Bitmap(new BitmapData(1,1,true,BGColor));
			_background.y = 15;
			addChild(_background);
			_header = new Bitmap(new BitmapData(1,15,true,TopColor));
			addChild(_header);
			
			_title = new TextField();
			_title.x = 2;
			_title.height = 16;
			_title.selectable = false;
			_title.multiline = false;
			_title.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			_title.text = Title;
			addChild(_title);
			
			if(_resizable)
			{
				_handle = new ImgHandle();
				addChild(_handle);
			}
			
			if((_width != 0) || (_height != 0))
				updateSize();
			bound();
			
			addEventListener(Event.ENTER_FRAME,init);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			minSize = null;
			maxSize = null;
			_bounds = null;
			removeChild(_shadow);
			_shadow = null;
			removeChild(_background);
			_background = null;
			removeChild(_header);
			_header = null;
			removeChild(_title);
			_title = null;
			if(_handle != null)
				removeChild(_handle);
			_handle = null;
			_drag = null;
		}
		
		/**
		 * Resize the window.  Subject to pre-specified minimums, maximums, and bounding rectangles.
		 *  
		 * @param Width		How wide to make the window.
		 * @param Height	How tall to make the window.
		 */
		public function resize(Width:Number,Height:Number):void
		{
			_width = Width;
			_height = Height;
			updateSize();
		}
		
		/**
		 * Change the position of the window.  Subject to pre-specified bounding rectangles.
		 * 
		 * @param X		Desired X position of top left corner of the window.
		 * @param Y		Desired Y position of top left corner of the window.
		 */
		public function reposition(X:Number,Y:Number):void
		{
			x = X;
			y = Y;
			bound();
		}
		
		//***EVENT HANDLERS***//
		
		/**
		 * Used to set up basic mouse listeners.
		 * 
		 * @param E		Flash event.
		 */
		protected function init(E:Event=null):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME,init);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		/**
		 * Mouse movement handler.  Figures out if mouse is over handle or header bar or what.
		 * 
		 * @param E		Flash mouse event.
		 */
		protected function onMouseMove(E:MouseEvent=null):void
		{
			if(_dragging) //user is moving the window around
			{
				_overHeader = true;
				reposition(parent.mouseX - _drag.x, parent.mouseY - _drag.y);
			}
			else if(_resizing)
			{
				_overHandle = true;
				resize(mouseX - _drag.x, mouseY - _drag.y);
			}
			else if((mouseX >= 0) && (mouseX <= _width) && (mouseY >= 0) && (mouseY <= _height))
			{	//not dragging, mouse is over the window
				_overHeader = (mouseX <= _header.width) && (mouseY <= _header.height);
				if(_resizable)
					_overHandle = (mouseX >= _width - _handle.width) && (mouseY >= _height - _handle.height);
			}
			else
			{	//not dragging, mouse is NOT over window
				_overHandle = _overHeader = false;
			}
			
			updateGUI();
		}
		
		/**
		 * Figure out if window is being repositioned (clicked on header) or resized (clicked on handle).
		 * 
		 * @param E		Flash mouse event.
		 */
		protected function onMouseDown(E:MouseEvent=null):void
		{
			if(_overHeader)
			{
				_dragging = true;
				_drag.x = mouseX;
				_drag.y = mouseY;
			}
			else if(_overHandle)
			{
				_resizing = true;
				_drag.x = _width-mouseX;
				_drag.y = _height-mouseY;
			}
		}
		
		/**
		 * User let go of header bar or handler (or nothing), so turn off drag and resize behaviors.
		 * 
		 * @param E		Flash mouse event.
		 */
		protected function onMouseUp(E:MouseEvent=null):void
		{
			_dragging = false;
			_resizing = false;
		}
		
		//***MISC GUI MGMT STUFF***//
		
		/**
		 * Keep the window within the pre-specified bounding rectangle. 
		 */
		protected function bound():void
		{
			if(_bounds != null)
			{
				x = FlxU.bound(x,_bounds.left,_bounds.right-_width);
				y = FlxU.bound(y,_bounds.top,_bounds.bottom-_height);
			}
		}
		
		/**
		 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
		 */
		protected function updateSize():void
		{
			_width = FlxU.bound(_width,minSize.x,maxSize.x);
			_height = FlxU.bound(_height,minSize.y,maxSize.y);
			
			_header.scaleX = _width;
			_background.scaleX = _width;
			_background.scaleY = _height-15;
			_shadow.scaleX = _width;
			_shadow.y = _height;
			_title.width = _width-4;
			if(_resizable)
			{
				_handle.x = _width-_handle.width;
				_handle.y = _height-_handle.height;
			}
		}
		
		/**
		 * Figure out if the header or handle are highlighted.
		 */
		protected function updateGUI():void
		{
			if(_overHeader || _overHandle)
			{
				if(_title.alpha != 1.0)
					_title.alpha = 1.0;
			}
			else
			{
				if(_title.alpha != 0.65)
					_title.alpha = 0.65;
			}
		}
	}
}

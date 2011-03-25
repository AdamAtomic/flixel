package org.flixel.aux
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
	
	public class FlxWindow extends Sprite
	{
		[Embed(source="../data/handle.png")] protected var ImgHandle:Class;

		public var minSize:Point;
		public var maxSize:Point;
		
		protected var _width:uint;
		protected var _height:uint;
		protected var _bounds:Rectangle;
		protected var _minSize:Point;
		
		protected var _bg:Bitmap;
		protected var _header:Bitmap;
		protected var _shadow:Bitmap;
		protected var _title:TextField;
		protected var _handle:Bitmap;
		
		protected var _overHeader:Boolean;
		protected var _overHandle:Boolean;
		protected var _drag:Point;
		protected var _dragging:Boolean;
		protected var _resizing:Boolean;
		protected var _resizable:Boolean;
		
		public function FlxWindow(Title:String,Width:Number,Height:Number,Resizable:Boolean=true,Bounds:Rectangle=null,BGColor:uint=0xdfBABCBF,TopColor:uint=0xff4E5359)
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
			_bg = new Bitmap(new BitmapData(1,1,true,BGColor));
			_bg.y = 15;
			addChild(_bg);
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
		
		public function resize(Width:Number,Height:Number):void
		{
			_width = Width;
			_height = Height;
			updateSize();
		}
		
		public function reposition(X:Number,Y:Number):void
		{
			x = X;
			y = Y;
			bound();
		}
		
		//***EVENT HANDLERS***//
		
		protected function init(E:Event=null):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME,init);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
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
		
		protected function onMouseUp(E:MouseEvent=null):void
		{
			_dragging = false;
			_resizing = false;
		}
		
		//***MISC GUI MGMT STUFF***//
		
		protected function bound():void
		{
			if(_bounds != null)
			{
				x = FlxU.bound(x,_bounds.left,_bounds.right-_width);
				y = FlxU.bound(y,_bounds.top,_bounds.bottom-_height);
			}
		}
		
		protected function updateSize():void
		{
			_width = FlxU.bound(_width,minSize.x,maxSize.x);
			_height = FlxU.bound(_height,minSize.y,maxSize.y);
			
			_header.scaleX = _width;
			_bg.scaleX = _width;
			_bg.scaleY = _height-15;
			_shadow.scaleX = _width;
			_shadow.y = _height;
			_title.width = _width-4;
			if(_resizable)
			{
				_handle.x = _width-_handle.width;
				_handle.y = _height-_handle.height;
			}
		}
		
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

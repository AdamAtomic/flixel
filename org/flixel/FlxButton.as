package org.flixel
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//@desc		A simple button class that calls a function when mouse-clicked
	public class FlxButton extends FlxCore
	{
		private var _onToggle:Boolean;
		private var _off:FlxSprite;
		private var _on:FlxSprite;
		private var _offT:FlxText;
		private var _offTO:Point;
		private var _onT:FlxText;
		private var _onTO:Point;
		private var _callback:Function;
		private var _pressed:Boolean;
		private var _initialized:Boolean;
		
		//@desc		Constructor
		//@param	X			The X position of the button
		//@param	Y			The Y position of the button
		//@param	Image		A FlxSprite object to use for the button background
		//@param	Callback	The function to call whenever the button is clicked
		//@param	ImageOn		A FlxSprite object to use for the button background when highlighted (optional)
		//@param	Text		A FlxText object to use to display text on this button (optional)
		//@param	TextOn		A FlxText object that is used when the button is highlighted (optional)
		public function FlxButton(X:int,Y:int,Image:FlxSprite,Callback:Function,ImageOn:FlxSprite=null,Text:FlxText=null,TextOn:FlxText=null)
		{
			super();
			x = X;
			y = Y;
			_off = Image;
			if(ImageOn == null) _on = _off;
			else _on = ImageOn;
			width = _off.width;
			height = _off.height;
			if(Text != null) _offT = Text;
			if(TextOn == null) _onT = _offT;
			else _onT = TextOn;
			if(_offT != null) _offTO = new Point(_offT.x,_offT.y);
			if(_onT != null) _onTO = new Point(_onT.x,_onT.y);
			
			_off.scrollFactor = scrollFactor;
			_on.scrollFactor = scrollFactor;
			if(_offT != null)
			{
				_offT.scrollFactor = scrollFactor;
				_onT.scrollFactor = scrollFactor;
			}
			
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			
			updatePositions();
			
			_initialized = false;
		}
		
		//@desc		Called by the game loop automatically, handles mouseover and click detection
		override public function update():void
		{
			if(!_initialized)
			{
				if(FlxG.state == null) return;
				if(FlxG.state.parent == null) return;
				if(FlxG.state.parent.stage == null) return;
				FlxG.state.parent.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
				_initialized = true;
			}
			
			super.update();

			if((_off != null) && _off.exists && _off.active) _off.update();
			if((_on != null) && _on.exists && _on.active) _on.update();
			if(_offT != null)
			{
				if((_offT != null) && _offT.exists && _offT.active) _offT.update();
				if((_onT != null) && _onT.exists && _onT.active) _onT.update();
			}

			visibility(false);
			if(_off.overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(!FlxG.kMouse)
					_pressed = false;
				else if(!_pressed)
				{
					_pressed = true;
					if(!_initialized) _callback();
				}
				visibility(!_pressed);
			}
			if(_onToggle) visibility(_off.visible);
			updatePositions();
		}
		
		override public function render():void
		{
			super.render();
			if((_off != null) && _off.exists && _off.visible) _off.render();
			if((_on != null) && _on.exists && _on.visible) _on.render();
			if(_offT != null)
			{
				if((_offT != null) && _offT.exists && _offT.visible) _offT.render();
				if((_onT != null) && _onT.exists && _onT.visible) _onT.render();
			}
		}
		
		//@desc		Call this function from your callback to toggle the button off, like a checkbox
		public function switchOff():void
		{
			_onToggle = false;
		}
		
		//@desc		Call this function from your callback to toggle the button on, like a checkbox
		public function switchOn():void
		{
			_onToggle = true;
		}
		
		//@desc		Check to see if the button is toggled on, like a checkbox
		//@return	Whether the button is toggled
		public function on():Boolean
		{
			return _onToggle;
		}
		
		//@desc		Internal function for handling the visibility of the off and on graphics
		//@param	On		Whether the button should be on or off
		private function visibility(On:Boolean):void
		{
			if(On)
			{
				_off.visible = false;
				if(_offT != null) _offT.visible = false;
				_on.visible = true;
				if(_onT != null) _onT.visible = true;
			}
			else
			{
				_on.visible = false;
				if(_onT != null) _onT.visible = false;
				_off.visible = true;
				if(_offT != null) _offT.visible = true;
			}
		}
		
		//@desc		Internal function that just updates the X and Y position of the button's graphics
		private function updatePositions():void
		{
			_off.x = x;
			_off.y = y;
			if(_offT)
			{
				_offT.x = _offTO.x+x;
				_offT.y = _offTO.y+y;
			}
			_on.x = x;
			_on.y = y;
			if(_onT)
			{
				_onT.x = _onTO.x+x;
				_onT.y = _onTO.y+y;
			}
		}
		
		//@desc		Internal function for handling the actual callback call (for UI thread dependent calls)
		private function onMouseUp(event:MouseEvent):void
		{
			if((!exists) || (!visible)) return;
			if(_off.overlapsPoint(FlxG.mouse.x+(1-scrollFactor.x)*FlxG.scroll.x,FlxG.mouse.y+(1-scrollFactor.y)*FlxG.scroll.y)) _callback();
		}
	}
}

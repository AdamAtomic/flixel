package org.flixel
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	//@desc		A simple button class that calls a function when mouse-clicked
	public class FlxButton extends FlxCore
	{
		protected var _onToggle:Boolean;
		protected var _off:FlxSprite;
		protected var _on:FlxSprite;
		protected var _offT:FlxText;
		protected var _offTO:Point;
		protected var _onT:FlxText;
		protected var _onTO:Point;
		protected var _callback:Function;
		protected var _pressed:Boolean;
		protected var _initialized:Boolean;
		protected var _sf:Point;
		
		//@desc		The FlxButton constructor generates a gray button with a callback function on the UI thread
		//@param	X			The X position of the button
		//@param	Y			The Y position of the button
		//@param	Callback	The function to call whenever the button is clicked
		public function FlxButton(X:int,Y:int,Callback:Function)
		{
			super();
			x = X;
			y = Y;
			width = 100;
			height = 10;
			_off = new FlxSprite();
			_off.createGraphic(width,height,0xff7f7f7f);
			_off.scrollFactor = scrollFactor;
			_on  = new FlxSprite();
			_on.createGraphic(width,height,0xffffffff);
			_on.scrollFactor = scrollFactor;
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			updatePositions();
			_initialized = false;
			_sf = null;
		}
		
		//@desc		Set your own image as the button background
		//@param	Image				A FlxSprite object to use for the button background
		//@param	ImageHighlight		A FlxSprite object to use for the button background when highlighted (optional)
		//@return	This FlxButton instance (nice for chaining stuff together, if you're into that)
		public function loadGraphic(Image:FlxSprite,ImageHighlight:FlxSprite=null):FlxButton
		{
			_off = Image;
			_off.scrollFactor = scrollFactor;
			if(ImageHighlight == null) _on = _off;
			else _on = ImageHighlight;
			_on.scrollFactor = scrollFactor;
			width = _off.width;
			height = _off.height;
			updatePositions();
			return this;
		}

		//@desc		Add a text field to the button
		//@param	Text				A FlxText object to use to display text on this button (optional)
		//@param	TextHighlight		A FlxText object that is used when the button is highlighted (optional)
		//@return	This FlxButton instance (nice for chaining stuff together, if you're into that)
		public function loadText(Text:FlxText,TextHighlight:FlxText=null):FlxButton
		{
			if(Text != null) _offT = Text;
			if(TextHighlight == null) _onT = _offT;
			else _onT = TextHighlight;
			if(_offT != null) _offTO = new Point(_offT.x,_offT.y);
			if(_onT != null) _onTO = new Point(_onT.x,_onT.y);
			_offT.scrollFactor = scrollFactor;
			_onT.scrollFactor = scrollFactor;
			updatePositions();
			return this;
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
			
			//If the button's scrollFactor object changes we need to
			// update the rest of the object's scrollFactors.
			//If the scrollFactor's member x and y variables
			// change, the objects are automatically updated.
			if(_sf != scrollFactor)
			{
				_sf = scrollFactor;
				if(_off != null) _off.scrollFactor = _sf;
				if(_on != null) _on.scrollFactor = _sf;
				if(_offT != null) _offT.scrollFactor = _sf;
				if(_onT != null) _onT.scrollFactor = _sf;
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
				if(!FlxG.mouse.pressed())
					_pressed = false;
				else if(!_pressed)
					_pressed = true;
				visibility(!_pressed);
			}
			if(_onToggle) visibility(_off.visible);
			updatePositions();
		}
		
		//@desc		Called by the game loop automatically, renders button to screen
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
		
		//@desc		Called by the game state when state is changed (if this object belongs to the state)
		override public function destroy():void
		{
			FlxG.state.parent.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		//@desc		Internal function for handling the visibility of the off and on graphics
		//@param	On		Whether the button should be on or off
		protected function visibility(On:Boolean):void
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
		protected function updatePositions():void
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
		protected function onMouseUp(event:MouseEvent):void
		{
			if(!exists || !visible || !active || !FlxG.mouse.justReleased() || (_callback == null)) return;
			if(_off.overlapsPoint(FlxG.mouse.x+(1-scrollFactor.x)*FlxG.scroll.x,FlxG.mouse.y+(1-scrollFactor.y)*FlxG.scroll.y)) _callback();
		}
	}
}

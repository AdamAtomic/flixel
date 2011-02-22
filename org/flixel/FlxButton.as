package org.flixel
{
	import flash.events.MouseEvent;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 * Supports labels, highlight states, and parallax scrolling.
	 */
	public class FlxButton extends FlxGroup
	{
		/**
		 * Used for checkbox-style behavior.
		 */
		protected var _onToggle:Boolean;
		/**
		 * Stores the 'off' or normal button state graphic.
		 */
		protected var _off:FlxSprite;
		/**
		 * Stores the 'on' or highlighted button state graphic.
		 */
		protected var _on:FlxSprite;
		/**
		 * Stores the 'off' or normal button state label.
		 */
		protected var _offT:FlxText;
		/**
		 * Stores the 'on' or highlighted button state label.
		 */
		protected var _onT:FlxText;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _callback:Function;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		protected var _pressed:Boolean;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		protected var _initialized:Boolean;
		/**
		 * Helper variable for correcting its members' <code>scrollFactor</code> objects.
		 */
		protected var _sf:FlxPoint;
		
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 */
		public function FlxButton(X:int,Y:int,Callback:Function)
		{
			super();
			x = X;
			y = Y;
			width = 100;
			height = 20;
			_off = new FlxSprite().createGraphic(width,height,0xff7f7f7f);
			_off.solid = false;
			add(_off,true);
			_on  = new FlxSprite().createGraphic(width,height,0xffffffff);
			_on.solid = false;
			add(_on,true);
			_offT = null;
			_onT = null;
			_callback = Callback;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
			_sf = null;
		}
		
		/**
		 * Set your own image as the button background.
		 * 
		 * @param	Image				A FlxSprite object to use for the button background.
		 * @param	ImageHighlight		A FlxSprite object to use for the button background when highlighted (optional).
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadGraphic(Image:FlxSprite,ImageHighlight:FlxSprite=null):FlxButton
		{
			_off = replace(_off,Image) as FlxSprite;
			if(ImageHighlight == null)
			{
				if(_on != _off)
					remove(_on);
				_on = _off;
			}
			else
				_on = replace(_on,ImageHighlight) as FlxSprite;
			_on.solid = _off.solid = false;
			_off.scrollFactor = scrollFactor;
			_on.scrollFactor = scrollFactor;
			width = _off.width;
			height = _off.height;
			refreshHulls();
			return this;
		}

		/**
		 * Add a text label to the button.
		 * 
		 * @param	Text				A FlxText object to use to display text on this button (optional).
		 * @param	TextHighlight		A FlxText object that is used when the button is highlighted (optional).
		 * 
		 * @return	This FlxButton instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadText(Text:FlxText,TextHighlight:FlxText=null):FlxButton
		{
			if(Text != null)
			{
				if(_offT == null)
				{
					_offT = Text;
					add(_offT);
				}
				else
					_offT = replace(_offT,Text) as FlxText;
			}
			if(TextHighlight == null)
				_onT = _offT;
			else
			{
				if(_onT == null)
				{
					_onT = TextHighlight;
					add(_onT);
				}
				else
					_onT = replace(_onT,TextHighlight) as FlxText;
			}
			_offT.scrollFactor = scrollFactor;
			_onT.scrollFactor = scrollFactor;
			return this;
		}
		
		/**
		 * Called by the game loop automatically, handles mouseover and click detection.
		 */
		override public function update():void
		{
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
			
			super.update();

			visibility(false);
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(!FlxG.mouse.pressed())
					_pressed = false;
				else if(!_pressed)
					_pressed = true;
				visibility(!_pressed);
			}
			if(_onToggle) visibility(_off.visible);
		}
		
		/**
		 * Use this to toggle checkbox-style behavior.
		 */
		public function get on():Boolean
		{
			return _onToggle;
			_onToggle = On;
		}
		
		/**
		 * @private
		 */
		public function set on(On:Boolean):void
		{
			_onToggle = On;
		}
		
		/**
		 * Called by the game state when state is changed (if this object belongs to the state)
		 */
		override public function destroy():void
		{
			if(FlxG.stage != null)
				FlxG.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}
		
		/**
		 * Internal function for handling the visibility of the off and on graphics.
		 * 
		 * @param	On		Whether the button should be on or off.
		 */
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
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if(!exists || !visible || !active || !FlxG.mouse.justReleased() || (_callback == null)) return;
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y)) _callback();
		}
	}
}

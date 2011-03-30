package org.flixel
{
	import flash.events.MouseEvent;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 */
	public class FlxButton extends FlxSprite
	{
		[Embed(source="data/button.png")] protected var ImgDefault:Class;
		
		static public var NORMAL:uint = 0;
		static public var HIGHLIGHT:uint = 1;
		static public var PRESSED:uint = 2;
		
		/**
		 * The text that appears on the button.
		 */
		public var label:FlxText;
		/**
		 * Controls the offset (from top left) of the text from the button.
		 */
		public var labelOffset:FlxPoint;
		/**
		 * Set this to true if you want this button to function even while the game is paused.
		 */
		public var pauseProof:Boolean;

		/**
		 * Shows the current state of the button.
		 */
		protected var _status:uint;
		/**
		 * Used for checkbox-style behavior.
		 */
		protected var _onToggle:Boolean;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _onClick:Function;
		/**
		 * Tracks whether or not the button is currently pressed.
		 */
		protected var _pressed:Boolean;
		/**
		 * Whether or not the button has initialized itself yet.
		 */
		protected var _initialized:Boolean;
		
		/**
		 * Creates a new <code>FlxButton</code> object with a gray background
		 * and a callback function on the UI thread.
		 * 
		 * @param	X			The X position of the button.
		 * @param	Y			The Y position of the button.
		 * @param	Callback	The function to call whenever the button is clicked.
		 * @param	Label		The text that you want to appear on the button.
		 */
		public function FlxButton(X:int,Y:int,Callback:Function,Label:String=null)
		{
			super(X,Y);
			_onClick = Callback;
			if(Label != null)
			{
				label = new FlxText(0,0,80,Label);
				label.setFormat(null,8,0x333333,"center");
				labelOffset = new FlxPoint(-1,3);
			}
			loadGraphic(ImgDefault,true,false,80,20);

			_status = NORMAL;
			pauseProof = false;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
		}
		
		/**
		 * Attempting to update the size of the text field to match the button.
		 */
		override protected function resetHelpers():void
		{
			super.resetHelpers();
			if(label != null)
				label.width = width;
		}
		
		/**
		 * Called by the game loop automatically, handles mouseover and click detection.
		 */
		override public function update():void
		{
			updateButton(); //Basic button logic

			//Default button appearance is to simply update
			// the label appearance based on animation frame.
			if(label == null)
				return;
			switch(frame)
			{
				case HIGHLIGHT:	//Extra behavior to accomodate checkbox logic.
					label.alpha = 1.0;
					break;
				case PRESSED:
					label.alpha = 0.5;
					label.y++;
					break;
				case NORMAL:
				default:
					label.alpha = 0.8;
					break;
			}
		}
		
		/**
		 * Basic button update logic
		 */
		protected function updateButton():void
		{
			//Super basic update/stage event stuff.
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
			super.update();
			
			//Figure out if the button is highlighted or pressed or what
			// (ignore checkbox behavior for now).
			if(overlapsPoint(FlxG.mouse.x,FlxG.mouse.y))
			{
				if(FlxG.mouse.justPressed())
					_status = PRESSED;
				if(_status == NORMAL)
					_status = HIGHLIGHT;
			}
			else
				_status = NORMAL;
			
			//Then if the label and/or the label offset exist,
			// position them to match the button.
			if(label != null)
			{
				label.x = x;
				label.y = y;
			}
			if(labelOffset != null)
			{
				label.x += labelOffset.x;
				label.y += labelOffset.y;
			}
			
			//Then pick the appropriate frame of animation
			if((_status == HIGHLIGHT) && _onToggle)
				frame = NORMAL;
			else
				frame = _status;
		}
		
		override public function draw():void
		{
			super.draw();
			label.draw();
		}
		
		/**
		 * Use this to toggle checkbox-style behavior.
		 */
		public function get on():Boolean
		{
			return _onToggle;
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
			if(label != null)
			{
				label.destroy();
				label = null;
			}
			_onClick = null;
			super.destroy();
		}
		
		/**
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if(exists && visible && active && (_status == PRESSED) && (_onClick != null) && (pauseProof || !FlxG.paused))
				_onClick();
		}
	}
}

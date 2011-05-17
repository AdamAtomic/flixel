package org.flixel
{
	import flash.events.MouseEvent;
	
	/**
	 * A simple button class that calls a function when clicked by the mouse.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxButton extends FlxSprite
	{
		[Embed(source="data/button.png")] protected var ImgDefaultButton:Class;
		
		/**
		 * Used with public variable <code>status</code>, means not highlighted or pressed.
		 */
		static public var NORMAL:uint = 0;
		/**
		 * Used with public variable <code>status</code>, means highlighted (usually from mouse over).
		 */
		static public var HIGHLIGHT:uint = 1;
		/**
		 * Used with public variable <code>status</code>, means pressed (usually from mouse click).
		 */
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
		 * Shows the current state of the button.
		 */
		public var status:uint;

		/**
		 * Used for checkbox-style behavior.
		 */
		protected var _onToggle:Boolean;
		/**
		 * This function is called when the button is clicked.
		 */
		protected var _onClick:Function;
		/**
		 * This function is called when the mouse goes over the button.
		 */
		protected var _onOver:Function;
		/**
		 * This function is called when the mouse leaves the button area.
		 */
		protected var _onOut:Function;
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
		 * @param	Label		The text that you want to appear on the button.
		 * @param	OnClick		The function to call whenever the button is clicked.
		 * @param	OnOver		The function to call whenever the mouse goes over the button.
		 * @param	OnOut		The function to call whenever the mouse leaves the button area.
		 */
		public function FlxButton(X:Number=0,Y:Number=0,Label:String=null,OnClick:Function=null,OnOver:Function=null,OnOut:Function=null)
		{
			super(X,Y);
			_onClick = OnClick;
			_onOver = OnOver;
			_onOut = OnOut;
			if(Label != null)
			{
				label = new FlxText(0,0,80,Label);
				label.setFormat(null,8,0x333333,"center");
				labelOffset = new FlxPoint(-1,3);
			}
			loadGraphic(ImgDefaultButton,true,false,80,20);

			status = NORMAL;
			_onToggle = false;
			_pressed = false;
			_initialized = false;
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
		 * Since button uses its own mouse handler for thread reasons,
		 * we run a little pre-check here to make sure that we only add
		 * the mouse handler when it is actually safe to do so.
		 */
		override public function preUpdate():void
		{
			super.preUpdate();
			
			if(!_initialized)
			{
				if(FlxG.stage != null)
				{
					FlxG.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
					_initialized = true;
				}
			}
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
			//Figure out if the button is highlighted or pressed or what
			// (ignore checkbox behavior for now).
			if(FlxG.mouse.visible)
			{
				if(cameras == null)
					cameras = FlxG.cameras;
				var camera:FlxCamera;
				var i:uint = 0;
				var l:uint = cameras.length;
				var offAll:Boolean = true;
				while(i < l)
				{
					camera = cameras[i++] as FlxCamera;
					FlxG.mouse.getWorldPosition(camera,_point);
					if(overlapsPoint(_point,true,camera))
					{
						offAll = false;
						if(FlxG.mouse.justPressed())
							status = PRESSED;
						if(status == NORMAL)
						{
							status = HIGHLIGHT;
							if(_onOver != null)
								_onOver();
						}
					}
				}
				if(offAll)
				{
					if((status != NORMAL) && (_onOut != null))
						_onOut();
					status = NORMAL;
				}
			}
		
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
			if((status == HIGHLIGHT) && _onToggle)
				frame = NORMAL;
			else
				frame = status;
		}
		
		/**
		 * Just draws the button graphic and text label to the screen.
		 */
		override public function draw():void
		{
			super.draw();
			if(label != null)
				label.draw();
		}
		
		/**
		 * Updates the size of the text field to match the button.
		 */
		override protected function resetHelpers():void
		{
			super.resetHelpers();
			if(label != null)
				label.width = width;
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
		 * Internal function for handling the actual callback call (for UI thread dependent calls like <code>FlxU.openURL()</code>).
		 */
		protected function onMouseUp(event:MouseEvent):void
		{
			if(exists && visible && active && (status == PRESSED) && (_onClick != null))
				_onClick();
		}
	}
}

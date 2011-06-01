package org.flixel.system.debug
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.flixel.FlxG;
	
	/**
	 * This control panel has all the visual debugger toggles in it, in the debugger overlay.
	 * Currently there is only one toggle that flips on all the visual debug settings.
	 * This panel is heavily based on the VCR panel.
	 * 
	 * @author Adam Atomic
	 */
	public class Vis extends Sprite
	{
		[Embed(source="../../data/vis/bounds.png")] protected var ImgBounds:Class;

		protected var _bounds:Bitmap;
		protected var _overBounds:Boolean;
		protected var _pressingBounds:Boolean;
		
		/**
		 * Instantiate the visual debugger panel.
		 */
		public function Vis()
		{
			super();
			
			var spacing:uint = 7;
			
			_bounds = new ImgBounds();
			addChild(_bounds);
			
			unpress();
			checkOver();
			updateGUI();
			
			addEventListener(Event.ENTER_FRAME,init);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			removeChild(_bounds);
			_bounds = null;
			
			parent.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			parent.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			parent.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		//***ACTUAL BUTTON BEHAVIORS***//
		
		/**
		 * Called when the bounding box toggle is pressed.
		 */
		public function onBounds():void
		{
			FlxG.visualDebug = !FlxG.visualDebug;
		}
		
		//***EVENT HANDLERS***//
		
		/**
		 * Just sets up basic mouse listeners, a la FlxWindow.
		 * 
		 * @param	E	Flash event.
		 */
		protected function init(E:Event=null):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME,init);
			
			parent.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			parent.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			parent.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		/**
		 * If the mouse moves, check to see if any buttons should be highlighted.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function onMouseMove(E:MouseEvent=null):void
		{
			if(!checkOver())
				unpress();
			updateGUI();
		}
		
		/**
		 * If the mouse is pressed down, check to see if the user started pressing down a specific button.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function onMouseDown(E:MouseEvent=null):void
		{
			unpress();
			if(_overBounds)
				_pressingBounds = true;
		}
		
		/**
		 * If the mouse is released, check to see if it was released over a button that was pressed.
		 * If it was, take the appropriate action based on button state and visibility.
		 * 
		 * @param	E	Flash mouse event.
		 */
		protected function onMouseUp(E:MouseEvent=null):void
		{
			if(_overBounds && _pressingBounds)
				onBounds();
			unpress();
			checkOver();
			updateGUI();
		}
		
		//***MISC GUI MGMT STUFF***//
		
		/**
		 * This function checks to see what button the mouse is currently over.
		 * Has some special behavior based on whether a recording is happening or not.
		 * 
		 * @return	Whether the mouse was over any buttons or not.
		 */
		protected function checkOver():Boolean
		{
			_overBounds = false;
			if((mouseX < 0) || (mouseX > width) || (mouseY < 0) || (mouseY > height))
				return false;
			if((mouseX > _bounds.x) || (mouseX < _bounds.x + _bounds.width))
				_overBounds = true;
			return true;
		}
		
		/**
		 * Sets all the pressed state variables for the buttons to false.
		 */
		protected function unpress():void
		{
			_pressingBounds = false;
		}
		
		/**
		 * Figures out what buttons to highlight based on the _overWhatever and _pressingWhatever variables.
		 */
		protected function updateGUI():void
		{
			if(FlxG.visualDebug)
			{
				if(_overBounds && (_bounds.alpha != 1.0))
					_bounds.alpha = 1.0;
				else if(!_overBounds && (_bounds.alpha != 0.9))
					_bounds.alpha = 0.9;
			}
			else
			{
				if(_overBounds && (_bounds.alpha != 0.6))
					_bounds.alpha = 0.6;
				else if(!_overBounds && (_bounds.alpha != 0.5))
					_bounds.alpha = 0.5;
			}
		}
	}
}
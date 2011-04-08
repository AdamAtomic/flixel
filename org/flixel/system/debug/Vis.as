package org.flixel.system.debug
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.flixel.FlxG;
	
	public class Vis extends Sprite
	{
		[Embed(source="../../data/vis/bounds.png")] protected var ImgBounds:Class;

		protected var _bounds:Bitmap;
		protected var _overBounds:Boolean;
		protected var _pressingBounds:Boolean;
		
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
		
		public function destroy():void
		{
			removeChild(_bounds);
			_bounds = null;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		//***ACTUAL BUTTON BEHAVIORS***//
		
		public function onBounds():void
		{
			FlxG.visualDebug = !FlxG.visualDebug;
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
			if(!checkOver())
				unpress();
			updateGUI();
		}
		
		protected function onMouseDown(E:MouseEvent=null):void
		{
			unpress();
			if(_overBounds)
				_pressingBounds = true;
		}
		
		protected function onMouseUp(E:MouseEvent=null):void
		{
			if(_overBounds && _pressingBounds)
				onBounds();
			unpress();
			checkOver();
			updateGUI();
		}
		
		//***MISC GUI MGMT STUFF***//
		
		protected function checkOver():Boolean
		{
			_overBounds = false;
			if((mouseX < 0) || (mouseX > width) || (mouseY < 0) || (mouseY > height))
				return false;
			if((mouseX > _bounds.x) || (mouseX < _bounds.x + _bounds.width))
				_overBounds = true;
			return true;
		}
		
		protected function unpress():void
		{
			_pressingBounds = false;
		}
		
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
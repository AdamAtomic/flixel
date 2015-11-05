package org.flixel.system.debug
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;

	/**
	 * Helper class for the debugger overlay's Watch window.
	 * Handles the display and modification of game variables on the fly.
	 * 
	 * @author Adam Atomic
	 */
	public class WatchEntry
	{
		/**
		 * The <code>Object</code> being watched.
		 */
		public var object:Object;
		/**
		 * The member variable of that object.
		 */
		public var field:String;
		/**
		 * A custom display name for this object, if there is any.
		 */
		public var custom:String;
		/**
		 * The Flash <code>TextField</code> object used to display this entry's name.
		 */
		public var nameDisplay:TextField;
		/**
		 * The Flash <code>TextField</code> object used to display and edit this entry's value.
		 */
		public var valueDisplay:TextField;
		/**
		 * Whether the entry is currently being edited or not.
		 */
		public var editing:Boolean;
		/**
		 * The value of the field before it was edited.
		 */
		public var oldValue:Object;
		
		protected var _whiteText:TextFormat;
		protected var _blackText:TextFormat;
		
		/**
		 * Creates a new watch entry in the watch window.
		 * 
		 * @param Y				The initial height in the Watch window.
		 * @param NameWidth		The initial width of the name field.
		 * @param ValueWidth	The initial width of the value field.
		 * @param Obj			The <code>Object</code> containing the variable we want to watch.
		 * @param Field			The variable name we want to watch.
		 * @param Custom		A custom display name (optional).
		 */
		public function WatchEntry(Y:Number,NameWidth:Number,ValueWidth:Number,Obj:Object,Field:String,Custom:String=null)
		{
			editing = false;
			
			object = Obj;
			field = Field;
			custom = Custom;
			
			_whiteText = new TextFormat("Courier",12,0xffffff);
			_blackText = new TextFormat("Courier",12,0);
			
			nameDisplay = new TextField();
			nameDisplay.y = Y;
			nameDisplay.multiline = false;
			nameDisplay.selectable = true;
			nameDisplay.defaultTextFormat = _whiteText;
			
			valueDisplay = new TextField();
			valueDisplay.y = Y;
			valueDisplay.height = 15;
			valueDisplay.multiline = false;
			valueDisplay.selectable = true;
			valueDisplay.doubleClickEnabled = true;
			valueDisplay.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			valueDisplay.background = false;
			valueDisplay.backgroundColor = 0xffffff;
			valueDisplay.defaultTextFormat = _whiteText;
			
			updateWidth(NameWidth,ValueWidth);
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			object = null;
			oldValue = null;
			nameDisplay = null;
			field = null;
			custom = null;
			valueDisplay.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			valueDisplay.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay = null;
		}
		
		/**
		 * Set the watch window Y height of the Flash <code>TextField</code> objects.
		 */
		public function setY(Y:Number):void
		{
			nameDisplay.y = Y;
			valueDisplay.y = Y;
		}
		
		/**
		 * Adjust the width of the Flash <code>TextField</code> objects.
		 */
		public function updateWidth(NameWidth:Number,ValueWidth:Number):void
		{
			nameDisplay.width = NameWidth;
			valueDisplay.width = ValueWidth;
			if(custom != null)
				nameDisplay.text = custom;
			else
			{
				nameDisplay.text = "";
				if(NameWidth > 120)
					nameDisplay.appendText(FlxU.getClassName(object,(NameWidth < 240)) + ".");
				nameDisplay.appendText(field);
			}
		}
		
		/**
		 * Update the variable value on display with the current in-game value.
		 */
		public function updateValue():Boolean
		{
			if(editing)
				return false;
			valueDisplay.text = object[field].toString();
			return true;
		}
		
		/**
		 * A watch entry was clicked, so flip into edit mode for that entry.
		 * 
		 * @param	FlashEvent	Flash mouse event.
		 */
		public function onMouseUp(FlashEvent:MouseEvent):void
		{
			editing = true;
			oldValue = object[field];
			valueDisplay.type = TextFieldType.INPUT;
			valueDisplay.setTextFormat(_blackText);
			valueDisplay.background = true;
			
		}
		
		/**
		 * Check to see if Enter, Tab or Escape were just released.
		 * Enter or Tab submit the change, and Escape cancels it.
		 * 
		 * @param	FlashEvent	Flash keyboard event.
		 */
		public function onKeyUp(FlashEvent:KeyboardEvent):void
		{
			if((FlashEvent.keyCode == 13) || (FlashEvent.keyCode == 9) || (FlashEvent.keyCode == 27)) //enter or tab or escape
			{
				if(FlashEvent.keyCode == 27)
					cancel();
				else
					submit();
			}
		}
		
		/**
		 * Cancel the current edits and stop editing.
		 */
		public function cancel():void
		{
			valueDisplay.text = oldValue.toString();
			doneEditing();
		}
		
		/**
		 * Submit the current edits and stop editing.
		 */
		public function submit():void
		{
			object[field] = valueDisplay.text;
			doneEditing();
		}
		
		/**
		 * Helper function, switches the text field back to display mode.
		 */
		protected function doneEditing():void
		{
			valueDisplay.type = TextFieldType.DYNAMIC;
			valueDisplay.setTextFormat(_whiteText);
			valueDisplay.defaultTextFormat = _whiteText;
			valueDisplay.background = false;
			editing = false;
		}
	}
}
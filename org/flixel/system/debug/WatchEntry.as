package org.flixel.system.debug
{
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;

	public class WatchEntry
	{
		public var object:Object;
		public var field:String;
		public var custom:String;
		public var nameDisplay:TextField;
		public var valueDisplay:TextField;
		public var editing:Boolean;
		public var oldValue:Object;
		
		public function WatchEntry(Y:Number,NameWidth:Number,ValueWidth:Number,Obj:Object,Field:String,Custom:String=null)
		{
			editing = false;
			
			object = Obj;
			field = Field;
			custom = Custom;
			
			nameDisplay = new TextField();
			nameDisplay.y = Y;
			nameDisplay.multiline = false;
			nameDisplay.selectable = true;
			nameDisplay.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			
			valueDisplay = new TextField();
			valueDisplay.y = Y;
			valueDisplay.multiline = false;
			valueDisplay.selectable = true;
			valueDisplay.doubleClickEnabled = true;
			valueDisplay.addEventListener(MouseEvent.CLICK,onClick);
			valueDisplay.addEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay.defaultTextFormat = new TextFormat("Courier",12,0xffffff);
			
			updateWidth(NameWidth,ValueWidth);
		}
		
		public function destroy():void
		{
			object = null;
			oldValue = null;
			nameDisplay = null;
			valueDisplay.removeEventListener(MouseEvent.CLICK,onClick);
			valueDisplay.removeEventListener(KeyboardEvent.KEY_UP,onKeyUp);
			valueDisplay = null;
		}
		
		public function setY(Y:Number):void
		{
			nameDisplay.y = Y;
			valueDisplay.y = Y;
		}
		
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
		
		public function updateValue():Boolean
		{
			if(editing)
				return false;
			valueDisplay.text = object[field].toString();
			return true;
		}
		
		public function onClick(E:MouseEvent):void
		{
			editing = true;
			oldValue = object[field];
			valueDisplay.type = TextFieldType.INPUT;
		}
		
		public function onKeyUp(E:KeyboardEvent):void
		{
			var k:uint = E.keyCode;
			if((k == 13) || (k == 9) || (k == 27)) //enter or tab or escape
			{
				if(k == 27)
					valueDisplay.text = oldValue.toString();
				else
					object[field] = valueDisplay.text;
				valueDisplay.type = TextFieldType.DYNAMIC;
				editing = false;
			}
		}
	}
}
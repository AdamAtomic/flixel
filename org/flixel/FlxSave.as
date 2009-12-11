package org.flixel
{
	import flash.net.SharedObject;
	
	public class FlxSave extends Object
	{
		public var data:Object;
		public var name:String;
		protected var _so:SharedObject;
		
		public function FlxSave(Name:String)
		{
			name = Name;
			_so = SharedObject.getLocal(name);
			data = _so.data;
		}
		
		public function write(FieldName:String,FieldValue:Object):void
		{
			data[FieldName] = FieldValue;
			forceSave();
		}
		
		public function read(FieldName:String):Object
		{
			return data[FieldName];
		}
		
		public function forceSave():void
		{
			_so.flush();
		}
		
		public function erase():void
		{
			_so.clear();
		}
	}
}

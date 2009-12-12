package org.flixel
{
	import flash.net.SharedObject;
	
	//@desc		A class to help automate and simplify save games
	public class FlxSave extends Object
	{
		//@desc		Allows you to directly access the data container in the local shared object
		public var data:Object;
		//@desc		The name of the local shared object
		public var name:String;
		protected var _so:SharedObject;
		
		//@desc		The save game constructor; creates a new local shared object to store data
		//@param	Name	The name of the object (should be the same each time to access old data)
		public function FlxSave(Name:String)
		{
			name = Name;
			_so = SharedObject.getLocal(name);
			data = _so.data;
		}
		
		//@desc		If you don't like to access the data object directly, you can use this to write to it
		//@param	FieldName		The name of the data field you want to create or overwrite
		//@param	FieldValue		The data you want to store
		public function write(FieldName:String,FieldValue:Object):void
		{
			data[FieldName] = FieldValue;
			forceSave();
		}
		
		//@desc		If you don't like to access the data object directly, you can use this to read from it
		//@param	FieldName		The name of the data field you want to read
		//@return	The value of the data field you are reading (null if it doesn't exist)
		public function read(FieldName:String):Object
		{
			return data[FieldName];
		}
		
		//@desc		Writes the local shared object to disk immediately
		public function forceSave():void
		{
			_so.flush();
		}
		
		//@desc		Erases everything stored in the local shared object
		public function erase():void
		{
			_so.clear();
			forceSave();
		}
	}
}

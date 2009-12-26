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
		//@return	Whether or not the write and flush were successful
		public function write(FieldName:String,FieldValue:Object):Boolean
		{
			data[FieldName] = FieldValue;
			return forceSave();
		}
		
		//@desc		If you don't like to access the data object directly, you can use this to read from it
		//@param	FieldName		The name of the data field you want to read
		//@return	The value of the data field you are reading (null if it doesn't exist)
		public function read(FieldName:String):Object
		{
			return data[FieldName];
		}
		
		//@desc		Writes the local shared object to disk immediately
		//@param	MinFileSize		If you need X amount of space for your save, specify it here
		//@return	Whether or not the flush was successful
		public function forceSave(MinFileSize:uint=0):Boolean
		{
			if(_so.flush(MinFileSize) == true)
				return true;
			else
			{
				FlxG.log("WARNING: There was a problem flushing\nthe shared object data from FlxSave.");
				return false;
			}
		}
		
		//@desc		Erases everything stored in the local shared object
		//@return	Whether or not the clear and flush was successful
		public function erase():Boolean
		{
			_so.clear();
			return forceSave();
		}
	}
}

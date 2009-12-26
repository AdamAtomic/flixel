package org.flixel
{
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
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
		public function FlxSave()
		{
			name = null;
			_so = null;
			data = null;
		}
		
		//@desc		This function either creates or reconnects to locally saved data
		//@param	Name	The name of the object (should be the same each time to access old data)
		//@return	Whether or not you successfully connected to the save data
		public function bind(Name:String):Boolean
		{
			name = null;
			_so = null;
			data = null;
			name = Name;
			try
			{
				_so = SharedObject.getLocal(name);
			}
			catch(e:Error)
			{
				FlxG.log("WARNING: There was a problem binding to\nthe shared object data from FlxSave.");
				name = null;
				_so = null;
				data = null;
				return false;
			}
			data = _so.data;
			return true;
		}
		
		//@desc		If you don't like to access the data object directly, you can use this to write to it
		//@param	FieldName		The name of the data field you want to create or overwrite
		//@param	FieldValue		The data you want to store
		//@param	MinFileSize		If you need X amount of space for your save, specify it here
		//@return	Whether or not the write and flush were successful
		public function write(FieldName:String,FieldValue:Object,MinFileSize:uint=0):Boolean
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.write().");
				return false;
			}
			data[FieldName] = FieldValue;
			return forceSave(MinFileSize);
		}
		
		//@desc		If you don't like to access the data object directly, you can use this to read from it
		//@param	FieldName		The name of the data field you want to read
		//@return	The value of the data field you are reading (null if it doesn't exist)
		public function read(FieldName:String):Object
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.read().");
				return null;
			}
			return data[FieldName];
		}
		
		//@desc		Writes the local shared object to disk immediately
		//@param	MinFileSize		If you need X amount of space for your save, specify it here
		//@return	Whether or not the flush was successful
		public function forceSave(MinFileSize:uint=0):Boolean
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.forceSave().");
				return false;
			}
			var status:Object = null;
			try
			{
				status = _so.flush(MinFileSize);
			}
			catch (e:Error)
			{
				FlxG.log("WARNING: There was a problem flushing\nthe shared object data from FlxSave.");
				return false;
			}
			return status == SharedObjectFlushStatus.FLUSHED;
		}
		
		//@desc		Erases everything stored in the local shared object
		//@param	MinFileSize		If you need X amount of space for your save, specify it here
		//@return	Whether or not the clear and flush was successful
		public function erase(MinFileSize:uint=0):Boolean
		{
			if(_so == null)
			{
				FlxG.log("WARNING: You must call FlxSave.bind()\nbefore calling FlxSave.erase().");
				return false;
			}
			_so.clear();
			return forceSave(MinFileSize);
		}
	}
}

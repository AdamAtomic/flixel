package org.flixel
{
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * A class to help automate and simplify save game functionality.
	 */
	public class FlxSave extends Object
	{
		/**
		 * Allows you to directly access the data container in the local shared object.
		 * @default null
		 */
		public var data:Object;
		/**
		 * The name of the local shared object.
		 * @default null
		 */
		public var name:String;
		/**
		 * The local shared object itself.
		 * @default null
		 */
		protected var _so:SharedObject;
		
		protected var _onComplete:Function;
		
		protected var _closeRequested:Boolean;
		
		/**
		 * Blanks out the containers.
		 */
		public function FlxSave()
		{
			destroy();
			_closeRequested = false;
		}

		public function destroy():void
		{
			name = null;
			if(_so != null)
				_so.close();
			_so = null;
			data = null;
			_onComplete = null;
		}
		
		/**
		 * Automatically creates or reconnects to locally saved data.
		 * 
		 * @param	Name	The name of the object (should be the same each time to access old data).
		 * 
		 * @return	Whether or not you successfully connected to the save data.
		 */
		public function bind(Name:String):Boolean
		{
			_so = null;
			data = null;
			name = Name;
			try
			{
				_so = SharedObject.getLocal(name);
			}
			catch(e:Error)
			{
				FlxG.log("ERROR: There was a problem binding to\nthe shared object data from FlxSave.");
				name = null;
				_so = null;
				data = null;
				return false;
			}
			data = _so.data;
			return true;
		}
		
		/**
		 * If you don't like to access the data object directly, you can use this to write to it.
		 * 
		 * @param	FieldName		The name of the data field you want to create or overwrite.
		 * @param	FieldValue		The data you want to store.
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * 
		 * @return	Whether or not the write and flush were successful.
		 */
		public function write(FieldName:String,FieldValue:Object,MinFileSize:uint=0,OnPending:Function=null):Boolean
		{
			if(!checkBinding())
				return false;
			data[FieldName] = FieldValue;
			return forceSave(MinFileSize,OnPending);
		}
		
		/**
		 * If you don't like to access the data object directly, you can use this to read from it.
		 * 
		 * @param	FieldName		The name of the data field you want to read
		 * 
		 * @return	The value of the data field you are reading (null if it doesn't exist).
		 */
		public function read(FieldName:String):Object
		{
			if(!checkBinding())
				return null;
			return data[FieldName];
		}
		
		/**
		 * Calls forceSave() and then cleans up the object from memory.
		 *
		 * @param	Force			Leave this set to false if you want to force a write and flush on your save data first.  Setting to true means data you've written to the object MAY NOT be saved!
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * @param	OnComplete		This callback will be triggered when the data is written successfully.
		 *
		 * @return	Whether the operation was completed.  If NoSave == true, then it will always return true.  If NoSave == false, then the result of ForceSave() is returned.
		 */
		public function close(Force:Boolean=false,MinFileSize:uint=0,OnComplete:Function=null):Boolean
		{
			if(Force)
			{
				if(checkBinding())
					_so.close();
				destroy();
				return true;
			}
			_closeRequested = true;
			return forceSave(MinFileSize,OnComplete);
		}

		/**
		 * Writes the local shared object to disk immediately.  Leaves the object open in memory.
		 *
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * @param	OnComplete		This callback will be triggered when the data is written successfully.
		 *
		 * @return	Whether or not the data was written immediately.  False could be an error or a pending/popup.
		 */
		public function forceSave(MinFileSize:uint=0,OnComplete:Function=null):Boolean
		{
			if(!checkBinding())
				return false;
			_onComplete = OnComplete;
			var status:Object = null;
			try { status = _so.flush(MinFileSize); }
			catch (e:Error) { return onDone(false); }
			if(status == SharedObjectFlushStatus.PENDING)
				_so.addEventListener(NetStatusEvent.NET_STATUS,onFlushStatus);
			return onDone(status == SharedObjectFlushStatus.FLUSHED);
		}
		
		/**
		 * Erases everything stored in the local shared object.
		 * 
		 * @param	MinFileSize		If you need X amount of space for your save, specify it here.
		 * 
		 * @return	Whether or not the clear and flush was successful.
		 */
		public function erase(MinFileSize:uint=0,OnComplete:Function=null):Boolean
		{
			if(!checkBinding())
				return false;
			_so.clear();
			return forceSave(MinFileSize,OnComplete);
		}
		
		protected function onFlushStatus(event:NetStatusEvent):void
		{
			_so.removeEventListener(NetStatusEvent.NET_STATUS,onFlushStatus);
			onDone(event.info.code == "SharedObject.Flush.Success");
		}
		
		protected function onDone(State:Boolean):Boolean
		{
			if(_onComplete != null)
				_onComplete(State);
			else if(!State)
				FlxG.log("ERROR: There was a problem flushing\nthe shared object data from FlxSave.");
			if(_closeRequested)
			{
				_closeRequested = false;
				destroy();
			}
			return State;
		}
		
		protected function checkBinding():Boolean
		{
			if(_so == null)
			{
				FlxG.log("FLIXEL: You must call FlxSave.bind()\nbefore calling FlxSave.read().");
				return false;
			}
			return true;
		}
	}
}

package org.flixel.aux.debug
{
	public class FrameRecord
	{
		public var frame:int;
		public var keys:Array;
		public var mouse:MouseRecord;
		
		public function FrameRecord(Keys:Array,Mouse:MouseRecord,Data:String=null)
		{
			if(Data != null)
			{
				load(Data);
				return;
			}
			frame = -1;
			keys = Keys;
			mouse = Mouse;
		}
		
		public function save():String
		{
			var output:String = frame+"k";
			
			if(keys != null)
			{
				var o:Object;
				var i:uint = 0;
				var l:uint = keys.length;
				while(i < l)
				{
					if(i > 0)
						output += ",";
					o = keys[i++];
					output += o.code+":"+o.value;
				}
			}
			
			output += "m";
			if(mouse != null)
				output += mouse.x + "," + mouse.y + "," + mouse.button + "," + mouse.wheel;
			
			return output;
		}
		
		public function load(Data:String):void
		{
			var i:uint;
			var l:uint;
			
			//get frame number
			var a:Array = Data.split("k");
			frame = int(a[0] as String);
			
			//split up keyboard and mouse data
			a = (a[1] as String).split("m");
			var keyData:String = a[0];
			var mouseData:String = a[1];
			
			//parse keyboard data
			if(keyData.length > 0)
			{
				//get keystroke data pairs
				a = keyData.split(",");
				
				//go through each data pair and enter it into this frame's key state
				var k:Array;
				i = 0;
				l = a.length;
				while(i < l)
				{
					k = (a[i++] as String).split(":");
					if(k.length == 2)
					{
						if(keys == null)
							keys = new Array();
						keys.push({code:int(k[0] as String),value:int(k[1] as String)});
					}
				}
			}
			
			//mouse data is just 4 integers, easy peezy
			if(mouseData.length > 0)
			{
				a = mouseData.split(",");
				if(a.length >= 4)
					mouse = new MouseRecord(int(a[0] as String),int(a[1] as String),int(a[2] as String),int(a[3] as String));
			}
		}
	}
}

package org.flixel.system.replay
{
	
	/**
	 * Helper class for the new replay system.  Represents all the game inputs for one "frame" or "step" of the game loop.
	 * 
	 * @author Adam Atomic
	 */
	public class FrameRecord
	{
		/**
		 * Which frame of the game loop this record is from or for.
		 */
		public var frame:int;
		/**
		 * An array of simple integer pairs referring to what key is pressed, and what state its in.
		 */
		public var keys:Array;
		/**
		 * A container for the 4 mouse state integers.
		 */
		public var mouse:MouseRecord;
		
		/**
		 * Instantiate a new frame record.
		 */
		public function FrameRecord()
		{
			frame = 0;
			keys = null;
			mouse = null;
		}
		
		/**
		 * Load this frame record with input data from the input managers.
		 * 
		 * @param Frame		What frame it is.
		 * @param Keys		Keyboard data from the keyboard manager.
		 * @param Mouse		Mouse data from the mouse manager.
		 * 
		 * @return A reference to this <code>FrameRecord</code> object.
		 * 
		 */
		public function create(Frame:Number,Keys:Array=null,Mouse:MouseRecord=null):FrameRecord
		{
			frame = Frame;
			keys = Keys;
			mouse = Mouse;
			return this;
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			keys = null;
			mouse = null;
		}
		
		/**
		 * Save the frame record data to a simple ASCII string.
		 * 
		 * @return	A <code>String</code> object containing the relevant frame record data.
		 */
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
		
		/**
		 * Load the frame record data from a simple ASCII string.
		 * 
		 * @param	Data	A <code>String</code> object containing the relevant frame record data.
		 */
		public function load(Data:String):FrameRecord
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
			
			return this;
		}
	}
}

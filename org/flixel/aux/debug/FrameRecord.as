package org.flixel.aux.debug
{
	public class FrameRecord
	{
		public var frame:int;
		public var keys:Array;
		public var mouse:MouseRecord;
		
		public function FrameRecord(Keys:Array,Mouse:MouseRecord)
		{
			frame = 0;
			keys = Keys;
			mouse = Mouse;
		}
	}
}
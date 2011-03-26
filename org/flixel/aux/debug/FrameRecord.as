package org.flixel.aux.debug
{
	public class FrameRecord
	{
		public var keys:Array;
		public var mouse:MouseRecord;
		public var skip:int;
		
		public function FrameRecord(Keys:Array,Mouse:MouseRecord)
		{
			keys = Keys;
			mouse = Mouse;
			skip = 0;
		}
	}
}
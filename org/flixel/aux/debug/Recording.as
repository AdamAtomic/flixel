package org.flixel.aux.debug
{
	public class Recording
	{
		public var frame:int;
		public var finished:Boolean;
		
		protected var _frames:Array;
		protected var _capacity:int;
		protected var _count:int;
		protected var _marker:int;
		
		public function Recording(FileContents:String=null)
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			_count = 0;
			rewind();
			if(FileContents != null)
			{
				load(FileContents);
				return;
			}
		}
		
		public function destroy():void
		{
			var i:uint = _count-1;
			while(i >= 0)
				(_frames[i++] as FrameRecord).destroy();
			_frames = null;
		}
		
		public function add(Record:FrameRecord):void
		{
			if(Record == null)
			{
				frame++;
				return;
			}
			if(Record.frame < 0)
				Record.frame = frame++;
			_frames[_count++] = Record;
			if(_count >= _capacity)
			{
				_capacity *= 2;
				_frames.length = _capacity;
			}
		}
		
		public function advance():FrameRecord
		{
			if(_marker >= _count)
			{
				finished = true;
				return null;
			}
			if((_frames[_marker] as FrameRecord).frame != frame++)
				return null;
			return _frames[_marker++];
		}
		
		public function rewind():void
		{
			_marker = 0;
			frame = 0;
			finished = false;
		}

		public function save():String
		{
			if(_count <= 0)
				return null;
			var output:String = "";
			var i:uint = 0;
			while(i < _count)
				output += _frames[i++].save() + "\n";
			return output;
		}
		
		public function load(FileContents:String):void
		{
			var lines:Array = FileContents.split("\n");
			
			var line:String;
			var i:uint = 0;
			var l:uint = lines.length;
			while(i < l)
			{
				line = lines[i++] as String;
				if(line.length > 3)
					add(new FrameRecord(null,null,line));
			}
			
			rewind();
		}
	}
}

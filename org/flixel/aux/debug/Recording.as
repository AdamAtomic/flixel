package org.flixel.aux.debug
{
	public class Recording
	{
		public var finished:Boolean;
		
		protected var _frames:Array;
		protected var _capacity:int;
		protected var _count:int;
		protected var _marker:int;
		protected var _total:int;
		
		public function Recording(FileContents:String=null)
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			_count = 0;
			rewind();
			if(FileContents != null)
				load(FileContents);
		}
		
		public function add(Record:FrameRecord):void
		{
			if(Record == null)
			{
				_total++;
				return;
			}
			Record.frame = _total++;
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
			if((_frames[_marker] as FrameRecord).frame != _total++)
				return null;
			return _frames[_marker++];
		}
		
		public function rewind():void
		{
			_marker = 0;
			_total = 0;
			finished = false;
		}

		public function save():String
		{
			return "some bullshit";
		}
		
		public function load(FileContents:String):void
		{
			rewind();
		}
	}
}

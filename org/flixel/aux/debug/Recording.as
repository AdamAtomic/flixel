package org.flixel.aux.debug
{
	public class Recording
	{
		public var currentFrame:FrameRecord;

		protected var _frames:Array;
		protected var _capacity:int;
		protected var _count:int;
		protected var _marker:int;
		protected var _skipCounter:int;
		
		public function Recording()
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			_count = 0;
			rewind();
		}
		
		public function add(Record:FrameRecord):void
		{
			if(Record == null)
			{
				if((_count <= 0) || ((_frames[_count-1] as FrameRecord).skip <= 0))
					_frames[_count++] = new FrameRecord(null,null);
				_frames[_count-1].skip++;
				return;
			}
			_frames[_count++] = Record;
			if(_count >= _capacity)
			{
				_capacity *= 2;
				_frames.length = _capacity;
			}
		}
		
		public function advance():void
		{
			_skipCounter++;
			if((_skipCounter > currentFrame.skip) && (_marker < _count-1))
			{
				_skipCounter = 0;
				_marker++;
				currentFrame = _frames[_marker];
			}
		}
		
		public function rewind():void
		{
			_skipCounter = 0;
			_marker = 0;
			currentFrame = _frames[_marker];
		}
	}
}
package org.flixel.helpers
{
	import org.flixel.FlxG;
	import org.flixel.helpers.replay.*;

	public class FlxReplay
	{
		public var seed:Number;
		public var frame:int;
		public var frameCount:int;
		public var finished:Boolean;
		
		protected var _frames:Array;
		protected var _capacity:int;
		protected var _marker:int;
		
		public function FlxReplay()
		{
		}
		
		public function create(Seed:Number):void
		{
			destroy();
			init();
			seed = Seed;
			rewind();
		}
		
		protected function init():void
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			frameCount = 0;
		}
		
		public function destroy():void
		{
			if(_frames == null)
				return;
			var i:int = frameCount-1;
			while(i >= 0)
				(_frames[i--] as FrameRecord).destroy();
			_frames = null;
		}
		
		public function recordFrame():void
		{
			var keysRecord:Array = FlxG.keys.record();
			var mouseRecord:MouseRecord = FlxG.mouse.record();
			if((keysRecord == null) && (mouseRecord == null))
			{
				frame++;
				return;
			}
			_frames[frameCount++] = new FrameRecord().create(frame++,keysRecord,mouseRecord);
			if(frameCount >= _capacity)
			{
				_capacity *= 2;
				_frames.length = _capacity;
			}
		}
		
		public function playNextFrame():void
		{
			FlxG.resetInput();
			
			if(_marker >= frameCount)
			{
				finished = true;
				return;
			}
			if((_frames[_marker] as FrameRecord).frame != frame++)
				return;
			
			var fr:FrameRecord = _frames[_marker++];
			if(fr.keys != null)
				FlxG.keys.playback(fr.keys);
			if(fr.mouse != null)
				FlxG.mouse.playback(fr.mouse);
		}
		
		public function rewind():void
		{
			_marker = 0;
			frame = 0;
			finished = false;
		}

		public function save():String
		{
			if(frameCount <= 0)
				return null;
			var output:String = seed+"\n";
			var i:uint = 0;
			while(i < frameCount)
				output += _frames[i++].save() + "\n";
			return output;
		}
		
		public function load(FileContents:String):void
		{
			init();
			
			var lines:Array = FileContents.split("\n");
			
			seed = Number(lines[0]);
			
			var line:String;
			var i:uint = 1;
			var l:uint = lines.length;
			while(i < l)
			{
				line = lines[i++] as String;
				if(line.length > 3)
				{
					_frames[frameCount++] = new FrameRecord().load(line);
					if(frameCount >= _capacity)
					{
						_capacity *= 2;
						_frames.length = _capacity;
					}
				}
			}
			
			rewind();
		}
	}
}

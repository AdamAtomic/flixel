package org.flixel.system
{
	import org.flixel.FlxG;
	import org.flixel.system.replay.FrameRecord;
	import org.flixel.system.replay.MouseRecord;

	/**
	 * The replay object both records and replays game recordings,
	 * as well as handle saving and loading replays to and from files.
	 * Gameplay recordings are essentially a list of keyboard and mouse inputs,
	 * but since Flixel is fairly deterministic, we can use these to play back
	 * recordings of gameplay with a decent amount of fidelity.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxReplay
	{
		/**
		 * The random number generator seed value for this recording.
		 */
		public var seed:Number;
		/**
		 * The current frame for this recording.
		 */
		public var frame:int;
		/**
		 * The number of frames in this recording.
		 */
		public var frameCount:int;
		/**
		 * Whether the replay has finished playing or not.
		 */
		public var finished:Boolean;
		
		/**
		 * Internal container for all the frames in this replay.
		 */
		protected var _frames:Array;
		/**
		 * Internal tracker for max number of frames we can fit before growing the <code>_frames</code> again.
		 */
		protected var _capacity:int;
		/**
		 * Internal helper variable for keeping track of where we are in <code>_frames</code> during recording or replay.
		 */
		protected var _marker:int;
		
		/**
		 * Instantiate a new replay object.  Doesn't actually do much until you call create() or load().
		 */
		public function FlxReplay()
		{
			seed = 0;
			frame = 0;
			frameCount = 0;
			finished = false;
			_frames = null;
			_capacity = 0;
			_marker = 0;
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			if(_frames == null)
				return;
			var i:int = frameCount-1;
			while(i >= 0)
				(_frames[i--] as FrameRecord).destroy();
			_frames = null;
		}
		
		/**
		 * Create a new gameplay recording.  Requires the current random number generator seed.
		 * 
		 * @param	Seed	The current seed from the random number generator.
		 */
		public function create(Seed:Number):void
		{
			destroy();
			init();
			seed = Seed;
			rewind();
		}
		
		/**
		 * Load replay data from a <code>String</code> object.
		 * Strings can come from embedded assets or external
		 * files loaded through the debugger overlay. 
		 * 
		 * @param	FileContents	A <code>String</code> object containing a gameplay recording.
		 */
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
		
		/**
		 * Common initialization terms used by both <code>create()</code> and <code>load()</code> to set up the replay object.
		 */
		protected function init():void
		{
			_capacity = 100;
			_frames = new Array(_capacity);
			frameCount = 0;
		}
		
		/**
		 * Save the current recording data off to a <code>String</code> object.
		 * Basically goes through and calls <code>FrameRecord.save()</code> on each frame in the replay.
		 * 
		 * return	The gameplay recording in simple ASCII format.
		 */
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

		/**
		 * Get the current input data from the input managers and store it in a new frame record.
		 */
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
		
		/**
		 * Get the current frame record data and load it into the input managers.
		 */
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
		
		/**
		 * Reset the replay back to the first frame.
		 */
		public function rewind():void
		{
			_marker = 0;
			frame = 0;
			finished = false;
		}
	}
}

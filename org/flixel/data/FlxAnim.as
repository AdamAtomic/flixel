package org.flixel.data
{
	//@desc		Just a helper structure for the FlxSprite animation system
	public class FlxAnim
	{
		public var name:String;
		public var delay:Number;
		public var frames:Array;
		public var looped:Boolean;
		
		//@desc		Constructor
		//@param	Name		What this animation should be called (e.g. "run")
		//@param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
		//@param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps)
		//@param	Looped		Whether or not the animation is looped or just plays once
		public function FlxAnim(Name:String, Frames:Array, FrameRate:Number=0, Looped:Boolean=true)
		{
			name = Name;
			delay = 1.0/FrameRate;
			frames = Frames;
			looped = Looped;
		}
	}
}
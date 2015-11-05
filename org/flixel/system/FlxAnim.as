package org.flixel.system
{
	/**
	 * Just a helper structure for the FlxSprite animation system.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxAnim
	{
		/**
		 * String name of the animation (e.g. "walk")
		 */
		public var name:String;
		/**
		 * Seconds between frames (basically the framerate)
		 */
		public var delay:Number;
		/**
		 * A list of frames stored as <code>uint</code> objects
		 */
		public var frames:Array;
		/**
		 * Whether or not the animation is looped
		 */
		public var looped:Boolean;
		
		/**
		 * Constructor
		 * 
		 * @param	Name		What this animation should be called (e.g. "run")
		 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
		 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
		 * @param	Looped		Whether or not the animation is looped or just plays once
		 */
		public function FlxAnim(Name:String, Frames:Array, FrameRate:Number=0, Looped:Boolean=true)
		{
			name = Name;
			delay = 0;
			if(FrameRate > 0)
				delay = 1.0/FrameRate;
			frames = Frames;
			looped = Looped;
		}
		
		/**
		 * Clean up memory.
		 */
		public function destroy():void
		{
			frames = null;
		}
	}
}
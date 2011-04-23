package org.flixel.system.replay
{
	/**
	 * A helper class for the frame records, part of the replay/demo/recording system.
	 * 
	 * @author Adam Atomic
	 */
	public class MouseRecord
	{
		/**
		 * The main X value of the mouse in screen space.
		 */
		public var x:int;
		/**
		 * The main Y value of the mouse in screen space.
		 */
		public var y:int;
		/**
		 * The state of the left mouse button.
		 */
		public var button:int;
		/**
		 * The state of the mouse wheel.
		 */
		public var wheel:int;
		
		/**
		 * Instantiate a new mouse input record.
		 *  
		 * @param X			The main X value of the mouse in screen space.
		 * @param Y			The main Y value of the mouse in screen space.
		 * @param Button	The state of the left mouse button.
		 * @param Wheel		The state of the mouse wheel.
		 */
		public function MouseRecord(X:int,Y:int,Button:int,Wheel:int)
		{
			x = X;
			y = Y;
			button = Button;
			wheel = Wheel;
		}
	}
}
package org.flixel.aux.debug
{
	public class MouseRecord
	{
		public var x:int;
		public var y:int;
		public var button:int;
		public var wheel:int;
		
		public function MouseRecord(X:int,Y:int,Button:int,Wheel:int)
		{
			x = X;
			y = Y;
			button = Button;
			wheel = Wheel;
		}
	}
}
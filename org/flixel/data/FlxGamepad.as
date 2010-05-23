package org.flixel.data
{
	import org.flixel.FlxG;
	
	public class FlxGamepad extends FlxInput
	{
		public var UP:Boolean;
		public var DOWN:Boolean;
		public var LEFT:Boolean;
		public var RIGHT:Boolean;
		public var A:Boolean;
		public var B:Boolean;
		public var X:Boolean;
		public var Y:Boolean;
		public var START:Boolean;
		public var SELECT:Boolean;
		public var L1:Boolean;
		public var L2:Boolean;
		public var R1:Boolean;
		public var R2:Boolean;
		
		public function FlxGamepad()
		{
			super();
		}
		
		/**
		 * Assign a keyboard key to a gamepad button.  For example, if you pass "X" as the <code>AButton</code>
		 * parameter, this gamepad's member variable <code>A</code> will be set to true whenever the 'x' key
		 * on the keyboard is pressed.  Pretty simple!  Nice for multiplayer games and utilities that
		 * can convert gamepad pressed to keyboard keys at the operating system level.
		 */
		public function bind(Up:String=null, Down:String=null, Left:String=null, Right:String=null,
							 AButton:String=null, BButton:String=null, XButton:String=null, YButton:String=null,
							 StartButton:String=null, SelectButton:String=null,
							 L1Button:String=null, L2Button:String=null, R1Button:String=null, R2Button:String=null):void
		{
			if(Up != null)			addKey("UP",FlxG.keys._lookup[Up]);
			if(Down != null)		addKey("DOWN",FlxG.keys._lookup[Down]);
			if(Left != null)		addKey("LEFT",FlxG.keys._lookup[Left]);
			if(Right != null)		addKey("RIGHT",FlxG.keys._lookup[Right]);
			if(AButton != null)		addKey("A",FlxG.keys._lookup[AButton]);
			if(BButton != null)		addKey("B",FlxG.keys._lookup[BButton]);
			if(XButton != null)		addKey("X",FlxG.keys._lookup[XButton]);
			if(YButton != null)		addKey("Y",FlxG.keys._lookup[YButton]);
			if(StartButton != null)	addKey("START",FlxG.keys._lookup[StartButton]);
			if(SelectButton != null)addKey("SELECT",FlxG.keys._lookup[SelectButton]);
			if(L1Button != null)	addKey("L1",FlxG.keys._lookup[L1Button]);
			if(L2Button != null)	addKey("L2",FlxG.keys._lookup[L2Button]);
			if(R1Button != null)	addKey("R1",FlxG.keys._lookup[R1Button]);
			if(R2Button != null)	addKey("R2",FlxG.keys._lookup[R2Button]);
		}
	}
}
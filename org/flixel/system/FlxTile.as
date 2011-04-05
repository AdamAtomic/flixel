package org.flixel.system
{
	import org.flixel.FlxObject;
	
	public class FlxTile extends FlxObject
	{
		public var callback:Function;
		
		public function FlxTile(Width:Number=0, Height:Number=0)
		{
			super(0, 0, Width, Height);
			callback = null;
			immovable = true;
		}
		
		override public function destroy():void
		{
			super.destroy();
			callback = null;
		}
	}
}

package org.flixel.system
{
	import org.flixel.FlxObject;
	
	public class FlxTile extends FlxObject
	{
		public var callback:Function;
		
		public function FlxTile(Width:Number, Height:Number, AllowCollisions:uint)
		{
			super(0, 0, Width, Height);
			callback = null;
			allowCollisions = AllowCollisions;
			immovable = true;
		}
		
		override public function destroy():void
		{
			super.destroy();
			callback = null;
		}
	}
}

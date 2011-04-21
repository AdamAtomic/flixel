package org.flixel.plugin
{
	import org.flixel.*;
	
	public class DebugPathDisplay extends FlxBasic
	{
		public var cameras:Array;
		
		protected var _paths:Array;
		
		public function DebugPathDisplay()
		{
			_paths = new Array();
		}
		
		override public function destroy():void
		{
			clear();
			_paths = null;
		}
		
		override public function draw():void
		{
			if(!FlxG.visualDebug)
				return;			
			
			if(cameras == null)
				cameras = FlxG.cameras;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
				drawDebug(cameras[i++]);
		}
		
		override public function drawDebug(Camera:FlxCamera=null):void
		{
			if(Camera == null)
				Camera = FlxG.camera;
			
			var i:int = _paths.length-1;
			var path:FlxPath;
			while(i >= 0)
			{
				path = _paths[i--] as FlxPath;
				if(path != null)
					path.drawDebug(Camera);
			}
		}
		
		public function add(Path:FlxPath):void
		{
			_paths.push(Path);
		}
		
		public function remove(Path:FlxPath):void
		{
			var index:int = _paths.indexOf(Path);
			if(index >= 0)
				_paths.splice(index,1);
		}
		
		public function clear():void
		{
			var i:int = _paths.length-1;
			var path:FlxPath;
			while(i >= 0)
			{
				path = _paths[i--] as FlxPath;
				if(path != null)
					path.destroy();
			}
			_paths.length = 0;
		}
	}
}
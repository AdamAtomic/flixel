package org.flixel.system.debug
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;
	import org.flixel.system.FlxWindow;
	
	public class Watch extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 1024;
		static protected const LINE_HEIGHT:uint = 15;
		
		public var editing:Boolean;
		
		protected var _names:Sprite;
		protected var _values:Sprite;
		protected var _watching:Array;
		
		public function Watch(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0x7f7f7f7f, TopColor:uint=0x7f000000)
		{
			super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
			
			_names = new Sprite();
			_names.x = 2;
			_names.y = 15;
			addChild(_names);

			_values = new Sprite();
			_values.x = 2;
			_values.y = 15;
			addChild(_values);
			
			_watching = new Array();
			
			editing = false;
			
			removeAll();
		}
		
		override public function destroy():void
		{
			removeChild(_names);
			_names = null;
			removeChild(_values);
			_values = null;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
				(_watching[i++] as WatchEntry).destroy();
			_watching = null;
			super.destroy();
		}
		
		public function add(AnyObject:Object,VariableName:String,DisplayName:String=null):void
		{
			//Don't add repeats
			var w:WatchEntry;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				w = _watching[i++] as WatchEntry;
				if((w.object == AnyObject) && (w.field == VariableName))
					return;
			}
			
			//Good, no repeats, add away!
			w = new WatchEntry(_watching.length*LINE_HEIGHT,_width/2,_width/2-10,AnyObject,VariableName,DisplayName);
			_names.addChild(w.nameDisplay);
			_values.addChild(w.valueDisplay);
			_watching.push(w);
		}
		
		public function remove(AnyObject:Object,VariableName:String=null):void
		{
			//splice out the requested object
			var w:WatchEntry;
			var i:int = _watching.length-1;
			while(i >= 0)
			{
				w = _watching[i];
				if((w.object == AnyObject) && ((VariableName == null) || (w.field == VariableName)))
				{
					_watching.splice(i,1);
					_names.removeChild(w.nameDisplay);
					_values.removeChild(w.valueDisplay);
					w.destroy();
				}
				i--;
			}
			w = null;
			
			//reset the display heights of the remaining objects
			i = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				(_watching[i] as WatchEntry).setY(i*LINE_HEIGHT);
				i++;
			}
		}
		
		public function removeAll():void
		{
			var w:WatchEntry;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				w = _watching.pop();
				_names.removeChild(w.nameDisplay);
				_values.removeChild(w.valueDisplay);
				w.destroy();
				i++
			}
			_watching.length = 0;
		}

		public function update():void
		{
			editing = false;
			var i:uint = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				if(!(_watching[i++] as WatchEntry).updateValue())
					editing = true;
			}
		}
		
		override protected function updateSize():void
		{
			if(_height < _watching.length*LINE_HEIGHT + 17)
				_height = _watching.length*LINE_HEIGHT + 17;

			super.updateSize();

			_values.x = _width/2 + 2;

			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
				(_watching[i++] as WatchEntry).updateWidth(_width/2,_width/2-10);
		}
	}
}

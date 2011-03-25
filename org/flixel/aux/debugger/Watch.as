package org.flixel.aux.debugger
{
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;
	import org.flixel.aux.FlxWindow;
	
	public class Watch extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 1024;
		
		protected var _names:TextField;
		protected var _values:TextField;
		protected var _watching:Array;
		
		public function Watch(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0xdfBABCBF, TopColor:uint=0xff4E5359)
		{
			super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
			
			_names = new TextField();
			_names.x = 2;
			_names.y = 15;
			_names.multiline = true;
			_names.selectable = true;
			_names.defaultTextFormat = new TextFormat("Courier",12,0);
			addChild(_names);
			
			_values = new TextField();
			_values.x = 2;
			_values.y = 15;
			_values.multiline = true;
			_values.selectable = true;
			_values.defaultTextFormat = new TextFormat("Courier",12,0);
			addChild(_values);
			
			_watching = new Array();
		}
		
		public function add(AnyObject:Object,VariableName:String):void
		{
			_watching.push({object:AnyObject,field:VariableName});
			updateNames();
		}

		public function update():void
		{
			var o:Object;
			var i:uint = 0;
			var l:uint = _watching.length;
			var str:String = "";
			while(i < l)
			{
				o = _watching[i++];
				str += o.object[o.field].toString() + "\n";
			}
			_values.text = str;
		}
		
		protected function updateNames():void
		{
			var o:Object;
			var i:uint = 0;
			var l:uint = _watching.length;
			var str:String = "";
			while(i < l)
			{
				o = _watching[i++];
				if(_width > 300)
					str += FlxU.getClassName(o.object,(_width < 500)) + ".";
				str += o.field + "\n";
			}
			_names.text = str;
		}
		
		override protected function updateSize():void
		{
			super.updateSize();
			
			_names.width = _width/2;
			_names.height = _height-15;
			
			_values.width = _width/2-10;
			_values.x = _width/2 + 2;
			_values.height = _names.height;
			
			updateNames();
		}
	}
}
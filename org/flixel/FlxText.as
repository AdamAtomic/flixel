package org.flixel
{
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//@desc		A basic text display class, can do some fun stuff though like flicker and rotate
	public class FlxText extends FlxCore
	{
		public var angle:Number;
		
		private var _tf:TextField;
		private var _mtx:Matrix;
		private var _ox:Number;
		private var _oy:Number;
		private var _oa:Number;
		
		//@desc		Constructor
		//@param	X		The X position of the text
		//@param	Y		The Y position of the text
		//@param	Width	The width of the text object
		//@param	Height	The height of the text object (eventually these may be unnecessary by leveraging text metrics, but I couldn't get it together for this release)
		//@param	Text	The actual text you would like to display initially
		//@param	Color	The color of the text object
		//@param	Font	The name of the font you'd like to use (pass null to use the built-in pixel font)
		//@param	Size	The size of the font (recommend using multiples of 8 for cleanest rendering)
		//@param	Justification	Valid strings include "left", "center", and "right"
		//@param	Angle	How much the text should be rotated
		public function FlxText(X:Number, Y:Number, Width:uint, Height:uint, Text:String="", Color:uint=0xffffff, Font:String=null, Size:uint=8, Justification:String=null, Angle:Number=0)
		{
			super();
			
			_ox = x = X;
			_oy = y = Y;
			_oa = angle = Angle;
			width = Width;
			height = Height;
			
			if(Font == null)
				Font = "system";
			if(Text == null)
				Text = "";
			_tf = new TextField();
			_tf.width = width;
			_tf.height = height;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.sharpness = 100;
			_tf.defaultTextFormat = new TextFormat(Font,Size,Color,null,null,null,null,null,Justification);
			_tf.text = Text;
			
			_mtx = new Matrix();
			_mtx.translate(-(width>>1),-(height>>1));
			_mtx.rotate(Math.PI * 2 * (angle / 360));
			_mtx.translate(Math.floor(x)+(width>>1),Math.floor(y)+(height>>1));
		}
		
		//@desc		Changes the text being displayed
		//@param	Text	The new string you want to display
		public function setText(Text:String):void
		{
			_tf.text = Text;
		}
		
		//@desc		Changes the color being used by the text
		//@param	Color	The new color you want to use
		public function setColor(Color:uint):void
		{
			var format:TextFormat = _tf.defaultTextFormat;
			format.color = Color;
			_tf.defaultTextFormat = format;
			_tf.text = _tf.text;
		}
		
		//@desc		Called by the game loop automatically, updates the position and angle of the text
		override public function update():void
		{
			super.update();
			var n:Point = new Point();
			getScreenXY(n);
			if((_ox != n.x) || (_oy != n.y) || (_oa != angle))
			{
				_mtx = new Matrix();
				_mtx.translate(-(width>>1),-(height>>1));
				_mtx.rotate(Math.PI * 2 * (angle / 360));
				_mtx.translate(n.x+(width>>1),n.y+(height>>1));
				_ox = n.x;
				_oy = n.y;
			}
		}
		
		//@desc		Called by the game loop automatically, blits the text object to the screen
		override public function render():void
		{
			FlxG.buffer.draw(_tf,_mtx);
		}
	}
}
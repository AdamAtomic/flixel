package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	//@desc		A basic text display class, can do some fun stuff though like flicker and rotate
	public class FlxText extends FlxSprite
	{
		protected var _tf:TextField;
		protected var _regen:Boolean;
		
		//@desc		Constructor
		//@param	X		The X position of the text
		//@param	Y		The Y position of the text
		//@param	Width	The width of the text object
		//@param	Height	The height of the text object (eventually these may be unnecessary by leveraging text metrics, but I couldn't get it together for this release)
		//@param	Text	The actual text you would like to display initially
		//@param	Color	The color of the text object
		//@param	Font	The name of the font you'd like to use (pass null to use the built-in pixel font)
		//@param	Size	The size of the font (recommend using multiples of 8 for cleanest rendering)
		//@param	Align	Valid strings include "left", "center", and "right"
		public function FlxText(X:Number, Y:Number, Width:uint, Text:String="", Color:uint=0xffffff, Font:String=null, Size:Number=8, Align:String=null)
		{
			if(Font == null)
				Font = "system";
			if(Text == null)
				Text = "";
			_tf = new TextField();
			_tf.width = Width;
			_tf.height = 1;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.sharpness = 100;
			_tf.defaultTextFormat = new TextFormat(Font,Size,0xffffff,null,null,null,null,null,Align);
			_tf.text = Text;
			super(null,X,Y,false,false,Width,1);
			_regen = true;
			color = Color; //calls calcFrame() implicitly
		} 
		
		//@desc		Changes the text being displayed
		//@param	Text	The new string you want to display
		public function set text(Text:String):void
		{
			_tf.text = Text;
			_regen = true;
			calcFrame();
		}
		
		//@desc		Getter to retrieve the text being displayed
		//@param	Text	The text string being displayed
		public function get text():String
		{
			return _tf.text;
		}
		
		//@desc		Changes the text being displayed
		//@param	Text	The new string you want to display
		public function set size(Size:Number):void
		{
			_tf.defaultTextFormat.size = Size;
			_regen = true;
			calcFrame();
		}
		
		//@desc		Getter to retrieve the text being displayed
		//@param	Text	The text string being displayed
		public function get size():Number
		{
			return _tf.defaultTextFormat.size as Number;
		}
		
		//@desc		Internal function to update the current animation frame
		override protected function calcFrame():void
		{
			//Just leave if there's no text to render
			if((_tf == null) || (_tf.text == null) || (_tf.text.length <= 0))
			{
				_pixels.fillRect(_r,0);
				return;
			}
			if(_regen)
			{
				//Need to generate a new buffer to store the text graphic
				var nl:uint = _tf.numLines;
				height = 0;
				for(var i:uint = 0; i < nl; i++)
					height += _tf.getLineMetrics(i).height;
				height += 4; //account for 2px gutter on top and bottom
				_pixels = new BitmapData(width,height,true,0);
				_bh = height;
				_tf.height = height;
				_r = new Rectangle(0,0,width,height);
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
				_pixels.fillRect(_r,0);
			
			//Now that we've cleared a buffer, we need to actually render the text to it
			var tf:TextFormat = _tf.defaultTextFormat;
			_mtx.identity();
			//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
			if((tf.align == "center") && (_tf.numLines == 1))
			{
				_tf.setTextFormat(new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,"left"));				
				_mtx.translate(Math.floor((width - _tf.getLineMetrics(0).width)/2),0);
			}
			_pixels.draw(_tf,_mtx,_ct);	//Actually draw the text onto the buffer
			_tf.setTextFormat(new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,tf.align));
		}
	}
}

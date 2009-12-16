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
		//@param	Width	The width of the text object (height is determined automatically)
		//@param	Text	The actual text you would like to display initially
		public function FlxText(X:Number, Y:Number, Width:uint, Text:String=null)
		{
			if(Text == null)
				Text = "";
			_tf = new TextField();
			_tf.width = Width;
			_tf.height = 1;
			_tf.embedFonts = true;
			_tf.selectable = false;
			_tf.sharpness = 100;
			_tf.defaultTextFormat = new TextFormat("system",8,0xffffff);
			_tf.text = Text;
			super(X,Y);
			createGraphic(Width,1);
			_regen = true;
			calcFrame();
		}
		
		//@desc		You can use this if you have a lot of text parameters to set instead of the individual properties
		//@param	Font		The name of the font face for the text display
		//@param	Size		The size of the font (in pixels essentially)
		//@param	Color		The color of the text in traditional flash 0xAARRGGBB format
		//@param	Alignment	A string representing the desired alignment ("left,"right" or "center")
		//@return	This FlxText instance (nice for chaining stuff together, if you're into that)
		public function setFormat(Font:String=null,Size:Number=8,Color:uint=0xffffff,Alignment:String=null):FlxText
		{
			if(Font == null)
				Font = "";
			var tf:TextFormat = dtfCopy();
			tf.font = Font;
			tf.size = Size;
			tf.align = Alignment;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			color = Color;
			calcFrame();
			return this;
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
		//@return	The text string being displayed
		public function get text():String
		{
			return _tf.text;
		}
		
		//@desc		Changes the size of the text being displayed
		//@param	Size	The new font size you want to use
		public function set size(Size:Number):void
		{
			var tf:TextFormat = dtfCopy();
			tf.size = Size;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			calcFrame();
		}
		
		//@desc		Getter to retrieve the size of the text
		//@return	The size of the font
		public function get size():Number
		{
			return _tf.defaultTextFormat.size as Number;
		}
		
		//@desc		Sets the font face being used
		//@param	Font	The name of the font face
		public function set font(Font:String):void
		{
			var tf:TextFormat = dtfCopy();
			tf.font = Font;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			calcFrame();
		}
		
		//@desc		Gets the name of the font face being used
		//@return	The name of the font face
		public function get font():String
		{
			return _tf.defaultTextFormat.font;
		}
		
		//@desc		Sets the alignment of the text being displayed
		//@param	A string indicating the desired alignment - acceptable values are "left", "right" and "center"
		public function set alignment(Alignment:String):void
		{
			var tf:TextFormat = dtfCopy();
			tf.align = Alignment;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			calcFrame();
		}
		
		//@desc		Gets the alignment of the text being displayed
		//@return	A string indicating the current alignment
		public function get alignment():String
		{
			return _tf.defaultTextFormat.align;
		}
		
		//@desc		Internal function to update the current animation frame
		override protected function calcFrame():void
		{
			//Just leave if there's no text to render
			if((_tf == null) || (_tf.text == null) || (_tf.text.length <= 0))
			{
				_framePixels.fillRect(_r,0);
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
				_framePixels = new BitmapData(width,height,true,0);
				_bh = height;
				_tf.height = height;
				_r = new Rectangle(0,0,width,height);
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
				_framePixels.fillRect(_r,0);
			
			//Now that we've cleared a buffer, we need to actually render the text to it
			var tf:TextFormat = _tf.defaultTextFormat;
			_mtx.identity();
			//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
			if((tf.align == "center") && (_tf.numLines == 1))
			{
				_tf.setTextFormat(new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,"left"));				
				_mtx.translate(Math.floor((width - _tf.getLineMetrics(0).width)/2),0);
			}
			_framePixels.draw(_tf,_mtx,_ct);	//Actually draw the text onto the buffer
			_tf.setTextFormat(new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,tf.align));
		}
		
		//@desc		A helper function for updating the flash TextField that we use for rendering
		//@return	A writable copy of TextField.defaultTextFormat
		protected function dtfCopy():TextFormat
		{
			var dtf:TextFormat = _tf.defaultTextFormat;
			return new TextFormat(dtf.font,dtf.size,dtf.color,dtf.bold,dtf.italic,dtf.underline,dtf.url,dtf.target,dtf.align);
		}
	}
}

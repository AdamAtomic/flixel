package org.flixel
{
	import flash.display.BitmapData;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * Extends <code>FlxSprite</code> to support rendering text.
	 * Can tint, fade, rotate and scale just like a sprite.
	 * Doesn't really animate though, as far as I know.
	 * Also does nice pixel-perfect centering on pixel fonts
	 * as long as they are only one liners.
	 */
	public class FlxText extends FlxSprite
	{
		protected var _tf:TextField;
		protected var _regen:Boolean;
		protected var _shadow:uint;
		
		/**
		 * Creates a new <code>FlxText</code> object at the specified position.
		 * 
		 * @param	X				The X position of the text.
		 * @param	Y				The Y position of the text.
		 * @param	Width			The width of the text object (height is determined automatically).
		 * @param	Text			The actual text you would like to display initially.
		 * @param	EmbeddedFont	Whether this text field uses embedded fonts or nto
		 */
		public function FlxText(X:Number, Y:Number, Width:uint, Text:String=null, EmbeddedFont:Boolean=true)
		{
			super(X,Y);
			createGraphic(Width,1,0);
			
			if(Text == null)
				Text = "";
			_tf = new TextField();
			_tf.width = Width;
			_tf.embedFonts = EmbeddedFont;
			_tf.selectable = false;
			_tf.sharpness = 100;
			_tf.multiline = true;
			_tf.wordWrap = true;
			_tf.text = Text;
			var tf:TextFormat = new TextFormat("system",8,0xffffff);
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			if(Text.length <= 0)
				_tf.height = 1;
			else
				_tf.height = 10;
			
			_regen = true;
			_shadow = 0;
			solid = false;
			calcFrame();
		}
		
		/**
		 * You can use this if you have a lot of text parameters
		 * to set instead of the individual properties.
		 * 
		 * @param	Font		The name of the font face for the text display.
		 * @param	Size		The size of the font (in pixels essentially).
		 * @param	Color		The color of the text in traditional flash 0xRRGGBB format.
		 * @param	Alignment	A string representing the desired alignment ("left,"right" or "center").
		 * @param	ShadowColor	A uint representing the desired text shadow color in flash 0xRRGGBB format.
		 * 
		 * @return	This FlxText instance (nice for chaining stuff together, if you're into that).
		 */
		public function setFormat(Font:String=null,Size:Number=8,Color:uint=0xffffff,Alignment:String=null,ShadowColor:uint=0):FlxText
		{
			if(Font == null)
				Font = "";
			var tf:TextFormat = dtfCopy();
			tf.font = Font;
			tf.size = Size;
			tf.color = Color;
			tf.align = Alignment;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_shadow = ShadowColor;
			_regen = true;
			calcFrame();
			return this;
		}
		
		/**
		 * The text being displayed.
		 */
		public function get text():String
		{
			return _tf.text;
		}
		
		/**
		 * @private
		 */
		public function set text(Text:String):void
		{
			var ot:String = _tf.text;
			_tf.text = Text;
			if(_tf.text != ot)
			{
				_regen = true;
				calcFrame();
			}
		}
		
		/**
		 * The size of the text being displayed.
		 */
		 public function get size():Number
		{
			return _tf.defaultTextFormat.size as Number;
		}
		
		/**
		 * @private
		 */
		public function set size(Size:Number):void
		{
			var tf:TextFormat = dtfCopy();
			tf.size = Size;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The color of the text being displayed.
		 */
		override public function get color():uint
		{
			return _tf.defaultTextFormat.color as uint;
		}
		
		/**
		 * @private
		 */
		override public function set color(Color:uint):void
		{
			var tf:TextFormat = dtfCopy();
			tf.color = Color;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The font used for this text.
		 */
		public function get font():String
		{
			return _tf.defaultTextFormat.font;
		}
		
		/**
		 * @private
		 */
		public function set font(Font:String):void
		{
			var tf:TextFormat = dtfCopy();
			tf.font = Font;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The alignment of the font ("left", "right", or "center").
		 */
		public function get alignment():String
		{
			return _tf.defaultTextFormat.align;
		}
		
		/**
		 * @private
		 */
		public function set alignment(Alignment:String):void
		{
			var tf:TextFormat = dtfCopy();
			tf.align = Alignment;
			_tf.defaultTextFormat = tf;
			_tf.setTextFormat(tf);
			calcFrame();
		}
		
		/**
		 * The alignment of the font ("left", "right", or "center").
		 */
		public function get shadow():uint
		{
			return _shadow;
		}
		
		/**
		 * @private
		 */
		public function set shadow(Color:uint):void
		{
			_shadow = Color;
			calcFrame();
		}
		
		/**
		 * Internal function to update the current animation frame.
		 */
		override protected function calcFrame():void
		{
			if(_regen)
			{
				//Need to generate a new buffer to store the text graphic
				var i:uint = 0;
				var nl:uint = _tf.numLines;
				height = 0;
				while(i < nl)
					height += _tf.getLineMetrics(i++).height;
				height += 4; //account for 2px gutter on top and bottom
				_pixels = new BitmapData(width,height,true,0);
				_bbb = new BitmapData(width,height,true,0);
				frameHeight = height;
				_tf.height = height*1.2;
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width;
				_flashRect.height = height;
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
				_pixels.fillRect(_flashRect,0);
			
			if((_tf != null) && (_tf.text != null) && (_tf.text.length > 0))
			{
				//Now that we've cleared a buffer, we need to actually render the text to it
				var tf:TextFormat = _tf.defaultTextFormat;
				var tfa:TextFormat = tf;
				_mtx.identity();
				//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				if((tf.align == "center") && (_tf.numLines == 1))
				{
					tfa = new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,"left");
					_tf.setTextFormat(tfa);				
					_mtx.translate(Math.floor((width - _tf.getLineMetrics(0).width)/2),0);
				}
				//Render a single pixel shadow beneath the text
				if(_shadow > 0)
				{
					_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,_shadow,null,null,null,null,null,tfa.align));				
					_mtx.translate(1,1);
					_pixels.draw(_tf,_mtx,_ct);
					_mtx.translate(-1,-1);
					_tf.setTextFormat(new TextFormat(tfa.font,tfa.size,tfa.color,null,null,null,null,null,tfa.align));
				}
				//Actually draw the text onto the buffer
				_pixels.draw(_tf,_mtx,_ct);
				_tf.setTextFormat(new TextFormat(tf.font,tf.size,tf.color,null,null,null,null,null,tf.align));
			}
			
			//Finally, update the visible pixels
			if((_framePixels == null) || (_framePixels.width != _pixels.width) || (_framePixels.height != _pixels.height))
				_framePixels = new BitmapData(_pixels.width,_pixels.height,true,0);
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			if(FlxG.showBounds)
				drawBounds();
			if(solid)
				refreshHulls();
		}
		
		/**
		 * A helper function for updating the <code>TextField</code> that we use for rendering.
		 * 
		 * @return	A writable copy of <code>TextField.defaultTextFormat</code>.
		 */
		protected function dtfCopy():TextFormat
		{
			var dtf:TextFormat = _tf.defaultTextFormat;
			return new TextFormat(dtf.font,dtf.size,dtf.color,dtf.bold,dtf.italic,dtf.underline,dtf.url,dtf.target,dtf.align);
		}
	}
}

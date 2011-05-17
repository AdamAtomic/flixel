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
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxText extends FlxSprite
	{
		/**
		 * Internal reference to a Flash <code>TextField</code> object.
		 */
		protected var _textField:TextField;
		/**
		 * Whether the actual text field needs to be regenerated and stamped again.
		 * This is NOT the same thing as <code>FlxSprite.dirty</code>.
		 */
		protected var _regen:Boolean;
		/**
		 * Internal tracker for the text shadow color, default is clear/transparent.
		 */
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
			makeGraphic(Width,1,0);
			
			if(Text == null)
				Text = "";
			_textField = new TextField();
			_textField.width = Width;
			_textField.embedFonts = EmbeddedFont;
			_textField.selectable = false;
			_textField.sharpness = 100;
			_textField.multiline = true;
			_textField.wordWrap = true;
			_textField.text = Text;
			var format:TextFormat = new TextFormat("system",8,0xffffff);
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			if(Text.length <= 0)
				_textField.height = 1;
			else
				_textField.height = 10;
			
			_regen = true;
			_shadow = 0;
			allowCollisions = NONE;
			calcFrame();
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void
		{
			_textField = null;
			super.destroy();
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
			var format:TextFormat = dtfCopy();
			format.font = Font;
			format.size = Size;
			format.color = Color;
			format.align = Alignment;
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
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
			return _textField.text;
		}
		
		/**
		 * @private
		 */
		public function set text(Text:String):void
		{
			var ot:String = _textField.text;
			_textField.text = Text;
			if(_textField.text != ot)
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
			return _textField.defaultTextFormat.size as Number;
		}
		
		/**
		 * @private
		 */
		public function set size(Size:Number):void
		{
			var format:TextFormat = dtfCopy();
			format.size = Size;
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The color of the text being displayed.
		 */
		override public function get color():uint
		{
			return _textField.defaultTextFormat.color as uint;
		}
		
		/**
		 * @private
		 */
		override public function set color(Color:uint):void
		{
			var format:TextFormat = dtfCopy();
			format.color = Color;
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The font used for this text.
		 */
		public function get font():String
		{
			return _textField.defaultTextFormat.font;
		}
		
		/**
		 * @private
		 */
		public function set font(Font:String):void
		{
			var format:TextFormat = dtfCopy();
			format.font = Font;
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			_regen = true;
			calcFrame();
		}
		
		/**
		 * The alignment of the font ("left", "right", or "center").
		 */
		public function get alignment():String
		{
			return _textField.defaultTextFormat.align;
		}
		
		/**
		 * @private
		 */
		public function set alignment(Alignment:String):void
		{
			var format:TextFormat = dtfCopy();
			format.align = Alignment;
			_textField.defaultTextFormat = format;
			_textField.setTextFormat(format);
			calcFrame();
		}
		
		/**
		 * The color of the text shadow in 0xAARRGGBB hex format.
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
				var nl:uint = _textField.numLines;
				height = 0;
				while(i < nl)
					height += _textField.getLineMetrics(i++).height;
				height += 4; //account for 2px gutter on top and bottom
				_pixels = new BitmapData(width,height,true,0);
				frameHeight = height;
				_textField.height = height*1.2;
				_flashRect.x = 0;
				_flashRect.y = 0;
				_flashRect.width = width;
				_flashRect.height = height;
				_regen = false;
			}
			else	//Else just clear the old buffer before redrawing the text
				_pixels.fillRect(_flashRect,0);
			
			if((_textField != null) && (_textField.text != null) && (_textField.text.length > 0))
			{
				//Now that we've cleared a buffer, we need to actually render the text to it
				var format:TextFormat = _textField.defaultTextFormat;
				var formatAdjusted:TextFormat = format;
				_matrix.identity();
				//If it's a single, centered line of text, we center it ourselves so it doesn't blur to hell
				if((format.align == "center") && (_textField.numLines == 1))
				{
					formatAdjusted = new TextFormat(format.font,format.size,format.color,null,null,null,null,null,"left");
					_textField.setTextFormat(formatAdjusted);				
					_matrix.translate(Math.floor((width - _textField.getLineMetrics(0).width)/2),0);
				}
				//Render a single pixel shadow beneath the text
				if(_shadow > 0)
				{
					_textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,_shadow,null,null,null,null,null,formatAdjusted.align));				
					_matrix.translate(1,1);
					_pixels.draw(_textField,_matrix,_colorTransform);
					_matrix.translate(-1,-1);
					_textField.setTextFormat(new TextFormat(formatAdjusted.font,formatAdjusted.size,formatAdjusted.color,null,null,null,null,null,formatAdjusted.align));
				}
				//Actually draw the text onto the buffer
				_pixels.draw(_textField,_matrix,_colorTransform);
				_textField.setTextFormat(new TextFormat(format.font,format.size,format.color,null,null,null,null,null,format.align));
			}
			
			//Finally, update the visible pixels
			if((framePixels == null) || (framePixels.width != _pixels.width) || (framePixels.height != _pixels.height))
				framePixels = new BitmapData(_pixels.width,_pixels.height,true,0);
			framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
		}
		
		/**
		 * A helper function for updating the <code>TextField</code> that we use for rendering.
		 * 
		 * @return	A writable copy of <code>TextField.defaultTextFormat</code>.
		 */
		protected function dtfCopy():TextFormat
		{
			var defaultTextFormat:TextFormat = _textField.defaultTextFormat;
			return new TextFormat(defaultTextFormat.font,defaultTextFormat.size,defaultTextFormat.color,defaultTextFormat.bold,defaultTextFormat.italic,defaultTextFormat.underline,defaultTextFormat.url,defaultTextFormat.target,defaultTextFormat.align);
		}
	}
}

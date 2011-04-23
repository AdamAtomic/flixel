package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.system.FlxAnim;
	
	/**
	 * The main "game object" class, the sprite is a <code>FlxObject</code>
	 * with a bunch of graphics options and abilities, like animation and stamping.
	 * 
	 * @author	Adam Atomic
	 */
	public class FlxSprite extends FlxObject
	{
		[Embed(source="data/default.png")] protected var ImgDefault:Class;
		
		/**
		 * WARNING: The origin of the sprite will default to its center.
		 * If you change this, the visuals and the collisions will likely be
		 * pretty out-of-sync if you do any rotation.
		 */
		public var origin:FlxPoint;
		/**
		* If you changed the size of your sprite object after loading or making the graphic,
		* you might need to offset the graphic away from the bound box to center it the way you want.
		*/
		public var offset:FlxPoint;
		
		/**
		 * Change the size of your sprite's graphic.
		 * NOTE: Scale doesn't currently affect collisions automatically,
		 * you will need to adjust the width, height and offset manually.
		 * WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
		 */
		public var scale:FlxPoint;
		/**
		 * Blending modes, just like Photoshop or whatever.
		 * E.g. "multiply", "screen", etc.
		 * @default null
		 */
		public var blend:String;
		/**
		 * Controls whether the object is smoothed when rotated, affects performance.
		 * @default false
		 */
		public var antialiasing:Boolean;
		/**
		 * Whether the current animation has finished its first (or only) loop.
		 */
		public var finished:Boolean;
		/**
		 * The width of the actual graphic or image being displayed (not necessarily the game object/bounding box).
		 * NOTE: Edit at your own risk!!  This is intended to be read-only.
		 */
		public var frameWidth:uint;
		/**
		 * The height of the actual graphic or image being displayed (not necessarily the game object/bounding box).
		 * NOTE: Edit at your own risk!!  This is intended to be read-only.
		 */
		public var frameHeight:uint;
		/**
		 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
		 */
		public var frames:uint;
		/**
		 * The actual Flash <code>BitmapData</code> object representing the current display state of the sprite.
		 */
		public var framePixels:BitmapData;
		/**
		 * Set this flag to true to force the sprite to update during the draw() call.
		 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
		 */
		public var dirty:Boolean;
		
		/**
		 * Internal, stores all the animations that were added to this sprite.
		 */
		protected var _animations:Array;
		/**
		 * Internal, keeps track of whether the sprite was loaded with support for automatic reverse/mirroring.
		 */
		protected var _flipped:uint;
		/**
		 * Internal, keeps track of the current animation being played.
		 */
		protected var _curAnim:FlxAnim;
		/**
		 * Internal, keeps track of the current frame of animation.
		 * This is NOT an index into the tile sheet, but the frame number in the animation object.
		 */
		protected var _curFrame:uint;
		/**
		 * Internal, keeps track of the current index into the tile sheet based on animation or rotation.
		 */
		protected var _caf:uint;
		/**
		 * Internal, used to time each frame of animation.
		 */
		protected var _frameTimer:Number;
		/**
		 * Internal tracker for the animation callback.  Default is null.
		 * If assigned, will be called each time the current frame changes.
		 * A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
		 */
		protected var _callback:Function;
		/**
		 * Internal tracker for what direction the sprite is currently facing, used with Flash getter/setter.
		 */
		protected var _facing:uint;
		/**
		 * Internal tracker for opacity, used with Flash getter/setter.
		 */
		protected var _alpha:Number;
		/**
		 * Internal tracker for color tint, used with Flash getter/setter.
		 */
		protected var _color:uint;
		/**
		 * Internal tracker for how many frames of "baked" rotation there are (if any).
		 */
		protected var _bakedRotation:Number;
		/**
		 * Internal, stores the entire source graphic (not the current displayed animation frame), used with Flash getter/setter.
		 */
		protected var _pixels:BitmapData;
		
		/**
		 * Internal, reused frequently during drawing and animating.
		 */
		protected var _flashPoint:Point;
		/**
		 * Internal, reused frequently during drawing and animating.
		 */
		protected var _flashRect:Rectangle;
		/**
		 * Internal, reused frequently during drawing and animating.
		 */
		protected var _flashRect2:Rectangle;
		/**
		 * Internal, reused frequently during drawing and animating. Always contains (0,0).
		 */
		protected var _flashPointZero:Point;
		/**
		 * Internal, helps with animation, caching and drawing.
		 */
		protected var _ct:ColorTransform;
		/**
		 * Internal, helps with animation, caching and drawing.
		 */
		protected var _mtx:Matrix;
		
		/**
		 * Creates a white 8x8 square <code>FlxSprite</code> at the specified position.
		 * Optionally can load a simple, one-frame graphic instead.
		 * 
		 * @param	X				The initial X position of the sprite.
		 * @param	Y				The initial Y position of the sprite.
		 * @param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!).
		 */
		public function FlxSprite(X:Number=0,Y:Number=0,SimpleGraphic:Class=null)
		{
			super(X,Y);
			
			health = 1;

			_flashPoint = new Point();
			_flashRect = new Rectangle();
			_flashRect2 = new Rectangle();
			_flashPointZero = new Point();
			offset = new FlxPoint();
			origin = new FlxPoint();
			
			scale = new FlxPoint(1.0,1.0);
			_alpha = 1;
			_color = 0x00ffffff;
			blend = null;
			antialiasing = false;
			cameras = null;
			
			finished = false;
			_facing = RIGHT;
			_animations = new Array();
			_flipped = 0;
			_curAnim = null;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;

			_mtx = new Matrix();
			_callback = null;
			
			if(SimpleGraphic == null)
				SimpleGraphic = ImgDefault;
			loadGraphic(SimpleGraphic);
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void
		{
			if(_animations != null)
			{
				var a:FlxAnim;
				var i:uint = 0;
				var l:uint = _animations.length;
				while(i < l)
				{
					a = _animations[i++];
					if(a != null)
						a.destroy();
				}
				_animations = null;
			}
			
			_flashPoint = null;
			_flashRect = null;
			_flashRect2 = null;
			_flashPointZero = null;
			offset = null;
			origin = null;
			scale = null;
			_curAnim = null;
			_mtx = null;
			_callback = null;
			framePixels = null;
		}
		
		/**
		 * Load an image from an embedded graphic file.
		 * 
		 * @param	Graphic		The image you want to use.
		 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
		 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
		 * @param	Width		Optional, specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Height		Optional, specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Unique		Optional, whether the graphic should be a unique instance in the graphics cache.  Default is false.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadGraphic(Graphic:Class,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.addBitmap(Graphic,Reverse,Unique);
			if(Reverse)
				_flipped = _pixels.width>>1;
			else
				_flipped = 0;
			if(Width == 0)
			{
				if(Animated)
					Width = _pixels.height;
				else if(_flipped > 0)
					Width = _pixels.width*0.5;
				else
					Width = _pixels.width;
			}
			width = frameWidth = Width;
			if(Height == 0)
			{
				if(Animated)
					Height = width;
				else
					Height = _pixels.height;
			}
			height = frameHeight = Height;
			resetHelpers();
			return this;
		}
		
		/**
		 * Create a pre-rotated sprite sheet from a simple sprite.
		 * This can make a huge difference in graphical performance!
		 * 
		 * @param	Graphic			The image you want to rotate and stamp.
		 * @param	Rotations		The number of rotation frames the final sprite should have.  For small sprites this can be quite a large number (360 even) without any problems.
		 * @param	Frame			If the Graphic has a single row of square animation frames on it, you can specify which of the frames you want to use here.  Default is -1, or "use whole graphic."
		 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.  Default is false.
		 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function loadRotatedGraphic(Graphic:Class, Rotations:uint=16, Frame:int=-1, AntiAliasing:Boolean=false, AutoBuffer:Boolean=false):FlxSprite
		{
			//Create the brush and canvas
			var rows:uint = Math.sqrt(Rotations);
			var brush:BitmapData = FlxG.addBitmap(Graphic);
			if(Frame >= 0)
			{
				//Using just a segment of the graphic - find the right bit here
				var full:BitmapData = brush;
				brush = new BitmapData(full.height,full.height);
				var rx:uint = Frame*brush.width;
				var ry:uint = 0;
				var fw:uint = full.width;
				if(rx >= fw)
				{
					ry = uint(rx/fw)*brush.height;
					rx %= fw;
				}
				_flashRect.x = rx;
				_flashRect.y = ry;
				_flashRect.width = brush.width;
				_flashRect.height = brush.height;
				brush.copyPixels(full,_flashRect,_flashPointZero);
			}
			
			var max:uint = brush.width;
			if(brush.height > max)
				max = brush.height;
			if(AutoBuffer)
				max *= 1.5;
			var cols:uint = FlxU.ceil(Rotations/rows);
			width = max*cols;
			height = max*rows;
			var key:String = String(Graphic) + ":" + Frame + ":" + width + "x" + height;
			var skipGen:Boolean = FlxG.checkBitmapCache(key);
			_pixels = FlxG.createBitmap(width, height, 0, true, key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			_bakedRotation = 360/Rotations;
			
			//Generate a new sheet if necessary, then fix up the width and height
			if(!skipGen)
			{
				var r:uint = 0;
				var c:uint;
				var ba:Number = 0;
				var bw2:uint = brush.width*0.5;
				var bh2:uint = brush.height*0.5;
				var gxc:uint = max*0.5;
				var gyc:uint = max*0.5;
				while(r < rows)
				{
					c = 0;
					while(c < cols)
					{
						_mtx.identity();
						_mtx.translate(-bw2,-bh2);
						_mtx.rotate(ba*0.017453293);
						_mtx.translate(max*c+gxc, gyc);
						ba += _bakedRotation;
						_pixels.draw(brush,_mtx,null,null,null,AntiAliasing);
						c++;
					}
					gyc += max;
					r++;
				}
			}
			frameWidth = frameHeight = width = height = max;
			resetHelpers();
			return this;
		}
		
		/**
		 * This function creates a flat colored square image dynamically.
		 * 
		 * @param	Width		The width of the sprite you want to generate.
		 * @param	Height		The height of the sprite you want to generate.
		 * @param	Color		Specifies the color of the generated block.
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.  Default is false.
		 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function makeGraphic(Width:uint,Height:uint,Color:uint=0xffffffff,Unique:Boolean=false,Key:String=null):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
			return this;
		}
		
		/**
		 * Resets some important variables for sprite optimization and rendering.
		 */
		protected function resetHelpers():void
		{
			_flashRect.x = 0;
			_flashRect.y = 0;
			_flashRect.width = frameWidth;
			_flashRect.height = frameHeight;
			_flashRect2.x = 0;
			_flashRect2.y = 0;
			_flashRect2.width = _pixels.width;
			_flashRect2.height = _pixels.height;
			if((framePixels == null) || (framePixels.width != width) || (framePixels.height != height))
				framePixels = new BitmapData(width,height);
			origin.make(frameWidth*0.5,frameHeight*0.5);
			framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			frames = (_flashRect2.width / _flashRect.width) * (_flashRect2.height / _flashRect.height);
			if(_ct != null) framePixels.colorTransform(_flashRect,_ct);
			_caf = 0;
		}
		
		/**
		 * Automatically called after update() by the game loop,
		 * this function just calls updateAnimation().
		 */
		override public function postUpdate():void
		{
			super.postUpdate();
			updateAnimation();
		}
		
		/**
		 * Called by game loop, updates then blits or renders current frame of animation to the screen
		 */
		override public function draw():void
		{
			if(_flickerTimer != 0)
			{
				_flicker = !_flicker;
				if(_flicker)
					return;
			}
			
			if(dirty)	//rarely 
				calcFrame();
			
			if(cameras == null)
				cameras = FlxG.cameras;
			var c:FlxCamera;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				c = cameras[i++];
				if(!onScreen(c))
					continue;
				_point.x = x - int(c.scroll.x*scrollFactor.x) - offset.x;
				_point.y = y - int(c.scroll.y*scrollFactor.y) - offset.y;
				_point.x += (_point.x > 0)?0.0000001:-0.0000001;
				_point.y += (_point.y > 0)?0.0000001:-0.0000001;
				if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null))
				{	//Simple render
					_flashPoint.x = _point.x;
					_flashPoint.y = _point.y;
					c.buffer.copyPixels(framePixels,_flashRect,_flashPoint,null,null,true);
				}
				else
				{	//Advanced render
					_mtx.identity();
					_mtx.translate(-origin.x,-origin.y);
					_mtx.scale(scale.x,scale.y);
					if((angle != 0) && (_bakedRotation <= 0))
						_mtx.rotate(angle * 0.017453293);
					_mtx.translate(_point.x+origin.x,_point.y+origin.y);
					c.buffer.draw(framePixels,_mtx,null,blend,null,antialiasing);
				}
				_VISIBLECOUNT++;
				if(FlxG.visualDebug)
					drawDebug(c);
			}
		}
		
		/**
		 * This function draws or stamps one <code>FlxSprite</code> onto another.
		 * This function is NOT intended to replace <code>render()</code>!
		 * 
		 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
		 * @param	X			The X coordinate of the brush's top left corner on this sprite.
		 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
		 */
		public function stamp(Brush:FlxSprite,X:int=0,Y:int=0):void
		{
			var b:BitmapData = Brush.framePixels;
			
			//Simple draw
			if(((Brush.angle == 0) || (Brush._bakedRotation > 0)) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
			{
				_flashPoint.x = X;
				_flashPoint.y = Y;
				_flashRect2.width = b.width;
				_flashRect2.height = b.height;
				_pixels.copyPixels(b,_flashRect2,_flashPoint,null,null,true);
				_flashRect2.width = _pixels.width;
				_flashRect2.height = _pixels.height;
				calcFrame();
				return;
			}
			
			//Advanced draw
			_mtx.identity();
			_mtx.translate(-Brush.origin.x,-Brush.origin.y);
			_mtx.scale(Brush.scale.x,Brush.scale.y);
			if(Brush.angle != 0)
				_mtx.rotate(Brush.angle * 0.017453293);
			_mtx.translate(X+Brush.origin.x,Y+Brush.origin.y);
			_pixels.draw(b,_mtx,null,Brush.blend,null,Brush.antialiasing);
			calcFrame();
		}
		
		/**
		 * This function draws a line on this sprite from position X1,Y1
		 * to position X2,Y2 with the specified color.
		 * 
		 * @param	StartX		X coordinate of the line's start point.
		 * @param	StartY		Y coordinate of the line's start point.
		 * @param	EndX		X coordinate of the line's end point.
		 * @param	EndY		Y coordinate of the line's end point.
		 * @param	Color		The line's color.
		 * @param	Thickness	How thick the line is in pixels (default value is 1).
		 */
		public function drawLine(StartX:Number,StartY:Number,EndX:Number,EndY:Number,Color:uint,Thickness:uint=1):void
		{
			//Draw line
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			gfx.moveTo(StartX,StartY);
			var a:Number = Number((Color >> 24) & 0xFF) / 255;
			if(a <= 0)
				a = 1;
			gfx.lineStyle(Thickness,Color,a);
			gfx.lineTo(EndX,EndY);
			
			//Cache line to bitmap
			_pixels.draw(FlxG.flashGfxSprite);
			dirty = true;
		}
		
		/**
		 * Fills this sprite's graphic with a specific color.
		 * 
		 * @param	Color		The color with which to fill the graphic, format 0xAARRGGBB.
		 */
		public function fill(Color:uint):void
		{
			_pixels.fillRect(_flashRect2,Color);
			if(_pixels != framePixels)
				dirty = true;
		}
		
		/**
		 * Internal function for updating the sprite's animation.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 * This function is called automatically by <code>FlxSprite.postUpdate()</code>.
		 */
		protected function updateAnimation():void
		{
			if(_bakedRotation > 0)
			{
				var oc:uint = _caf;
				var ta:int = angle%360;
				if(ta < 0)
					ta += 360;
				_caf = ta/_bakedRotation + 0.5;
				if(oc != _caf)
					dirty = true;
			}
			else if((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished))
			{
				_frameTimer += FlxG.elapsed;
				while(_frameTimer > _curAnim.delay)
				{
					_frameTimer = _frameTimer - _curAnim.delay;
					if(_curFrame == _curAnim.frames.length-1)
					{
						if(_curAnim.looped)
							_curFrame = 0;
						finished = true;
					}
					else
						_curFrame++;
					_caf = _curAnim.frames[_curFrame];
					dirty = true;
				}
			}
			
			if(dirty)
				calcFrame();
		}
		
		/**
		 * Request (or force) that the sprite update the frame before rendering.
		 * Useful if you are doing procedural generation or other weirdness!
		 * 
		 * @param	Force	Force the frame to redraw, even if its not flagged as necessary.
		 */
		public function drawFrame(Force:Boolean=false):void
		{
			if(Force || dirty)
				calcFrame();
		}
		
		/**
		 * Adds a new animation to the sprite.
		 * 
		 * @param	Name		What this animation should be called (e.g. "run").
		 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
		 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
		 * @param	Looped		Whether or not the animation is looped or just plays once.
		 */
		public function addAnimation(Name:String, Frames:Array, FrameRate:Number=0, Looped:Boolean=true):void
		{
			_animations.push(new FlxAnim(Name,Frames,FrameRate,Looped));
		}
		
		/**
		 * Pass in a function to be called whenever this sprite's animation changes.
		 * 
		 * @param	AnimationCallback		A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
		 */
		public function addAnimationCallback(AnimationCallback:Function):void
		{
			_callback = AnimationCallback;
		}
		
		/**
		 * Plays an existing animation (e.g. "run").
		 * If you call an animation that is already playing it will be ignored.
		 * 
		 * @param	AnimName	The string name of the animation you want to play.
		 * @param	Force		Whether to force the animation to restart.
		 */
		public function play(AnimName:String,Force:Boolean=false):void
		{
			if(!Force && (_curAnim != null) && (AnimName == _curAnim.name) && (_curAnim.looped || !finished)) return;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;
			var i:uint = 0;
			var al:uint = _animations.length;
			while(i < al)
			{
				if(_animations[i].name == AnimName)
				{
					_curAnim = _animations[i];
					if(_curAnim.delay <= 0)
						finished = true;
					else
						finished = false;
					_caf = _curAnim.frames[_curFrame];
					dirty = true;
					return;
				}
				i++;
			}
			FlxG.log("WARNING: No animation called \""+AnimName+"\"");
		}
		
		/**
		 * Tell the sprite to change to a random frame of animation
		 * Useful for instantiating particles or other weird things.
		 */
		public function randomFrame():void
		{
			_curAnim = null;
			_caf = int(FlxG.random()*(_pixels.width/frameWidth));
			dirty = true;
		}
		
		/**
		 * Helper function that just sets origin to (0,0)
		 */
		public function setOriginToCorner():void
		{
			origin.x = origin.y = 0;
		}
		
		/**
		 * Helper function that adjusts the offset automatically to center the bounding box within the graphic.
		 * 
		 * @param	AdjustPosition		Adjusts the actual X and Y position just once to match the offset change. Default is false.
		 */
		public function centerOffsets(AdjustPosition:Boolean=false):void
		{
			offset.x = (frameWidth-width)*0.5;
			offset.y = (frameHeight-height)*0.5;
			if(AdjustPosition)
			{
				x += offset.x;
				y += offset.y;
			}
		}
		
		/**
		 * Set <code>pixels</code> to any <code>BitmapData</code> object.
		 * Automatically adjust graphic size and render helpers.
		 */
		public function get pixels():BitmapData
		{
			return _pixels;
		}
		
		/**
		 * @private
		 */
		public function set pixels(Pixels:BitmapData):void
		{
			_pixels = Pixels;
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
		}
		
		/**
		 * Set <code>facing</code> using <code>FlxSprite.LEFT</code>,<code>RIGHT</code>,
		 * <code>UP</code>, and <code>DOWN</code> to take advantage of
		 * flipped sprites and/or just track player orientation more easily.
		 */
		public function get facing():uint
		{
			return _facing;
		}
		
		/**
		 * @private
		 */
		public function set facing(Direction:uint):void
		{
			if(_facing != Direction)
				dirty = true;
			_facing = Direction;
		}
		
		/**
		 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
		 */
		public function get alpha():Number
		{
			return _alpha;
		}
		
		override public function get boundingX():Number
		{
			return x - offset.x;
		}
		
		override public function get boundingY():Number
		{
			return y - offset.y;
		}
		
		/**
		 * @private
		 */
		public function set alpha(Alpha:Number):void
		{
			if(Alpha > 1)
				Alpha = 1;
			if(Alpha < 0)
				Alpha = 0;
			if(Alpha == _alpha)
				return;
			_alpha = Alpha;
			if((_alpha != 1) || (_color != 0x00ffffff))
				_ct = new ColorTransform((_color>>16)*0.00392,(_color>>8&0xff)*0.00392,(_color&0xff)*0.00392,_alpha);
			else
				_ct = null;
			dirty = true;
		}
		
		/**
		 * Set <code>color</code> to a number in this format: 0xRRGGBB.
		 * <code>color</code> IGNORES ALPHA.  To change the opacity use <code>alpha</code>.
		 * Tints the whole sprite to be this color (similar to OpenGL vertex colors).
		 */
		public function get color():uint
		{
			return _color;
		}
		
		/**
		 * @private
		 */
		public function set color(Color:uint):void
		{
			Color &= 0x00ffffff;
			if(_color == Color)
				return;
			_color = Color;
			if((_alpha != 1) || (_color != 0x00ffffff))
				_ct = new ColorTransform((_color>>16)*0.00392,(_color>>8&0xff)*0.00392,(_color&0xff)*0.00392,_alpha);
			else
				_ct = null;
			dirty = true;
		}
		
		/**
		 * Tell the sprite to change to a specific frame of animation.
		 * 
		 * @param	Frame	The frame you want to display.
		 */
		public function get frame():uint
		{
			return _caf;
		}
		
		/**
		 * @private
		 */
		public function set frame(Frame:uint):void
		{
			_curAnim = null;
			_caf = Frame;
			dirty = true;
		}
		
		/**
		 * Check and see if this object is currently on screen.
		 * Differs from <code>FlxObject</code>'s implementation
		 * in that it takes the actual graphic into account,
		 * not just the hitbox or bounding box or whatever.
		 * 
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * 
		 * @return	Whether the object is on screen or not.
		 */
		override public function onScreen(Camera:FlxCamera=null):Boolean
		{
			if(Camera == null)
				Camera = FlxG.camera;
			getScreenXY(_point,Camera);
			_point.x = _point.x - offset.x;
			_point.y = _point.y - offset.y;

			if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1))
				return ((_point.x + frameWidth > 0) && (_point.x < Camera.width) && (_point.y + frameHeight > 0) && (_point.y < Camera.height));
			
			var hw:Number = frameWidth/2;
			var hh:Number = frameHeight/2;
			var absScaleX:Number = (scale.x>0)?scale.x:-scale.x;
			var absScaleY:Number = (scale.y>0)?scale.y:-scale.y;
			var radius:Number = Math.sqrt(hw*hw+hh*hh)*((absScaleX >= absScaleY)?absScaleX:absScaleY);
			_point.x += hw;
			_point.y += hh;
			return ((_point.x + radius > 0) && (_point.x - radius < Camera.width) && (_point.y + radius > 0) && (_point.y - radius < Camera.height));
		}
		
		/**
		 * Checks to see if a point in 2D world space overlaps this <code>FlxSprite</code> object's current displayed pixels.
		 * This check is ALWAYS made in screen space, and always takes scroll factors into account.
		 * 
		 * @param	Point		The point in world space you want to check.
		 * @param	Mask		Used in the pixel hit test to determine what counts as solid.
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		public function pixelsOverlapPoint(Point:FlxPoint,Mask:uint=0xFF,Camera:FlxCamera=null):Boolean
		{
			if(Camera == null)
				Camera = FlxG.camera;
			getScreenXY(_point,Camera);
			_point.x = _point.x - offset.x;
			_point.y = _point.y - offset.y;
			_flashPoint.x = (Point.x - Camera.scroll.x) - _point.x;
			_flashPoint.y = (Point.y - Camera.scroll.y) - _point.y;
			return framePixels.hitTest(_flashPointZero,Mask,_flashPoint);
		}
		
		/**
		 * Internal function to update the current animation frame.
		 */
		protected function calcFrame():void
		{
			var rx:uint = _caf*frameWidth;
			var ry:uint = 0;

			//Handle sprite sheets
			var w:uint = _flipped?_flipped:_pixels.width;
			if(rx >= w)
			{
				ry = uint(rx/w)*frameHeight;
				rx %= w;
			}
			
			//handle reversed sprites
			if(_flipped && (_facing == LEFT))
				rx = (_flipped<<1)-rx-frameWidth;
			
			//Update display bitmap
			_flashRect.x = rx;
			_flashRect.y = ry;
			framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			_flashRect.x = _flashRect.y = 0;
			if(_ct != null)
				framePixels.colorTransform(_flashRect,_ct);
			if(_callback != null)
				_callback(((_curAnim != null)?(_curAnim.name):null),_curFrame,_caf);
			dirty = false;
		}
	}
}
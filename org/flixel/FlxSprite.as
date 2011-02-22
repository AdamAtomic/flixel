package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.data.FlxAnim;
	
	/**
	* The main "game object" class, handles basic physics and animation.
	*/
	public class FlxSprite extends FlxObject
	{
		/**
		 * Useful for controlling flipped animations and checking player orientation.
		 */
		static public const LEFT:uint = 0;
		/**
		 * Useful for controlling flipped animations and checking player orientation.
		 */
		static public const RIGHT:uint = 1;
		/**
		 * Useful for checking player orientation.
		 */
		static public const UP:uint = 2;
		/**
		 * Useful for checking player orientation.
		 */
		static public const DOWN:uint = 3;
		 
		/**
		* If you changed the size of your sprite object to shrink the bounding box,
		* you might need to offset the new bounding box from the top-left corner of the sprite.
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
		 * Blending modes, just like Photoshop!
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
		
		//Animation helpers
		protected var _animations:Array;
		protected var _flipped:uint;
		protected var _curAnim:FlxAnim;
		protected var _curFrame:uint;
		protected var _caf:uint;
		protected var _frameTimer:Number;
		protected var _callback:Function;
		protected var _facing:uint;
		protected var _bakedRotation:Number;
		
		//Various rendering helpers
		protected var _flashRect:Rectangle;
		protected var _flashRect2:Rectangle;
		protected var _flashPointZero:Point;
		protected var _pixels:BitmapData;
		protected var _framePixels:BitmapData;
		protected var _alpha:Number;
		protected var _color:uint;
		protected var _ct:ColorTransform;
		protected var _mtx:Matrix;
		protected var _bbb:BitmapData;
		
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
			super();
			x = X;
			y = Y;

			_flashRect = new Rectangle();
			_flashRect2 = new Rectangle();
			_flashPointZero = new Point();
			offset = new FlxPoint();
			
			scale = new FlxPoint(1,1);
			_alpha = 1;
			_color = 0x00ffffff;
			blend = null;
			antialiasing = false;
			
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
				createGraphic(8,8);
			else
				loadGraphic(SimpleGraphic);
		}
		
		/**
		 * Load an image from an embedded graphic file.
		 * 
		 * @param	Graphic		The image you want to use.
		 * @param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites.
		 * @param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames.
		 * @param	Width		OPTIONAL - Specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Height		OPTIONAL - Specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets).
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
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
					Width = _pixels.width/2;
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
		 * @param	Graphic			The image you want to rotate & stamp.
		 * @param	Frames			The number of frames you want to use (more == smoother rotations).
		 * @param	Offset			Use this to select a specific frame to draw from the graphic.
		 * @param	AntiAliasing	Whether to use high quality rotations when creating the graphic.
		 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.
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
			
			//Generate a new sheet if necessary, then fix up the width & height
			if(!skipGen)
			{
				var r:uint;
				var c:uint;
				var ba:Number = 0;
				var bw2:uint = brush.width/2;
				var bh2:uint = brush.height/2;
				var gxc:uint = max/2;
				var gyc:uint = max/2;
				for(r = 0; r < rows; r++)
				{
					for(c = 0; c < cols; c++)
					{
						_mtx.identity();
						_mtx.translate(-bw2,-bh2);
						_mtx.rotate(Math.PI * 2 * (ba / 360));
						_mtx.translate(max*c+gxc, gyc);
						ba += _bakedRotation;
						_pixels.draw(brush,_mtx,null,null,null,AntiAliasing);
					}
					gyc += max;
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
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
		 * @param	Key			Optional parameter - specify a string key to identify this graphic in the cache.  Trumps Unique flag.
		 * 
		 * @return	This FlxSprite instance (nice for chaining stuff together, if you're into that).
		 */
		public function createGraphic(Width:uint,Height:uint,Color:uint=0xffffffff,Unique:Boolean=false,Key:String=null):FlxSprite
		{
			_bakedRotation = 0;
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique,Key);
			width = frameWidth = _pixels.width;
			height = frameHeight = _pixels.height;
			resetHelpers();
			return this;
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
			if((_framePixels == null) || (_framePixels.width != width) || (_framePixels.height != height))
				_framePixels = new BitmapData(width,height);
			if((_bbb == null) || (_bbb.width != width) || (_bbb.height != height))
				_bbb = new BitmapData(width,height);
			origin.x = frameWidth/2;
			origin.y = frameHeight/2;
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			if(FlxG.showBounds)
				drawBounds();
			_caf = 0;
			refreshHulls();
		}
		
		/**
		 * @private
		 */
		override public function set solid(Solid:Boolean):void
		{
			var os:Boolean = _solid;
			_solid = Solid;
			if((os != _solid) && FlxG.showBounds)
				calcFrame();
		}
		
		/**
		 * @private
		 */
		override public function set fixed(Fixed:Boolean):void
		{
			var of:Boolean = _fixed;
			_fixed = Fixed;
			if((of != _fixed) && FlxG.showBounds)
				calcFrame();
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
			var c:Boolean = _facing != Direction;
			_facing = Direction;
			if(c) calcFrame();
		}
		
		/**
		 * Set <code>alpha</code> to a number between 0 and 1 to change the opacity of the sprite.
		 */
		public function get alpha():Number
		{
			return _alpha;
		}
		
		/**
		 * @private
		 */
		public function set alpha(Alpha:Number):void
		{
			if(Alpha > 1) Alpha = 1;
			if(Alpha < 0) Alpha = 0;
			if(Alpha == _alpha) return;
			_alpha = Alpha;
			if((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform(Number(_color>>16)/255,Number(_color>>8&0xff)/255,Number(_color&0xff)/255,_alpha);
			else _ct = null;
			calcFrame();
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
			if(_color == Color) return;
			_color = Color;
			if((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform(Number(_color>>16)/255,Number(_color>>8&0xff)/255,Number(_color&0xff)/255,_alpha);
			else _ct = null;
			calcFrame();
		}
		

		/**
		 * This function draws or stamps one <code>FlxSprite</code> onto another.
		 * This function is NOT intended to replace <code>render()</code>!
		 * 
		 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
		 * @param	X			The X coordinate of the brush's top left corner on this sprite.
		 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
		 */
		public function draw(Brush:FlxSprite,X:int=0,Y:int=0):void
		{
			var b:BitmapData = Brush._framePixels;
			
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
			if(Brush.angle != 0) _mtx.rotate(Math.PI * 2 * (Brush.angle / 360));
			_mtx.translate(X+Brush.origin.x,Y+Brush.origin.y);
			_pixels.draw(b,_mtx,null,Brush.blend,null,Brush.antialiasing);
			calcFrame();
		}
		
		/**
		 * Fills this sprite's graphic with a specific color.
		 * 
		 * @param	Color		The color with which to fill the graphic, format 0xAARRGGBB.
		 */
		public function fill(Color:uint):void
		{
			_pixels.fillRect(_flashRect2,Color);
			if(_pixels != _framePixels)
				calcFrame();
		}
		
		/**
		 * Internal function for updating the sprite's animation.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 * This function is called automatically by <code>FlxSprite.update()</code>.
		 */
		protected function updateAnimation():void
		{
			if(_bakedRotation)
			{
				var oc:uint = _caf;
				var ta:int = angle%360;
				if(ta < 0)
					ta += 360;
				_caf = ta/_bakedRotation;
				if(oc != _caf)
					calcFrame();
				return;
			}
			if((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !finished))
			{
				_frameTimer += FlxG.elapsed;
				if(_frameTimer > _curAnim.delay)
				{
					_frameTimer -= _curAnim.delay;
					if(_curFrame == _curAnim.frames.length-1)
					{
						if(_curAnim.looped) _curFrame = 0;
						finished = true;
					}
					else
						_curFrame++;
					_caf = _curAnim.frames[_curFrame];
					calcFrame();
				}
			}
		}
		
		/**
		 * Main game loop update function.  Override this to create your own sprite logic!
		 * Just don't forget to call super.update() or any of the helper functions.
		 */
		override public function update():void
		{
			updateMotion();
			updateAnimation();
			updateFlickering();
		}
		
		/**
		 * Internal function that performs the actual sprite rendering, called by render().
		 */
		protected function renderSprite():void
		{
			if(_refreshBounds)
				calcFrame();
			
			getScreenXY(_point);
			_flashPoint.x = _point.x;
			_flashPoint.y = _point.y;
			
			//Simple render
			if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null))
			{
				FlxG.buffer.copyPixels(_framePixels,_flashRect,_flashPoint,null,null,true);
				return;
			}
			
			//Advanced render
			_mtx.identity();
			_mtx.translate(-origin.x,-origin.y);
			_mtx.scale(scale.x,scale.y);
			if(angle != 0) _mtx.rotate(Math.PI * 2 * (angle / 360));
			_mtx.translate(_point.x+origin.x,_point.y+origin.y);
			FlxG.buffer.draw(_framePixels,_mtx,null,blend,null,antialiasing);
		}
		
		/**
		 * Called by game loop, updates then blits or renders current frame of animation to the screen
		 */
		override public function render():void
		{
			renderSprite();
		}
		
		/**
		 * Checks to see if a point in 2D space overlaps this FlxCore object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	PerPixel	Whether or not to use per pixel collision checking.
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		override public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			X -= FlxU.floor(FlxG.scroll.x);
			Y -= FlxU.floor(FlxG.scroll.y);
			getScreenXY(_point);
			if(PerPixel)
				return _framePixels.hitTest(new Point(0,0),0xFF,new Point(X-_point.x,Y-_point.y));
			else if((X <= _point.x) || (X >= _point.x+frameWidth) || (Y <= _point.y) || (Y >= _point.y+frameHeight))
				return false;
			return true;
		}
		
		/**
		 * Triggered whenever this sprite is launched by a <code>FlxEmitter</code>.
		 */
		virtual public function onEmit():void { }
		
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
			if(!Force && (_curAnim != null) && (AnimName == _curAnim.name)) return;
			_curFrame = 0;
			_caf = 0;
			_frameTimer = 0;
			var al:uint = _animations.length;
			for(var i:uint = 0; i < al; i++)
			{
				if(_animations[i].name == AnimName)
				{
					_curAnim = _animations[i];
					if(_curAnim.delay <= 0)
						finished = true;
					else
						finished = false;
					_caf = _curAnim.frames[_curFrame];
					calcFrame();
					return;
				}
			}
		}

		/**
		 * Tell the sprite to change to a random frame of animation
		 * Useful for instantiating particles or other weird things.
		 */
		public function randomFrame():void
		{
			_curAnim = null;
			_caf = int(FlxU.random()*(_pixels.width/frameWidth));
			calcFrame();
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
			calcFrame();
		}
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	P	Takes a <code>Point</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		override public function getScreenXY(Point:FlxPoint=null):FlxPoint
		{
			if(Point == null) Point = new FlxPoint();
			Point.x = FlxU.floor(x + FlxU.roundingError)+FlxU.floor(FlxG.scroll.x*scrollFactor.x) - offset.x;
			Point.y = FlxU.floor(y + FlxU.roundingError)+FlxU.floor(FlxG.scroll.y*scrollFactor.y) - offset.y;
			return Point;
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
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			_flashRect.x = _flashRect.y = 0;
			if(_ct != null) _framePixels.colorTransform(_flashRect,_ct);
			if(FlxG.showBounds)
				drawBounds();
			if(_callback != null) _callback(_curAnim.name,_curFrame,_caf);
		}
		
		protected function drawBounds():void
		{
			var bbbc:uint = getBoundingColor();
			_bbb.fillRect(_flashRect,0);
			var ofrw:uint = _flashRect.width;
			var ofrh:uint = _flashRect.height;
			_flashRect.width = width;
			_flashRect.height = height;
			_flashRect.x = int(offset.x);
			_flashRect.y = int(offset.y);
			_bbb.fillRect(_flashRect,bbbc);
			_flashRect.width -= 2;
			_flashRect.height -= 2;
			_flashRect.x++;
			_flashRect.y++;
			_bbb.fillRect(_flashRect,0);
			_flashRect.width = ofrw;
			_flashRect.height = ofrh;
			_flashRect.x = _flashRect.y = 0;
			_framePixels.copyPixels(_bbb,_flashRect,_flashPointZero,null,null,true);
		}
		
		/**
		 * Internal function, currently only used to quickly update FlxState.screen for post-processing.
		 * Potentially super-unsafe, since it doesn't call <code>resetHelpers()</code>!
		 * 
		 * @param	Pixels		The <code>BitmapData</code> object you want to point at.
		 */
		internal function unsafeBind(Pixels:BitmapData):void
		{
			_pixels = _framePixels = Pixels;
		}
	}
}
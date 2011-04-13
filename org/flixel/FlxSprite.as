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
	* The main "game object" class, handles basic physics and animation.
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
		/**
		 * The total number of frames in this image (assumes each row is full).
		 */
		public var frames:uint;
		/**
		 * Set this flag to true to force the sprite to update during the draw() call.
		 * NOTE: Rarely if ever necessary, most sprite operations will flip this flag automatically.
		 */
		public var dirty:Boolean;
		
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
		protected var _flashPoint:Point;
		protected var _flashRect:Rectangle;
		protected var _flashRect2:Rectangle;
		protected var _flashPointZero:Point;
		protected var _pixels:BitmapData;
		protected var _framePixels:BitmapData;
		protected var _alpha:Number;
		protected var _color:uint;
		protected var _ct:ColorTransform;
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
			
			scale = new FlxPoint(1,1);
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
			_framePixels = null;
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
		 * @param	Unique		Whether the graphic should be a unique instance in the graphics cache.
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
			if((_framePixels == null) || (_framePixels.width != width) || (_framePixels.height != height))
				_framePixels = new BitmapData(width,height);
			origin.make(frameWidth*0.5,frameHeight*0.5);
			_framePixels.copyPixels(_pixels,_flashRect,_flashPointZero);
			frames = (_flashRect2.width / _flashRect.width) * (_flashRect2.height / _flashRect.height);
			if(_ct != null) _framePixels.colorTransform(_flashRect,_ct);
			_caf = 0;
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
		 * This function draws or stamps one <code>FlxSprite</code> onto another.
		 * This function is NOT intended to replace <code>render()</code>!
		 * 
		 * @param	Brush		The image you want to use as a brush or stamp or pen or whatever.
		 * @param	X			The X coordinate of the brush's top left corner on this sprite.
		 * @param	Y			They Y coordinate of the brush's top left corner on this sprite.
		 */
		public function stamp(Brush:FlxSprite,X:int=0,Y:int=0):void
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
			if(_pixels != _framePixels)
				dirty = true;
		}
		
		/**
		 * Internal function for updating the sprite's animation.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 * This function is called automatically by <code>FlxSprite.update()</code>.
		 */
		protected function updateAnimation():void
		{
			if(_bakedRotation > 0)
			{
				var oc:uint = _caf;
				var ta:int = angle%360;
				if(ta < 0)
					ta += 360;
				_caf = ta/_bakedRotation;
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
						if(_curAnim.looped) _curFrame = 0;
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
				_point.x = x - int(c.scroll.x*scrollFactor.x) - offset.x + 0.0000001; //copied from getScreenXY()
				_point.y = y - int(c.scroll.y*scrollFactor.y) - offset.y + 0.0000001;
				if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1) && (blend == null))
				{	//Simple render
					_flashPoint.x = _point.x;
					_flashPoint.y = _point.y;
					c.buffer.copyPixels(_framePixels,_flashRect,_flashPoint,null,null,true);
				}
				else
				{	//Advanced render
					_mtx.identity();
					_mtx.translate(-origin.x,-origin.y);
					_mtx.scale(scale.x,scale.y);
					if((angle != 0) && (_bakedRotation <= 0))
						_mtx.rotate(angle * 0.017453293);
					_mtx.translate(_point.x+origin.x,_point.y+origin.y);
					c.buffer.draw(_framePixels,_mtx,null,blend,null,antialiasing);
				}
				_VISIBLECOUNT++;
				if(FlxG.visualDebug)
					drawDebug(c);
			}
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
		 * Checks to see if a point in 2D world space overlaps this FlxCore object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * @param	PerPixel	Whether or not to use per pixel collision checking.
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		override public function overlapsPoint(X:Number,Y:Number,Camera:FlxCamera=null,PerPixel:Boolean = false):Boolean
		{
			if(Camera == null)
				Camera = FlxG.camera;
			
			//convert the passed in point to screen space
			X = X - Camera.scroll.x;
			Y = Y - Camera.scroll.y;
			
			//then compare
			_point.x = x - int(Camera.scroll.x*scrollFactor.x) - offset.x + 0.0000001; //copied from getScreenXY()
			_point.y = y - int(Camera.scroll.y*scrollFactor.y) - offset.y + 0.0000001;
			if(PerPixel)
				return _framePixels.hitTest(new Point(0,0),0xFF,new Point(X-_point.x,Y-_point.y));
			return (X > _point.x) && (X < _point.x+frameWidth) && (Y > _point.y) && (Y < _point.y+frameHeight);
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
		
		public function corner():void
		{
			origin.x = origin.y = 0;
		}
		
		/**
		 * Reduces the "health" variable of this sprite by the amount specified in Damage.
		 * Calls kill() if health drops to or below zero.
		 * 
		 * @param	Damage		How much health to take away (use a negative number to give a health bonus).
		 */
		public function hurt(Damage:Number):void
		{
			health = health - Damage;
			if(health <= 0)
				kill();
		}
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * @param	P	Takes a <code>Point</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		override public function getScreenXY(Point:FlxPoint=null,Camera:FlxCamera=null):FlxPoint
		{
			if(Point == null)
				Point = new FlxPoint();
			if(Camera == null)
				Camera = FlxG.camera;
			_point.x = x - int(Camera.scroll.x*scrollFactor.x) - offset.x + 0.0000001; //copied from getScreenXY()
			_point.y = y - int(Camera.scroll.y*scrollFactor.y) - offset.y + 0.0000001;
			return Point;
		}
		
		/**
		 * Check and see if this object is currently on screen.
		 * 
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * 
		 * @return	Whether the object is on screen or not.
		 */
		override public function onScreen(Camera:FlxCamera=null):Boolean
		{
			if(Camera == null)
				Camera = FlxG.camera;
			_point.x = x - int(Camera.scroll.x*scrollFactor.x) - offset.x + 0.0000001; //copied from getScreenXY()
			_point.y = y - int(Camera.scroll.y*scrollFactor.y) - offset.y + 0.0000001;
			if(((angle == 0) || (_bakedRotation > 0)) && (scale.x == 1) && (scale.y == 1))
			{
				return ((_point.x + frameWidth > 0) && (_point.x < Camera.width) && (_point.y + frameHeight > 0) && (_point.y < Camera.height));
			}
			else
			{
				var hw:Number = width/2;
				var hh:Number = height/2;
				var radius:Number = Math.sqrt(hw*hw+hh*hh)*((scale.x >= scale.y)?scale.x:scale.y);
				_point.x += hw;
				_point.y += hh;
				return ((_point.x + radius > 0) && (_point.x - radius < Camera.width) && (_point.y + radius > 0) && (_point.y - radius < Camera.height));
			}
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
			if(_callback != null) _callback(_curAnim.name,_curFrame,_caf);
			dirty = false;
		}
	}
}
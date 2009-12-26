package org.flixel
{
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import org.flixel.data.FlxAnim;
	
	//@desc		The main "game object" class, handles basic physics and animation
	public class FlxSprite extends FlxCore
	{
		static public const LEFT:uint = 0;
		static public const RIGHT:uint = 1;
		static public const UP:uint = 2;
		static public const DOWN:uint = 3;
		static protected const _pZero:Point = new Point();
		
		//@desc If you changed the size of your sprite object to shrink the bounding box, you might need to offset the new bounding box from the top-left corner of the sprite
		public var offset:Point;
		public var velocity:Point;
		public var acceleration:Point;
		//@desc	This isn't drag exactly, more like deceleration that is only applied when acceleration is not affecting the sprite
		public var drag:Point;
		public var maxVelocity:Point;
		//@desc WARNING: rotating sprites decreases rendering performance for this sprite by a factor of 10x!
		public var angle:Number;
		public var angularVelocity:Number;
		public var angularAcceleration:Number;
		public var angularDrag:Number;
		public var maxAngular:Number;
		//@desc	The origin of the sprite will default to its center - if you change this, the visuals and the collisions will likely be pretty out-of-sync!  Just a heads up.
		public var origin:Point;
		//@desc	If you want to do Asteroids style stuff, check out thrust (instead of directly accessing the object's velocity or acceleration)
		public var thrust:Number;
		public var maxThrust:Number;
		public var health:Number;
		//@desc	Scale doesn't currently affect collisions automatically, you will need to adjust the width, height and offset manually.  WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
		public var scale:Point;
		public var blend:String;
		//@desc	Controls whether the object is smoothed when rotated, affects performance, off by default
		public var antialiasing:Boolean;
		
		//@desc	Whether the current animation has finished its first (or only) loop
		public var finished:Boolean;
		protected var _animations:Array;
		protected var _flipped:uint;
		protected var _curAnim:FlxAnim;
		protected var _curFrame:uint;
		protected var _caf:uint;
		protected var _frameTimer:Number;
		protected var _callback:Function;
		protected var _facing:uint;
		
		//helpers
		protected var _bw:uint;
		protected var _bh:uint;
		protected var _r:Rectangle;
		protected var _r2:Rectangle;
		protected var _p:Point;
		protected var _pixels:BitmapData;
		protected var _framePixels:BitmapData;
		protected var _alpha:Number;
		protected var _color:uint;
		protected var _ct:ColorTransform;
		protected var _mtx:Matrix;
		
		//@desc		Constructor
		//@param	X				The initial X position of the sprite
		//@param	Y				The initial Y position of the sprite
		//@param	SimpleGraphic	The graphic you want to display (OPTIONAL - for simple stuff only, do NOT use for animated images!)
		public function FlxSprite(X:int=0,Y:int=0,SimpleGraphic:Class=null)
		{
			super();
			
			last.x = x = X;
			last.y = y = Y;
			_p = new Point();
			_r = new Rectangle();
			_r2 = new Rectangle();
			origin = new Point();
			if(SimpleGraphic == null)
				createGraphic(8,8);
			else
				loadGraphic(SimpleGraphic);
			offset = new Point();
			
			velocity = new Point();
			acceleration = new Point();
			drag = new Point();
			maxVelocity = new Point(10000,10000);
			
			angle = 0;
			angularVelocity = 0;
			angularAcceleration = 0;
			angularDrag = 0;
			maxAngular = 10000;
			
			thrust = 0;
			
			scale = new Point(1,1);
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
			health = 1;
			_callback = null;
		}
		
		//@desc		Load an image from an embedded graphic file
		//@param	Graphic		The image you want to use
		//@param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites
		//@param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames
		//@param	Width		OPTIONAL - Specify the width of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets)
		//@param	Height		OPTIONAL - Specify the height of your sprite (helps FlxSprite figure out what to do with non-square sprites or sprite sheets)
		//@param	Unique		Whether the graphic should be a unique instance in the graphics cache
		//@return	This FlxSprite instance (nice for chaining stuff together, if you're into that)
		public function loadGraphic(Graphic:Class,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Unique:Boolean=false):FlxSprite
		{
			_pixels = FlxG.addBitmap(Graphic,Reverse);
			if(Reverse)
				_flipped = _pixels.width>>1;
			else
				_flipped = 0;
			if(Width == 0)
			{
				if(Animated)
					Width = _pixels.height;
				else
					Width = _pixels.width;
			}
			width = _bw = Width;
			if(Height == 0)
			{
				if(Animated)
					Height = width;
				else
					Height = _pixels.height;
			}
			height = _bh = Height;
			resetHelpers();
			return this;
		}
		
		//@desc		This function creates a flat colored square image dynamically
		//@param	Width		The width of the sprite you want to generate 
		//@param	Height		The height of the sprite you want to generate
		//@param	Color		Specifies the color of the generated block
		//@param	Unique		Whether the graphic should be a unique instance in the graphics cache
		//@return	This FlxSprite instance (nice for chaining stuff together, if you're into that)
		public function createGraphic(Width:uint,Height:uint,Color:uint=0xffffffff,Unique:Boolean=false):FlxSprite
		{
			_pixels = FlxG.createBitmap(Width,Height,Color,Unique);
			width = _bw = _pixels.width;
			height = _bh = _pixels.height;
			resetHelpers();
			return this;
		}
		
		//@desc		This function allows you to set the bitmap data directly, instead of loading it through FlxG
		//@param	Pixels		A flash BitmapData object containing preloaded graphic information
		public function set pixels(Pixels:BitmapData):void
		{
			_pixels = Pixels;
			width = _bw = _pixels.width;
			height = _bh = _pixels.height;
			resetHelpers();
		}
		
		//@desc		This function retrieves the reference bitmap data that powers this graphic
		//@return	A flash BitmapData object
		public function get pixels():BitmapData
		{
			return _pixels;
		}
		
		//@desc		Just resets some important background variables for sprite display
		protected function resetHelpers():void
		{
			_r.x = 0;
			_r.y = 0;
			_r.width = _bw;
			_r.height = _bh;
			_r2.x = 0;
			_r2.y = 0;
			_r2.width = _pixels.width;
			_r2.height = _pixels.height;
			if((_framePixels == null) || (_framePixels.width != width) || (_framePixels.height != height))
				_framePixels = new BitmapData(width,height);
			origin.x = _bw/2;
			origin.y = _bh/2;
			_framePixels.copyPixels(_pixels,_r,_pZero);
		}
		
		//@desc		Called by game loop, handles animation and physics
		override public function update():void
		{
			super.update();
			
			if(!active) return;
			
			//animation
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
			
			//motion + physics
			angle += (angularVelocity = FlxG.computeVelocity(angularVelocity,angularAcceleration,angularDrag,maxAngular))*FlxG.elapsed;
			var thrustComponents:Point;
			if(thrust != 0)
			{
				thrustComponents = FlxG.rotatePoint(-thrust,0,0,0,angle);
				var maxComponents:Point = FlxG.rotatePoint(-maxThrust,0,0,0,angle);
				var max:Number = Math.abs(maxComponents.x);
				if(max > Math.abs(maxComponents.y))
					maxComponents.y = max;
				else
					max = Math.abs(maxComponents.y);
				maxVelocity.x = Math.abs(max);
				maxVelocity.y = Math.abs(max);
			}
			else
				thrustComponents = _pZero;
			x += (velocity.x = FlxG.computeVelocity(velocity.x,acceleration.x+thrustComponents.x,drag.x,maxVelocity.x))*FlxG.elapsed;
			y += (velocity.y = FlxG.computeVelocity(velocity.y,acceleration.y+thrustComponents.y,drag.y,maxVelocity.y))*FlxG.elapsed;
		}
		
		//@desc		Called by game loop, blits current frame of animation to the screen (and handles rotation)
		override public function render():void
		{
			if(!visible)
				return;
			getScreenXY(_p);
			
			//Simple render
			if((angle == 0) && (scale.x == 1) && (scale.y == 1) && (blend == null))
			{
				FlxG.buffer.copyPixels(_framePixels,_r,_p,null,null,true);
				return;
			}
			
			//Advanced render
			_mtx.identity();
			_mtx.translate(-origin.x,-origin.y);
			_mtx.scale(scale.x,scale.y);
			if(angle != 0) _mtx.rotate(Math.PI * 2 * (angle / 360));
			_mtx.translate(_p.x+origin.x,_p.y+origin.y);
			FlxG.buffer.draw(_framePixels,_mtx,null,blend,null,antialiasing);
		}
		
		//@desc		Checks to see if a point in 2D space overlaps this FlxCore object
		//@param	X			The X coordinate of the point
		//@param	Y			The Y coordinate of the point
		//@param	PerPixel	Whether or not to use per pixel collision checking
		//@return	Whether or not the point overlaps this object
		override public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			var tx:Number = x;
			var ty:Number = y;
			if((scrollFactor.x != 1) || (scrollFactor.y != 1))
			{
				tx -= Math.floor(FlxG.scroll.x*(1-scrollFactor.x));
				ty -= Math.floor(FlxG.scroll.y*(1-scrollFactor.y));
			}
			if(PerPixel)
				return _framePixels.hitTest(new Point(0,0),0xFF,new Point(X-tx,Y-ty));
			else if((X <= tx) || (X >= tx+width) || (Y <= ty) || (Y >= ty+height))
				return false;
			return true;
		}
		
		//@desc		Called when this object collides with a FlxBlock on one of its sides
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitWall(Contact:FlxCore=null):Boolean { velocity.x = 0; return true; }
		
		//@desc		Called when this object collides with the top of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitFloor(Contact:FlxCore=null):Boolean { velocity.y = 0; return true; }
		
		//@desc		Called when this object collides with the bottom of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitCeiling(Contact:FlxCore=null):Boolean { velocity.y = 0; return true; }
		
		//@desc		Call this function to "damage" (or give health bonus) to this sprite
		//@param	Damage		How much health to take away (use a negative number to give a health bonus)
		virtual public function hurt(Damage:Number):void
		{
			if((health -= Damage) <= 0)
				kill();
		}
		
		//@desc		Called if/when this sprite is launched by a FlxEmitter
		virtual public function onEmit():void { }
		
		//@desc		Adds a new animation to the sprite
		//@param	Name		What this animation should be called (e.g. "run")
		//@param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
		//@param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps)
		//@param	Looped		Whether or not the animation is looped or just plays once
		public function addAnimation(Name:String, Frames:Array, FrameRate:Number=0, Looped:Boolean=true):void
		{
			_animations.push(new FlxAnim(Name,Frames,FrameRate,Looped));
		}
		
		//@desc		Pass in a function to be called whenever this sprite's animation changes
		//@param	AnimationCallback		A function that has 3 parameters: a string name, a uint frame number, and a uint frame index
		public function addAnimationCallback(AnimationCallback:Function):void
		{
			_callback = AnimationCallback;
		}
		
		//@desc		Plays an existing animation (e.g. "run") - if you call an animation that is already playing it will be ignored
		//@param	AnimName	The string name of the animation you want to play
		//@param	Force		Whether to force the animation to restart
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
					finished = false;
					_curAnim = _animations[i];
					_caf = _curAnim.frames[_curFrame];
					calcFrame();
					return;
				}
			}
		}
		
		//@desc		Tell the sprite which way to face (you can just set 'facing' but this function also updates the animation instantly)
		//@param	Direction		See static const members RIGHT, LEFT, UP, and DOWN	
		public function set facing(Direction:uint):void
		{
			var c:Boolean = _facing != Direction;
			_facing = Direction;
			if(c) calcFrame();
		}
		
		//@desc		Get the direction the sprite is facing
		//@return	True means facing right, False means facing left (see static const members RIGHT and LEFT)
		public function get facing():uint
		{
			return _facing;
		}
		
		//@desc		Tell the sprite to change to a random frame of animation (useful for instantiating particles or other weird things)
		public function randomFrame():void
		{
			_curAnim = null;
			_caf = int(FlxG.random()*(_pixels.width/_bw));
			calcFrame();
		}
		
		//@desc		Tell the sprite to change to a specific frame of animation (useful for instantiating particles)
		//@param	Frame	The frame you want to display
		public function specificFrame(Frame:uint):void
		{
			_curAnim = null;
			_caf = Frame;
			calcFrame();
		}
		
		//@desc		Call this function to figure out the post-scrolling "screen" position of the object
		//@param	P	Takes a Flash Point object and assigns the post-scrolled X and Y values of this object to it
		override public function getScreenXY(P:Point):void
		{
			P.x = Math.floor(x-offset.x)+Math.floor(FlxG.scroll.x*scrollFactor.x);
			P.y = Math.floor(y-offset.y)+Math.floor(FlxG.scroll.y*scrollFactor.y);
		}
		
		//@desc		Internal function to update the current animation frame
		protected function calcFrame():void
		{
			var rx:uint = _caf*_bw;
			var ry:uint = 0;

			//Handle sprite sheets
			var w:uint = _flipped?_flipped:_pixels.width;
			if(rx >= w)
			{
				ry = uint(rx/w)*_bh;
				rx %= w;
			}
			
			//handle reversed sprites
			if(_flipped && (_facing == LEFT))
				rx = (_flipped<<1)-rx-_bw;
			
			//Update display bitmap
			_r.x = rx;
			_r.y = ry;
			_framePixels.copyPixels(_pixels,_r,_pZero);
			_r.x = _r.y = 0;
			if(_ct != null) _framePixels.colorTransform(_r,_ct);
			if(_callback != null) _callback(_curAnim.name,_curFrame,_caf);
		}
		
		//@desc		The setter for alpha
		//@param	Alpha	The new opacity value of the sprite (between 0 and 1)
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
		
		//@desc		The getter for alpha
		//@return	The value of this sprite's opacity
		public function get alpha():Number
		{
			return _alpha;
		}
		
		//@desc		The setter for color - tints the whole sprite this color (similar to Photoshop multiply)
		//@param	Color	The new color value of the sprite (0xRRGGBB) - ignores alpha
		public function set color(Color:uint):void
		{
			Color &= 0x00ffffff;
			if(_color == Color) return;
			_color = Color;
			if((_alpha != 1) || (_color != 0x00ffffff)) _ct = new ColorTransform(Number(_color>>16)/255,Number(_color>>8&0xff)/255,Number(_color&0xff)/255,_alpha);
			else _ct = null;
			calcFrame();
		}
		
		//@desc		The getter for color - tints the whole sprite this color (similar to Photoshop multiply)
		//@return	The color value of the sprite (0xRRGGBB) - ignores alpha
		public function get color():uint
		{
			return _color;
		}
		
		//@desc		This function draws or stamps one FlxSprite onto another (not intended to replace render()!)
		//@param	Brush		The image you want to use as a brush or stamp or pen or whatever
		//@param	X			The X coordinate of the brush's top left corner on this sprite
		//@param	Y			They Y coordinate of the brush's top left corner on this sprite
		public function draw(Brush:FlxSprite,X:int=0,Y:int=0):void
		{
			var b:BitmapData = Brush._framePixels;
			
			//Simple draw
			if((Brush.angle == 0) && (Brush.scale.x == 1) && (Brush.scale.y == 1) && (Brush.blend == null))
			{
				_p.x = X;
				_p.y = Y;
				_r2.width = b.width;
				_r2.height = b.height;
				_pixels.copyPixels(b,_r2,_p,null,null,true);
				_r2.width = _pixels.width;
				_r2.height = _pixels.height;
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
		
		//@desc		Fills this sprite's graphic with a specific color
		//@param	Color		The color with which to fill the graphic
		public function fill(Color:uint):void
		{
			_pixels.fillRect(_r2,Color);
			calcFrame();
		}
		
		//@desc		Internal function, currently only used to quickly update FlxState.screen for post-processing
		//@param	Pixels		The flash BitmapData object you want to point at
		internal function unsafeBind(Pixels:BitmapData):void
		{
			_pixels = _framePixels = Pixels;
		}
	}
}
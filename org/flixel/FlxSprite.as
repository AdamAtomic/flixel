package org.flixel
{
	import org.flixel.data.FlxAnim;
	
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	//@desc		The main "game object" class, handles basic physics and animation
	public class FlxSprite extends FlxCore
	{
		static public const LEFT:Boolean = false;
		static public const RIGHT:Boolean = true;
		
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
		//@desc	If you want to do Asteroids style stuff, check out thrust (instead of directly accessing the object's velocity or acceleration)
		public var thrust:Number;
		public var maxThrust:Number;
		public var health:Number;
		//@desc	Scale doesn't currently affect collisions automatically, you will need to adjust the width, height and offset manually.  WARNING: scaling sprites decreases rendering performance for this sprite by a factor of 10x!
		public var scale:Point;
		
		//@desc	Whether the current animation has finished its first (or only) loop
		public var finished:Boolean;
		private var _animations:FlxArray;
		private var _flipped:uint;
		protected var _curAnim:FlxAnim;
		protected var _curFrame:uint;
		private var _frameTimer:Number;
		private var _callback:Function;
		private var _facing:Boolean;
		
		//helpers
		private var _bw:uint;
		private var _bh:uint;
		private var _r:Rectangle;
		private var _p:Point;
		private var _pZero:Point;
		public var pixels:BitmapData;
		private var _pixels:BitmapData;
		private var _alpha:Number;
		
		//@desc		Constructor
		//@param	Graphic		The image you want to use
		//@param	X			The initial X position of the sprite
		//@param	Y			The initial Y position of the sprite
		//@param	Animated	Whether the Graphic parameter is a single sprite or a row of sprites
		//@param	Reverse		Whether you need this class to generate horizontally flipped versions of the animation frames
		//@param	Width		If you opt to NOT use an image and want to generate a colored block, or your sprite's frames are not square, you can specify a width here 
		//@param	Height		If you opt to NOT use an image you can specify the height of the colored block here (ignored if Graphic is not null)
		//@param	Color		Specifies the color of the generated block (ignored if Graphic is not null)
		public function FlxSprite(Graphic:Class=null,X:int=0,Y:int=0,Animated:Boolean=false,Reverse:Boolean=false,Width:uint=0,Height:uint=0,Color:uint=0)
		{
			super();

			if(Graphic == null)
				pixels = FlxG.createBitmap(Width,Height,Color);
			else
				pixels = FlxG.addBitmap(Graphic,Reverse);
				
			x = X;
			y = Y;
			if(Width == 0)
			{
				if(Animated)
					Width = pixels.height;
				else
					Width = pixels.width;
			}
			width = _bw = Width;
			height = _bh = pixels.height;
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
			
			finished = false;
			_facing = true;
			_animations = new FlxArray();
			if(Reverse)
				_flipped = pixels.width>>1;
			else
				_flipped = 0;
			_curAnim = null;
			_curFrame = 0;
			_frameTimer = 0;
			
			_p = new Point(x,y);
			_pZero = new Point();
			_r = new Rectangle(0,0,_bw,_bh);
			_pixels = new BitmapData(width,height);
			_pixels.copyPixels(pixels,_r,_pZero);
			
			health = 1;
			alpha = 1;
			
			_callback = null;
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
				maxVelocity.x = Math.abs(maxComponents.x);
				maxVelocity.y = Math.abs(maxComponents.y);
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
			if((angle != 0) || (scale.x != 1) || (scale.y != 1))
			{
				var mtx:Matrix = new Matrix();
				mtx.translate(-(_bw>>1),-(_bh>>1));
				mtx.scale(scale.x,scale.y);
				if(angle != 0) mtx.rotate(Math.PI * 2 * (angle / 360));
				mtx.translate(_p.x+(_bw>>1),_p.y+(_bh>>1));
				FlxG.buffer.draw(_pixels,mtx);
				return;
			}
			FlxG.buffer.copyPixels(_pixels,_r,_p,null,null,true);
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
				tx -= Math.floor(FlxG.scroll.x*scrollFactor.x);
				ty -= Math.floor(FlxG.scroll.y*scrollFactor.y);
			}
			if(PerPixel)
				return _pixels.hitTest(new Point(0,0),0xFF,new Point(X-tx,Y-ty));
			else if((X <= tx) || (X >= tx+width) || (Y <= ty) || (Y >= ty+height))
				return false;
			return true;
		}
		
		//@desc		Called when this object collides with a FlxBlock on one of its sides
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitWall():Boolean { velocity.x = 0; return true; }
		
		//@desc		Called when this object collides with the top of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitFloor():Boolean { velocity.y = 0; return true; }
		
		//@desc		Called when this object collides with the bottom of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		override public function hitCeiling():Boolean { velocity.y = 0; return true; }
		
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
			_animations.add(new FlxAnim(Name,Frames,FrameRate,Looped));
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
			_frameTimer = 0;
			for(var i:uint = 0; i < _animations.length; i++)
			{
				if(_animations[i].name == AnimName)
				{
					finished = false;
					_curAnim = _animations[i];
					calcFrame();
					return;
				}
			}
		}
		
		//@desc		Tell the sprite which way to face (you can just set 'facing' but this function also updates the animation instantly)
		//@param	Direction		True is Right, False is Left (see static const members RIGHT and LEFT)		
		public function set facing(Direction:Boolean):void
		{
			var c:Boolean = _facing != Direction;
			_facing = Direction;
			if(c) calcFrame();
		}
		
		//@desc		Get the direction the sprite is facing
		//@return	True means facing right, False means facing left (see static const members RIGHT and LEFT)
		public function get facing():Boolean
		{
			return _facing;
		}
		
		//@desc		Tell the sprite to change to a random frame of animation (useful for instantiating particles or other weird things)
		public function randomFrame():void
		{
			_pixels.copyPixels(pixels,new Rectangle(Math.floor(Math.random()*(pixels.width/_bw))*_bw,0,_bw,_bh),_pZero);
		}
		
		//@desc		Tell the sprite to change to a specific frame of animation (useful for instantiating particles)
		//@param	Frame	The frame you want to display
		public function specificFrame(Frame:uint):void
		{
			_pixels.copyPixels(pixels,new Rectangle(Frame*_bw,0,_bw,_bh),_pZero);
		}
		
		//@desc		Call this function to figure out the post-scrolling "screen" position of the object
		//@param	P	Takes a Flash Point object and assigns the post-scrolled X and Y values of this object to it
		override protected function getScreenXY(P:Point):void
		{
			P.x = Math.floor(x-offset.x)+Math.floor(FlxG.scroll.x*scrollFactor.x);
			P.y = Math.floor(y-offset.y)+Math.floor(FlxG.scroll.y*scrollFactor.y);
		}
		
		//@desc		Internal function to update the current animation frame
		private function calcFrame():void
		{
			var rx:uint;
			if(_curAnim == null)
				rx = 0;
			else
				rx = _curAnim.frames[_curFrame]*_bw;
			if(!_facing && (_flipped > 0))
				rx = (_flipped<<1)-rx-_bw;
			_pixels.copyPixels(pixels,new Rectangle(rx,0,_bw,_bh),_pZero);
			if(_alpha != 1) _pixels.colorTransform(_r,new ColorTransform(1,1,1,_alpha));
			if(_callback != null) _callback(_curAnim.name,_curFrame,_curAnim.frames[_curFrame]);
		}
		
		//@desc		The setter for alpha
		//@param	Alpha	The new opacity value of the sprite (between 0 and 1)
		public function set alpha(Alpha:Number):void
		{
			if(Alpha > 1) Alpha = 1;
			if(Alpha < 0) Alpha = 0;
			_alpha = Alpha;
			calcFrame();
		}
		
		//@desc		The getter for alpha
		//@return	The value of this sprite's opacity
		public function get alpha():Number
		{
			return _alpha;
		}
	}
}
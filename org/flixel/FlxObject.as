package org.flixel
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Point;
	
	import org.flixel.FlxBasic;
	
	/**
	 * This is the base class for most of the display objects (<code>FlxSprite</code>, <code>FlxText</code>, etc).
	 * It includes some basic attributes about game objects, including retro-style flickering,
	 * basic state information, sizes, scrolling, and basic physics and motion.
	 */
	public class FlxObject extends FlxBasic
	{
		static public const LEFT:uint	= 0x0001;
		static public const RIGHT:uint	= 0x0010;
		static public const UP:uint		= 0x0100;
		static public const DOWN:uint	= 0x1000;
		
		static public const NONE:uint	= 0;
		static public const CEILING:uint= UP;
		static public const FLOOR:uint	= DOWN;
		static public const WALL:uint	= LEFT | RIGHT;
		static public const ANY:uint	= LEFT | RIGHT | UP | DOWN;
		
		static public const OVERLAP_BIAS:Number = 4;
		
		static public const PATH_FORWARD:uint = 0;
		static public const PATH_BACKWARD:uint = 1;
		static public const PATH_LOOP_FORWARD:uint = 2;
		static public const PATH_LOOP_BACKWARD:uint = 3;
		static public const PATH_YOYO:uint = 4;
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;

		/**
		 * Whether an object will move/alter position after a collision.
		 */
		public var immovable:Boolean;
		
		/**
		 * The basic speed of this object.
		 */
		public var velocity:FlxPoint;
		public var mass:Number;
		public var elasticity:Number;
		/**
		 * How fast the speed of this object is changing.
		 * Useful for smooth movement and gravity.
		 */
		public var acceleration:FlxPoint;
		/**
		 * This isn't drag exactly, more like deceleration that is only applied
		 * when acceleration is not affecting the sprite.
		 */
		public var drag:FlxPoint;
		/**
		 * If you are using <code>acceleration</code>, you can use <code>maxVelocity</code> with it
		 * to cap the speed automatically (very useful!).
		 */
		public var maxVelocity:FlxPoint;
		/**
		 * Set the angle of a sprite to rotate it.
		 * WARNING: rotating sprites decreases rendering
		 * performance for this sprite by a factor of 10x!
		 */
		public var angle:Number;
		/**
		 * This is how fast you want this sprite to spin.
		 */
		public var angularVelocity:Number;
		/**
		 * How fast the spin speed should change.
		 */
		public var angularAcceleration:Number;
		/**
		 * Like <code>drag</code> but for spinning.
		 */
		public var angularDrag:Number;
		/**
		 * Use in conjunction with <code>angularAcceleration</code> for fluid spin speed control.
		 */
		public var maxAngular:Number;
		/**
		 * A handy "empty point" object
		 */
		static protected const _pZero:FlxPoint = new FlxPoint();
		
		/**
		 * A point that can store numbers from 0 to 1 (for X and Y independently)
		 * that governs how much this object is affected by the camera subsystem.
		 * 0 means it never moves, like a HUD element or far background graphic.
		 * 1 means it scrolls along a the same speed as the foreground layer.
		 * scrollFactor is initialized as (1,1) by default.
		 */
		public var scrollFactor:FlxPoint;
		/**
		 * Internal helper used for retro-style flickering.
		 */
		protected var _flicker:Boolean;
		/**
		 * Internal helper used for retro-style flickering.
		 */
		protected var _flickerTimer:Number;
		/**
		 * Handy for storing health percentage or armor points or whatever.
		 */
		public var health:Number;
		/**
		 * This is just a pre-allocated x-y point container to be used however you like
		 */
		protected var _point:FlxPoint;
		/**
		 * This is just a pre-allocated rectangle container to be used however you like
		 */
		protected var _rect:FlxRect;
		/**
		 * Set this to false if you want to skip the automatic motion/movement stuff (see <code>updateMotion()</code>).
		 * FlxObject and FlxSprite default to true.
		 * FlxText, FlxTileblock, FlxTilemap and FlxSound default to false.
		 */
		public var moves:Boolean;
		/**
		 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating surface contacts and collision qualities.
		 * Use bitwise operators to check the values stored here, or use touching(), justStartedTouching(), etc.
		 * You can even use them broadly as boolean values if you're feeling saucy!
		 */
		public var touching:uint;
		public var wasTouching:uint;
		/**
		 * Bit field of flags (use with UP, DOWN, LEFT, RIGHT, etc) indicating collision directions.
		 * Use bitwise operators to check the values stored here.
		 * Useful for things like one-way platforms (e.g. allowCollisions = UP;)
		 * The accessor "solid" just flips this variable between NONE and ANY.
		 */
		public var allowCollisions:uint;
		
		public var last:FlxPoint;
		
		public var cameras:Array;
		
		//PATH FOLLOWING VARIABLES
		public var path:FlxPath;
		public var pathSpeed:Number;
		protected var _pathNodeIndex:int;
		protected var _pathMode:uint;
		protected var _pathInc:int;
		protected var _pathCheck:FlxPoint;
		protected var _pathRotate:Boolean;
		
		/**
		 * Instantiates a <code>FlxObject</code>.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 * @param	Width	Desired width of the rectangle.
		 * @param	Height	Desired height of the rectangle.
		 */
		public function FlxObject(X:Number=0,Y:Number=0,Width:Number=0,Height:Number=0)
		{
			x = X;
			y = Y;
			last = new FlxPoint(x,y);
			width = Width;
			height = Height;
			mass = 1.0;
			elasticity = 0.0;

			immovable = false;
			moves = true;
			
			touching = NONE;
			wasTouching = NONE;
			allowCollisions = ANY;
			
			velocity = new FlxPoint();
			acceleration = new FlxPoint();
			drag = new FlxPoint();
			maxVelocity = new FlxPoint(10000,10000);
			
			angle = 0;
			angularVelocity = 0;
			angularAcceleration = 0;
			angularDrag = 0;
			maxAngular = 10000;
			
			scrollFactor = new FlxPoint(1,1);
			_flicker = false;
			_flickerTimer = 0;
			
			_point = new FlxPoint();
			_rect = new FlxRect();
			
			path = null;
			_pathCheck = null;
		}
		
		/**
		 * Override this function to null out variables or
		 * manually call destroy() on class members if necessary.
		 * Don't forget to call super.destroy()!
		 */
		override public function destroy():void
		{
			velocity = null;
			acceleration = null;
			drag = null;
			maxVelocity = null;
			scrollFactor = null;
			_point = null;
			_rect = null;
			last = null;
			if(path != null)
				path.destroy();
			path = null;
			_pathCheck = null;
		}
		
		override public function preUpdate():void
		{
			_ACTIVECOUNT++;
			
			if(_flickerTimer != 0)
			{
				if(_flickerTimer > 0)
				{
					_flickerTimer = _flickerTimer - FlxG.elapsed;
					if(_flickerTimer <= 0)
					{
						_flickerTimer = 0;
						_flicker = false;
					}
				}
			}
			
			last.x = x;
			last.y = y;
		}
		
		/**
		 * Called by the main game loop, handles motion/physics and game logic
		 */
		override public function update():void
		{
			//
		}
		
		override public function postUpdate():void
		{
			if(moves)
			{
				if((path != null) && (pathSpeed != 0) && (path.nodes[_pathNodeIndex] != null))
					updatePathMotion();
				updateMotion();
			}
			
			wasTouching = touching;
			touching = NONE;
		}
		
		/**
		 * Internal function for updating the position and speed of this object.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 */
		protected function updateMotion():void
		{
			var vc:Number;

			vc = (FlxU.computeVelocity(angularVelocity,angularAcceleration,angularDrag,maxAngular) - angularVelocity)/2;
			angularVelocity += vc; 
			angle += angularVelocity*FlxG.elapsed;
			angularVelocity += vc;
			
			vc = (FlxU.computeVelocity(velocity.x,acceleration.x,drag.x,maxVelocity.x) - velocity.x)/2;
			velocity.x += vc;
			var xd:Number = velocity.x*FlxG.elapsed;
			velocity.x += vc;
			
			vc = (FlxU.computeVelocity(velocity.y,acceleration.y,drag.y,maxVelocity.y) - velocity.y)/2;
			velocity.y += vc;
			var yd:Number = velocity.y*FlxG.elapsed;
			velocity.y += vc;
			
			x += xd;
			y += yd;
		}
		
		override public function draw():void
		{
			if(cameras == null)
				cameras = FlxG.cameras;
			var c:FlxCamera;
			var i:uint = 0;
			var l:uint = cameras.length;
			while(i < l)
			{
				c = cameras[i++];
				if(!onScreen(c)) //preloads _point with getScreenXY results
					continue;
				_VISIBLECOUNT++;
				if(FlxG.visualDebug)
					drawDebug(c);
			}
		}
		
		/**
		 * Called per camera by draw() to draw relevant debug information to the game world.
		 */
		override public function drawDebug(Camera:FlxCamera=null):void
		{
			if(Camera == null)
				Camera = FlxG.camera;

			//get bounding box coordinates
			var bx:int = x - Camera.scroll.x*scrollFactor.x; //from getscreenxy
			var by:int = y - Camera.scroll.y*scrollFactor.y;
			var bw:int = (width != int(width))?width:width-1;
			var bh:int = (height != int(height))?height:height-1;

			//fill static graphics object with square shape
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			gfx.moveTo(bx,by);
			var c:uint;
			if(allowCollisions)
			{
				if(allowCollisions != ANY)
					c = FlxG.PINK;
				if(immovable)
					c = FlxG.GREEN;
				else
					c = FlxG.RED;
			}
			else
				c = FlxG.BLUE;
			gfx.lineStyle(1,c,0.5);
			gfx.lineTo(bx+bw,by);
			gfx.lineTo(bx+bw,by+bh);
			gfx.lineTo(bx,by+bh);
			gfx.lineTo(bx,by);
			
			//draw graphics shape to camera buffer
			Camera.buffer.draw(FlxG.flashGfxSprite);
			
			if((path != null) && (pathSpeed != 0))
				path.drawDebug(Camera);
		}
		
		public function followPath(Path:FlxPath,Speed:Number=100,Mode:uint=PATH_FORWARD,AutoRotate:Boolean=false):void
		{
			if(Path.nodes.length <= 0)
			{
				FlxG.log("WARNING: Paths need at least one node in them to be followed.");
				return;
			}
			
			path = Path;
			pathSpeed = FlxU.abs(Speed);
			_pathMode = Mode;
			_pathRotate = AutoRotate;
			_pathCheck = new FlxPoint();
			
			//get starting node
			if((_pathMode == PATH_BACKWARD) || (_pathMode == PATH_LOOP_BACKWARD))
			{
				_pathNodeIndex = path.nodes.length-1;
				_pathInc = -1;
			}
			else
			{
				_pathNodeIndex = 0;
				_pathInc = 1;
			}
			getMidpoint(_point);
			var node:FlxPoint = path.nodes[_pathNodeIndex];
			_pathCheck.x = node.x - _point.x;
			_pathCheck.y = node.y - _point.y;
		}
		
		public function stopFollowingPath(DestroyPath:Boolean=false):void
		{
			pathSpeed = 0;
			if(DestroyPath)
			{
				path.destroy();
				path = null;
			}
		}
		
		protected function advancePath():void
		{
			_pathNodeIndex += _pathInc;
			switch(_pathMode)
			{
				case PATH_FORWARD:
					if(_pathNodeIndex >= path.nodes.length)
					{
						_pathNodeIndex = path.nodes.length-1;
						pathSpeed = 0;
					}
					break;
				case PATH_BACKWARD:
					if(_pathNodeIndex < 0)
					{
						_pathNodeIndex = 0;
						pathSpeed = 0;
					}
					break;
				case PATH_LOOP_FORWARD:
					if(_pathNodeIndex >= path.nodes.length)
						_pathNodeIndex = 0;
					break;
				case PATH_LOOP_BACKWARD:
					if(_pathNodeIndex < 0)
					{
						_pathNodeIndex = path.nodes.length-1;
						if(_pathNodeIndex < 0)
							_pathNodeIndex = 0;
					}
				case PATH_YOYO:
					if(_pathInc > 0)
					{
						if(_pathNodeIndex >= path.nodes.length)
						{
							_pathNodeIndex = path.nodes.length-2;
							if(_pathNodeIndex < 0)
								_pathNodeIndex = 0;
							_pathInc = -_pathInc;
						}
					}
					else if(_pathNodeIndex < 0)
					{
						_pathNodeIndex = 1;
						if(_pathNodeIndex >= path.nodes.length)
							_pathNodeIndex = path.nodes.length-1;
						if(_pathNodeIndex < 0)
							_pathNodeIndex = 0;
						_pathInc = -_pathInc;
					}
					break;
			}
			getMidpoint(_point);
			var node:FlxPoint = path.nodes[_pathNodeIndex];
			_pathCheck.x = node.x - _point.x;
			_pathCheck.y = node.y - _point.y;
		}
		
		public function updatePathMotion():void
		{
			//first check if we need to be pointing at the next node yet
			getMidpoint(_point);
			var dx:Number = path.nodes[_pathNodeIndex].x - _point.x;
			var dy:Number = path.nodes[_pathNodeIndex].y - _point.y;
			if( ((_pathCheck.x <= 0) && (dx >= 0)) || ((_pathCheck.x >= 0) && (dx <= 0)) ||
				((_pathCheck.y <= 0) && (dy >= 0)) || ((_pathCheck.y >= 0) && (dy <= 0)) )
				advancePath();
			
			//then just move toward the current node at the requested speed
			if(pathSpeed != 0)
			{
				var a:Number = FlxU.getAngle(getMidpoint(_point),path.nodes[_pathNodeIndex]);
				FlxU.rotatePoint(0,pathSpeed,0,0,a,_point);
				velocity.x = _point.x;
				velocity.y = _point.y;
				acceleration.x = 0;
				acceleration.y = 0;
				drag.x = 0;
				drag.y = 0;
				if(_pathRotate)
				{
					angularVelocity = 0;
					angularAcceleration = 0;
					angle = a;
				}
			}
			else
			{
				velocity.x = 0;
				velocity.y = 0;
				acceleration.x = 0;
				acceleration.y = 0;
				drag.x = 0;
				drag.y = 0;
			}
		}
		
		/**
		 * Checks to see if a point in 2D world space overlaps this <code>FlxObject</code> object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * @param	PerPixel	Whether or not to use per pixel collision checking (only available in <code>FlxSprite</code> subclass).
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		public function overlapsPoint(X:Number,Y:Number,Camera:FlxCamera=null,PerPixel:Boolean = false):Boolean
		{
			if(Camera == null)
				Camera = FlxG.camera;
			
			//convert passed point into screen space
			X = X - Camera.scroll.x;
			Y = Y - Camera.scroll.y;
			
			//then compare
			_point.x = x - Camera.scroll.x*scrollFactor.x; //from getscreenxy
			_point.y = y - Camera.scroll.y*scrollFactor.y;
			return (X > _point.x) && (X < _point.x+width) && (Y > _point.y) && (Y < _point.y+height);
		}
		
		/**
		 * Tells this object to flicker, retro-style.
		 * Pass a negative value to flicker forever.
		 * 
		 * @param	Duration	How many seconds to flicker for.
		 */
		public function flicker(Duration:Number=1):void
		{
			_flickerTimer = Duration;
			if(_flickerTimer == 0)
				_flicker = false;
		}
		
		/**
		 * Check to see if the object is still flickering.
		 * 
		 * @return	Whether the object is flickering or not.
		 */
		public function get flickering():Boolean
		{
			return _flickerTimer != 0;
		}
		
		public function get solid():Boolean
		{
			return (allowCollisions & ANY) as Boolean;
		}
		
		public function set solid(Solid:Boolean):void
		{
			if(Solid)
				allowCollisions = ANY;
			else
				allowCollisions = NONE;
		}
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	Camera		Specify which game camera you want.  If null getScreenXY() will just grab the first global camera.
		 * @param	Point		Takes a <code>FlxPoint</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		public function getScreenXY(Point:FlxPoint=null,Camera:FlxCamera=null):FlxPoint
		{
			if(Point == null)
				Point = new FlxPoint();
			if(Camera == null)
				Camera = FlxG.camera;
			Point.x = x - Camera.scroll.x*scrollFactor.x;
			Point.y = y - Camera.scroll.y*scrollFactor.y;
			//Point.x = FlxU.floor(x + ROUNDING_ERROR)-FlxU.floor(Camera.scroll.x*scrollFactor.x);
			//Point.y = FlxU.floor(y + ROUNDING_ERROR)-FlxU.floor(Camera.scroll.y*scrollFactor.y);
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
			//getScreenXY(_point,Camera);
			_point.x = x - Camera.scroll.x*scrollFactor.x; //from getscreenxy
			_point.y = y - Camera.scroll.y*scrollFactor.y;
			return (_point.x + width > 0) && (_point.x < Camera.width) && (_point.y + height > 0) && (_point.y < Camera.height);
		}
		
		public function getMidpoint(Point:FlxPoint=null):FlxPoint
		{
			if(Point == null)
				Point = new FlxPoint();
			return Point.make(x + (width>>1),y + (height>>1));
		}
		
		/**
		 * Handy function for reviving game objects.
		 * Resets their existence flags and position, including LAST position.
		 * 
		 * @param	X	The new X position of this object.
		 * @param	Y	The new Y position of this object.
		 */
		public function reset(X:Number,Y:Number):void
		{
			revive();
			touching = NONE;
			wasTouching = NONE;
			x = X;
			y = Y;
			last.x = x;
			last.y = y;
			velocity.x = 0;
			velocity.y = 0;
		}
		
		/**
		 * Checks to see if some <code>FlxObject</code> overlaps this <code>FlxObject</code> object in world space.
		 * 
		 * @param	Object	The object being tested.
		 * 
		 * @return	Whether or not the two objects overlap.
		 */
		public function overlaps(Object:FlxObject):Boolean
		{
			return (Object.x + Object.width > x) && (Object.x < x + width) && (Object.y + Object.height > y) && (Object.y < y + height);
		}
		
		public function isTouching(Direction:uint):Boolean
		{
			return Boolean(touching & Direction);
		}
		
		public function justTouched(Direction:uint):Boolean
		{
			return Boolean((touching & Direction) && (wasTouching & Direction));
		}
		
		static public function separate(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			var sx:Boolean = separateX(Object1,Object2);
			var sy:Boolean = separateY(Object1,Object2);
			return sx || sy;
		}
		
		static public function separateX(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			//can't separate two immovable objects
			var obj1immovable:Boolean = Object1.immovable;
			var obj2immovable:Boolean = Object2.immovable;
			if(obj1immovable && obj2immovable)
				return false;
			
			//If one of the objects is a tilemap, just pass it off.
			if(Object1 is FlxTilemap)
				return (Object1 as FlxTilemap).overlapsWithCallback(Object2,separateX);
			if(Object2 is FlxTilemap)
				return (Object2 as FlxTilemap).overlapsWithCallback(Object1,separateX);
			
			//First, get the two object deltas
			var overlap:Number = 0;
			var obj1delta:Number = Object1.x - Object1.last.x;
			var obj2delta:Number = Object2.x - Object2.last.x;
			if(obj1delta != obj2delta)
			{
				//Check if the X hulls actually overlap
				var obj1deltaAbs:Number = (obj1delta > 0)?obj1delta:-obj1delta;
				var obj2deltaAbs:Number = (obj2delta > 0)?obj2delta:-obj2delta;
				var obj1rect:FlxRect = new FlxRect(Object1.x-((obj1delta > 0)?obj1delta:0),Object1.last.y,Object1.width+((obj1delta > 0)?obj1delta:-obj1delta),Object1.height);
				var obj2rect:FlxRect = new FlxRect(Object2.x-((obj2delta > 0)?obj2delta:0),Object2.last.y,Object2.width+((obj2delta > 0)?obj2delta:-obj2delta),Object2.height);
				if((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
				{
					var maxOverlap:Number = obj1deltaAbs + obj2deltaAbs + OVERLAP_BIAS;
					
					//If they did overlap (and can), figure out by how much and flip the corresponding flags
					if(obj1delta > obj2delta)
					{
						overlap = Object1.x + Object1.width - Object2.x;
						if((overlap > maxOverlap) || !(Object1.allowCollisions & RIGHT) || !(Object2.allowCollisions & LEFT))
							overlap = 0;
						else
						{
							Object1.touching |= RIGHT;
							Object2.touching |= LEFT;
						}
					}
					else if(obj1delta < obj2delta)
					{
						overlap = Object1.x - Object2.width - Object2.x;
						if((-overlap > maxOverlap) || !(Object1.allowCollisions & LEFT) || !(Object2.allowCollisions & RIGHT))
							overlap = 0;
						else
						{
							Object1.touching |= LEFT;
							Object2.touching |= RIGHT;
						}
					}
				}
			}
			
			//Then adjust their positions and velocities accordingly (if there was any overlap)
			if(overlap != 0)
			{
				if(!obj1immovable && !obj2immovable)
					overlap *= 0.5;
				var object1velocityX:Number = Object1.velocity.x;
				if(!obj1immovable)
				{
					Object1.x -= overlap;
					Object1.velocity.x = (Object2.mass/Object1.mass)*Object2.velocity.x - Object1.velocity.x*Object1.elasticity;
				}
				if(!obj2immovable)
				{
					Object2.x += overlap;
					Object2.velocity.x = (Object1.mass/Object2.mass)*object1velocityX - Object2.velocity.x*Object2.elasticity;
				}
				return true;
			}
			else
				return false;
		}
		
		static public function separateY(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			//can't separate two immovable objects
			var obj1immovable:Boolean = Object1.immovable;
			var obj2immovable:Boolean = Object2.immovable;
			if(obj1immovable && obj2immovable)
				return false;
			
			//If one of the objects is a tilemap, just pass it off.
			if(Object1 is FlxTilemap)
				return (Object1 as FlxTilemap).overlapsWithCallback(Object2,separateY);
			if(Object2 is FlxTilemap)
				return (Object2 as FlxTilemap).overlapsWithCallback(Object1,separateY);

			//First, get the two object deltas
			var overlap:Number = 0;
			var obj1delta:Number = Object1.y - Object1.last.y;
			var obj2delta:Number = Object2.y - Object2.last.y;
			if(obj1delta != obj2delta)
			{
				//Check if the Y hulls actually overlap
				var obj1deltaAbs:Number = (obj1delta > 0)?obj1delta:-obj1delta;
				var obj2deltaAbs:Number = (obj2delta > 0)?obj2delta:-obj2delta;
				var obj1rect:FlxRect = new FlxRect(Object1.x,Object1.y-((obj1delta > 0)?obj1delta:0),Object1.width,Object1.height+obj1deltaAbs);
				var obj2rect:FlxRect = new FlxRect(Object2.x,Object2.y-((obj2delta > 0)?obj2delta:0),Object2.width,Object2.height+obj2deltaAbs);
				if((obj1rect.x + obj1rect.width > obj2rect.x) && (obj1rect.x < obj2rect.x + obj2rect.width) && (obj1rect.y + obj1rect.height > obj2rect.y) && (obj1rect.y < obj2rect.y + obj2rect.height))
				{
					var maxOverlap:Number = obj1deltaAbs + obj2deltaAbs + OVERLAP_BIAS;
					
					//If they did overlap (and can), figure out by how much and flip the corresponding flags
					if(obj1delta > obj2delta)
					{
						overlap = Object1.y + Object1.height - Object2.y;
						if((overlap > maxOverlap) || !(Object1.allowCollisions & DOWN) || !(Object2.allowCollisions & UP))
							overlap = 0;
						else
						{
							Object1.touching |= DOWN;
							Object2.touching |= UP;
						}
					}
					else if(obj1delta < obj2delta)
					{
						overlap = Object1.y - Object2.height - Object2.y;
						if((-overlap > maxOverlap) || !(Object1.allowCollisions & UP) || !(Object2.allowCollisions & DOWN))
							overlap = 0;
						else
						{
							Object1.touching |= UP;
							Object2.touching |= DOWN;
						}
					}
				}
			}
			
			//Then adjust their positions and velocities accordingly (if there was any overlap)
			if(overlap != 0)
			{
				if(!obj1immovable && !obj2immovable)
					overlap *= 0.5;
				var object1velocityY:Number = Object1.velocity.y;
				if(!obj1immovable)
				{
					Object1.y -= overlap;
					Object1.velocity.y = (Object2.mass/Object1.mass)*Object2.velocity.y - Object1.velocity.y*Object1.elasticity;
				}
				if(!obj2immovable)
				{
					Object2.y += overlap;
					Object2.velocity.y = (Object1.mass/Object2.mass)*object1velocityY - Object2.velocity.y*Object2.elasticity;
				}
				return true;
			}
			else
				return false;
		}
	}
}

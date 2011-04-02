package org.flixel
{
	import flash.geom.Point;
	
	import org.flixel.FlxBasic;
	
	/**
	 * This is the base class for most of the display objects (<code>FlxSprite</code>, <code>FlxText</code>, etc).
	 * It includes some basic attributes about game objects, including retro-style flickering,
	 * basic state information, sizes, scrolling, and basic physics and motion.
	 */
	public class FlxObject extends FlxBasic
	{
		/**
		 * Helps to eliminate false collisions and/or rendering glitches caused by rounding errors
		 */
		static protected const ROUNDING_ERROR:Number = 0.0000001;
		
		public var x:Number;
		public var y:Number;
		public var width:Number;
		public var height:Number;
		
		/**
		 * Whether or not the object collides.
		 */
		public var solid:Boolean;
		/**
		 * Whether an object will move/alter position after a collision.
		 */
		public var fixed:Boolean;
		
		/**
		 * The basic speed of this object.
		 */
		public var velocity:FlxPoint;
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
		 * This is a pre-allocated Flash Point object, which is useful for certain Flash graphics API calls
		 */
		protected var _flashPoint:Point;
		/**
		 * Set this to false if you want to skip the automatic motion/movement stuff (see <code>updateMotion()</code>).
		 * FlxObject and FlxSprite default to true.
		 * FlxText, FlxTileblock, FlxTilemap and FlxSound default to false.
		 */
		public var moves:Boolean;
		/**
		 * These store a couple of useful numbers for speeding up collision resolution.
		 */
		public var colHullX:FlxRect;
		/**
		 * These store a couple of useful numbers for speeding up collision resolution.
		 */
		public var colHullY:FlxRect;
		/**
		 * These store a couple of useful numbers for speeding up collision resolution.
		 */
		public var colVector:FlxPoint;
		/**
		 * An array of <code>FlxPoint</code> objects.  By default contains a single offset (0,0).
		 */
		public var colOffsets:Array;
		/**
		 * Flag that indicates whether or not you just hit the floor.
		 * Primarily useful for platformers, this flag is reset during the <code>updateMotion()</code>.
		 */
		public var onFloor:Boolean;
		/**
		 * Flag for direction collision resolution.
		 */
		public var collideLeft:Boolean;
		/**
		 * Flag for direction collision resolution.
		 */
		public var collideRight:Boolean;
		/**
		 * Flag for direction collision resolution.
		 */
		public var collideTop:Boolean;
		/**
		 * Flag for direction collision resolution.
		 */
		public var collideBottom:Boolean;
		
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
			width = Width;
			height = Height;
			
			solid = true;
			fixed = false;
			moves = true;
			
			collideLeft = true;
			collideRight = true;
			collideTop = true;
			collideBottom = true;
			
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
			_flashPoint = new Point();
			
			colHullX = new FlxRect();
			colHullY = new FlxRect();
			colVector = new FlxPoint();
			colOffsets = new Array(new FlxPoint());
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
			_flashPoint = null;
			colHullX = null;
			colHullY = null;
			colVector = null;
			colOffsets = null;
		}
		
		/**
		 * Called by the main game loop, handles motion/physics and game logic
		 */
		override public function update():void
		{
			_ACTIVECOUNT++;
			updateMotion();
			updateFlickering();
		}
		
		/**
		 * Called by <code>FlxObject.updateMotion()</code> and some constructors to
		 * rebuild the basic collision data for this object.
		 */
		public function refreshHulls():void
		{
			colHullX.make(x,y,width,height);
			colHullY.copyFrom(colHullX);
		}
		
		/**
		 * Internal function for updating the position and speed of this object.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 */
		protected function updateMotion():void
		{
			if(!moves)
				return;
			
			if(solid)
				refreshHulls();
			onFloor = false;
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
			
			//Update collision data with new movement results
			if(!solid)
				return;
			colVector.make(xd,yd);
			colHullX.width += ((colVector.x>0)?colVector.x:-colVector.x);
			if(colVector.x < 0)
				colHullX.x += colVector.x;
			colHullY.x = x;
			colHullY.height += ((colVector.y>0)?colVector.y:-colVector.y);
			if(colVector.y < 0)
				colHullY.y += colVector.y;
		}
		
		/**
		 * Just updates the retro-style flickering.
		 * Considered update logic rather than rendering because it toggles visibility.
		 */
		protected function updateFlickering():void
		{
			if(flickering)
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
			X = X - FlxU.floor(Camera.scroll.x);
			Y = Y - FlxU.floor(Camera.scroll.y);
			
			//then compare
			getScreenXY(_point,Camera);
			return (X > _point.x) && (X < _point.x+width) && (Y > _point.y) && (Y < _point.y+height);
		}
		
		/**
		 * If you don't want to call <code>FlxU.collide()</code> you can use this instead.
		 * Just calls <code>FlxU.collide(this,Object);</code>.  Will collide against itself
		 * if Object==null.
		 * 
		 * @param	Object		The <code>FlxObject</code> you want to collide with.
		 */
		public function collide(Object:FlxObject=null):Boolean
		{
			return FlxU.collide(this,((Object==null)?this:Object));
		}
		
		/**
		 * <code>FlxU.collide()</code> (and thus <code>FlxObject.collide()</code>) call
		 * this function each time two objects are compared to see if they collide.
		 * It doesn't necessarily mean these objects WILL collide, however.
		 * 
		 * @param	Object	The <code>FlxObject</code> you're about to run into.
		 */
		public function preCollide(Object:FlxObject):void
		{
			//Most objects don't have to do anything here.
		}
		
		/**
		 * Called when this object's left side collides with another <code>FlxObject</code>'s right.
		 * NOTE: by default this function just calls <code>hitSide()</code>.
		 * 
		 * @param	Contact		The <code>FlxObject</code> you just ran into.
		 * @param	Velocity	The suggested new velocity for this object.
		 */
		public function hitLeft(Contact:FlxObject,Velocity:Number):void
		{
			hitSide(Contact,Velocity);
		}
		
		/**
		 * Called when this object's right side collides with another <code>FlxObject</code>'s left.
		 * NOTE: by default this function just calls <code>hitSide()</code>.
		 * 
		 * @param	Contact		The <code>FlxObject</code> you just ran into.
		 * @param	Velocity	The suggested new velocity for this object.
		 */
		public function hitRight(Contact:FlxObject,Velocity:Number):void
		{
			hitSide(Contact,Velocity);
		}
		
		/**
		 * Since most games have identical behavior for running into walls,
		 * you can just override this function instead of overriding both hitLeft and hitRight. 
		 * 
		 * @param	Contact		The <code>FlxObject</code> you just ran into.
		 * @param	Velocity	The suggested new velocity for this object.
		 */
		public function hitSide(Contact:FlxObject,Velocity:Number):void
		{
			if(!fixed || (Contact.fixed && ((velocity.y != 0) || (velocity.x != 0))))
				velocity.x = Velocity;
		}
		
		/**
		 * Called when this object's top collides with the bottom of another <code>FlxObject</code>.
		 * 
		 * @param	Contact		The <code>FlxObject</code> you just ran into.
		 * @param	Velocity	The suggested new velocity for this object.
		 */
		public function hitTop(Contact:FlxObject,Velocity:Number):void
		{
			if(!fixed || (Contact.fixed && ((velocity.y != 0) || (velocity.x != 0))))
				velocity.y = Velocity;
		}
		
		/**
		 * Called when this object's bottom edge collides with the top of another <code>FlxObject</code>.
		 * 
		 * @param	Contact		The <code>FlxObject</code> you just ran into.
		 * @param	Velocity	The suggested new velocity for this object.
		 */
		public function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			onFloor = true;
			if(!fixed || (Contact.fixed && ((velocity.y != 0) || (velocity.x != 0))))
				velocity.y = Velocity;
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
			Point.x = FlxU.floor(x + ROUNDING_ERROR)-FlxU.floor(Camera.scroll.x*scrollFactor.x);
			Point.y = FlxU.floor(y + ROUNDING_ERROR)-FlxU.floor(Camera.scroll.y*scrollFactor.y);
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
			getScreenXY(_point,Camera);
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
			x = X;
			y = Y;
			velocity.make();
			refreshHulls();
		}
		
		/**
		 * Checks to see if some <code>FlxObject</code> object overlaps this <code>FlxObject</code> object.
		 * 
		 * @param	Object	The object being tested.
		 * 
		 * @return	Whether or not the two objects overlap.
		 */
		public function overlaps(Object:FlxObject):Boolean
		{
			return (Object.x + Object.width > x) && (Object.x < x + width) && (Object.y + Object.height > y) && (Object.y < y + height);
		}
		
		/*
		public function getBoundingColor():uint
		{
			if(solid)
			{
				if(fixed)
					return 0x7f00f225;
				else
					return 0x7fff0012;
			}
			else
				return 0x7f0090e9;
		}*/
	}
}

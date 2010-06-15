package org.flixel
{
	import flash.geom.Point;
	
	/**
	 * This is the base class for most of the display objects (<code>FlxSprite</code>, <code>FlxText</code>, etc).
	 * It includes some basic attributes about game objects, including retro-style flickering,
	 * basic state information, sizes, scrolling, and basic physics & motion.
	 */
	public class FlxObject extends FlxRect
	{
		/**
		 * Kind of a global on/off switch for any objects descended from <code>FlxObject</code>.
		 */
		public var exists:Boolean;
		/**
		 * If an object is not alive, the game loop will not automatically call <code>update()</code> on it.
		 */
		public var active:Boolean;
		/**
		 * If an object is not visible, the game loop will not automatically call <code>render()</code> on it.
		 */
		public var visible:Boolean;
		/**
		 * Internal tracker for whether or not the object collides (see <code>solid</code>).
		 */
		protected var _solid:Boolean;
		/**
		 * Internal tracker for whether an object will move/alter position after a collision (see <code>fixed</code>).
		 */
		protected var _fixed:Boolean;
		
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
		 * WARNING: The origin of the sprite will default to its center.
		 * If you change this, the visuals and the collisions will likely be
		 * pretty out-of-sync if you do any rotation.
		 */
		public var origin:FlxPoint;
		/**
		 * If you want to do Asteroids style stuff, check out thrust,
		 * instead of directly accessing the object's velocity or acceleration.
		 */
		public var thrust:Number;
		/**
		 * Used to cap <code>thrust</code>, helpful and easy!
		 */
		public var maxThrust:Number;
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
		 * Handy for tracking gameplay or animations.
		 */
		public var dead:Boolean;
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
		 * Dedicated internal flag for whether or not this class is a FlxGroup.
		 */
		internal var _group:Boolean;
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
		 * Creates a new <code>FlxObject</code>.
		 * 
		 * @param	X		The X-coordinate of the point in space.
		 * @param	Y		The Y-coordinate of the point in space.
		 * @param	Width	Desired width of the rectangle.
		 * @param	Height	Desired height of the rectangle.
		 */
		public function FlxObject(X:Number=0, Y:Number=0, Width:Number=0, Height:Number=0)
		{
			super(X,Y,Width,Height);
			
			exists = true;
			active = true;
			visible = true;
			_solid = true;
			_fixed = false;
			moves = true;
			
			collideLeft = true;
			collideRight = true;
			collideTop = true;
			collideBottom = true;
			
			origin = new FlxPoint();

			velocity = new FlxPoint();
			acceleration = new FlxPoint();
			drag = new FlxPoint();
			maxVelocity = new FlxPoint(10000,10000);
			
			angle = 0;
			angularVelocity = 0;
			angularAcceleration = 0;
			angularDrag = 0;
			maxAngular = 10000;
			
			thrust = 0;
			
			scrollFactor = new FlxPoint(1,1);
			_flicker = false;
			_flickerTimer = -1;
			health = 1;
			dead = false;
			_point = new FlxPoint();
			_rect = new FlxRect();
			_flashPoint = new Point();
			
			colHullX = new FlxRect();
			colHullY = new FlxRect();
			colVector = new FlxPoint();
			colOffsets = new Array(new FlxPoint());
			_group = false;
		}
		
		/**
		 * Called by <code>FlxGroup</code>, commonly when game states are changed.
		 */
		public function destroy():void
		{
			//Nothing to destroy yet
		}
		
		/**
		 * Set <code>solid</code> to true if you want to collide this object.
		 */
		public function get solid():Boolean
		{
			return _solid;
		}
		
		/**
		 * @private
		 */
		public function set solid(Solid:Boolean):void
		{
			_solid = Solid;
		}
		
		/**
		 * Set <code>fixed</code> to true if you want the object to stay in place during collisions.
		 * Useful for levels and other environmental objects.
		 */
		public function get fixed():Boolean
		{
			return _fixed;
		}
		
		/**
		 * @private
		 */
		public function set fixed(Fixed:Boolean):void
		{
			_fixed = Fixed;
		}
		
		/**
		 * Called by <code>FlxObject.updateMotion()</code> and some constructors to
		 * rebuild the basic collision data for this object.
		 */
		public function refreshHulls():void
		{
			colHullX.x = x;
			colHullX.y = y;
			colHullX.width = width;
			colHullX.height = height;
			colHullY.x = x;
			colHullY.y = y;
			colHullY.width = width;
			colHullY.height = height;
		}
		
		/**
		 * Internal function for updating the position and speed of this object.
		 * Useful for cases when you need to update this but are buried down in too many supers.
		 */
		protected function updateMotion():void
		{
			if(!moves)
				return;
			
			if(_solid)
				refreshHulls();
			onFloor = false;
			var vc:Number;

			vc = (FlxU.computeVelocity(angularVelocity,angularAcceleration,angularDrag,maxAngular) - angularVelocity)/2;
			angularVelocity += vc; 
			angle += angularVelocity*FlxG.elapsed;
			angularVelocity += vc;
			
			var thrustComponents:FlxPoint;
			if(thrust != 0)
			{
				thrustComponents = FlxU.rotatePoint(-thrust,0,0,0,angle);
				var maxComponents:FlxPoint = FlxU.rotatePoint(-maxThrust,0,0,0,angle);
				var max:Number = ((maxComponents.x>0)?maxComponents.x:-maxComponents.x);
				if(max > ((maxComponents.y>0)?maxComponents.y:-maxComponents.y))
					maxComponents.y = max;
				else
					max = ((maxComponents.y>0)?maxComponents.y:-maxComponents.y);
				maxVelocity.x = maxVelocity.y = ((max>0)?max:-max);
			}
			else
				thrustComponents = _pZero;
			
			vc = (FlxU.computeVelocity(velocity.x,acceleration.x+thrustComponents.x,drag.x,maxVelocity.x) - velocity.x)/2;
			velocity.x += vc;
			var xd:Number = velocity.x*FlxG.elapsed;
			velocity.x += vc;
			
			vc = (FlxU.computeVelocity(velocity.y,acceleration.y+thrustComponents.y,drag.y,maxVelocity.y) - velocity.y)/2;
			velocity.y += vc;
			var yd:Number = velocity.y*FlxG.elapsed;
			velocity.y += vc;
			
			x += xd;
			y += yd;
			
			//Update collision data with new movement results
			if(!_solid)
				return;
			colVector.x = xd;
			colVector.y = yd;
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
			if(flickering())
			{
				if(_flickerTimer > 0)
				{
					_flickerTimer = _flickerTimer - FlxG.elapsed;
					if(_flickerTimer == 0)
						_flickerTimer = -1;
				}
				if(_flickerTimer < 0)
					flicker(-1);
				else
				{
					_flicker = !_flicker;
					visible = !_flicker;
				}
			}
		}
		
		/**
		 * Called by the main game loop, handles motion/physics and game logic
		 */
		public function update():void
		{
			updateMotion();
			updateFlickering();
		}
		
		/**
		 * Override this function to draw graphics (see <code>FlxSprite</code>).
		 */
		public function render():void
		{
			//Objects don't have any visual logic/display of their own.
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
			getScreenXY(_point);
			var tx:Number = _point.x;
			var ty:Number = _point.y;
			Object.getScreenXY(_point);
			if((_point.x <= tx-Object.width) || (_point.x >= tx+width) || (_point.y <= ty-Object.height) || (_point.y >= ty+height))
				return false;
			return true;
		}
		
		/**
		 * Checks to see if a point in 2D space overlaps this <code>FlxObject</code> object.
		 * 
		 * @param	X			The X coordinate of the point.
		 * @param	Y			The Y coordinate of the point.
		 * @param	PerPixel	Whether or not to use per pixel collision checking (only available in <code>FlxSprite</code> subclass).
		 * 
		 * @return	Whether or not the point overlaps this object.
		 */
		public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			X = X + FlxU.floor(FlxG.scroll.x);
			Y = Y + FlxU.floor(FlxG.scroll.y);
			getScreenXY(_point);
			if((X <= _point.x) || (X >= _point.x+width) || (Y <= _point.y) || (Y >= _point.y+height))
				return false;
			return true;
		}
		
		/**
		 * If you don't want to call <code>FlxU.collide()</code> you can use this instead.
		 * Just calls <code>FlxU.collide(this,Object);</code>.  Will collide against itself
		 * if Object==null.
		 * 
		 * @param	Object		The <FlxObject> you want to collide with.
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
		 * Call this function to "damage" (or give health bonus) to this sprite.
		 * 
		 * @param	Damage		How much health to take away (use a negative number to give a health bonus).
		 */
		virtual public function hurt(Damage:Number):void
		{
			health = health - Damage;
			if(health <= 0)
				kill();
		}
		
		/**
		 * Call this function to "kill" a sprite so that it no longer 'exists'.
		 */
		public function kill():void
		{
			exists = false;
			dead = true;
		}
		
		/**
		 * Tells this object to flicker, retro-style.
		 * 
		 * @param	Duration	How many seconds to flicker for.
		 */
		public function flicker(Duration:Number=1):void { _flickerTimer = Duration; if(_flickerTimer < 0) { _flicker = false; visible = true; } }
		
		/**
		 * Check to see if the object is still flickering.
		 * 
		 * @return	Whether the object is flickering or not.
		 */
		public function flickering():Boolean { return _flickerTimer >= 0; }
		
		/**
		 * Call this function to figure out the on-screen position of the object.
		 * 
		 * @param	P	Takes a <code>Point</code> object and assigns the post-scrolled X and Y values of this object to it.
		 * 
		 * @return	The <code>Point</code> you passed in, or a new <code>Point</code> if you didn't pass one, containing the screen X and Y position of this object.
		 */
		public function getScreenXY(Point:FlxPoint=null):FlxPoint
		{
			if(Point == null) Point = new FlxPoint();
			Point.x = FlxU.floor(x + FlxU.roundingError)+FlxU.floor(FlxG.scroll.x*scrollFactor.x);
			Point.y = FlxU.floor(y + FlxU.roundingError)+FlxU.floor(FlxG.scroll.y*scrollFactor.y);
			return Point;
		}
		
		/**
		 * Check and see if this object is currently on screen.
		 * 
		 * @return	Whether the object is on screen or not.
		 */
		public function onScreen():Boolean
		{
			getScreenXY(_point);
			if((_point.x + width < 0) || (_point.x > FlxG.width) || (_point.y + height < 0) || (_point.y > FlxG.height))
				return false;
			return true;
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
			x = X;
			y = Y;
			exists = true;
			dead = false;
		}
		
		/**
		 * Returns the appropriate color for the bounding box depending on object state.
		 */
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
		}
	}
}

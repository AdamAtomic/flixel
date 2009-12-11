package org.flixel
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	//@desc		This is the base class for most of the display objects (FlxSprite, FlxText, etc).  It includes some very simple basic attributes about game objects.
	public class FlxCore
	{
		//@desc	Kind of a global on/off switch for any objects descended from FlxCore
		public var exists:Boolean;
		//@desc	If an object is not alive, the game loop will not automatically call update() on it
		public var active:Boolean;
		//@desc	If an object is not visible, the game loop will not automatically call render() on it
		public var visible:Boolean;
		//@desc	If an object is dead, the functions that automate collisions will skip it (see overlapArrays in FlxSprite and collideArrays in FlxBlock)
		public var dead:Boolean;
		//@desc If an object is 'fixed' in space, it will not budge when it collides with a not-fixed object
		public var fixed:Boolean;
		
		//Basic attributes variables
		public var width:uint;
		public var height:uint;
		public var x:Number;
		public var y:Number;
		//@desc	Stores the last position of the sprite, used by collision detection algorithm
		public var last:Point;
		
		//@desc	A point that can store numbers from 0 to 1 (for X and Y independently) that governs how much this object is affected by the camera subsystem.  0 means it never moves, like a HUD element or far background graphic.  1 means it scrolls along a tthe same speed as the foreground layer.
		public var scrollFactor:Point;
		protected var _flicker:Boolean;
		protected var _flickerTimer:Number;
		
		//@desc		Constructor
		public function FlxCore()
		{
			exists = true;
			active = true;
			visible = true;
			dead = false;
			fixed = false;
			
			width = 0;
			height = 0;
			x = 0;
			y = 0;
			last = new Point(x,y);
			
			scrollFactor = new Point(1,1);
			_flicker = false;
			_flickerTimer = -1;
		}
		
		//@desc		Called by the game state when states are changed (if it's in the state's layer)
		virtual public function destroy():void
		{
			//Nothing to destroy by default, core just stores some simple variables.
		}
		
		//@desc		Just updates the flickering.  FlxSprite and other subclasses override this to do more complicated behavior.
		virtual public function update():void
		{
			last.x = x;
			last.y = y;
			
			if(flickering())
			{
				if(_flickerTimer > 0)
				{
					_flickerTimer -= FlxG.elapsed;
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
		
		//@desc		FlxSprite and other subclasses override this to render their materials to the screen
		virtual public function render():void {}
		
		//@desc		Checks to see if some FlxCore object overlaps this FlxCore object
		//@param	Core	The object being tested
		//@return	Whether or not the two objects overlap
		virtual public function overlaps(Core:FlxCore):Boolean
		{
			var tx:Number = x;
			var ty:Number = y;
			if((scrollFactor.x != 1) || (scrollFactor.y != 1))
			{
				tx -= Math.floor(FlxG.scroll.x*scrollFactor.x);
				ty -= Math.floor(FlxG.scroll.y*scrollFactor.y);
			}
			var cx:Number = Core.x;
			var cy:Number = Core.y;
			if((Core.scrollFactor.x != 1) || (Core.scrollFactor.y != 1))
			{
				cx -= Math.floor(FlxG.scroll.x*Core.scrollFactor.x);
				cy -= Math.floor(FlxG.scroll.y*Core.scrollFactor.y);
			}
			if((cx <= tx-Core.width) || (cx >= tx+width) || (cy <= ty-Core.height) || (cy >= ty+height))
				return false;
			return true;
		}
		
		//@desc		Checks to see if a point in 2D space overlaps this FlxCore object
		//@param	X			The X coordinate of the point
		//@param	Y			The Y coordinate of the point
		//@param	PerPixel	Whether or not to use per pixel collision checking (only available in FlxSprite subclass, included here because of Flash's F'd up lack of polymorphism)
		//@return	Whether or not the point overlaps this object
		virtual public function overlapsPoint(X:Number,Y:Number,PerPixel:Boolean = false):Boolean
		{
			var tx:Number = x;
			var ty:Number = y;
			if((scrollFactor.x != 1) || (scrollFactor.y != 1))
			{
				tx -= Math.floor(FlxG.scroll.x*scrollFactor.x);
				ty -= Math.floor(FlxG.scroll.y*scrollFactor.y);
			}
			if((X <= tx) || (X >= tx+width) || (Y <= ty) || (Y >= ty+height))
				return false;
			return true;
		}
		
		//@desc		Collides a FlxCore against this object.  Simply calls collideX then collideY internally.
		//@param	Core	The FlxCore you want to collide
		virtual public function collide(Core:FlxCore):Boolean
		{
			var hx:Boolean = collideX(Core);
			var hy:Boolean = collideY(Core);
			return hx || hy;
		}
		
		//@desc		Collides a FlxCore against this object on the X axis ONLY.
		//@param	Core	The FlxCore you want to collide
		virtual public function collideX(Core:FlxCore):Boolean
		{
			//Helper variables for our collision process
			var split:Number;
			var thisBounds:Rectangle = new Rectangle();
			var coreBounds:Rectangle = new Rectangle();
			
			//Calculate the Core's X axis collision bounds
			if(Core.x > Core.last.x)
			{
				coreBounds.x = Core.last.x;
				coreBounds.width = (Core.x - Core.last.x) + Core.width;
			}
			else
			{
				coreBounds.x = Core.x;
				coreBounds.width = (Core.last.x - Core.x) + Core.width;
			}
			coreBounds.y = Core.last.y;
			coreBounds.height = Core.height;
			
			//Calculate this object's own X axis collision bounds
			if(x > last.x)
			{
				thisBounds.x = last.x;
				thisBounds.width = (x - last.x) + width;
			}
			else
			{
				thisBounds.x = x;
				thisBounds.width = (last.x - x) + width;
			}
			thisBounds.y = last.y;
			thisBounds.height = height;
			
			//Basic overlap check
			if( (coreBounds.x + coreBounds.width <= thisBounds.x) ||
				(coreBounds.x >= thisBounds.x + thisBounds.width) ||
				(coreBounds.y + coreBounds.height <= thisBounds.y) ||
				(coreBounds.y >= thisBounds.y + thisBounds.height) )
				return false;
			
			//NOTE: at this point we know the two volumes overlap.
			// It's just a matter of figuring out what kind of collision just happened.
			// We know collisions have to be either "right side" or "left side" of 'Core'
			// But there is a matched speed + adjacency corner case that we're not handling.
			// Differentiating this corner case from teleportation is the crux move.
			
			
				
			//Check for a right side collision if Core is moving right faster than 'this',
			// or if Core is moving left slower than 'this' we want to check the right side too
			var ctp:Number = Core.x - Core.last.x;
			var ttp:Number = x - last.x;
			var tco:Boolean = (Core.x < x + width) && (Core.x + Core.width > x);
			if(	( (ctp > 0) && (ttp <= 0) ) ||
				( (ctp >= 0) && ( ( ctp >  ttp) && tco ) ) ||
				( (ctp <= 0) && ( (-ctp < -ttp) && tco ) ) )
			{
				//Right side collision
				if(fixed && !Core.fixed)
				{	
					if(Core.hitWall(this))
					{
						Core.x = x - Core.width;
						return true;
					}
				}
				else if(!fixed && Core.fixed)
				{
					if(hitWall(Core))
					{
						x = Core.x + Core.width;
						return true;
					}
				}
				else if(Core.hitWall(this) && hitWall(Core))
				{
					split = (coreBounds.right - thisBounds.left) / 2;
					Core.x -= split;
					x += split;
					return true;
				}
			}
			else if(( (ctp < 0) && (ttp >= 0) ) ||
					( (ctp >= 0) && ( ( ctp <  ttp) && tco) ) ||
					( (ctp <= 0) && ( (-ctp > -ttp) && tco) ) )
			{
				//Left side collision
				if(coreBounds.left < thisBounds.right)
				{
					if(fixed && !Core.fixed)
					{
						if(Core.hitWall(this))
						{
							Core.x = x + width;
							return true;
						}
					}
					else if(!fixed && Core.fixed)
					{
						if(hitWall(Core))
						{
							x = Core.x - width;
							return true;
						}
					}
					else if(Core.hitWall(this) && hitWall(Core))
					{
						split = (thisBounds.right - coreBounds.left) / 2;
						Core.x += split;
						x -= split;
						return true;
					}
				}
			}
			return false;
		}
		
		//@desc		Collides a FlxCore against this object on the Y axis ONLY.
		//@param	Core	The FlxCore you want to collide
		virtual public function collideY(Core:FlxCore):Boolean
		{
			//Helper variables for our collision process
			var split:Number;
			var thisBounds:Rectangle = new Rectangle();
			var coreBounds:Rectangle = new Rectangle();
			
			//Now we just repeat this basic process only for the Y axis
			if(Core.y > Core.last.y)
			{
				coreBounds.y = Core.last.y;
				coreBounds.height = (Core.y - Core.last.y) + Core.height;
			}
			else
			{
				coreBounds.y = Core.y;
				coreBounds.height = (Core.last.y - Core.y) + Core.height;
			}
			coreBounds.x = Core.x;
			coreBounds.width = Core.width;
			
			//Calculate this object's own Y axis collision bounds
			if(y > last.y)
			{
				thisBounds.y = last.y;
				thisBounds.height = (y - last.y) + height;
			}
			else
			{
				thisBounds.y = y;
				thisBounds.height = (last.y - y) + height;
			}
			thisBounds.x = x;
			thisBounds.width = width;
			
			//Basic overlap check
			if( (coreBounds.x + coreBounds.width <= thisBounds.x) ||
				(coreBounds.x >= thisBounds.x + thisBounds.width) ||
				(coreBounds.y + coreBounds.height <= thisBounds.y) ||
				(coreBounds.y >= thisBounds.y + thisBounds.height) )
				return false;
				
			//Check for a bottom collision if Core is moving down faster than 'this',
			// or if Core is moving up slower than 'this' we want to check the bottom too
			var ctp:Number = Core.y - Core.last.y;
			var ttp:Number = y - last.y;
			var tco:Boolean = (Core.y < y + height) && (Core.y + Core.height > y);
			if(	( (ctp > 0) && (ttp <= 0) ) ||
				( (ctp >= 0) && ( ( ctp >  ttp) && tco ) ) ||
				( (ctp <= 0) && ( (-ctp < -ttp) && tco ) ) )
			{
				//Bottom collision
				if(coreBounds.bottom > thisBounds.top)
				{
					if(fixed && !Core.fixed)
					{
						if(Core.hitFloor(this))
						{
							Core.y = y - Core.height;
							return true;
						}
					}
					else if(!fixed && Core.fixed)
					{
						if(hitCeiling(Core))
						{
							y = Core.y + Core.height;
							return true;
						}
					}
					else if(Core.hitFloor(this) && hitCeiling(Core))
					{
						split = (coreBounds.bottom - thisBounds.top) / 2;
						Core.y -= split;
						y += split;
						return true;
					}
				}
			}
			else if(( (ctp < 0) && (ttp >= 0) ) ||
					( (ctp >= 0) && ( ( ctp <  ttp) && tco) ) ||
					( (ctp <= 0) && ( (-ctp > -ttp) && tco) ) )
			{
				//Top collision
				if(coreBounds.top < thisBounds.bottom)
				{
					if(fixed && !Core.fixed)
					{
						if(Core.hitCeiling(this))
						{
							Core.y = y + height;
							return true;
						}
					}
					else if(!fixed && Core.fixed)
					{
						if(hitFloor(Core))
						{
							y = Core.y - height;
							return true;
						}
					}
					else if(Core.hitCeiling(this) && hitFloor(Core))
					{
						split = (thisBounds.bottom - coreBounds.top) / 2;
						Core.y += split;
						y -= split;
						return true;
					}
				}
			}
			return false;
		}
		
		//@desc		Collides an array of FlxCore objects against the tilemap
		//@param	Cores		The FlxCore objects you want to collide against
		public function collideArray(Cores:Array):void
		{
			if(!exists || dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === this) || (core == null) || !core.exists || core.dead) continue;
				collide(core);
			}
		}
		
		//@desc		Collides an array of FlxCore objects against the tilemap against the X axis only
		//@param	Cores		The FlxCore objects you want to collide against
		public function collideArrayX(Cores:Array):void
		{
			if(!exists || dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === this) || (core == null) || !core.exists || core.dead) continue;
				collideX(core);
			}
		}
		
		//@desc		Collides an array of FlxCore objects against the tilemap against the Y axis only
		//@param	Cores		The FlxCore objects you want to collide against
		public function collideArrayY(Cores:Array):void
		{
			if(!exists || dead) return;
			var core:FlxCore;
			var l:uint = Cores.length;
			for(var i:uint = 0; i < l; i++)
			{
				core = Cores[i];
				if((core === this) || (core == null) || !core.exists || core.dead) continue;
				collideY(core);
			}
		}
		
		//@desc		Called when this object collides with a FlxBlock on one of its sides
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitWall(Contact:FlxCore=null):Boolean { return true; }
		
		//@desc		Called when this object collides with the top of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitFloor(Contact:FlxCore=null):Boolean { return true; }
		
		//@desc		Called when this object collides with the bottom of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitCeiling(Contact:FlxCore=null):Boolean { return true; }
		
		//@desc		Call this function to "kill" a sprite so that it no longer 'exists'
		virtual public function kill():void
		{
			exists = false;
			dead = true;
		}
		
		//@desc		Tells this object to flicker for the number of seconds requested (0 = infinite, negative number tells it to stop)
		public function flicker(Duration:Number=1):void { _flickerTimer = Duration; if(_flickerTimer < 0) { _flicker = false; visible = true; } }
		
		//@desc		Called when this object collides with the bottom of a FlxBlock
		//@return	Whether the object is flickering or not
		public function flickering():Boolean { return _flickerTimer >= 0; }
		
		//@desc		Call this to check and see if this object is currently on screen
		//@return	Whether the object is on screen or not
		public function onScreen():Boolean
		{
			var p:Point = new Point();
			getScreenXY(p);
			if((p.x + width < 0) || (p.x > FlxG.width) || (p.y + height < 0) || (p.y > FlxG.height))
				return false;
			return true;
		}
		
		//@desc		Call this function to figure out the post-scrolling "screen" position of the object
		//@param	p	Takes a Flash Point object and assigns the post-scrolled X and Y values of this object to it
		virtual public function getScreenXY(P:Point):void
		{
			P.x = Math.floor(x)+Math.floor(FlxG.scroll.x*scrollFactor.x);
			P.y = Math.floor(y)+Math.floor(FlxG.scroll.y*scrollFactor.y);
		}
		
		//@desc		Handy function for reviving game objects.  Resets their existence flags and position, including LAST position.
		//@param	X	The X position of the revived object
		//@param	Y	The Y position of the revived object
		virtual public function reset(X:Number,Y:Number):void
		{
			exists = true;
			active = true;
			visible = true;
			dead = false;
			last.x = x = X;
			last.y = y = Y;
		}
	}
}
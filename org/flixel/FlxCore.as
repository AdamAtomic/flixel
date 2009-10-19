package org.flixel
{
	import flash.geom.Point;
	
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
		
		//Basic attributes variables
		public var x:Number;
		public var y:Number;
		public var width:uint;
		public var height:uint;
		
		//@desc	A point that can store numbers from 0 to 1 (for X and Y independently) that governs how much this object is affected by the camera subsystem.  0 means it never moves, like a HUD element or far background graphic.  1 means it scrolls along a tthe same speed as the foreground layer.
		public var scrollFactor:Point;
		private var _flicker:Boolean;
		private var _flickerTimer:Number;
		
		//@desc		Constructor
		public function FlxCore()
		{
			exists = true;
			active = true;
			visible = true;
			dead = false;
			
			x = 0;
			y = 0;
			width = 0;
			height = 0;
			
			scrollFactor = new Point(1,1);
			_flicker = false;
			_flickerTimer = -1;
		}
		
		//@desc		Just updates the flickering.  FlxSprite and other subclasses override this to do more complicated behavior.
		virtual public function update():void
		{
			if(flickering())
			{
				if(_flickerTimer > 0) _flickerTimer -= FlxG.elapsed;
				if(_flickerTimer < 0) flicker(-1);
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
		
		//@desc		Collides a FlxSprite against this block
		//@param	Spr		The FlxSprite you want to collide
		virtual public function collide(Spr:FlxSprite):void
		{
			if((Math.abs(Spr.x + (Spr.width>>1) - x - (width>>1)) > (width>>1) + (Spr.width>>1)) && (Math.abs(Spr.y + (Spr.height>>1) - y - (height>>1)) > (height>>1) + (Spr.height>>1)))
				return;

			if((Spr.x > x) && (Spr.x + Spr.width < x + width))
			{
				if((Spr.y + Spr.height < y + (height>>1)) && (Spr.y + Spr.height > y) && Spr.hitFloor())
				{
					Spr.y = y - Spr.height;
					return;
				}	
				if((Spr.y > y + (height>>1)) && (Spr.y < y + height) && Spr.hitCeiling())
				{
					Spr.y = y + height;
					return;
				}
			}
			if((Spr.y > y) && (Spr.y + Spr.height < y + height))
			{
				if((Spr.x + Spr.width < x + (width>>1)) && (Spr.x + Spr.width > x) && Spr.hitWall())
				{
					Spr.x = x - Spr.width;
					return;
				}	
				if((Spr.x > x + (width>>1)) && (Spr.x < x + width) && Spr.hitWall())
				{
					Spr.x = x + width;
					return;
				}
			}
			
			var yFirst:Boolean = true;
			if((Math.abs(Spr.velocity.x) > Math.abs(Spr.velocity.y)))
				yFirst = false;
			
			var checkForMoreX:Boolean = false;
			var checkForMoreY:Boolean = false;
			if(yFirst)
			{
				if(Spr.velocity.y > 0)
				{
					if(overlapsPoint(Spr.x + (Spr.width>>1),Spr.y + Spr.height))
					{
						if(Spr.hitFloor())
							Spr.y = y - Spr.height;
					}
					else
						checkForMoreY = true;
				}
				else if(Spr.velocity.y < 0)
				{
					if(overlapsPoint(Spr.x + (Spr.width>>1),Spr.y))
					{
						if(Spr.hitCeiling())
							Spr.y = y + height;
					}
					else
						checkForMoreY = true;
				}

				if(Spr.velocity.x < 0)
				{
					if(overlapsPoint(Spr.x,Spr.y + (Spr.height>>1)))
					{
						if(Spr.hitWall())
							Spr.x = x + width;
					}
					else
						checkForMoreX = true;
				}
				else if(Spr.velocity.x > 0)
				{
					if(overlapsPoint(Spr.x + Spr.width,Spr.y + (Spr.height>>1)))
					{
						if(Spr.hitWall())
							Spr.x = x - Spr.width;
					}
					else
						checkForMoreX = true;
				}
			}
			else
			{
				if(Spr.velocity.x < 0)
				{
					if(overlapsPoint(Spr.x,Spr.y + (Spr.height>>1)))
					{
						if(Spr.hitWall())
							Spr.x = x + width;
					}
					else
						checkForMoreX = true;
				}
				else if(Spr.velocity.x > 0)
				{
					if(overlapsPoint(Spr.x + Spr.width,Spr.y + (Spr.height>>1)))
					{
						if(Spr.hitWall())
							Spr.x = x - Spr.width;
					}
					else
						checkForMoreX = true;
				}
				
				if(Spr.velocity.y > 0)
				{
					if(overlapsPoint(Spr.x + (Spr.width>>1),Spr.y + Spr.height))
					{
						if(Spr.hitFloor())
							Spr.y = y - Spr.height;
					}
					else
						checkForMoreY = true;
				}
				else if(Spr.velocity.y < 0)
				{
					if(overlapsPoint(Spr.x + (Spr.width>>1),Spr.y))
					{
						if(Spr.hitCeiling())
							Spr.y = y + height;
					}
					else
						checkForMoreY = true;
				}
			}
			
			if(!checkForMoreY && !checkForMoreX)
				return;
			var bias:int = Spr.width>>3;
			if(bias < 1)
				bias = 1;
			if(checkForMoreY && checkForMoreX)
			{				
				if(yFirst)
				{
					if(checkForMoreY)
					{
						if((Spr.x + Spr.width - bias > x) && (Spr.x + bias < x + width))
						{
							if((Spr.velocity.y > 0) && (Spr.y + Spr.height > y) && (Spr.y + Spr.height < y + height) && Spr.hitFloor())
								Spr.y = y - Spr.height;
							else if((Spr.velocity.y < 0) && (Spr.y > y) && (Spr.y < y + height) && Spr.hitCeiling())
								Spr.y = y + height;
						}
					}
					if(checkForMoreX)
					{
						if((Spr.y + Spr.height - bias > y) && (Spr.y + bias < y + height))
						{
							if((Spr.velocity.x > 0) && (Spr.x + Spr.width > x) && (Spr.x + Spr.width < x + width) && Spr.hitWall())
								Spr.x = x - Spr.width;
							else if((Spr.velocity.x < 0) && (Spr.x > x) && (Spr.x < x + width) && Spr.hitWall())
								Spr.x = x + width;
						}
					}
				}
				else
				{
					if(checkForMoreX)
					{
						if((Spr.y + Spr.height - bias > y) && (Spr.y + bias < y + height))
						{
							if((Spr.velocity.x > 0) && (Spr.x + Spr.width > x) && (Spr.x + Spr.width < x + width) && Spr.hitWall())
								Spr.x = x - Spr.width;
							else if((Spr.velocity.x < 0) && (Spr.x > x) && (Spr.x < x + width) && Spr.hitWall())
								Spr.x = x + width;
						}
					}
					if(checkForMoreY)
					{
						if((Spr.x + Spr.width - bias > x) && (Spr.x + bias < x + width))
						{
							if((Spr.velocity.y > 0) && (Spr.y + Spr.height > y) && (Spr.y + Spr.height < y + height) && Spr.hitFloor())
								Spr.y = y - Spr.height;
							else if((Spr.velocity.y < 0) && (Spr.y > y) && (Spr.y < y + height) && Spr.hitCeiling())
								Spr.y = y + height;
						}
					}
				}
			}
			else if(checkForMoreY)
			{
				if((Spr.x + Spr.width - bias > x) && (Spr.x + bias < x + width))
				{
					if((Spr.velocity.y > 0) && (Spr.y + Spr.height > y) && (Spr.y + Spr.height < y + height) && Spr.hitFloor())
						Spr.y = y - Spr.height;
					else if((Spr.velocity.y < 0) && (Spr.y > y) && (Spr.y < y + height) && Spr.hitCeiling())
						Spr.y = y + height;
				}
			}
			else if(checkForMoreX)
			{
				if((Spr.y + Spr.height - bias > y) && (Spr.y + bias < y + height))
				{
					if((Spr.velocity.x > 0) && (Spr.x + Spr.width > x) && (Spr.x + Spr.width < x + width) && Spr.hitWall())
						Spr.x = x - Spr.width;
					else if((Spr.velocity.x < 0) && (Spr.x > x) && (Spr.x < x + width) && Spr.hitWall())
						Spr.x = x + width;
				}
			}
		}
		
		//@desc		Called when this object collides with a FlxBlock on one of its sides
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitWall():Boolean { return true; }
		
		//@desc		Called when this object collides with the top of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitFloor():Boolean { return true; }
		
		//@desc		Called when this object collides with the bottom of a FlxBlock
		//@return	Whether you wish the FlxBlock to collide with it or not
		virtual public function hitCeiling():Boolean { return true; }
		
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
		virtual protected function getScreenXY(p:Point):void
		{
			p.x = Math.floor(x)+Math.floor(FlxG.scroll.x*scrollFactor.x);
			p.y = Math.floor(y)+Math.floor(FlxG.scroll.y*scrollFactor.y);
		}
	}
}
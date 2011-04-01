package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class FlxCamera extends FlxBasic
	{
		static public const BOTH_AXES:uint = 0;
		static public const VERTICAL_ONLY:uint = 1;
		static public const HORIZONTAL_ONLY:uint = 2;
		
		static public var defaultZoom:uint;
		
		public var x:Number;
		public var y:Number;
		public var width:uint;
		public var height:uint;
		/**
		 * Tells the camera to follow this <code>FlxObject</code> object around.
		 */
		public var target:FlxObject;
		/**
		 * How fast the camera catches up with the target object.
		 */
		public var speed:Number;
		/**
		 * Used to force the camera to look ahead of the <code>followTarget</code>.
		 * The look-ahead distance is calculated by multiplying this value by
		 * the target object's velocity on each axis.
		 */
		public var lead:FlxPoint;
		/**
		 * The edges of the camera's range, i.e. where to stop scrolling.
		 */
		public var bounds:FlxRect;
		
		/**
		 * Stores the basic parallax scrolling values.
		 */
		public var scroll:FlxPoint;
		/**
		 * The actual bitmap data of the camera display itself.
		 */
		public var buffer:BitmapData;
		/**
		 * The natural background color of the camera. Defaults to FlxG.bgColor.
		 * NOTE: can be transparent for crazy FX!
		 */
		public var bgColor:uint;
		
		/**
		 * Internal, used to assist camera and scrolling.
		 */
		protected var _scrollTarget:FlxPoint;
		/**
		 * Internal, to help avoid costly allocations.
		 */
		protected var _point:FlxPoint;
		/**
		 * Internal, help with color transforming the flash bitmap.
		 */
		protected var _color:uint;
		
		/**
		 * Internal, used to render buffer to screen space.
		 */
		internal var _flashBitmap:Bitmap;
		protected var _flashRect:Rectangle;
		protected var _flashPoint:Point;
		
		//special effects
		protected var _fxFlashColor:uint;
		protected var _fxFlashDuration:Number;
		protected var _fxFlashComplete:Function;
		protected var _fxFlashAlpha:Number;
		
		protected var _fxFadeColor:uint;
		protected var _fxFadeDuration:Number;
		protected var _fxFadeComplete:Function;
		protected var _fxFadeAlpha:Number;
		
		protected var _fxShakeIntensity:Number;
		protected var _fxShakeDuration:Number;
		protected var _fxShakeComplete:Function;
		protected var _fxShakeOffset:FlxPoint;
		protected var _fxShakeDirection:uint;
		
		protected var _fill:BitmapData;
		
		public function FlxCamera(X:int,Y:int,Width:int,Height:int,Zoom:uint=0)
		{
			x = X;
			y = Y;
			width = Width;
			height = Height;
			target = null;
			scroll = new FlxPoint();
			_scrollTarget = new FlxPoint();
			_point = new FlxPoint();
			speed = 0;
			lead = new FlxPoint();
			bounds = null;
			bgColor = FlxG.bgColor;
			buffer = new BitmapData(width,height,true,0);
			_color = 0xffffff;

			_flashBitmap = new Bitmap(buffer);
			_flashBitmap.x = x;
			_flashBitmap.y = y;
			if(Zoom == 0)
				Zoom = defaultZoom;
			_flashBitmap.scaleX = Zoom;
			_flashBitmap.scaleY = Zoom;
			_flashRect = new Rectangle(0,0,width,height);
			_flashPoint = new Point();
			
			_fxFlashColor = 0;
			_fxFlashDuration = 0.0;
			_fxFlashComplete = null;
			_fxFlashAlpha = 0.0;
			
			_fxFadeColor = 0;
			_fxFadeDuration = 0.0;
			_fxFadeComplete = null;
			_fxFadeAlpha = 0.0;
			
			_fxShakeIntensity = 0.0;
			_fxShakeDuration = 0.0;
			_fxShakeComplete = null;
			_fxShakeOffset = new FlxPoint();
			_fxShakeDirection = 0;
			
			_fill = new BitmapData(width,height,true,0);
		}
		
		override public function destroy():void
		{
			scroll = null;
			lead = null;
			bounds = null;
			buffer = null;
			_flashBitmap = null;
			_fxFlashComplete = null;
			_fxFadeComplete = null;
			_fxShakeComplete = null;
			_fxShakeOffset = null;
		}
		
		override public function update():void
		{
			//If we're tracking something, pick our new target destination
			if(target != null)
			{
				target.getMidpoint(_point);
				_scrollTarget.make(_point.x - (width>>1) + target.velocity.x * lead.x,_point.y - (height>>1) + target.velocity.y * lead.y);
			}
			
			//Then, step the camera toward that destination
			scroll.x += (_scrollTarget.x-scroll.x) * speed * FlxG.elapsed;
			scroll.y += (_scrollTarget.y-scroll.y) * speed * FlxG.elapsed;
			
			//Finally, make sure the camera hasn't gone outside the bounds we set for it
			if(bounds != null)
			{
				if(scroll.x < bounds.left)
					scroll.x = bounds.left;
				if(scroll.x > bounds.right - width)
					scroll.x = bounds.right - width;
				if(scroll.y < bounds.top)
					scroll.y = bounds.top;
				if(scroll.y > bounds.bottom - height)
					scroll.y = bounds.bottom - height;
			}
			
			//Update the "flash" special effect
			if(_fxFlashAlpha > 0.0)
			{
				_fxFlashAlpha -= FlxG.elapsed/_fxFlashDuration;
				if((_fxFlashAlpha <= 0) && (_fxFlashComplete != null))
					_fxFlashComplete();
			}
			
			//Update the "fade" special effect
			if((_fxFadeAlpha > 0.0) && (_fxFadeAlpha < 1.0))
			{
				_fxFadeAlpha += FlxG.elapsed/_fxFadeDuration;
				if(_fxFadeAlpha >= 1.0)
				{
					_fxFadeAlpha = 1.0;
					if(_fxFadeComplete != null)
						_fxFadeComplete();
				}
			}
			
			//Update the "shake" special effect
			if(_fxShakeDuration > 0)
			{
				_fxShakeDuration -= FlxG.elapsed;
				if(_fxShakeDuration <= 0)
				{
					_fxShakeOffset.make();
					if(_fxShakeComplete != null)
						_fxShakeComplete();
				}
				else
				{
					if((_fxShakeDirection == BOTH_AXES) || (_fxShakeDirection == HORIZONTAL_ONLY))
						_fxShakeOffset.x = (FlxG.random()*_fxShakeIntensity*width*2-_fxShakeIntensity*width)*_flashBitmap.scaleX;
					if((_fxShakeDirection == BOTH_AXES) || (_fxShakeDirection == VERTICAL_ONLY))
						_fxShakeOffset.y = (FlxG.random()*_fxShakeIntensity*height*2-_fxShakeIntensity*height)*_flashBitmap.scaleY;
				}
			}
		}
		
		/**
		 * Tells this camera object what <code>FlxObject</code> to track.
		 * 
		 * @param	Target		The object you want the camera to track.  Set to null to not follow anything.
		 * @param	Speed		How fast to track it (default: 1 - slowish).
		 * @param	LeadX		How far in front of the camera to look on the X axis, times the target's X velocity (default: 0).
		 * @param	LeadY		How far in front of the camera to look on the Y axis, times the target's Y velocity (default: 0).
		 * @param	Snap		Whether the camera should start on the new object, or smoothly scroll over to it (default: true).
		 */
		public function follow(Target:FlxObject, Speed:Number=1, LeadX:Number=0, LeadY:Number=0, Snap:Boolean=true):void
		{
			target = Target;
			lead.make(LeadX,LeadY);
			goTo(target.getMidpoint(_point),Speed,Snap);
		}
		
		/**
		 * Tells the camera to move to the specified location.
		 * 
		 * @param	Location	The point in game-space you want the camera to scroll to.
		 * @param	Speed		How fast to go there.
		 * @param	Snap		Whether to go there instantly.
		 */
		public function goTo(Location:FlxPoint,Speed:Number=1,Snap:Boolean=false):void
		{
			if(Location == null)
				return;
			speed = Speed;
			_scrollTarget.make(Location.x - (width>>1), Location.y - (height>>1));
			if(Snap)
			{
				scroll.copyFrom(_scrollTarget);
				update();
			}
		}
		
		/**
		 * Specify the boundaries of the level or where the camera is allowed to move.
		 * 
		 * @param	X				The smallest X value of your level (usually 0).
		 * @param	Y				The smallest Y value of your level (usually 0).
		 * @param	Width			The largest X value of your level (usually the level width).
		 * @param	Height			The largest Y value of your level (usually the level height).
		 * @param	UpdateWorld		Whether the global quad-tree's dimensions should be updated to match (default: false).
		 */
		public function setBounds(X:Number=0, Y:Number=0, Width:Number=0, Height:Number=0, UpdateWorld:Boolean=false):void
		{
			if(bounds == null)
				bounds = new FlxRect();
			bounds.make(X,Y,Width,Height);
			if(UpdateWorld)
				FlxU.worldBounds.copyFrom(bounds);
			update();
		}
		
		/**
		 * The screen is filled with this color and gradually returns to normal.
		 * 
		 * @param	Color		The color you want to use.
		 * @param	Duration	How long it takes for the flash to fade.
		 * @param	OnComplete	A function you want to run when the flash finishes.
		 * @param	Force		Force the effect to reset.
		 */
		public function flash(Color:uint=0xffffffff, Duration:Number=1, OnComplete:Function=null, Force:Boolean=false):void
		{
			if(!Force && (_fxFlashAlpha > 0.0))
				return;
			_fxFlashColor = Color;
			if(Duration <= 0)
				Duration = Number.MIN_VALUE;
			_fxFlashDuration = Duration;
			_fxFlashComplete = OnComplete;
			_fxFlashAlpha = 1.0;
		}
		
		/**
		 * The screen is gradually filled with this color.
		 * 
		 * @param	Color		The color you want to use.
		 * @param	Duration	How long it takes for the fade to finish.
		 * @param	OnComplete	A function you want to run when the fade finishes.
		 * @param	Force		Force the effect to reset.
		 */
		public function fade(Color:uint=0xffffffff, Duration:Number=1, OnComplete:Function=null, Force:Boolean=false):void
		{
			if(!Force && (_fxFadeAlpha > 0.0))
				return;
			_fxFadeColor = Color;
			if(Duration <= 0)
				Duration = Number.MIN_VALUE;
			_fxFadeDuration = Duration;
			_fxFadeComplete = OnComplete;
			_fxFadeAlpha = Number.MIN_VALUE;
		}
		
		/**
		 * A simple screen-shake effect.
		 * 
		 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
		 * @param	Duration	The length in seconds that the shaking effect should last.
		 * @param	OnComplete	A function you want to run when the shake effect finishes.
		 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
		 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants BOTH_AXES, VERTICAL_ONLY, or HORIZONTAL_ONLY).
		 */
		public function shake(Intensity:Number=0.05, Duration:Number=0.5, OnComplete:Function=null, Force:Boolean=true, Direction:uint=BOTH_AXES):void
		{
			if(!Force && ((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0)))
				return;
			_fxShakeIntensity = Intensity;
			_fxShakeDuration = Duration;
			_fxShakeComplete = OnComplete;
			_fxShakeDirection = Direction;
			_fxShakeOffset.make();
		}
		
		public function stopFX():void
		{
			_fxFlashAlpha = 0.0;
			_fxFadeAlpha = 0.0;
			_fxShakeDuration = 0;
			_flashBitmap.x = x;
			_flashBitmap.y = y;
		}
		
		public function copyFrom(Camera:FlxCamera):FlxCamera
		{
			if(Camera.bounds == null)
				bounds = null;
			else
			{
				if(bounds == null)
					bounds = new FlxRect();
				bounds.copyFrom(Camera.bounds);
			}
			follow(Camera.target,Camera.speed,Camera.lead.x,Camera.lead.y);
			return this;
		}
		
		public function get alpha():Number
		{
			return _flashBitmap.alpha;
		}
		
		public function set alpha(Alpha:Number):void
		{
			_flashBitmap.alpha = Alpha;
		}
		
		public function get angle():Number
		{
			return _flashBitmap.rotation;
		}
		
		public function set angle(Angle:Number):void
		{
			_flashBitmap.rotation = Angle;
		}
		
		public function get color():uint
		{
			return _color;
		}
		
		public function set color(Color:uint):void
		{
			_color = Color;
			var ct:ColorTransform = _flashBitmap.transform.colorTransform;
			ct.redMultiplier = (_color>>16)*0.00392;
			ct.greenMultiplier = (_color>>8&0xff)*0.00392;
			ct.blueMultiplier = (_color&0xff)*0.00392;
			_flashBitmap.transform.colorTransform = ct;
		}
		
		public function setScale(X:Number,Y:Number):void
		{
			_flashBitmap.scaleX = X;
			_flashBitmap.scaleY = Y;
		}
		
		public function getScale():FlxPoint
		{
			return _point.make(_flashBitmap.scaleX,_flashBitmap.scaleY);
		}
		
		public function fill(Color:uint=0):void
		{
			if(Color == 0)
				Color = bgColor;
			_fill.fillRect(_flashRect,Color);
			buffer.copyPixels(_fill,_flashRect,_flashPoint,null,null,true);
		}
		
		internal function drawFX():void
		{
			var a:Number;
			
			//Draw the "flash" special effect onto the buffer
			if(_fxFlashAlpha > 0.0)
			{
				a = _fxFlashColor>>24;
				fill((uint(((a <= 0)?0xff:a)*_fxFlashAlpha)<<24)+(_fxFlashColor&0x00ffffff));
			}
			
			//Draw the "flash" special effect onto the buffer
			if(_fxFadeAlpha > 0.0)
			{
				a = _fxFadeColor>>24;
				fill((uint(((a <= 0)?0xff:a)*_fxFadeAlpha)<<24)+(_fxFadeColor&0x00ffffff));
			}
			
			if((_fxShakeOffset.x != 0) || (_fxShakeOffset.y != 0))
			{
				_flashBitmap.x = x + _fxShakeOffset.x;
				_flashBitmap.y = y + _fxShakeOffset.y;
			}
		}
	}
}

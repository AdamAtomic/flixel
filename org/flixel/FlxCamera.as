package org.flixel
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	public class FlxCamera extends FlxBasic
	{
		static public var defaultZoom:uint;
		
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
		internal var _flashRect:Rectangle;
		
		public function FlxCamera(X:int,Y:int,Width:int,Height:int,Zoom:uint=0)
		{
			width = Width;
			height = Height;
			target = null;
			scroll = new FlxPoint();
			_scrollTarget = new FlxPoint();
			_point = new FlxPoint();
			speed = 0;
			lead = new FlxPoint();
			bounds = null;
			buffer = new BitmapData(width,height,true,FlxG.bgColor);
			_color = 0xffffff;

			_flashBitmap = new Bitmap(buffer);
			_flashBitmap.x = X;
			_flashBitmap.y = Y;
			if(Zoom == 0)
				Zoom = defaultZoom;
			_flashBitmap.scaleX = Zoom;
			_flashBitmap.scaleY = Zoom;
			_flashRect = new Rectangle(0,0,width,height);
		}
		
		override public function destroy():void
		{
			scroll = null;
			lead = null;
			bounds = null;
			buffer = null;
			_flashBitmap = null;
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
	}
}
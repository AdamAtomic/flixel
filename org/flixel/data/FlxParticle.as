package org.flixel.data
{
	import org.flixel.*;
	
	public class FlxParticle extends FlxSprite
	{
		protected var _bounce:Number;
		
		public function FlxParticle(Bounce:Number)
		{
			super();
			_bounce = Bounce;
		}
		
		override public function hitSide(Contact:FlxObject,Velocity:Number):void
		{
			velocity.x = -velocity.x * _bounce;
			if(angularVelocity != 0)
				angularVelocity = -angularVelocity * _bounce;
		}
		
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			onFloor = true;
			if(((velocity.y > 0)?velocity.y:-velocity.y) > _bounce*100)
			{
				velocity.y = -velocity.y * _bounce;
				if(angularVelocity != 0)
					angularVelocity *= -_bounce;
			}
			else
			{
				angularVelocity = 0;
				super.hitBottom(Contact,Velocity);
			}
			velocity.x *= _bounce;
		}
	}
}
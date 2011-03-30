package org.flixel
{
	
	public class FlxParticle extends FlxSprite
	{
		public var bounce:Number;
		public var lifespan:Number;
		
		public function FlxParticle(Bounce:Number=0,Lifespan:Number=0)
		{
			super();
			bounce = Bounce;
			lifespan = Lifespan;
		}
		
		override public function update():void
		{
			super.update();
			if(lifespan <= 0)
				return;
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0)
				kill();
		}
		
		override public function hitSide(Contact:FlxObject,Velocity:Number):void
		{
			velocity.x = -velocity.x * bounce;
			if(angularVelocity != 0)
				angularVelocity = -angularVelocity * bounce;
		}
		
		override public function hitBottom(Contact:FlxObject,Velocity:Number):void
		{
			onFloor = true;
			if(((velocity.y > 0)?velocity.y:-velocity.y) > bounce*100)
			{
				velocity.y = -velocity.y * bounce;
				if(angularVelocity != 0)
					angularVelocity *= -bounce;
			}
			else
			{
				angularVelocity = 0;
				super.hitBottom(Contact,Velocity);
			}
			velocity.x *= bounce;
		}
	}
}
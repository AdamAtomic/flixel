package org.flixel
{
	
	public class FlxParticle extends FlxSprite
	{
		public var lifespan:Number;
		
		public function FlxParticle()
		{
			super();
			lifespan = 0;
		}
		
		override public function update():void
		{
			//lifespan behavior
			if(lifespan <= 0)
				return;
			lifespan -= FlxG.elapsed;
			if(lifespan <= 0)
				kill();
			
			//simpler bounce/spin behavior for now
			if(touching)
			{
				if(angularVelocity != 0)
					angularVelocity = -angularVelocity * elasticity;
			}
			if(acceleration.y > 0) //special behavior for particles with gravity
			{
				if(touching & FLOOR)
				{
					drag.x = 200;
					
					if(!(wasTouching & FLOOR))
					{
						if(velocity.y < -elasticity*100)
						{
							if(angularVelocity != 0)
								angularVelocity *= -elasticity;
						}
						else
						{
							velocity.y = 0;
							angularVelocity = 0;
						}
					}
				}
				else
					drag.x = 0;
			}
			return;
		}
		
		
		/**
		 * Triggered whenever this sprite is launched by a <code>FlxEmitter</code>.
		 */
		public function onEmit():void
		{
			//nothing for now
		}
	}
}

package org.flixel
{
	/**
	 * This is an organizational class that can update and render a bunch of FlxCore objects
	 */
	public class FlxLayer extends FlxCore
	{
		/**
		 * Array of all the FlxCore objects that exist in this layer.
		 */
		protected var _children:Array;

		/**
		 * Constructor
		 */
		virtual public function FlxLayer()
		{
			_children = new Array();
		}
		
		/**
		 * Adds a new FlxCore subclass (FlxSprite, FlxBlock, etc) to the list of children
		 *
		 * @param	Core			The object you want to add
		 * @param	ShareScroll		Whether or not this FlxCore should sync up with this layer's scrollFactor
		 *
		 * @return	The same <code>FlxCore</code> object that was passed in.
		 */
		virtual public function add(Core:FlxCore,ShareScroll:Boolean=false):FlxCore
		{
			_children.push(Core);
			if(ShareScroll)
				Core.scrollFactor = scrollFactor;
			return Core;
		}
		
		/**
		 * Automatically goes through and calls update on everything you added,
		 * override this function to handle custom input and perform collisions.
		 */
		override public function update():void
		{
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			if((x != last.x) || (y != last.y))
			{
				moved = true;
				mx = x - last.x;
				my = y - last.y;
			}
			super.update();
			
			var c:FlxCore;
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
			{
				c = _children[i] as FlxCore;
				if((c != null) && c.exists)
				{
					if(moved)
					{
						c.x += mx;
						c.y += my;
					}
					if(c.active)
						c.update();
				}
			}
		}
		
		/**
		 * Automatically goes through and calls render on everything you added,
		 * override this loop to control render order manually.
		 */
		override public function render():void
		{
			super.render();
			var c:FlxCore;
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
			{
				c = _children[i];
				if((c != null) && c.exists && c.visible) c.render();
			}
		}
		
		/**
		 * Override this function to handle any deleting or "shutdown" type operations you might need,
		 * such as removing traditional Flash children like Sprite objects.
		 */
		override public function destroy():void
		{
			super.destroy();
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
				_children[i].destroy();
			_children.length = 0;
		}
		
		/**
		 * Returns the array of children
		 */
		public function children():Array { return _children; }
	}
}

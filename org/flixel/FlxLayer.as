package org.flixel
{
	//@desc		This is an organizational class that can update and render a bunch of FlxCore objects
	public class FlxLayer extends FlxCore
	{
		protected var _children:Array;

		//@desc		Constructor		
		virtual public function FlxLayer()
		{
			_children = new Array();
		}
		
		//@desc		Adds a new FlxCore subclass (FlxSprite, FlxBlock, etc) to the list of children
		//@param	Core			The object you want to add
		//@param	ShareScroll		Whether or not this FlxCore should sync up with this layer's scrollFactor
		virtual public function add(Core:FlxCore,ShareScroll:Boolean=false):FlxCore
		{
			_children.push(Core);
			Core.x += x;
			Core.y += y;
			if(ShareScroll)
				Core.scrollFactor = scrollFactor;
			return Core;
		}
		
		//@desc		Automatically goes through and calls update on everything you added, override this function to handle custom input and perform collisions
		override public function update():void
		{
			super.update();
			var mx:Number;
			var my:Number;
			var moved:Boolean = false;
			if((x != last.x) || (y != last.y))
			{
				moved = true;
				mx = x - last.x;
				my = y - last.y;
			}
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
				if((_children[i] != null) && _children[i].exists)
				{
					if(moved)
					{
						_children[i].x += mx;
						_children[i].y += my;
					}
					if(_children[i].active)
						_children[i].update();
				}
		}
		
		//@desc		Automatically goes through and calls render on everything you added, override this loop to do crazy graphical stuffs I guess?
		override public function render():void
		{
			super.render();
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
				if((_children[i] != null) && _children[i].exists && _children[i].visible) _children[i].render();
		}
		
		//@desc		Override this function to handle any deleting or "shutdown" type operations you might need (such as removing traditional Flash children like Sprite objects)
		override public function destroy():void
		{
			super.destroy();
			var cl:uint = _children.length;
			for(var i:uint = 0; i < cl; i++)
				_children[i].destroy();
			_children.length = 0;
		}
		
		//@desc		Returns the array of children
		public function children():Array { return _children; }
	}
}

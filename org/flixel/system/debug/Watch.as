package org.flixel.system.debug
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import org.flixel.FlxU;
	import org.flixel.system.FlxWindow;
	
	/**
	 * A Visual Studio-style "watch" window, for use in the debugger overlay.
	 * Track the values of any public variable in real-time, and/or edit their values on the fly.
	 * 
	 * @author Adam Atomic
	 */
	public class Watch extends FlxWindow
	{
		static protected const MAX_LOG_LINES:uint = 1024;
		static protected const LINE_HEIGHT:uint = 15;
		
		/**
		 * Whether a watch entry is currently being edited or not. 
		 */		
		public var editing:Boolean;
		
		protected var _names:Sprite;
		protected var _values:Sprite;
		protected var _watching:Array;
		
		/**
		 * Creates a new window object.  This Flash-based class is mainly (only?) used by <code>FlxDebugger</code>.
		 * 
		 * @param Title			The name of the window, displayed in the header bar.
		 * @param Width			The initial width of the window.
		 * @param Height		The initial height of the window.
		 * @param Resizable		Whether you can change the size of the window with a drag handle.
		 * @param Bounds		A rectangle indicating the valid screen area for the window.
		 * @param BGColor		What color the window background should be, default is gray and transparent.
		 * @param TopColor		What color the window header bar should be, default is black and transparent.
		 */
		public function Watch(Title:String, Width:Number, Height:Number, Resizable:Boolean=true, Bounds:Rectangle=null, BGColor:uint=0x7f7f7f7f, TopColor:uint=0x7f000000)
		{
			super(Title, Width, Height, Resizable, Bounds, BGColor, TopColor);
			
			_names = new Sprite();
			_names.x = 2;
			_names.y = 15;
			addChild(_names);

			_values = new Sprite();
			_values.x = 2;
			_values.y = 15;
			addChild(_values);
			
			_watching = new Array();
			
			editing = false;
			
			removeAll();
		}
		
		/**
		 * Clean up memory.
		 */
		override public function destroy():void
		{
			removeChild(_names);
			_names = null;
			removeChild(_values);
			_values = null;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
				(_watching[i++] as WatchEntry).destroy();
			_watching = null;
			super.destroy();
		}

		/**
		 * Add a new variable to the watch window.
		 * Has some simple code in place to prevent
		 * accidentally watching the same variable twice.
		 * 
		 * @param AnyObject		The <code>Object</code> containing the variable you want to track, e.g. this or Player.velocity.
		 * @param VariableName	The <code>String</code> name of the variable you want to track, e.g. "width" or "x".
		 * @param DisplayName	Optional <code>String</code> that can be displayed in the watch window instead of the basic class-name information.
		 */
		public function add(AnyObject:Object,VariableName:String,DisplayName:String=null):void
		{
			//Don't add repeats
			var watchEntry:WatchEntry;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				watchEntry = _watching[i++] as WatchEntry;
				if((watchEntry.object == AnyObject) && (watchEntry.field == VariableName))
					return;
			}
			
			//Good, no repeats, add away!
			watchEntry = new WatchEntry(_watching.length*LINE_HEIGHT,_width/2,_width/2-10,AnyObject,VariableName,DisplayName);
			_names.addChild(watchEntry.nameDisplay);
			_values.addChild(watchEntry.valueDisplay);
			_watching.push(watchEntry);
		}
		
		/**
		 * Remove a variable from the watch window.
		 * 
		 * @param AnyObject		The <code>Object</code> containing the variable you want to remove, e.g. this or Player.velocity.
		 * @param VariableName	The <code>String</code> name of the variable you want to remove, e.g. "width" or "x".  If left null, this will remove all variables of that object. 
		 */
		public function remove(AnyObject:Object,VariableName:String=null):void
		{
			//splice out the requested object
			var watchEntry:WatchEntry;
			var i:int = _watching.length-1;
			while(i >= 0)
			{
				watchEntry = _watching[i];
				if((watchEntry.object == AnyObject) && ((VariableName == null) || (watchEntry.field == VariableName)))
				{
					_watching.splice(i,1);
					_names.removeChild(watchEntry.nameDisplay);
					_values.removeChild(watchEntry.valueDisplay);
					watchEntry.destroy();
				}
				i--;
			}
			watchEntry = null;
			
			//reset the display heights of the remaining objects
			i = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				(_watching[i] as WatchEntry).setY(i*LINE_HEIGHT);
				i++;
			}
		}
		
		/**
		 * Remove everything from the watch window.
		 */
		public function removeAll():void
		{
			var watchEntry:WatchEntry;
			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				watchEntry = _watching.pop();
				_names.removeChild(watchEntry.nameDisplay);
				_values.removeChild(watchEntry.valueDisplay);
				watchEntry.destroy();
				i++
			}
			_watching.length = 0;
		}

		/**
		 * Update all the entries in the watch window.
		 */
		public function update():void
		{
			editing = false;
			var i:uint = 0;
			var l:uint = _watching.length;
			while(i < l)
			{
				if(!(_watching[i++] as WatchEntry).updateValue())
					editing = true;
			}
		}
		
		/**
		 * Force any watch entries currently being edited to submit their changes.
		 */
		public function submit():void
		{
			var i:uint = 0;
			var l:uint = _watching.length;
			var watchEntry:WatchEntry;
			while(i < l)
			{
				watchEntry = _watching[i++] as WatchEntry;
				if(watchEntry.editing)
					watchEntry.submit();
			}
			editing = false;
		}
		
		/**
		 * Update the Flash shapes to match the new size, and reposition the header, shadow, and handle accordingly.
		 * Also adjusts the width of the entries and stuff, and makes sure there is room for all the entries.
		 */
		override protected function updateSize():void
		{
			if(_height < _watching.length*LINE_HEIGHT + 17)
				_height = _watching.length*LINE_HEIGHT + 17;

			super.updateSize();

			_values.x = _width/2 + 2;

			var i:int = 0;
			var l:uint = _watching.length;
			while(i < l)
				(_watching[i++] as WatchEntry).updateWidth(_width/2,_width/2-10);
		}
	}
}

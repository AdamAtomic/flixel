package org.flixel
{
	import flash.display.Graphics;
	
	public class FlxPath
	{
		static public var debugDrawTracker:Boolean;
		
		public var nodes:Array;
		
		//NOTE: doesn't actually affect anything, just used for debug visuals
		public var scrollFactor:FlxPoint;
		
		protected var _debugDrawSwitches:Array;
		protected var _point:FlxPoint;
		
		public function FlxPath(Nodes:Array=null)
		{
			if(Nodes == null)
				nodes = new Array();
			else
				nodes = Nodes;
			_debugDrawSwitches = new Array();
			_point = new FlxPoint();
			scrollFactor = new FlxPoint();
		}
		
		public function destroy():void
		{
			nodes = null;
		}
		
		public function add(X:Number,Y:Number):void
		{
			nodes.push(new FlxPoint(X,Y));
		}
		
		public function addAt(X:Number, Y:Number, Index:uint):void
		{
			if(Index > nodes.length)
				Index = nodes.length;
			nodes.splice(Index,0,new FlxPoint(X,Y));
		}
		
		public function addPoint(Point:FlxPoint,AsReference:Boolean=false):void
		{
			if(AsReference)
				nodes.push(Point);
			else
				nodes.push(new FlxPoint(Point.x,Point.y));
		}
		
		public function addPointAt(Point:FlxPoint,Index:uint,AsReference:Boolean=false):void
		{
			if(Index > nodes.length)
				Index = nodes.length;
			if(AsReference)
				nodes.splice(Index,0,Point);
			else
				nodes.splice(Index,0,new FlxPoint(Point.x,Point.y));
		}
		
		//note: only works with points added by reference or with references from nodes itself
		public function remove(Point:FlxPoint):FlxPoint
		{
			var index:int = nodes.indexOf(Point);
			if(index >= 0)
				return nodes.splice(index,1);
			else
				return null;
		}
		
		public function removeAt(Index:uint):FlxPoint
		{
			if(nodes.length <= 0)
				return null;
			if(Index >= nodes.length)
				Index = nodes.length-1;
			return nodes.splice(Index,1);
		}
		
		public function head():FlxPoint
		{
			if(nodes.length > 0)
				return nodes[0];
			return null;
		}
		
		public function tail():FlxPoint
		{
			if(nodes.length > 0)
				return nodes[nodes.length-1];
			return null;
		}
		
		public function drawDebug(Camera:FlxCamera=null):void
		{
			if(nodes.length <= 0)
				return;

			//Figure out which camera to draw to, but only draw the path once per frame.
			if(Camera == null)
				Camera = FlxG.camera;
			var debugIndex:int = FlxG.cameras.indexOf(Camera);
			if(debugIndex < 0)
				return;
			if(debugIndex >= _debugDrawSwitches.length)
				_debugDrawSwitches.push(!debugDrawTracker);
			if(_debugDrawSwitches[debugIndex] == debugDrawTracker)
				return;
			_debugDrawSwitches[debugIndex] = !_debugDrawSwitches[debugIndex];
			
			//Set up our global flash graphics object to draw out the path
			var gfx:Graphics = FlxG.flashGfx;
			gfx.clear();
			
			//Then fill up the object with node and path graphics
			var p:FlxPoint;
			var n:FlxPoint;
			var i:uint = 0;
			var l:uint = nodes.length;
			while(i < l)
			{
				//get a reference to the current node
				p = nodes[i] as FlxPoint;
				
				//find the screen position of the node on this camera
				_point.x = int(p.x - Camera.scroll.x*scrollFactor.x);
				_point.y = int(p.y - Camera.scroll.y*scrollFactor.y);
				
				//decide what color this node should be
				var nodeSize:uint = 2;
				if((i == 0) || (i == l-1))
					nodeSize *= 2;
				var color:uint = 0xffffff;
				if(l > 1)
				{
					if(i == 0)
						color = FlxG.GREEN;
					else if(i == l-1)
						color = FlxG.RED;
				}
				
				//draw a box for the node
				gfx.beginFill(color,0.5);
				gfx.lineStyle();
				gfx.drawRect(_point.x-nodeSize*0.5,_point.y-nodeSize*0.5,nodeSize,nodeSize);
				gfx.endFill();

				//then find the next node in the path
				var linealpha:Number = 0.3;
				if(i < l-1)
					n = nodes[i+1];
				else
				{
					n = nodes[0];
					linealpha = 0.15;
				}
				
				//then draw a line to the next node
				gfx.moveTo(_point.x,_point.y);
				gfx.lineStyle(1,0xffffff,linealpha);
				gfx.lineTo(int(n.x - Camera.scroll.x*scrollFactor.x),int(n.y - Camera.scroll.y*scrollFactor.y));

				i++;
			}
			
			//then stamp the path down onto the game buffer
			Camera.buffer.draw(FlxG.flashGfxSprite);
		}
	}
}
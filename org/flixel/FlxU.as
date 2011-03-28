package org.flixel
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	
	import org.flixel.helpers.FlxQuadTree;
	
	public class FlxU
	{
		/**
		 * Helps to eliminate false collisions and/or rendering glitches caused by rounding errors
		 */
		static protected const ROUNDING_ERROR:Number = 0.0000001;
		/**
		 * The last quad tree you generated will be stored here for reference or whatever.
		 */
		static public var quadTree:FlxQuadTree;
		
		/**
		 * Opens a web page in a new tab or window.
		 * 
		 * @param	URL		The address of the web page.
		 */
		static public function openURL(URL:String):void
		{
			navigateToURL(new URLRequest(URL), "_blank");
		}
		
		static public function abs(Value:Number):Number
		{
			return (Value>0)?Value:-Value;
		}
		
		static public function floor(Value:Number):Number
		{
			var n:Number = int(Value);
			return (Value>0)?(n):((n!=Value)?(n-1):(n));
		}
		
		static public function ceil(Value:Number):Number
		{
			var n:Number = int(Value);
			return (Value>0)?((n!=Value)?(n+1):(n)):(n);
		}
		
		static public function min(Number1:Number,Number2:Number):Number
		{
			return (Number1 <= Number2)?Number1:Number2;
		}
		
		static public function max(Number1:Number,Number2:Number):Number
		{
			return (Number1 >= Number2)?Number1:Number2;
		}
		
		static public function bound(Value:Number,Min:Number,Max:Number):Number
		{
			var lb:Number = (Value<Min)?Min:Value;
			return (lb>Max)?Max:lb;
		}
		
		/**
		 * Generates a random number based on the seed provided.
		 * 
		 * @param	Seed	A number between 0 and 1, used to generate a predictable random number (very optional).
		 * 
		 * @return	A <code>Number</code> between 0 and 1.
		 */
		static public function srand(Seed:Number):Number
		{
			return ((69621 * int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
		}
		
		/**
		 * Useful for finding out how long it takes to execute specific blocks of code.
		 * 
		 * @return	A <code>uint</code> to be passed to <code>FlxU.endProfile()</code>.
		 */
		static public function startProfile():uint
		{
			return getTimer();
		}
		
		/**
		 * Useful for finding out how long it takes to execute specific blocks of code.
		 * 
		 * @param	Start	A <code>uint</code> created by <code>FlxU.startProfile()</code>.
		 * @param	Name	Optional tag (for debug console display).  Default value is "Profiler".
		 * @param	Log		Whether or not to log this elapsed time in the debug console.
		 * 
		 * @return	A <code>uint</code> to be passed to <code>FlxU.endProfile()</code>.
		 */
		static public function endProfile(Start:uint,Name:String="Profiler",Log:Boolean=true):uint
		{
			var t:uint = getTimer();
			if(Log)
				FlxG.log(Name+": "+((t-Start)/1000)+"s");
			return t;
		}
		
		/**
		 * Rotates a point in 2D space around another point by the given angle.
		 * 
		 * @param	X		The X coordinate of the point you want to rotate.
		 * @param	Y		The Y coordinate of the point you want to rotate.
		 * @param	PivotX	The X coordinate of the point you want to rotate around.
		 * @param	PivotY	The Y coordinate of the point you want to rotate around.
		 * @param	Angle	Rotate the point by this many degrees.
		 * @param	P		Optional <code>FlxPoint</code> to store the results in.
		 * 
		 * @return	A <code>FlxPoint</code> containing the coordinates of the rotated point.
		 */
		static public function rotatePoint(X:Number, Y:Number, PivotX:Number, PivotY:Number, Angle:Number,P:FlxPoint=null):FlxPoint
		{
			var sin:Number = 0;
			var cos:Number = 0;
			var radians:Number = Angle * -0.017453293;
			while (radians < -3.14159265)
				radians += 6.28318531;
			while (radians >  3.14159265)
				radians = radians - 6.28318531;

			if (radians < 0)
			{
				sin = 1.27323954 * radians + .405284735 * radians * radians;
				if (sin < 0)
					sin = .225 * (sin *-sin - sin) + sin;
				else
					sin = .225 * (sin * sin - sin) + sin;
			}
			else
			{
				sin = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (sin < 0)
					sin = .225 * (sin *-sin - sin) + sin;
				else
					sin = .225 * (sin * sin - sin) + sin;
			}
			
			radians += 1.57079632;
			if (radians >  3.14159265)
				radians = radians - 6.28318531;
			if (radians < 0)
			{
				cos = 1.27323954 * radians + 0.405284735 * radians * radians;
				if (cos < 0)
					cos = .225 * (cos *-cos - cos) + cos;
				else
					cos = .225 * (cos * cos - cos) + cos;
			}
			else
			{
				cos = 1.27323954 * radians - 0.405284735 * radians * radians;
				if (cos < 0)
					cos = .225 * (cos *-cos - cos) + cos;
				else
					cos = .225 * (cos * cos - cos) + cos;
			}

			var dx:Number = X-PivotX;
			var dy:Number = PivotY+Y; //Y axis is inverted in flash, normally this would be a subtract operation
			if(P == null)
				P = new FlxPoint();
			P.x = PivotX + cos*dx - sin*dy;
			P.y = PivotY - sin*dx - cos*dy;
			return P;
		};
		
		/**
		 * Calculates the angle between two points.  0 degrees points straight up.
		 * 
		 * @param	Point1		The X coordinate of the point.
		 * @param	Point2		The Y coordinate of the point.
		 * 
		 * @return	The angle in degrees, between -90 and 270.
		 */
		static public function getAngle(Point1:FlxPoint, Point2:FlxPoint):Number
		{
			var x:Number = Point2.x - Point1.x;
			var y:Number = Point2.y - Point1.y;
			var c1:Number = 3.14159265 * 0.25;
			var c2:Number = 3 * c1;
			var ay:Number = (y < 0)?-y:y;
			var angle:Number = 0;
			if (x >= 0)
				angle = c1 - c1 * ((x - ay) / (x + ay));
			else
				angle = c2 - c1 * ((x + ay) / (ay - x));
			return ((y < 0)?-angle:angle)*57.2957796 + 90;
		};
		
		/**
		 * Calculate the distance between two points.
		 * 
		 * @param Point1	A <code>FlxPoint</code> object referring to the first location.
		 * @param Point2	A <code>FlxPoint</code> object referring to the second location.
		 * 
		 * @return	The distance between the two points as a floating point <code>Number</code> object.
		 */
		static public function getDistance(Point1:FlxPoint,Point2:FlxPoint):Number
		{
			var dx:Number = Point1.x - Point2.x;
			var dy:Number = Point1.y - Point2.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * Generate a Flash <code>uint</code> color from RGBA components.
		 * 
		 * @param   Red     The red component, between 0 and 255.
		 * @param   Green   The green component, between 0 and 255.
		 * @param   Blue    The blue component, between 0 and 255.
		 * @param   Alpha   How opaque the color should be, either between 0 and 1 or 0 and 255.
		 * 
		 * @return  The color as a <code>uint</code>.
		 */
		static public function makeColor(Red:uint, Green:uint, Blue:uint, Alpha:Number=1.0):uint
		{
			return (((Alpha>1)?Alpha:(Alpha * 255)) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF);
		}

		/**
		 * Generate a Flash <code>uint</code> color from HSB components.
		 * 
		 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
		 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
		 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
		 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
		 * 
		 * @return	The color as a <code>uint</code>.
		 */
		static public function makeColorFromHSB(Hue:Number,Saturation:Number,Brightness:Number,Alpha:Number=1.0):uint
		{
			var red:Number;
			var green:Number;
			var blue:Number;
			if(Saturation == 0.0)
			{
				red   = Brightness;
				green = Brightness;        
				blue  = Brightness;
			}       
			else
			{
				if(Hue == 360)
					Hue = 0;
				var slice:int = Hue/60;
				var hf:Number = Hue/60 - slice;
				var aa:Number = Brightness*(1 - Saturation);
				var bb:Number = Brightness*(1 - Saturation*hf);
				var cc:Number = Brightness*(1 - Saturation*(1.0 - hf));
				switch (slice)
				{
					case 0: red = Brightness; green = cc;   blue = aa;  break;
					case 1: red = bb;  green = Brightness;  blue = aa;  break;
					case 2: red = aa;  green = Brightness;  blue = cc;  break;
					case 3: red = aa;  green = bb;   blue = Brightness; break;
					case 4: red = cc;  green = aa;   blue = Brightness; break;
					case 5: red = Brightness; green = aa;   blue = bb;  break;
					default: red = 0;  green = 0;    blue = 0;   break;
				}
			}
			
			return (((Alpha>1)?Alpha:(Alpha * 255)) & 0xFF) << 24 | uint(red*255) << 16 | uint(green*255) << 8 | uint(blue*255);
		}
		
		/**
		 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
		 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1.
		 * 
		 * @param	Color	The color you want to break into components.
		 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
		 * 
		 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
		 */
		static public function getRGBA(Color:uint,Results:Array=null):Array
		{
			if(Results == null)
				Results = new Array();
			Results[0] = (Color >> 16) & 0xFF;
			Results[1] = (Color >> 8) & 0xFF;
			Results[2] = Color & 0xFF;
			Results[3] = Number((Color >> 24) & 0xFF) / 255;
			return Results;
		}
		
		/**
		 * Loads an array with the HSB values of a Flash <code>uint</code> color.
		 * Hue is a value between 0 and 360.  Saturation, Brightness and Alpha
		 * are as floating point numbers between 0 and 1.
		 * 
		 * @param	Color	The color you want to break into components.
		 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
		 * 
		 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
		 */
		static public function getHSB(Color:uint,Results:Array=null):Array
		{
			if(Results == null)
				Results = new Array();
			
			var red:Number = Number((Color >> 16) & 0xFF) / 255;
			var green:Number = Number((Color >> 8) & 0xFF) / 255;
			var blue:Number = Number((Color) & 0xFF) / 255;
			
			var m:Number = (red>green)?red:green;
			var dmax:Number = (m>blue)?m:blue;
			m = (red>green)?green:red;
			var dmin:Number = (m>blue)?blue:m;
			var range:Number = dmax - dmin;
			
			Results[2] = dmax;
			Results[1] = 0;
			Results[0] = 0;
			
			if(dmax != 0)
				Results[1] = range / dmax;
			if(Results[1] != 0) 
			{
				if (red == dmax)
					Results[0] = (green - blue) / range;
				else if (green == dmax)
					Results[0] = 2 + (blue - red) / range;
				else if (blue == dmax)
					Results[0] = 4 + (red - green) / range;
				Results[0] *= 60;
				if(Results[0] < 0)
					Results[0] += 360;
			}
			
			Results[3] = Number((Color >> 24) & 0xFF) / 255;
			return Results;
		}
		
		static public function formatTime(Seconds:Number):String
		{
			var ts:String = uint(Seconds/60) + ":";
			var dts:uint = uint(Seconds)%60;
			if(dts < 10)
				ts += "0"+dts;
			else
				ts += dts;
			return ts;
		}
		
		static public function formatArray(A:Array):String
		{
			if((A == null) || (A.length <= 0))
				return null;
			var s:String = A[0].toString();
			for(var i:uint = 1; i < A.length; i++)
				s += ", " + A[i].toString();
			return s;
		}
		
		static public function formatMoney(Amount:Number,ShowDecimal:Boolean=true):String
		{
			var h:int;
			var a:int = Amount;
			var s:String = "";
			var comma:String = "";
			var zeroes:String = "";
			while(a > 0)
			{
				if((s.length > 0) && comma.length <= 0)
					comma = ",";
				zeroes = "";
				h = a - int(a/1000)*1000;
				a /= 1000;
				if(a > 0)
				{
					if(h < 100)
						zeroes += "0";
					if(h < 10)
						zeroes += "0";
				}
				s = zeroes + h + comma + s;
			}
			if(ShowDecimal)
			{
				a = int(Amount*100)-(int(Amount)*100);
				s += "." + a;
				if(a < 10)
					s += "0";
			}
			return s;
		}
		
		/**
		 * Get the <code>String</code> name of any <code>Object</code>.
		 * 
		 * @param	Obj		The <code>Object</code> object in question.
		 * @param	Simple	Returns only the class name, not the package or packages.
		 * 
		 * @return	The name of the <code>Class</code> as a <code>String</code> object.
		 */
		static public function getClassName(Obj:Object,Simple:Boolean=false):String
		{
			var s:String = getQualifiedClassName(Obj);
			s = s.replace("::",".");
			if(Simple)
				s = s.substr(s.lastIndexOf(".")+1);
			return s;
		};
		
		/**
		 * Look up a <code>Class</code> object by its string name.
		 * 
		 * @param	Name	The <code>String</code> name of the <code>Class</code> you are interested in.
		 * 
		 * @return	A <code>Class</code> object.
		 */
		static public function getClass(Name:String):Class
		{
			return getDefinitionByName(Name) as Class;
		}
		
		/**
		 * A tween-like function that takes a starting velocity
		 * and some other factors and returns an altered velocity.
		 * 
		 * @param	Velocity		Any component of velocity (e.g. 20).
		 * @param	Acceleration	Rate at which the velocity is changing.
		 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
		 * @param	Max				An absolute value cap for the velocity.
		 * 
		 * @return	The altered Velocity value.
		 */
		static public function computeVelocity(Velocity:Number, Acceleration:Number=0, Drag:Number=0, Max:Number=10000):Number
		{
			if(Acceleration != 0)
				Velocity += Acceleration*FlxG.elapsed;
			else if(Drag != 0)
			{
				var d:Number = Drag*FlxG.elapsed;
				if(Velocity - d > 0)
					Velocity = Velocity - d;
				else if(Velocity + d < 0)
					Velocity += d;
				else
					Velocity = 0;
			}
			if((Velocity != 0) && (Max != 10000))
			{
				if(Velocity > Max)
					Velocity = Max;
				else if(Velocity < -Max)
					Velocity = -Max;
			}
			return Velocity;
		}

		/**
		 * Call this function to specify a more efficient boundary for your game world.
		 * This boundary is used by <code>overlap()</code> and <code>collide()</code>, so it
		 * can't hurt to have it be the right size!  Flixel will invent a size for you, but
		 * it's pretty huge - 256x the size of the screen, whatever that may be.
		 * Leave width and height empty if you want to just update the game world's position.
		 * 
		 * @param	X			The X-coordinate of the left side of the game world.
		 * @param	Y			The Y-coordinate of the top of the game world.
		 * @param	Width		Desired width of the game world.
		 * @param	Height		Desired height of the game world.
		 * @param	Divisions	Pass a non-zero value to set <code>quadTreeDivisions</code>.  Default value is 3.
		 */
		static public function setWorldBounds(X:Number=0, Y:Number=0, Width:Number=0, Height:Number=0, Divisions:uint=3):void
		{
			if(FlxQuadTree.bounds == null)
				FlxQuadTree.bounds = new FlxRect();
			FlxQuadTree.bounds.x = X;
			FlxQuadTree.bounds.y = Y;
			if(Width > 0)
				FlxQuadTree.bounds.width = Width;
			if(Height > 0)
				FlxQuadTree.bounds.height = Height;
			if(Divisions > 0)
				FlxQuadTree.divisions = Divisions;
		}
		
		/**
		 * Call this function to see if one <code>FlxObject</code> overlaps another.
		 * Can be called with one object and one group, or two groups, or two objects,
		 * whatever floats your boat!  It will put everything into a quad tree and then
		 * check for overlaps.  For maximum performance try bundling a lot of objects
		 * together using a <code>FlxGroup</code> (even bundling groups together!)
		 * NOTE: does NOT take objects' scrollfactor into account.
		 * 
		 * @param	Object1		The first object or group you want to check.
		 * @param	Object2		The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
		 * @param	Callback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject);</code>  If no function is provided, <code>FlxQuadTree</code> will call <code>kill()</code> on both objects.
		 */
		static public function overlap(Object1:FlxObject,Object2:FlxObject,Callback:Function=null):Boolean
		{
			if( (Object1 == null) || !Object1.exists ||
				(Object2 == null) || !Object2.exists )
				return false;
			if(quadTree != null)
				quadTree.destroy();
			quadTree = new FlxQuadTree(FlxQuadTree.bounds.x,FlxQuadTree.bounds.y,FlxQuadTree.bounds.width,FlxQuadTree.bounds.height);
			quadTree.add(Object1,FlxQuadTree.A_LIST);
			if(Object1 === Object2)
				return quadTree.overlap(false,Callback);
			quadTree.add(Object2,FlxQuadTree.B_LIST);
			return quadTree.overlap(true,Callback);
		}
		
		/**
		 * Call this function to see if one <code>FlxObject</code> collides with another.
		 * Can be called with one object and one group, or two groups, or two objects,
		 * whatever floats your boat!  It will put everything into a quad tree and then
		 * check for collisions.  For maximum performance try bundling a lot of objects
		 * together using a <code>FlxGroup</code> (even bundling groups together!)
		 * NOTE: does NOT take objects' scrollfactor into account.
		 * 
		 * @param	Object1		The first object or group you want to check.
		 * @param	Object2		The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
		 */
		static public function collide(Object1:FlxObject,Object2:FlxObject):Boolean
		{
			if( (Object1 == null) || !Object1.exists ||
				(Object2 == null) || !Object2.exists )
				return false;
			if(quadTree != null)
				quadTree.destroy();
			quadTree = new FlxQuadTree(FlxQuadTree.bounds.x,FlxQuadTree.bounds.y,FlxQuadTree.bounds.width,FlxQuadTree.bounds.height);
			quadTree.add(Object1,FlxQuadTree.A_LIST);
			var match:Boolean = Object1 === Object2;
			if(!match)
				quadTree.add(Object2,FlxQuadTree.B_LIST);
			var cx:Boolean = quadTree.overlap(!match,solveXCollision);
			var cy:Boolean = quadTree.overlap(!match,solveYCollision);
			return cx || cy;			
		}
		
		/**
		 * This quad tree callback function can be used externally as well.
		 * Takes two objects and separates them along their X axis (if possible/reasonable).
		 * 
		 * @param	Object1		The first object or group you want to check.
		 * @param	Object2		The second object or group you want to check.
		 */
		static public function solveXCollision(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			//Avoid messed up collisions ahead of time
			var o1:Number = Object1.colVector.x;
			var o2:Number = Object2.colVector.x;
			if(o1 == o2)
				return false;
			
			//Give the objects a heads up that we're about to resolve some collisions
			Object1.preCollide(Object2);
			Object2.preCollide(Object1);

			//Basic resolution variables
			var f1:Boolean;
			var f2:Boolean;
			var overlap:Number;
			var hit:Boolean = false;
			var p1hn2:Boolean;
			
			//Directional variables
			var obj1Stopped:Boolean = o1 == 0;
			var obj1MoveNeg:Boolean = o1 < 0;
			var obj1MovePos:Boolean = o1 > 0;
			var obj2Stopped:Boolean = o2 == 0;
			var obj2MoveNeg:Boolean = o2 < 0;
			var obj2MovePos:Boolean = o2 > 0;
			
			//Offset loop variables
			var i1:uint;
			var i2:uint;
			var obj1Hull:FlxRect = Object1.colHullX;
			var obj2Hull:FlxRect = Object2.colHullX;
			var co1:Array = Object1.colOffsets;
			var co2:Array = Object2.colOffsets;
			var l1:uint = co1.length;
			var l2:uint = co2.length;
			var ox1:Number;
			var oy1:Number;
			var ox2:Number;
			var oy2:Number;
			var r1:Number;
			var r2:Number;
			var sv1:Number;
			var sv2:Number;
			
			//Decide based on object's movement patterns if it was a right-side or left-side collision
			p1hn2 = ((obj1Stopped && obj2MoveNeg) || (obj1MovePos && obj2Stopped) || (obj1MovePos && obj2MoveNeg) || //the obvious cases
					(obj1MoveNeg && obj2MoveNeg && (((o1>0)?o1:-o1) < ((o2>0)?o2:-o2))) || //both moving left, obj2 overtakes obj1
					(obj1MovePos && obj2MovePos && (((o1>0)?o1:-o1) > ((o2>0)?o2:-o2))) ); //both moving right, obj1 overtakes obj2
			
			//Check to see if these objects allow these collisions
			if(p1hn2?(!Object1.collideRight || !Object2.collideLeft):(!Object1.collideLeft || !Object2.collideRight))
				return false;
			
			//this looks insane, but we're just looping through collision offsets on each object
			i1 = 0;
			while(i1 < l1)
			{
				ox1 = co1[i1].x;
				oy1 = co1[i1].y;
				obj1Hull.x += ox1;
				obj1Hull.y += oy1;
				i2 = 0;
				while(i2 < l2)
				{
					ox2 = co2[i2].x;
					oy2 = co2[i2].y;
					obj2Hull.x += ox2;
					obj2Hull.y += oy2;
					
					//See if it's a actually a valid collision
					if( (obj1Hull.x + obj1Hull.width  < obj2Hull.x + ROUNDING_ERROR) ||
						(obj1Hull.x + ROUNDING_ERROR > obj2Hull.x + obj2Hull.width) ||
						(obj1Hull.y + obj1Hull.height < obj2Hull.y + ROUNDING_ERROR) ||
						(obj1Hull.y + ROUNDING_ERROR > obj2Hull.y + obj2Hull.height) )
					{
						obj2Hull.x = obj2Hull.x - ox2;
						obj2Hull.y = obj2Hull.y - oy2;
						i2++;
						continue;
					}

					//Calculate the overlap between the objects
					if(p1hn2)
					{
						if(obj1MoveNeg)
							r1 = obj1Hull.x + Object1.colHullY.width;
						else
							r1 = obj1Hull.x + obj1Hull.width;
						if(obj2MoveNeg)
							r2 = obj2Hull.x;
						else
							r2 = obj2Hull.x + obj2Hull.width - Object2.colHullY.width;
					}
					else
					{
						if(obj2MoveNeg)
							r1 = -obj2Hull.x - Object2.colHullY.width;
						else
							r1 = -obj2Hull.x - obj2Hull.width;
						if(obj1MoveNeg)
							r2 = -obj1Hull.x;
						else
							r2 = -obj1Hull.x - obj1Hull.width + Object1.colHullY.width;
					}
					overlap = r1 - r2;
					
					//Slightly smarter version of checking if objects are 'fixed' in space or not
					f1 = Object1.fixed;
					f2 = Object2.fixed;
					if(f1 && f2)
					{
						f1 &&= (Object1.colVector.x == 0) && (o1 == 0);
						f2 &&= (Object2.colVector.x == 0) && (o2 == 0);
					}

					//Last chance to skip out on a bogus collision resolution
					if( (overlap == 0) ||
						((!f1 && ((overlap>0)?overlap:-overlap) > obj1Hull.width*0.8)) ||
						((!f2 && ((overlap>0)?overlap:-overlap) > obj2Hull.width*0.8)) )
					{
						obj2Hull.x = obj2Hull.x - ox2;
						obj2Hull.y = obj2Hull.y - oy2;
						i2++;
						continue;
					}
					hit = true;
					
					//Adjust the objects according to their flags and stuff
					sv1 = Object2.velocity.x;
					sv2 = Object1.velocity.x;
					if(!f1 && f2)
						Object1.x = Object1.x - overlap;
					else if(f1 && !f2)
						Object2.x += overlap;
					else if(!f1 && !f2)
					{
						overlap /= 2;
						Object1.x = Object1.x - overlap;
						Object2.x += overlap;
						sv1 *= 0.5;
						sv2 *= 0.5;
					}
					if(p1hn2)
					{
						Object1.hitRight(Object2,sv1);
						Object2.hitLeft(Object1,sv2);
					}
					else
					{
						Object1.hitLeft(Object2,sv1);
						Object2.hitRight(Object1,sv2);
					}
					
					//Adjust collision hulls if necessary
					if(!f1 && (overlap != 0))
					{
						if(p1hn2)
							obj1Hull.width = obj1Hull.width - overlap;
						else
						{
							obj1Hull.x = obj1Hull.x - overlap;
							obj1Hull.width += overlap;
						}
						Object1.colHullY.x = Object1.colHullY.x - overlap;
					}
					if(!f2 && (overlap != 0))
					{
						if(p1hn2)
						{
							obj2Hull.x += overlap;
							obj2Hull.width = obj2Hull.width - overlap;
						}
						else
							obj2Hull.width += overlap;
						Object2.colHullY.x += overlap;
					}
					obj2Hull.x = obj2Hull.x - ox2;
					obj2Hull.y = obj2Hull.y - oy2;
					i2++;
				}
				obj1Hull.x = obj1Hull.x - ox1;
				obj1Hull.y = obj1Hull.y - oy1;
				i1++;
			}

			return hit;
		}
		
		/**
		 * This quad tree callback function can be used externally as well.
		 * Takes two objects and separates them along their Y axis (if possible/reasonable).
		 * 
		 * @param	Object1		The first object or group you want to check.
		 * @param	Object2		The second object or group you want to check.
		 */
		static public function solveYCollision(Object1:FlxObject, Object2:FlxObject):Boolean
		{
			//Avoid messed up collisions ahead of time
			var o1:Number = Object1.colVector.y;
			var o2:Number = Object2.colVector.y;
			if(o1 == o2)
				return false;
			
			//Give the objects a heads up that we're about to resolve some collisions
			Object1.preCollide(Object2);
			Object2.preCollide(Object1);
			
			//Basic resolution variables
			var f1:Boolean;
			var f2:Boolean;
			var overlap:Number;
			var hit:Boolean = false;
			var p1hn2:Boolean;
			
			//Directional variables
			var obj1Stopped:Boolean = o1 == 0;
			var obj1MoveNeg:Boolean = o1 < 0;
			var obj1MovePos:Boolean = o1 > 0;
			var obj2Stopped:Boolean = o2 == 0;
			var obj2MoveNeg:Boolean = o2 < 0;
			var obj2MovePos:Boolean = o2 > 0;
			
			//Offset loop variables
			var i1:uint;
			var i2:uint;
			var obj1Hull:FlxRect = Object1.colHullY;
			var obj2Hull:FlxRect = Object2.colHullY;
			var co1:Array = Object1.colOffsets;
			var co2:Array = Object2.colOffsets;
			var l1:uint = co1.length;
			var l2:uint = co2.length;
			var ox1:Number;
			var oy1:Number;
			var ox2:Number;
			var oy2:Number;
			var r1:Number;
			var r2:Number;
			var sv1:Number;
			var sv2:Number;
			
			//Decide based on object's movement patterns if it was a top or bottom collision
			p1hn2 = ((obj1Stopped && obj2MoveNeg) || (obj1MovePos && obj2Stopped) || (obj1MovePos && obj2MoveNeg) || //the obvious cases
				(obj1MoveNeg && obj2MoveNeg && (((o1>0)?o1:-o1) < ((o2>0)?o2:-o2))) || //both moving up, obj2 overtakes obj1
				(obj1MovePos && obj2MovePos && (((o1>0)?o1:-o1) > ((o2>0)?o2:-o2))) ); //both moving down, obj1 overtakes obj2
			
			//Check to see if these objects allow these collisions
			if(p1hn2?(!Object1.collideBottom || !Object2.collideTop):(!Object1.collideTop || !Object2.collideBottom))
				return false;
			
			//this looks insane, but we're just looping through collision offsets on each object
			i1 = 0;
			while(i1 < l1)
			{
				ox1 = co1[i1].x;
				oy1 = co1[i1].y;
				obj1Hull.x += ox1;
				obj1Hull.y += oy1;
				i2 = 0;
				while(i2 < l2)
				{
					ox2 = co2[i2].x;
					oy2 = co2[i2].y;
					obj2Hull.x += ox2;
					obj2Hull.y += oy2;
					
					//See if it's a actually a valid collision
					if( (obj1Hull.x + obj1Hull.width  < obj2Hull.x + ROUNDING_ERROR) ||
						(obj1Hull.x + ROUNDING_ERROR > obj2Hull.x + obj2Hull.width) ||
						(obj1Hull.y + obj1Hull.height < obj2Hull.y + ROUNDING_ERROR) ||
						(obj1Hull.y + ROUNDING_ERROR > obj2Hull.y + obj2Hull.height) )
					{
						obj2Hull.x = obj2Hull.x - ox2;
						obj2Hull.y = obj2Hull.y - oy2;
						i2++;
						continue;
					}
					
					//Calculate the overlap between the objects
					if(p1hn2)
					{
						if(obj1MoveNeg)
							r1 = obj1Hull.y + Object1.colHullX.height;
						else
							r1 = obj1Hull.y + obj1Hull.height;
						if(obj2MoveNeg)
							r2 = obj2Hull.y;
						else
							r2 = obj2Hull.y + obj2Hull.height - Object2.colHullX.height;
					}
					else
					{
						if(obj2MoveNeg)
							r1 = -obj2Hull.y - Object2.colHullX.height;
						else
							r1 = -obj2Hull.y - obj2Hull.height;
						if(obj1MoveNeg)
							r2 = -obj1Hull.y;
						else
							r2 = -obj1Hull.y - obj1Hull.height + Object1.colHullX.height;
					}
					overlap = r1 - r2;
					
					//Slightly smarter version of checking if objects are 'fixed' in space or not
					f1 = Object1.fixed;
					f2 = Object2.fixed;
					if(f1 && f2)
					{
						f1 &&= (Object1.colVector.x == 0) && (o1 == 0);
						f2 &&= (Object2.colVector.x == 0) && (o2 == 0);
					}
					
					//Last chance to skip out on a bogus collision resolution
					if( (overlap == 0) ||
						((!f1 && ((overlap>0)?overlap:-overlap) > obj1Hull.height*0.8)) ||
						((!f2 && ((overlap>0)?overlap:-overlap) > obj2Hull.height*0.8)) )
					{
						obj2Hull.x = obj2Hull.x - ox2;
						obj2Hull.y = obj2Hull.y - oy2;
						i2++;
						continue;
					}
					hit = true;
					
					//Adjust the objects according to their flags and stuff
					sv1 = Object2.velocity.y;
					sv2 = Object1.velocity.y;
					if(!f1 && f2)
						Object1.y = Object1.y - overlap;
					else if(f1 && !f2)
						Object2.y += overlap;
					else if(!f1 && !f2)
					{
						overlap /= 2;
						Object1.y = Object1.y - overlap;
						Object2.y += overlap;
						sv1 *= 0.5;
						sv2 *= 0.5;
					}
					if(p1hn2)
					{
						Object1.hitBottom(Object2,sv1);
						Object2.hitTop(Object1,sv2);
					}
					else
					{
						Object1.hitTop(Object2,sv1);
						Object2.hitBottom(Object1,sv2);
					}
					
					//Adjust collision hulls if necessary
					if(!f1 && (overlap != 0))
					{
						if(p1hn2)
						{
							obj1Hull.y = obj1Hull.y - overlap;
							
							//This code helps stuff ride horizontally moving platforms.
							if(f2 && Object2.moves)
							{
								sv1 = Object2.colVector.x;
								Object1.x += sv1;
								obj1Hull.x += sv1;
								Object1.colHullX.x += sv1;
							}
						}
						else
						{
							obj1Hull.y = obj1Hull.y - overlap;
							obj1Hull.height += overlap;
						}
					}
					if(!f2 && (overlap != 0))
					{
						if(p1hn2)
						{
							obj2Hull.y += overlap;
							obj2Hull.height = obj2Hull.height - overlap;
						}
						else
						{
							obj2Hull.height += overlap;
						
							//This code helps stuff ride horizontally moving platforms.
							if(f1 && Object1.moves)
							{
								sv2 = Object1.colVector.x;
								Object2.x += sv2;
								obj2Hull.x += sv2;
								Object2.colHullX.x += sv2;
							}
						}
					}
					obj2Hull.x = obj2Hull.x - ox2;
					obj2Hull.y = obj2Hull.y - oy2;
					i2++;
				}
				obj1Hull.x = obj1Hull.x - ox1;
				obj1Hull.y = obj1Hull.y - oy1;
				i1++;
			}
			
			return hit;
		}
	}
}

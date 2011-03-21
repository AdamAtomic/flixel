/**
 * http://github.com/mrdoob/stats.as
 * Released under MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * Modified by Corey von Birnbaum (coldconstructs.com) for use with Flixel:
 * - removed all listeners--we handle everything in FlxConsole manually; especially didn't need the click listener since that messes with stage framerate
 * - removed Colors class and just made them local variables
 * - made init and destroy public so FlxGame can call them as necessary
 **/

package org.flixel.data {
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.System;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.utils.getTimer;	
	import org.flixel.FlxG;	

	public class Stats extends Sprite {	
		protected const WIDTH:uint = 70;
		protected const HEIGHT:uint = 140;
		protected const H_MOD:uint = 70;

		protected var xml:XML;

		protected var text:TextField;
		protected var style:StyleSheet;

		protected var timer:uint;
		protected var fps:uint;
		protected var ms:uint;
		protected var ms_prev:uint;
		protected var mem:Number;
		protected var mem_max:Number;

		protected var graph:BitmapData;
		protected var rectangle:Rectangle;

		protected var fps_graph:uint;
		protected var mem_graph:uint;
		protected var mem_max_graph:uint;

		protected var color_bg:uint = 0x000000;//0x000033;
		protected var color_fps:uint = 0xffff00;
		protected var color_ms:uint = 0x00ff00;
		protected var color_mem:uint = 0x00ffff;
		protected var color_memmax:uint = 0xff0070;

		/**
		 * <b>Stats</b> FPS, MS and MEM, all in one.
		 */
		public function Stats() : void {
			mem_max = 0;

			xml = <xml><fps>FPS:</fps><ums>UPD:</ums><rms>REN:</rms><ms>MS:</ms><mem>MEM:</mem><memMax>MAX:</memMax></xml>;
		
			style = new StyleSheet();
			style.setStyle('xml', {fontSize:'9px', fontFamily:'_sans', leading:'-2px'});
			style.setStyle('fps', {color: hex2css(color_fps)});
			style.setStyle('ums', {color: hex2css(color_ms)});
			style.setStyle('rms', {color: hex2css(color_ms)});
			style.setStyle('ms', {color: hex2css(color_ms)});
			style.setStyle('mem', {color: hex2css(color_mem)});
			style.setStyle('memMax', {color: hex2css(color_memmax)});
			
			text = new TextField();
			text.width = WIDTH;
			text.height = H_MOD;
			text.styleSheet = style;
			text.condenseWhite = true;
			text.selectable = false;
			text.mouseEnabled = false;
			
			rectangle = new Rectangle(WIDTH - 1, 0, 1, HEIGHT - H_MOD);
		}

		public function init(Zoom:uint) : void {
			graphics.beginFill(color_bg);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();

			addChild(text);
			
			graph = new BitmapData(WIDTH, HEIGHT - H_MOD, false, color_bg);
			graphics.beginBitmapFill(graph, new Matrix(1, 0, 0, 1, 0, H_MOD));
			graphics.drawRect(0, H_MOD, WIDTH, HEIGHT - H_MOD);
			
			x = (FlxG.width * Zoom) - WIDTH;
		}

		public function destroy() : void {
			graphics.clear();
			removeChild(text);//while (numChildren > 0) removeChildAt(0);
			graph.dispose();
			xml = null;
			text = null;
			style = null;
			rectangle = null;
		}

		public function update(updateMS:int, renderMS:int):void {
			timer = getTimer();
			
			if (timer - 1000 > ms_prev) {
				ms_prev = timer;
				mem = Number((System.totalMemory * 0.000000954).toFixed(3));
				mem_max = mem_max > mem ? mem_max : mem;
				
				fps_graph = Math.min(graph.height, ( fps / stage.frameRate ) * graph.height);
				mem_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem * 5000))) - 2;
				mem_max_graph = Math.min(graph.height, Math.sqrt(Math.sqrt(mem_max * 5000))) - 2;
				
				graph.scroll(-1, 0);
				
				graph.fillRect(rectangle, color_bg);
				graph.setPixel(graph.width - 1, graph.height - fps_graph, color_fps);
				graph.setPixel(graph.width - 1, graph.height - ( ( timer - ms ) >> 1 ), color_ms);
				graph.setPixel(graph.width - 1, graph.height - mem_graph, color_mem);
				graph.setPixel(graph.width - 1, graph.height - mem_max_graph, color_memmax);
				
				xml.fps = "FPS: " + fps + " / " + stage.frameRate; 
				xml.mem = "MEM: " + mem;
				xml.memMax = "MAX: " + mem_max;			
				
				fps = 0;
			}

			fps++;
			
			xml.ums = "UPD: " + updateMS;
			xml.rms = "REN: " + renderMS;
			xml.ms = "TTL: " + (timer - ms);
			ms = timer;
			
			text.htmlText = xml;
		}

		// Util
		private function hex2css(color:int):String { return "#" + color.toString(16); }
	}
}
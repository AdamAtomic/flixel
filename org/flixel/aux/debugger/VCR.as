package org.flixel.aux.debugger
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class VCR extends Sprite
	{
		[Embed(source="../../data/vcr/open.png")] protected var ImgOpen:Class;
		[Embed(source="../../data/vcr/record_off.png")] protected var ImgRecordOff:Class;
		[Embed(source="../../data/vcr/record_on.png")] protected var ImgRecordOn:Class;
		[Embed(source="../../data/vcr/flixel.png")] protected var ImgFlixel:Class;
		[Embed(source="../../data/vcr/pause.png")] protected var ImgPause:Class;
		[Embed(source="../../data/vcr/play.png")] protected var ImgPlay:Class;
		[Embed(source="../../data/vcr/step.png")] protected var ImgStep:Class;
		
		public var paused:Boolean;
		public var stepRequested:Boolean;
		
		protected var _open:Bitmap;
		protected var _recordOff:Bitmap;
		protected var _recordOn:Bitmap;
		protected var _flixel:Bitmap;
		protected var _pause:Bitmap;
		protected var _play:Bitmap;
		protected var _step:Bitmap;
		
		protected var _overOpen:Boolean;
		protected var _overRecord:Boolean;
		protected var _overPause:Boolean;
		protected var _overStep:Boolean;
		
		protected var _pressingOpen:Boolean;
		protected var _pressingRecord:Boolean;
		protected var _pressingPause:Boolean;
		protected var _pressingStep:Boolean;
		
		public function VCR()
		{
			super();
			
			var spacing:uint = 7;
			
			_open = new ImgOpen();
			addChild(_open);
			
			_recordOff = new ImgRecordOff();
			_recordOff.x = _open.x + _open.width + spacing;
			addChild(_recordOff);
			
			_recordOn = new ImgRecordOn();
			_recordOn.x = _recordOff.x;
			_recordOn.visible = false;
			addChild(_recordOn);
			
			_flixel = new ImgFlixel();
			_flixel.x = _recordOff.x + _recordOff.width + spacing;
			addChild(_flixel);
			
			_pause = new ImgPause();
			_pause.x = _flixel.x + _flixel.width + spacing;
			addChild(_pause);
			
			_play = new ImgPlay();
			_play.x = _pause.x;
			_play.visible = false;
			addChild(_play);
			
			_step = new ImgStep();
			_step.x = _pause.x + _pause.width + spacing;
			addChild(_step);
			
			unpress();
			
			addEventListener(Event.ENTER_FRAME,init);
		}
		
		public function onOpen():void
		{
			trace("open old record");
		}
		
		public function startRecording():void
		{
			trace("started recording");
			
			_recordOff.visible = false;
			_recordOn.visible = true;
		}
		
		public function stopRecording():void
		{
			trace("stopped recording");
			
			_recordOn.visible = false;
			_recordOff.visible = true;
		}
		
		public function onPause():void
		{
			paused = true;
			_pause.visible = false;
			_play.visible = true;
		}
		
		public function onPlay():void
		{
			paused = true;
			_play.visible = false;
			_pause.visible = true;
		}
		
		public function onStep():void
		{
			stepRequested = true;
		}
		
		protected function init(E:Event=null):void
		{
			if(root == null)
				return;
			removeEventListener(Event.ENTER_FRAME,init);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
			stage.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		protected function onMouseMove(E:MouseEvent=null):void
		{
			if((mouseX >= 0) && (mouseX <= width) && (mouseY >= 0) && (mouseY <= height))
			{
				_overOpen = _overRecord = _overPause = _overStep = false;

				if((mouseX >= _open.x) && (mouseX <= _open.x + _open.width))
					_overOpen = true;
				else if((mouseX >= _recordOff.x) && (mouseX <= _recordOff.x + _recordOff.width))
					_overRecord = true;
				else if((mouseX >= _pause.x) && (mouseX <= _pause.x + _pause.width))
					_overPause = true;
				else if((mouseX >= _step.x) && (mouseX <= _step.x + _step.width))
					_overStep = true;
				
				updateGUI();
			}
			else
				unpress();
		}
		
		protected function onMouseDown(E:MouseEvent=null):void
		{
			_pressingOpen = _pressingRecord = _pressingPause = _pressingStep = false;
			if(_overOpen)
				_pressingOpen = true;
			if(_overRecord)
				_pressingRecord = true;
			if(_overPause)
				_pressingPause = true;
			if(_overStep)
				_pressingStep = true;
		}
		
		protected function onMouseUp(E:MouseEvent=null):void
		{
			if(_overOpen && _pressingOpen)
				onOpen();
			if(_overRecord && _pressingRecord)
			{
				if(_recordOn.visible)
					stopRecording();
				else
					startRecording();
			}
			if(_overPause && _pressingPause)
			{
				if(_play.visible)
					onPlay();
				else
					onPause();
			}
			if(_overStep && _pressingStep)
				onStep();
			
			unpress();
		}
		
		protected function unpress():void
		{
			_overOpen = _pressingOpen = false;
			_overRecord = _pressingRecord = false;
			_overPause = _pressingPause = false;
			_overStep = _pressingStep = false;
			updateGUI();
		}
		
		protected function updateGUI():void
		{
			if(_overOpen && (_open.alpha != 1.0))
				_open.alpha = 1.0;
			else if(!_overOpen && (_open.alpha != 0.8))
				_open.alpha = 0.8;
			
			if(_overRecord && (_recordOff.alpha != 1.0))
				_recordOff.alpha = _recordOn.alpha = 1.0;
			else if(!_overRecord && (_recordOff.alpha != 0.8))
				_recordOff.alpha = _recordOn.alpha = 0.8;
			
			if(_overPause && (_pause.alpha != 1.0))
				_pause.alpha = _play.alpha = 1.0;
			else if(!_overPause && (_pause.alpha != 0.8))
				_pause.alpha = _play.alpha = 0.8;
			
			if(_overStep && (_step.alpha != 1.0))
				_step.alpha = 1.0;
			else if(!_overStep && (_step.alpha != 0.8))
				_step.alpha = 0.8;
		}
	}
}
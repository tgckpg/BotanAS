package {
	import flash.display.Sprite;

	import BotanAS.UI.BasicTools.EditTools.MotionEditor;
	import BotanAS.Sys.ExtAPI;

	[SWF (width='615', height='615', frameRate='60')]
	public class BezierStudy extends Sprite {

		private var _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build Counter
		, build:Build = new Build(echo = _extAPI_.getEcho())

		;

		public function BezierStudy():void {
			// Codes goes here.
			var mEditor:MotionEditor = new MotionEditor(echo);
			addChild(mEditor);
			
			this.graphics.beginFill(0xFFFFFF)
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
		}

	}
}
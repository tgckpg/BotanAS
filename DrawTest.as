package {
	import flash.display.Sprite;
	import flash.events.Event;

	import BotanAS.UI.BasicTools.Miscellaneous.DrawText;
	import BotanAS.Sys.ExtAPI;
	import BotanAS.Sys.GMotions;

	[SWF (width='640', height='640', frameRate='60')]
	public class DrawTest extends Sprite {

		private var _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build Counter
		, build:Build = new Build(echo = _extAPI_.getEcho(true))

		, _gMs_:GMotions = new GMotions(echo)
		;

		public function DrawTest():void {
			
			try {
				var mDrawText:DrawText = new DrawText(_gMs_, this, echo);
				mDrawText.addEventListener(Event.ADDED_TO_STAGE, activateCanvas);
				
				_extAPI_.addCall("getData", mDrawText.getData);
				
				addChild(mDrawText);
			} catch(e:Error) {
				echo(e);
			}
			this.graphics.beginFill(0xFFFFFF)
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			this.graphics.endFill();
		}

		protected function activateCanvas(e:Event):void {
			DrawText(e.target).activate();
		}
	}
}
package {
	// Basic Document Outline
	import flash.display.Sprite;
	import BotanAS.Sys.ExtAPI;
	import Build;

	import BotanAS.Sys.GMotions;
	
	import BotanAS.UI.BasicTools.Miscellaneous.Clock;

	[SWF (width='280', height='70', frameRate='60')]
	public class EClock extends Sprite {

		protected var _extAPI_:ExtAPI = new ExtAPI
		, echo:Function = function (...msg:*):void { trace(msg); }
		// Build Counter
		, build:Build = new Build(echo = _extAPI_.getEcho())

		;


		protected var GMs:GMotions = new GMotions(echo);
		public function EClock():void {
			this.graphics.beginFill(0xFFFFFF);
			this.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
			var clock:Clock = new Clock(GMs);
			addChild(clock);
			clock.activate('electronic');
			clock.x = .5*(stage.stageWidth - clock.width);
			clock.y = .5*(stage.stageHeight - clock.height);
			clock.signBuild(build.build);
		}


	}
}
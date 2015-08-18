package {
	// Basic Document Outline
	import flash.display.Sprite;

	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;

	import flash.events.Event;
	import flash.events.MouseEvent;

	import BotanAS.Sys.ExtAPI;
	import Build;

	[SWF (width='20', height='20', frameRate='12')]
	public class iClipboard extends Sprite{

		private var _extAPI_:ExtAPI = new ExtAPI
			, echo:Function = function (...msg:*):void { trace(msg); }
			// Build Counter
			, build:Build = new Build( echo = _extAPI_.getEcho(), false )

			, stringToCopy:String = ""
			, c:int = stage.stageWidth;
		;

		private var copiedCallback:String = "BotanJS.import( \"Components.Mouse.Clipboard\" )._textCopied";

		public function iClipboard():void
		{
			_extAPI_.addCall( 'copy', copyString );
			_extAPI_.addCall( 'debug', drawDebugArea );

			this.graphics.beginFill(0, 0);
			this.graphics.drawRect(0, 0, c, c);
			this.graphics.endFill();

			stage.addEventListener( MouseEvent.MOUSE_DOWN, copyToClipboard );
		}

		protected function copyString( str:String = "" ):void
		{
			stringToCopy = str;
		}

		protected function drawDebugArea():void
		{
			// Redraw the area with color
			this.graphics.clear();
			this.graphics.beginFill(0x00CCFF, 0.2);
			this.graphics.drawRect(0, 0, c, c);
			this.graphics.endFill();
		}

		protected function copyToClipboard( e:Event ):void
		{
			try
			{
				Clipboard.generalClipboard.clear();
				if( stringToCopy )
				{
					Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT, stringToCopy );
				}

				_extAPI_.getCall( copiedCallback );
			}
			catch ( e:Error )
			{
				echo( e.message );
			}
		}

	}
}

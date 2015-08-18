package BotanAS.UI.BasicTools.Miscellaneous {
	import flash.display.Sprite;

	public class CCheckBox extends Sprite{

		// Constants:
		// Public Properties:
		public var isChecked:Boolean;
		// Private Properties:

		// Initialization:
		public function CCheckBox($lab:String = '', $def:Boolean = false):void {
			this.isChecked = $def;
			drawUI();
		}

		// Public Methods:
		public function set label($str:String):void {
			
		}
		// Protected Methods:
		protected function drawUI():void {
			var sens:Sprite = new Sprite();
			this.graphics.lineStyle(1);
			this.graphics.drawRect(0, 0, 10, 10);
			sens.graphics.beginFill(0, 0);
		}
	}

}
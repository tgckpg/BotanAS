package BotanAS.UI.BasicTools.Miscellaneous{
	import flash.display.Sprite
	import flash.display.Shape
	import flash.text.TextField
	import flash.text.TextFieldAutoSize
	import flash.events.Event
	import flash.events.MouseEvent
	public class CButton extends Sprite {

		// Constants:
		// Public Properties:
		public var border:Boolean = true;
		public var background:Boolean = false;
		public const click:String = "buttonClick";
		// Private Properties:
		private var Label:String;
		private var defaultWidth:Number = 75;
		private var defaultHeight:Number = 20;
		private var maxWidth:Number = 180;
		private const gap:Number = 4;

		// Initialization:
		public function CButton(type:*):void {
			switch (type) {
				case 0 :
					{
						this.Label='OK';
						break;

					};
				case 1 :
					{
						this.Label='Cancel';
						break;

					};
				case 2 :
					{
						this.Label='Yes';
						break;

					};
				case 3 :
					{
						this.Label='No';
						break;

					};
				case 4 :
					{
						this.Label='Accept';
						break;

					};
				case 5 :
					{
						this.Label='Login';
						break;

					};
				case 6 :
					{
						this.Label='SignUp';
						break;

					};
				case 7 :
					{
						this.Label='Submit';
						break;

					};
				default :
					{
						this.Label=type;
						break;

				}
			}
			drawBtn();
		};

		// Public Methods:
		public function drawBtn():void {
			var spr:Sprite = new Sprite();
			var sprBt:Shape = new Shape();
			var labelText:TextField = new TextField();
			labelText.text = this.Label;
			labelText.selectable = false;
			labelText.autoSize = TextFieldAutoSize.CENTER;
			if(labelText.width > defaultWidth - gap*2)
				defaultWidth = labelText.width + gap*2;
			if(this.border)spr.graphics.lineStyle(1,0);
			if(this.background)spr.graphics.beginFill(0xFFFFFF);
			if(this.border || this.background)
				spr.graphics.drawRect(0,0,defaultWidth,defaultHeight);
			sprBt.graphics.beginFill(0,0);
			sprBt.graphics.drawRect(0,0,defaultWidth,defaultHeight);
			labelText.x = (sprBt.width - labelText.width)/2;
			labelText.y = (sprBt.height - labelText.height)/2;
			spr.addChild(labelText);
			spr.addChild(sprBt);
			addChild(spr);
			spr.addEventListener(MouseEvent.MOUSE_OVER, function(e:Event):void {labelText.textColor = 0xFFCC00});
			spr.addEventListener(MouseEvent.MOUSE_OUT, function(e:Event):void {labelText.textColor = 0x000000});
			spr.addEventListener(MouseEvent.CLICK, function(e:Event):void{dispatchEvent(new Event(click))});
		}
		// Protected Methods:
	}

}
package BotanAS.UI.BasicTools.Miscellaneous{
	import flash.display.Sprite
	import flash.display.Shape
	import flash.text.TextField
	import flash.text.TextFieldAutoSize
	import flash.events.Event
	import BotanAS.UI.BasicTools.Miscellaneous.CButton

	public class CAlert extends Sprite {

		// Constants:
		// Public Properties:
		public var title:String = 'Alert';
		public var content:String = '';
		public var back:Sprite = new Sprite();
		// Private Properties:
		private var defaultWidth:Number = 183;
		private const defaultCHeight:Number = 97;
		private const maxWidth:Number = 600;
		private var _gMs_:*;

		// Initialization:
		public function CAlert(g:*) {
			if(g['$GMC$'] as Boolean)
			this._gMs_ = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
			this.addEventListener(Event.ADDED_TO_STAGE,addAlert);
		};

		// Public Methods:
		// Protected Methods:
		protected function addAlert(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE,addAlert);
			var tBar:Shape = new Shape();
			var cPlane:Shape = new Shape();
			var ttext:TextField = new TextField();
			var ctext:TextField = new TextField();
			var cWidth:Number = 0;
			var cHeight:Number = 0;
			var closeBtn:Sprite = new Sprite();
			var btn:CButton = new CButton(0/*OK*/);

			closeBtn.graphics.lineStyle(1,0x000000);
			closeBtn.graphics.beginFill(0xFFFFFF);
			closeBtn.graphics.drawRoundRect(0, 0, 20, 20, 10, 10);
			ttext.text = title;
			ctext.text = content;
			ttext.selectable = ctext.selectable = false;
			ctext.autoSize = ttext.autoSize = TextFieldAutoSize.CENTER;

			if(ttext.width > defaultWidth || ctext.width > defaultWidth) {
				defaultWidth = ttext.width  > ctext.width ? ttext.width : ctext.width;
				cWidth = 40;
			}

			if(defaultWidth > maxWidth) {
				ttext.width = ctext.width = defaultWidth = maxWidth;
				ctext.wordWrap = true;
				ctext.autoSize = TextFieldAutoSize.CENTER;
				cHeight = ctext.height;
			}

			tBar.graphics.lineStyle(1, 0);
			tBar.graphics.beginFill(0xFFFFFF);
			tBar.graphics.drawRoundRect(0, 0, defaultWidth + cWidth, 25 + 5/*for hide bottomRound*/, 9, 9);
			cPlane.graphics.lineStyle(1, 0);
			cPlane.graphics.beginFill(0xFFFFFF);
			cPlane.graphics.drawRect(0, -5, defaultWidth + cWidth, defaultCHeight + cHeight);

			closeBtn.x = tBar.width - 23.5;
			closeBtn.y = (tBar.height - 4 - closeBtn.height)/2;
			ttext.x = ttext.y = ctext.y = 4.5;
			ctext.x = 10;
			cPlane.y = tBar.height;
			ctext.y = cPlane.y + 5;

			back.addChild(tBar);
			back.addChild(cPlane);
			back.addChild(ttext);
			back.addChild(ctext);
			back.addChild(closeBtn);

			btn.x = (cPlane.width - btn.width)/2;
			btn.y = cPlane.height - btn.height + btn.height/2;
			back.addChild(btn);

			back.x = (stage.stageWidth - back.width)/2;
			back.y = (stage.stageHeight - back.height)/2;
			back.alpha = 0;

			btn.addEventListener(btn.click, function():void{_gMs_['curveTween'](back, "alpha", 10, 0, .5, 0, NaN,{delObjAftTwn:true})});

			_gMs_['curveTween'](back, "alpha", 10, 1, .5);
			addChild(back);
		}

	}

}
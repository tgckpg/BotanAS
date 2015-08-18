package BotanAS.UI.BasicTools.Miscellaneous {
	import flash.display.Sprite
	import flash.display.Shape
	import flash.display.Graphics
	import flash.geom.Rectangle
	import flash.events.Event
	import flash.events.MouseEvent
	import flash.utils.getTimer

	public class SclBar extends Sprite{
		// Constants:
		// Public Properties:
		public var $sclBtnA_w:Number
		, $sclBtnB_w:Number
		, $dragtrack_w:Number
		, $sclBtnA_h:Number = 18
		, $sclBtnB_h:Number = 18
		, $dragtrack_h:Number = NaN
		, $Method:String = "vertical";
		// Private Properties:
		private var $base:Sprite = new Sprite()
		, $sclBtnA:Sprite = new Sprite()
		, $sclBtnB:Sprite = new Sprite()
		, $sclBase:Sprite = new Sprite()
		, $sclHand:Sprite = new Sprite()
		, $sclPane:Sprite = new Sprite()
		, $sclBtnA_s:Shape = new Shape()
		, $sclBtnB_s:Shape = new Shape()
		, $dragTrack:Shape = new Shape()
		, $dragBtn:Shape = new Shape()
		, $lockArea:Rectangle
		, $vh:Boolean = false
		, $sVal:Number
		, $Mask:*
		, $maskedArea:*;

		// Initialization:
		public function SclBar($w:Number = 18, $h:Number = 18) {
			$sclBtnA_w = $w;
			$sclBtnB_w = $w;
			$sclBtnA_h = $h;
			$sclBtnB_h = $h;
			$dragtrack_w = $w;
		}

		// Public $Methods:
		public function setScroll($a:* = null, $b:* = null):void {
			this.$Mask || (this.$Mask = $a);
			this.$maskedArea || (this.$maskedArea = $b);
			drawSclr();
			addChild($base);
				$base.addChild($sclBtnA);
				$base.addChild($sclBtnB);
				$base.addChild($sclBase);
				$base.addChild($sclPane);
				$base.addChild($sclHand);
			$base.x = $vh ? this.$Mask.x + this.$Mask.width:this.$Mask.x;
			$base.y = $vh ? this.$Mask.y:this.$Mask.y + this.$Mask.height;
			this.$maskedArea.addEventListener("csss",setScroll);
			switch($Method){
				case "vertical":
				{
					$sclBtnA_s.graphics.beginFill(0xFFFFFF);
					$sclBtnA_s.graphics.lineStyle(1,0x00CCFF);
					$sclBtnA_s.graphics.drawRect(0,0,$sclBtnA_w,$sclBtnA_h);
					$sclBtnA_s.graphics.endFill();
					$sclBtnB_s.graphics.beginFill(0xFFFFFF);
					$sclBtnB_s.graphics.lineStyle(1,0x00CCFF);
					$sclBtnB_s.graphics.drawRect(0,0,$sclBtnB_w,$sclBtnB_h);
					$sclBtnB_s.graphics.endFill();
					$dragTrack.y = $dragBtn.y = $sclBtnA_h;
					$sclBtnB_s.y = $dragTrack.y + $dragTrack.height;
					$sclBtnA.addChild($sclBtnA_s);
					$sclBtnB.addChild($sclBtnB_s);
					$sclPane.addChild($dragTrack);
					$sclHand.addChild($dragBtn);
					addEventListener(Event.ENTER_FRAME, moveHandler_vert);
					$sclHand.addEventListener(MouseEvent.MOUSE_DOWN,pressHandler);
					$sclBtnA.addEventListener(MouseEvent.MOUSE_DOWN,btnUp_dnHandler);
					$sclBtnB.addEventListener(MouseEvent.MOUSE_DOWN,btnDn_dnHandler);
					this.$maskedArea.addEventListener(MouseEvent.MOUSE_WHEEL, scl);
					break;
				};
				case "horizontal":
				{
					$sclBtnA_s.graphics.lineStyle(1,0x00CCFF);
					$sclBtnA_s.graphics.drawRect(0,0,$sclBtnA_w,$sclBtnA_h);
					$sclBtnB_s.graphics.lineStyle(1,0x00CCFF);
					$sclBtnB_s.graphics.drawRect(0,0,$sclBtnB_w,$sclBtnB_h);
					$dragTrack.x = $dragBtn.x = $sclBtnA_w;
					$sclBtnB_s.x = $dragTrack.x + $dragTrack.width;
					$sclBtnA.addChild($sclBtnA_s);
					$sclBtnB.addChild($sclBtnB_s);
					$sclPane.addChild($dragTrack);
					$sclHand.addChild($dragBtn);
					addEventListener(Event.ENTER_FRAME, moveHandler_horz);
					function btnLt_dnHandler($e:Event):void {
					}
					function btnLt_upHandler($e:Event):void {
					}
					function btnRt_dnHandler($e:Event):void {
					}
					function btnRt_upHandler($e:Event):void {
					}
					$sclHand.addEventListener(MouseEvent.MOUSE_DOWN, pressHandler);
					break;
				};
			}


		}
		public function update():void {
			this.visible = true;
			drawSclr();
		}
		// Protected $Methods:
		protected function drawSclr():void {
			$Method == "vertical" && ($vh = true);
			$dragTrack.graphics.clear();
			$dragTrack.graphics.beginFill(0xFDFEFC);
			$dragTrack.graphics.lineStyle(1,0x00BBEE);
			$dragTrack.graphics.drawRect(0,0,$vh ? $sclBtnA_w:this.$Mask.width - ($sclBtnA_w + $sclBtnB_w),$vh ? this.$Mask.height - ($sclBtnA_h + $sclBtnB_h):$sclBtnA_h);
			$dragTrack.graphics.endFill();
			$dragBtn.graphics.clear();
				$dragBtn.graphics.beginFill(0x00CCFF);
			if($vh){
				this.$maskedArea.height > this.$Mask.height &&
					$dragBtn.graphics.drawRect(0,0,$sclBtnA_w,$dragTrack.height * this.$Mask.height / this.$maskedArea.height);
					this.$sVal = this.$maskedArea.height;
			} else {
				this.$maskedArea.width > this.$Mask.width &&
					$dragBtn.graphics.drawRect(0,0,$dragTrack.width * this.$Mask.width / this.$maskedArea.width,$sclBtnA_h);
					this.$sVal = this.$maskedArea.width;
			}
			$dragBtn.graphics.endFill();
			$dragBtn.height || (this.visible = false);
			$lockArea = new Rectangle(0,0,$vh ? 0:$dragTrack.width - $dragBtn.width,$vh ? $dragTrack.height - $dragBtn.height:0);
			$sclHand.y > $lockArea.height && ($sclHand.y = $lockArea.height);
		}

		protected function moveHandler_vert($e:Event = null):void {
			//_twnr_.curveTween(this.$maskedArea,"y","OutCubic",-((this.$maskedArea.height - this.$Mask.height)*($sclHand.y / $lockArea.height)),1);
			var k:Number = -((this.$maskedArea.height - this.$Mask.height)*($sclHand.y / $lockArea.height));
			this.$maskedArea.y = this.$maskedArea.y*.7 + k*.3;
			this.$maskedArea.height != this.$sVal && update();
		}

		protected function moveHandler_horz($e:Event = null):void {
			var k:Number = -((this.$maskedArea.width - this.$Mask.width)*($sclHand.x / $lockArea.width));
			this.$maskedArea.x = this.$maskedArea.x*.7 + k*.3;
			this.$maskedArea.width != this.$sVal && update();
		}

		protected function relHandler($e:Event):void {
			stage.removeEventListener(MouseEvent.MOUSE_UP, relHandler);
			$sclHand.stopDrag();
		}

		protected function pressHandler($e:Event):void {
			stage.addEventListener(MouseEvent.MOUSE_UP, relHandler);
			$sclHand.startDrag(false, $lockArea);
		}

		protected function scl($e:Event):void {
			if($Mask.height > $maskedArea.height)return;
			$sclHand.y -= $e['delta']*($Mask.height/$maskedArea.height)*10;
			$sclHand.y > $lockArea.height && ($sclHand.y = $lockArea.height);
			$sclHand.y < 0 && ($sclHand.y = 0);
		}

		protected function btnUp_dnHandler($e:Event):void {
			trace("Btn_up: Down handle");
		}

		protected function btnUp_upHandler($e:Event):void {
			trace("Btn_up: Up handle");
			$sclBtnA.removeEventListener(MouseEvent.MOUSE_DOWN, btnUp_dnHandler);
		}

		protected function btnDn_dnHandler($e:Event):void {
			trace("Btn_dn: Down handle");
		}

		protected function btnDn_upHandler($e:Event):void {
			trace("Btn_dn: Up handle");
			$sclBtnB.removeEventListener(MouseEvent.MOUSE_DOWN, btnDn_dnHandler);
		}
	}

}
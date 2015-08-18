package BotanAS.UI.BasicTools.Miscellaneous {
	import BotanAS.UI.BasicTools.Miscellaneous.SclBar;

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.Graphics;
	import flash.display.DisplayObjectContainer
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.events.MouseEvent;
	import flash.events.Event;
	
	import BotanAS.Sys.ExtAPI;

	public class CTree extends Sprite {
		private var _gMs_:*;

		private var $xml:XML
		, $handle1:Function
		, $scllBar:SclBar = new SclBar(8, 8)
		, $cursor:Sprite = new Sprite()
		, $stg:Sprite = new Sprite()
		, $msk:Shape = new Shape()
		, $thmc:Array = [[0xCFFFD2, 0xD5FFD2], 0x79E7FF, 0xBBE7FF, 0xCEE7FF]
		, $w:Number = 0
		, $h:Number = 0
		, $it_h:Number = 20
		
		, _extAPI_:ExtAPI = new ExtAPI
		, echo :Function = function (...msg:*):void{}
		;//[[bg1, bg2], selection, over, down]

		public function CTree(g:*, $w:Number, $h:Number, $xml:XML = null, $itemHandler:Function = null):void {
			if(g['$GMC$'] as Boolean)
			this._gMs_ = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
			this.echo = this._extAPI_.getEcho(true);
			this.$w = $w;
			this.$h = $h;
			this.$handle1 = $itemHandler;
			this.graphics.lineStyle(1, this.$thmc[1]);
			this.graphics.drawRect(0, 0, $w, $h);
			if($xml) {
				this.$xml = new XML($xml);
				drawUI();
			}
		}

		public function setXML($xml:XML):void {
			this.$xml = new XML($xml);
			drawUI();
		}

		private function drawUI():void {
			for(var $i:int = 1; $i < $thmc.length; $i ++) {
				var $c:Shape = new Shape();
				drawBar($c.graphics, this.$thmc[$i], 1, this.$w, this.$it_h);
				$c.visible = false;
				$cursor.addChild($c);
			}
			$c = null;
			drawBar($msk.graphics, 0, 0, this.$w, this.$h);
			$stg.mask = $msk;
			$scllBar.setScroll($msk, $stg);
			$stg.addChild($cursor);
			this.addChild($stg);
			this.addChild($msk);
			this.addChild($scllBar);
			drawItems(this.$xml.children(), this.$stg);
		}

		private function drawItems($xml:XMLList, $frame:Sprite , $p:String = '', $child:Boolean = false):Number {
			var $childs:* = $xml;
			for (var $i:int = 0; $i < $childs.length(); $i ++) {
				var $item:Sprite = new Sprite()
				, $sens:Sprite = new Sprite()
				, $label:TextField = new TextField();
				drawBar($sens.graphics, 0, 0, this.$w, this.$it_h);
				$label.text = ($childs[$i].children()[0] ? " + " : " · ")
				+ ($childs[$i].name() || $childs[$i])
				+ " " +
				(String($childs[$i].attribute('val')) || String($childs[$i].attribute('sn')));
				$label.autoSize = TextFieldAutoSize.LEFT;
				$label.selectable = false;
				$child || drawBar($stg.graphics, this.$thmc[0][($i % 2 == 0) ? 0:1], 1, this.$w, this.$it_h, $i*$it_h);
				//*
				_gMs_.curveTween($item, "y", 1, ($child && ($item.x = this.$it_h) ? $i + 1 : $i)*this.$it_h, $i/$childs.length()*1.5);
				/*/
				$item.y = ($child && ($item.x = this.$it_h) ? $i + 1 : $i)*this.$it_h;
				//*/
				$item.name = $p + String($i);
				$sens.doubleClickEnabled = true;
				$sens.addEventListener(MouseEvent.MOUSE_OVER, h1);
				$sens.addEventListener(MouseEvent.MOUSE_OUT, h2);
				$sens.addEventListener(MouseEvent.MOUSE_DOWN, h3);
				$sens.addEventListener(MouseEvent.MOUSE_UP, h1);
				$sens.addEventListener(MouseEvent.CLICK, h4);
				$childs[$i].children()[0] ? $sens.addEventListener(MouseEvent.DOUBLE_CLICK, h5) : $sens.addEventListener(MouseEvent.DOUBLE_CLICK, h6);
				$item.addChild($label);
				$item.addChild($sens);
				$frame.addChild($item);
			}
			return (++ $i)*$it_h;
		}

		private function drawBar(g:Graphics, $a:Number, $b:Number, $w:Number, $h:Number, $y:Number = 0):void {
			g.beginFill($a, $b);
			g.moveTo(0, $y);
			g.drawRect(0, $y, $w, $h);
			g.endFill();
		}

		private function h1($e:Event):void {
			$cursor.getChildAt(1).visible = false;
			$cursor.getChildAt(2).visible = true;
			$cursor.getChildAt(2).y = getAbsY(Sprite($e.target.parent));
		}

		private function h2($e:Event):void {
			$cursor.getChildAt(1).visible = false;
			$cursor.getChildAt(2).visible = false;
		}

		private function h3($e:Event):void {
			$cursor.getChildAt(1).visible = true;
			$cursor.getChildAt(2).visible = false;
			$cursor.getChildAt(1).y = getAbsY(Sprite($e.target.parent));
		}

		private function h4($e:Event):void {
			$cursor.getChildAt(0).visible = true;
			$cursor.getChildAt(1).visible = false;
			$cursor.getChildAt(2).visible = false;
			$cursor.getChildAt(0).y = getAbsY(Sprite($e.target.parent));
		}

		private function h5($e:Event):void {
			var $item:Sprite = Sprite($e.target.parent)
			, $txt:TextField = TextField($item.getChildAt(0))
			, $name:Array = Sprite($item as Sprite || $item.parent).name.split('_')
			, $nodes:* = this.$xml.children();
			if($name[0] == 'e') {
				$txt.text = " +" + $txt.text.substring($txt.text.indexOf('-') + 2);
				shiftItems($item);
				$name.shift();
				$item.name = $name.join('_');
			} else {
				for each(var $i:String in $name) {
					$nodes = $nodes[$i];
					$nodes &&= $nodes.children();
				}
				if($nodes[0]) {
					$txt.text = " - " + $txt.text.substring($txt.text.indexOf('+') + 1);
					unshiftItems($item.parent
										 , $item.parent.getChildIndex($item) + 1
										 , $item.parent.numChildren
										 , drawItems($nodes, $item, $name.join('_') + '_', true) + $item.y);
					$item.name = 'e_' + $item.name;
				}
			}
		}

		private function h6($e:Event):void {
			var $item:Sprite = Sprite($e.target.parent)
			, $name:Array = Sprite($item as Sprite || $item.parent).name.split('_')
			, $nodes:* = this.$xml.children();
			for (var $i:int = 0; $i < $name.length - 1; $i ++) {
				$nodes = $nodes[$name[$i]];
				$nodes &&= $nodes.children();
			}
			if(this.$handle1 as Function)
			$handle1($nodes[$name[$i]].attribute('sn'));
		}

		private function unshiftItems($s:DisplayObjectContainer, $i:int, $total:int, $shift:Number):void {
			while($i < $total) {
				_gMs_.curveTween($s.getChildAt($i), 'y', 1, $shift, 1);
				$shift += $s.getChildAt($i ++).height;
			}
			if(isItem($s.name)) {
				unshiftItems($s.parent
									 , $s.parent.getChildIndex($s) + 1
									 , $s.parent.numChildren
									 , $s.y + $shift);
			} else {
				$stg.graphics.clear();
				for ($i = 0; $i < $shift/this.$it_h; $i ++) {
					drawBar($stg.graphics, this.$thmc[0][($i % 2 == 0) ? 0:1], 1, this.$w, this.$it_h, $i*$it_h);
				}
			}
		}

		private function shiftItems($s:Sprite):void {
			while($s.numChildren > 2) {
				$s.removeChildAt(2);
			}
			unshiftItems($s.parent, $s.parent.getChildIndex($s) + 1, $s.parent.numChildren, $s.y + $it_h);
		}

		private function getAbsY($obj:Sprite):Number {
			var $y:Number = 0;
			if(isItem($obj.name)) {
				$y += $obj.y;
				if(isItem($obj.parent.name))
					$y += getAbsY(Sprite($obj.parent));
			}
			return $y;
		}

		private function isItem($name:String):Boolean {
			return $name.split('_').every(checkName);
		}

		private function checkName($i:String, $d:int, $a:Array):Boolean {
			if($d == 0) {
				if($i.length >= 1)
				if($i == 'e' || $i.match(/^\d+$/))
					return true;
			} else {
				if($i.match(/\d/))
					return true;
			}
			return false;
		}

	}
}
package BotanAS.UI.BasicTools.Miscellaneous {
	import BotanAS.Sys.GMotions

	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.utils.setInterval;
	import flash.utils.clearInterval;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	import flash.display.Graphics;
	import flash.events.Event;

	public class Clock extends Sprite {

		// Constants:
		// Public Properties:
		// Private Properties:
		private var hrHand:Shape, minHand:Shape, secHand:Shape, GMotions:*, $tItvl:int
		, front:Sprite = new Sprite
		, back:Sprite = new Sprite
		, colorTiles:Vector.<uint> = new Vector.<uint>(6, true)
		;

		// Initialization:
		public function Clock(g:*) {
			if(g['$GMC$'] as Boolean)
			this.GMotions = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
			// Dark Orange
			colorTiles[0] = 0xF87217;
			// Lawn Green
			colorTiles[1] = 0x87F717;
			// Turquoise
			colorTiles[2] = 0x52F3FF;
			// Dark Orchid
			colorTiles[3] = 0x8B31C7;
			// Violet Red
			colorTiles[4] = 0xF6358A;
			// Royal Blue
			colorTiles[5] = 0x306EFF;
		}

		// Public Methods:
		public function activate(style:String):void {
			switch(style){
				case "quartz":{
					drawQClock();
					break;
				}case "electronic":{
					drawEClock();
					break;
				}
			}
			addChild(back);
			addChild(front);
			
			addEventListener(Event.REMOVED_FROM_STAGE, function($e:Event):void {
			 clearInterval($tItvl);
			});
		}
		public function signBuild(number:int):void {
			var __build:TextField = new TextField();
			__build.text = "EClock Build " + String(number);
			__build.selectable = false;
			__build.autoSize = TextFieldAutoSize.LEFT;
			__build.setTextFormat(new TextFormat("_sans", 12, 0xDDDDDD));
			__build.x = this.width - __build.width - 3;
			__build.y = 3;
			back.addChild(__build);
		}
		// Protected Methods:
		protected function drawQClock():void {
			//read user's information
			//default
			var shell:Sprite = new Sprite();
			var base:Shape = new Shape();
			var Background:Shape = new Shape();
			var compass:Sprite = new Sprite();
			this.hrHand = new Shape();
			this.minHand = new Shape();
			this.secHand = new Shape();
			var peg:Shape = new Shape();
			var times:Array = getTime();

			this.hrHand.name = "hrHand";
			this.minHand.name = "minHand";
			this.secHand.name = "secHand";

			base.graphics.beginFill(0xFFFFFF);
			base.graphics.lineStyle(1,0x00CCFF);
			base.graphics.drawCircle(0,0,80);
			base.graphics.endFill();

			Background.graphics.beginFill(0xFFFFFF);
			Background.graphics.lineStyle(1,0x00CCFF);
			Background.graphics.drawCircle(0,0,70);
			Background.graphics.endFill();

			peg.graphics.beginFill(0xFFFFFF);
			peg.graphics.lineStyle(1,0x00CCFF);
			peg.graphics.drawCircle(0,0,5);
			peg.graphics.endFill();

			hrHand.graphics.lineStyle(4,0x00CCFF);
			hrHand.graphics.moveTo(0,-30);
			hrHand.graphics.lineTo(0,0);

			minHand.graphics.lineStyle(3,0x00CCFF);
			minHand.graphics.moveTo(0,-43);
			minHand.graphics.lineTo(0,0);

			secHand.graphics.lineStyle(2,0x00CCFF);
			secHand.graphics.moveTo(0,-65);
			secHand.graphics.lineTo(0,0);

			var r:Number = 56;
			var xc:Number = Math.cos(30*Math.PI/180)*r;
			var yc:Number = r/2;

			var numArr:Array = new Array("I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII");
			var posArr:Array = new Array(new Point(yc,-xc),//1
									new Point(xc,-yc),//2
									new Point(r,0),//3
									new Point(xc,yc),//4
									new Point(yc,xc),//5
									new Point(0,r),//6
									new Point(-yc,xc),//7
									new Point(-xc,yc),//8
									new Point(-r,0),//9
									new Point(-xc,-yc),//10
									new Point(-yc,-xc),//11
									new Point(0,-r));//12
			var tformat:TextFormat = new TextFormat();
			tformat.font = "style1";
			tformat.size = 15;
			tformat.color = 0x00CCFF;
			for(var g:int = 0; 60 > g; g ++){
				var grid:Shape = new Shape();
				grid.graphics.moveTo(0,-Background.width/2)
				if(g % 5 == 0){
					grid.graphics.lineStyle(2,0x00CCFF);
					grid.graphics.lineTo(0,-Background.width/2+5)
				}else{
					grid.graphics.lineStyle(1,0x00CCFF);
					grid.graphics.lineTo(0,-Background.width/2+2)
				}
				grid.rotation = 6*g;
				compass.addChild(grid);
			}

			for(var i:int = 0; 12 > i; i ++){
				var num:TextField = new TextField();
				num.text = numArr[i];
				num.selectable = false;
				num.setTextFormat(tformat);
				num.autoSize = TextFieldAutoSize.CENTER;
				num.x = posArr[i].x-num.width/2;
				num.y = posArr[i].y-num.height/2;
				compass.addChild(num);
			}
			shell.x = shell.y = base.width/2;

			front.addChild(shell);
			shell.addChild(base);
			shell.addChild(Background);
			shell.addChild(compass);
			shell.addChild(hrHand);
			shell.addChild(minHand);
			shell.addChild(secHand);
			shell.addChild(peg);
			GMotions.curveTween(secHand,"rotation",10,times[2]*6,1);
			GMotions.curveTween(minHand,"rotation",10,times[1]*6+times[2]/10,1);
			GMotions.curveTween(hrHand,"rotation",10,times[0]*30+times[1]/2+times[2]/300,1);
			$tItvl = setInterval(tickQtz,1000);
		}
		protected function drawEClock():void {
			var base:Sprite = new Sprite();
			for(var j:int = 0; j < 3; j ++){
				var pane:Sprite = new Sprite();
				pane.name = 'pane'+String(j);
				for(var p:int= 0; p < 2; p ++){
					var panel:Sprite = new Sprite();
					panel.name = "panel"+String(p);
					var r:int = 0,c:int = 0;
					for(var i:int = 0; i<15; i++){
						var block:Shape = new Shape();
						var grf:Graphics = block.graphics;
						grf.beginFill(colorTiles[int(Math.random()*5)]);
						//grf.lineStyle(3, 0xFFFFFF);
						grf.drawRect(-5,-5,10,10);
						grf.endFill();
						block.alpha = 0;
						var positionWrapper:Sprite = new Sprite;
						positionWrapper.x = r*11;
						positionWrapper.y = c*11;
						positionWrapper.name = 'block'+String(i);
						if((i+1) % 3 != 0)r ++;
						else{
							r = 0;
							c ++;
						}
						positionWrapper.addChild(block);
						panel.addChild(positionWrapper);
						
					}
					// Turn on block 14
					GMotions.curveTween(block, ["x","y", "alpha", "DropShadowFilter"], 13, [-3, -3, 1, [2, 45, 0, .75, 4, 4]], 1);
					panel.x = p*(panel.width+10);
					panel.y = 5;
					pane.addChild(panel);
				}
				pane.x = j*(pane.width+20) + 5;
				base.addChild(pane);
			}
			front.addChild(base);
			tickEtc(base.getChildByName('pane0'), base.getChildByName('pane1'), base.getChildByName('pane2'));
		}
		protected function getTime():Array {
			var now:Date = new Date();
			return [now.getHours(),now.getMinutes(),now.getSeconds()];
		}
		protected function getDate(isLabel:Boolean):Array {
			var now:Date = new Date();
			var monthArr:Array = new Array("January","February","March","April","May","June","July","August","September","October","November","December");
			var daysArr:Array = new Array("Sunday","Sun","Monday","Mon","Tuesday","Tue","Wednesday","Wed","Thursday","Thu","Friday","Fri","Saturday","Sat");
			return [now.getDate(),isLabel ? monthArr[now.getMonth()]:now.getMonth(),now.getFullYear(),isLabel ? daysArr[now.getDay()*2]:daysArr[now.getDay()*2+1]]
		}
		protected function tickQtz():void {
			var times:Array = getTime();
			//apply tween
			GMotions.curveTween(secHand,"rotation",13,times[2]*6,.7,0,times[2]*6-6);
			minHand.rotation = times[1]*6+times[2]/10;
			hrHand.rotation = times[0]*30+times[1]/2+times[2]/300;
		}
		protected function tickEtc(hr:*, min:*, sec:*):void {
			var digits:Array = new Array(new Array(0,1,2,3,5,6,8,9,11,12,13,14)//0
										,new Array(1,3,4,7,10,12,13,14)//1
										,new Array(0,1,2,5,6,7,8,9,12,13,14)//2
										,new Array(0,1,2,5,6,7,8,11,12,13,14)//3
										,new Array(0,2,3,5,6,7,8,11,14)//4
										,new Array(0,1,2,3,6,7,8,11,12,13,14)//5
										,new Array(0,1,2,3,6,7,8,9,11,12,13,14)//6
										,new Array(0,1,2,3,5,8,11,14)//7
										,new Array(0,1,2,3,5,6,7,8,9,11,12,13,14)//8
										,new Array(0,1,2,3,5,6,7,8,11,12,13,14));//9
			function ticking():void {
				var now:Array = addDigit(getTime());
				for(var r:int = 0; r < 2; r ++){
					var hour:Sprite = hr.getChildByName('panel' + String(r));
					var mn:Sprite = min.getChildByName('panel' + String(r));
					var sc:Sprite = sec.getChildByName('panel' + String(r));

					for(var i:int = 0; i < 14; i ++){//block 14 always on
						if(digits[now[0].charAt(r)].indexOf(i) == -1)
							GMotions.curveTween(Sprite(hour.getChildByName('block' + String(i))).getChildAt(0)
							, ["x","y", "alpha", "DropShadowFilter"], 10, [0, 0, 0, [0, 0, 0, 0, 0, 0]], 1);
						else GMotions.curveTween(Sprite(hour.getChildByName('block' + String(i))).getChildAt(0)
						, ["x","y", "alpha", "DropShadowFilter"], 30, [-3, -3, 1, [2, 45, 0, .75, Math.random()*10, Math.random()*10]], 1);
						if(digits[now[1].charAt(r)].indexOf(i) == -1)
							GMotions.curveTween(Sprite(mn.getChildByName('block' + String(i))).getChildAt(0)
							, ["x","y", "alpha", "DropShadowFilter"], 10, [0, 0, 0, [0, 0, 0, 0, 0, 0]], 1);
						else GMotions.curveTween(Sprite(mn.getChildByName('block' + String(i))).getChildAt(0)
						, ["x","y", "alpha", "DropShadowFilter"], 30, [-3, -3, 1, [2, 45, 0, .75, Math.random()*10, Math.random()*10]], 1);
						if(digits[now[2].charAt(r)].indexOf(i) == -1)
							GMotions.curveTween(Sprite(sc.getChildByName('block' + String(i))).getChildAt(0)
							, ["x","y", "alpha", "DropShadowFilter"], 10, [0, 0, 0, [0, 0, 0, 0, 0, 0]], 1);
						else GMotions.curveTween(Sprite(sc.getChildByName('block' + String(i))).getChildAt(0)
						, ["x","y", "alpha", "DropShadowFilter"], 30, [-3, -3, 1, [2, 45, 0, .75, Math.random()*10, Math.random()*10]], 1);
						/*
							GMotions.curveTween(hour.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 10, 0, 1);
						else GMotions.curveTween(hour.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 13, 1, 1);
						if(digits[now[1].charAt(r)].indexOf(i) == -1)
							GMotions.curveTween(mn.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 10, 0, 1);
						else GMotions.curveTween(mn.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 13, 1, 1);
						if(digits[now[2].charAt(r)].indexOf(i) == -1)
							GMotions.curveTween(sc.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 10, 0, 1);
						else GMotions.curveTween(sc.getChildByName('block' + String(i)), ["alpha","scaleX","scaleY"], 13, 1, 1);
						*/
					}
				}
			}
			$tItvl = setInterval(ticking, 1000);
		}
		protected function addDigit(len:Array):Array {
			len[0] = String(len[0]);
			len[1] = String(len[1]);
			len[2] = String(len[2]);
			if(len[0].length < 2)
				len[0] = '0' + len[0];
			if(len[1].length < 2)
				len[1] = '0' + len[1];
			if(len[2].length < 2)
				len[2] = '0' + len[2];
			return len;
		}
	}

}
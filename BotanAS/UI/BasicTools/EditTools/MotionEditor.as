package BotanAS.UI.BasicTools.EditTools{
	import flash.display.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import BotanAS.Sys.Engines.MathEngine.Functions;
	public class MotionEditor extends Sprite {

		// Constants:
		// Public Properties:
		// Private Properties:
		private var _Math:Functions = new Functions(true, 20, 10)
		, bt_txt:TextField = new TextField()
		// This is the point showing the point B(t)
		, bt:Sprite = new Sprite()
		, curve:Shape = new Shape()
		// Skeleton draws the control points and line
		, skeleton:Shape = new Shape()
		// This is a result of a Bezier curve
		, qCurve:Shape = new Shape()
		// Define Start Point and End Point
		, sPt:Point = new Point(15,585)
		, ePt:Point = new Point(sPt.y,sPt.x)
		// Control Points
		, ctrlPts:Array = []
		// t is the period of B(t)
		, t:Number = 0
		// How many line pieces should draw
		, pcs:Number = .01
		
		// Echo function for debugging
		, echo:Function = function (...msg:*):void { trace(msg); }
		;

		// Initialization:
		public function MotionEditor(echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo ("  {MotionEditor}");
			}
			// Draw the backgrund first
			var bg:Shape = new Shape();
			bg.graphics.lineStyle(1);
			bg.graphics.moveTo(sPt.x, ePt.y);
			bg.graphics.lineTo(sPt.x, sPt.y);
			bg.graphics.lineTo(ePt.x, sPt.y);
			// Draw point B(t)
			bt_txt.selectable = false;
			bt.graphics.lineStyle(1);
			bt.graphics.drawCircle(0, 0, 5);
			bt.x = sPt.x;
			bt.y = sPt.y;
			bt.addChild(bt_txt);
			addChild(bt);
			addChild(bg);
			drawLine();
		}

		// Public Methods:
		// Protected Methods:
		protected function drawLine():void {
		// Draw the basic strict line
			curve.graphics.lineStyle(1);
			curve.graphics.moveTo(sPt.x, sPt.y);
			curve.graphics.lineTo(ePt.x, ePt.y);
			addChild(skeleton);
			addChild(curve);
			addChild(qCurve);
			drawComp();
		}

		public function movement(e:KeyboardEvent):void {
			if(e.keyCode == 38) {
				t += pcs;
			} else if(e.keyCode == 40){
				t -= pcs;
			}
			if(t > 1) {
				t = 1;
			} else if(t < 0) {
				t = 0;
			}
			if(e.keyCode == 38 || e.keyCode == 40) {
				bt_txt.text = 'B('+t.toFixed(2)+')';
				bt_txt.autoSize = TextFieldAutoSize.LEFT;
				// Draw the curve
				drawQCurve();
			}
		}

		protected function drawComp():void {
		// This draw the basic UI
			var add_icon:Shape = new Shape();
			add_icon.graphics.lineStyle(2, 0xFFFFFF);
			add_icon.graphics.moveTo(2, 5);
			add_icon.graphics.lineTo(8, 5);
			add_icon.graphics.moveTo(5, 2);
			add_icon.graphics.lineTo(5, 8);
			var addCtrlPt:Function = function(e:Event):void{
				//there is three method:
				//add at the endPoint
				//ctrlPts.push(new Point(ePt.x,ePt.y));
				//add at the startPoint
				//ctrlPts.unshift(new Point(sPt.x,sPt.y));

				//Degree eleation
				elDeg();

				removeDraggers();
				drawQCurve();
				reDrawSkel(true);
				reDrawCurve();
			}
			drawBtn(add_icon, addCtrlPt);
			addEventListener(KeyboardEvent.KEY_DOWN, movement);
		}

		protected function drawBtn(icon:Shape, func:Function):void {
			var new_btn:Sprite = new Sprite();
			new_btn.graphics.beginFill(0xCCFF00);
			new_btn.graphics.drawRect(0, 0, 10, 10);
			new_btn.graphics.endFill();
			new_btn.buttonMode = true;
			new_btn.x = 600;
			new_btn.y = 20;
			addChild(new_btn);
			new_btn.addChild(icon);
			new_btn.addEventListener(MouseEvent.CLICK, func);
		}

		protected function removeDraggers():void {
			for (var i:int = 0; ctrlPts.length - 1 > i; i ++) {
				removeChild(getChildByName("dgr" + i));
			}
		}

		protected function reDrawCurve():void {
			curve.graphics.clear();
			curve.graphics.lineStyle(1);
			// Copy the array
			var curvArr:Array = ctrlPts.concat();
			// Push start point and end point to the array
			curvArr.unshift(new Point(sPt.x, sPt.y));
			curvArr.push(new Point(ePt.x, ePt.y));
			// Move to start point
			curve.graphics.moveTo(sPt.x, sPt.y);
			for (var p:Number = 0; p < 1; p += pcs) {
				var newPt:Point = getPosForTime(p, curvArr);
				curve.graphics.lineTo(newPt.x, newPt.y);
			}
			curve.graphics.lineTo(ePt.x, ePt.y);
			curvArr = null;
			newPt = null;
		}

		protected function getPosForTime(t:Number, Points:Array):Point {
			if(t < 0 || t > 1) {
				trace('Out of bounds [0,1]');
				return new Point(0, 0);
			}
			var n:int = Points.length - 1
			, currX:Number = 0
			, currY:Number = 0
			, binCArr:Vector.<Number> = _Math.binCoef(n);
			for (var i:int = 0; n >= i; i ++) {
			// bezier function B(t) = Summation(n, i=0)[(Pn)BinomialCoefficient(n, i)* t^i * (1-t)^(n-i)]
				var bez:Number = binCArr[i] * Math.pow(1 - t, n - i) * Math.pow(t, i);
				currX +=  bez * Points[i].x;
				currY +=  bez * Points[i].y;
			}
			binCArr = null;
			return new Point(currX, currY);
		}

		protected function reDrawSkel(renew:Boolean):void {
			skeleton.graphics.clear();
			skeleton.graphics.lineStyle(2, 0xFFCC000);
			skeleton.graphics.moveTo(sPt.x, sPt.y);
			if (renew) {
			// draw line between the control points
				for (var s:String in ctrlPts) {
					skeleton.graphics.lineTo(ctrlPts[s].x, ctrlPts[s].y);
					addDragger(int(s));
				}
			} else {
				for (s in ctrlPts) {
					skeleton.graphics.lineTo(ctrlPts[s].x, ctrlPts[s].y);
				}
			}
			// Line to end point
			skeleton.graphics.lineTo(ePt.x, ePt.y);
			s = null;
		}

		protected function drawQCurve():void {
			if(!ctrlPts.length)
			return;
			qCurve.graphics.clear();
			qCurve.graphics.lineStyle(1, 0, .5);
			qCurve.graphics.moveTo(sPt.x, sPt.y);
			drawFirst();
		}

		protected function drawFirst():void {
			var arr:Array = ctrlPts.concat();
			arr.unshift(sPt);
			arr.push(ePt);
			var arr2:Array = [];
			qCurve.graphics.moveTo(arr[0].x*(1 - t) + arr[1].x*t, arr[0].y*(1 - t) + arr[1].y*t);
			for(var i:int = 0; i < arr.length - 1; i ++) {
				var p:Point = new Point(arr[i].x*(1 - t) + arr[i + 1].x*t, arr[i].y*(1 - t) + arr[i + 1].y*t);
				qCurve.graphics.lineTo(p.x, p.y);
				arr2[arr2.length] = p;
				p = null;
			}
			if(arr2.length - 2) {
				qCurve.graphics.moveTo(arr2[0].x, arr2[0].y);
				drawSub(arr2);
			} else {
				bt.x = arr2[0].x*(1 - t) + arr2[1].x*t;
				bt.y = arr2[0].y*(1 - t) + arr2[1].y*t;
			}
			arr = arr2 = null;
		}

		protected function drawSub(arr:Array):void {
			var arr2:Array = [];
			qCurve.graphics.moveTo(arr[0].x*(1 - t) + arr[1].x*t
														 , arr[0].y*(1 - t) + arr[1].y*t);
			for(var i:int = 0; i < arr.length - 1; i ++) {
				var p:Point = new Point(arr[i].x*(1 - t) + arr[i + 1].x*t, arr[i].y*(1 - t) + arr[i + 1].y*t);
				qCurve.graphics.lineTo(p.x, p.y);
				arr2[arr2.length] = p;
				p = null;
			}
			if(arr2.length - 2) {
				qCurve.graphics.moveTo(arr2[0].x, arr2[0].y);
				drawSub(arr2);
			} else {
				bt.x = arr2[0].x*(1 - t) + arr2[1].x*t;
				bt.y = arr2[0].y*(1 - t) + arr2[1].y*t;
			}
			arr = arr2 = null;
		}

		protected function sttDrag(e:Event):void {
			if(!(e.target is TextField)) {
				e.target.startDrag(false);
				e.target.addEventListener(Event.ENTER_FRAME, changePos);
				e.target.addEventListener(MouseEvent.MOUSE_UP, stpDrag);
			}
		}

		protected function stpDrag(e:Event):void {
			e.target.stopDrag();
			e.target.removeEventListener(Event.ENTER_FRAME, changePos);
			e.target.removeEventListener(MouseEvent.MOUSE_UP, stpDrag);
		}

		protected function changePos(e:Event):void {
			var nPt:int = Number(e.target.name.slice(3, e.target.name.length));
			ctrlPts[nPt].x = e.target.x;
			ctrlPts[nPt].y = e.target.y;

			e.target.getChildAt(0).text =
			"x:"+((e.target.x - sPt.x)/(ePt.x-sPt.x)).toFixed(3)
			+"\ny:"+
			((sPt.y - e.target.y)/(sPt.y - ePt.y)).toFixed(3);

			e.target.getChildByName("val").autoSize = TextFieldAutoSize.LEFT;
			reDrawSkel(false);
			reDrawCurve();
			drawQCurve();
		}

		protected function addDragger(pos:int):void {
			var dot:Sprite = new Sprite();
			var valOfPt:TextField = new TextField();
			dot.name = "dgr" + pos;
			valOfPt.name = "val";
			dot.graphics.beginFill(0xCCFF00, .65);
			dot.graphics.drawCircle(0, 0, 5);
			dot.graphics.endFill();
			dot.buttonMode = true;
			dot.x = ctrlPts[pos].x;
			dot.y = ctrlPts[pos].y;
			dot.addEventListener(MouseEvent.MOUSE_DOWN, sttDrag);

			valOfPt.text =
			"x:" + ((dot.x - sPt.x)/(ePt.x - sPt.x)).toFixed(3)
			+"\ny:"+
			((sPt.y - dot.y)/(sPt.y - ePt.y)).toFixed(3);

			valOfPt.autoSize = TextFieldAutoSize.LEFT;
			valOfPt.x = 5;
			valOfPt.y =  -  valOfPt.height / 2;
			valOfPt.selectable = false;
			addChild(dot);
			dot.addChild(valOfPt);
			dot = null;
			valOfPt = null;
		}

		protected function elDeg():void {
			var Pts:Array = this.ctrlPts.concat();
			Pts.unshift(this.sPt);
			Pts[Pts.length] = this.ePt;
			var n:int = Pts.length;
			for (var i:int = 1; i < n; i ++) {
				var a:Number = i/n;
				this.ctrlPts[i - 1] = new Point(a*Pts[i - 1].x + (1 - a)*Pts[i].x, a*Pts[i - 1].y + (1 - a)*Pts[i].y);
			}
			Pts = null;
		}

	}
}
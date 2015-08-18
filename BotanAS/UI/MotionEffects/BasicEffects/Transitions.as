package BotanAS.UI.MotionEffects.BasicEffects {
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class Transitions extends Sprite{

		// Constants:
		// Public Properties:
		public var scaleFactor:Point;
		// Private Properties:
		private var GMotions:*

		, stageW:int = 1024
		, stageH:int = 576
		, halfW:int = .5*stageW
		, halfH:int = .5*stageH
		, _self:* = this


		, echo:Function = function (...msg:*):void { trace(msg); }
		;
		// Initialization:
		public function Transitions(g:*, echo:Function = null):void {
			if(echo as Function) {
				this.echo = echo;
				echo("  {Transitions}");
			}
			if(g['$GMC$'] as Boolean)
			this.GMotions = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
		}
		
		public function init(what:String, ...values:*):Boolean {
			return false;
		}

		public function FlipPage(m:Number = 1, PageColor:uint = 0, BackColor:uint = 0xFFFFFF):void {
			var page:Sprite = new Sprite
			, page_back:Shape = new Shape
			, page_front:Shape = new Shape
			, a:Number = m/(1+m*m)*(stageH + m*stageW)
			, b:Number = -(stageH + m*stageW)/(1+m*m)
			;
			function drw(i:Number):void {
				page_front.graphics.clear();
				page_back.graphics.clear();
				page_front.graphics.beginFill(PageColor);
				page_back.graphics.beginFill(BackColor);
				
				var points:Vector.<Point> = getPoints(a*(i = 1 - i), b*i, m);
				for each(var point:Point in points) {
					if(point)
					page_front.graphics.lineTo(point.x, point.y);
				}
				page_front.graphics.lineTo(0, 0);
				page_front.graphics.endFill();
			}
			page.addChild(page_front);
			page.addChild(page_back);
			clearScene();
			addChild(page);
			GMotions.regEaseFunction(page, 24, 1.5, drw);
		}
		
		public function ripple(__x:Number, __y:Number, wColor:uint = 0xFFFFFF, waves:uint = 3, startR:Number = 0):void {
			// largest R, the outermost ring
			var __R:int = 0;
			switch (getSection(__x, __y)) {
			// Math.sqrt((c - a)*(c - a) + (d - b)*(d - b));
				case 1:
				// a[__x], b[__y], c[stageW], d[stageH]
					__R = Math.ceil( Math.sqrt( (stageW - __x)*(stageW - __x) + (stageH - __y)*(stageH - __y) ) );
				break;
				case 2:
				// a[__x], b[__y], c[0], d[stageH]
					__R = Math.ceil( Math.sqrt( __x*__x + (stageH - __y)*(stageH - __y) ) );
				break;
				case 3:
				// a[__x], b[__y], c[stageW], d[0]
					__R = Math.ceil( Math.sqrt( (stageW - __x)*(stageW - __x) + __y*__y ) );
				break;
				case 4:
				// a[__x], b[__y], c[0], d[0]
					__R = Math.ceil( Math.sqrt( __x*__x + __y*__y ) );
				break;
				default:
					__R = stageH > stageW ? stageH : stageW;
			}
			// Clear the scene
			clearScene();

			var ripple:Sprite = new Sprite;
			ripple.x = __x;
			ripple.y = __y;

			addChild(ripple);

			var circle:Shape = new Shape;
			circle.graphics.beginFill(wColor);
			circle.graphics.drawCircle(0, 0, startR || __R/waves);
			circle.graphics.endFill();
			circle.scaleX = circle.scaleY = 0;
			ripple.addChild(circle);

			GMotions.curveTween(circle, ['scaleX', 'scaleY'], 10, 1, 1);

			__R = __R - startR;
			var stepR:Number = __R/waves
			, shiftConst:Number = 0.5*stepR
			, ringThickness:Number = stepR + 1;
			var ring:Sprite;
			for(var i:int = 0; i < waves; i ++) {
				ring = new Sprite;
				var ringValue:Shape = new Shape;
				
				// ringValue.x stores the radius of each ring.
				ringValue.x = startR + ( i + 1 )*stepR - shiftConst;

				ringValue.addEventListener('ON_MOTION', function (e:Event):void {
					var ringVal:Shape = Shape(e.target)
					, __ring:Sprite = Sprite(ringVal.parent);
					__ring.graphics.clear();
					__ring.graphics.lineStyle(ringThickness*ringVal.alpha, wColor);
					__ring.graphics.drawCircle(0, 0, ringVal.x);
				});

				ring.addChild(ringValue);
				ripple.addChild(ring);

				// ringValue.alpha is set by GMotion to get the easeValue.
				GMotions.curveTween(ringValue, 'alpha', 10, 1, 0.8, 0.1*i, 0);
				// Apeture motion
				GMotions.curveTween(ring, ['scaleX', 'scaleY'], 13, 1, 1, 0.1*i, 0.9);
			}
			ring.addEventListener('All_Tweened', function (e:Event):void {
				clearScene();
				_self.graphics.beginFill(wColor);
				_self.graphics.drawRect(0, 0, stageW, stageH);
				_self.graphics.endFill();
			});
		}

		protected function getPoints(a:Number, b:Number, m:Number):Vector.<Point> {
			var
			// For x = stageW
			  _a:Point = new Point(stageW, m*(stageW - a) + b)
			// For y = stageH
			, _b:Point = new Point((-stageH - b)/m + a, stageH)
			// For x = 0
			, _c:Point = new Point(0, b - m*a)
			// For y = 0
			, _d:Point = new Point(a - b/m, 0)
			, v:Vector.<Point> = new Vector.<Point>(4, true);
			// Tranform Cartesian coordinate system
			_a.y = -_a.y;
			_c.y = -_c.y;
			if(_a.y > 0 && _b.x > 0) {
				v[0] = new Point(stageW, 0);
				v[1] = _a;
				v[2] = _b;
				v[3] = new Point(0, stageH);
			} else if(_a.y < 0 && _b.x > 0) {
				v[0] = _d;
				v[2] = _b;
				v[3] = new Point(0, stageH);
			} else if(_a.y > 0 && _b.x < 0) {
				v[0] = new Point(stageW, 0);
				v[1] = _a;
				v[2] = _c;
			} else if(_a.y < 0 && _b.x < 0) {
				v[0] = _d;
				v[1] = _c;
			}
			return v;
		}

		public function clearScene():void {
			_self.graphics.clear();
			while(this.numChildren)
			removeChildAt(0);
		}

		public function Tint(ColorFrom:uint = 0xFFFFFFFF, ColorTo:uint = 0):void {
		// This simly tint the stage area with color transitions
			var TintScr:Shape = new Shape;
			TintScr.graphics.beginFill(ColorFrom);//0x00CCFF
			TintScr.graphics.drawRect(0, 0, stageW, stageH);
			TintScr.graphics.endFill();
			// Clear the scene
			clearScene();
			addChild(TintScr);
			GMotions.curveTween(TintScr, "color", 16, ColorTo, .5, 0, ColorFrom, {mpr:[[0,0], [0,0], [0,0], [0,0]]});
			TintScr.addEventListener("MOTION_color_COMPLETE", Tint_end);
		}

		private function Tint_end(e:Event):void {
			dispatchEvent(new Event("TintComplete"));
			e.target.removeEventListener(e.type, arguments.callee);
		}

		public function ColorCurtainOn(colorTiles:Vector.<uint>):void {
			clearScene();
			// Create a transition scene
			var Curtain:Sprite = new Sprite
			, leaves:int = colorTiles.length
			, leafH:Number = stageH/leaves
			;
			addChild(Curtain);
			for ( var i:int = 0; i < leaves; i ++ ) {
					var leaf:Shape = new Shape;
					leaf.graphics.beginFill(colorTiles[i]);
					leaf.graphics.drawRect(0, 0, stageW, leafH);
					leaf.graphics.endFill();
					leaf.y = -leafH;
					Curtain.addChild(leaf);
					GMotions.curveTween(leaf, "DropShadowFilter", 13, [5, 90, 0, .75, 10, 10], 0);
					GMotions.curveTween(leaf, "y", 10, leafH*(leaves - i - 1), 0.5);
			}
			leaf.addEventListener("All_Tweened", ColorCurtain_end);
		}

		private function ColorCurtain_end(e:Event):void {
			dispatchEvent(new Event("CurtainComplete"));
			e.target.removeEventListener(e.type, arguments.callee);
		}
		
		public function ColorCurtainOff(colorTiles:Vector.<uint>):void {
			clearScene();
			// Create a transition scene
			var Curtain:Sprite = new Sprite
			, leaves:int = colorTiles.length
			, leafH:Number = stageH/leaves
			;
			addChild(Curtain);
			for ( var i:int = 0; i < leaves; i ++ ) {
					var leaf:Shape = new Shape;
					leaf.graphics.beginFill(colorTiles[i]);
					leaf.graphics.drawRect(0, 0, stageW, leafH);
					leaf.graphics.endFill();
					leaf.y = leafH*(leaves - i - 1);
					Curtain.addChild(leaf);
					GMotions.curveTween(leaf, "DropShadowFilter", 13, [5, 90, 0, .75, 10, 10], 0);
					GMotions.curveTween(leaf, "y", 10, -leafH - 10, 0.5);
			}
			leaf.addEventListener("All_Tweened", ColorCurtain_end);
		}
		
		private function getSection(__x:Number, __y:Number):int {
			//
			// A----B----C
			// |SecA|SecB|
			// |  1 |  2 |
			// D----E----F
			// |SecC|SecD|
			// |  3 |  4 |
			// G----H----I
			//
			if( (__x >= 0 && __y >= 0) && (halfW >= __x && halfH >= __y) ) {
			// point is in section A.
				return 1;
			} else if( (__x >= halfW && __y >= 0) && (stageW >= __x && halfH >= __y) ){
			// point is in section B.
				return 2;
			} else if( (__x >= 0 && __y >= halfH) && (halfW >= __x && stageH >= __y) ) {
			// point is in section C.
				return 3;
			} else if( (__x >= halfW && __y >= halfH) && (stageW >= __x && stageH >= __y) ) {
			// point is in section D.
			  return 4;
			}
			// Out of boundary.
			return 0;
		}

	}
}
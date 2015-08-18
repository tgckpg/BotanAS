package BotanAS.UI.BasicTools.Miscellaneous {
// This components works with GLoader class, it display the loading info for loaders
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;
	
	import flash.events.Event;

	public class GLoaderInfo extends Sprite {
		private namespace GMS;
		private namespace GLC;

		private var
		// Classes that would be used
		  GLoader:*
		, GMotions:*
		// Info in GLoader class
		, info:Vector.<String>
		, infoName:Vector.<String>
		, infoTf:Vector.<TextField>
		// Text format for textfields
		, ITextFormat:TextFormat

		// Echo function for debugging
		, echo:Function = function (...msg:*):void { trace(msg); }
		
		, classStatus:Namespace
		;

		public function GLoaderInfo (GLoader:*, GMotions:* = null, echo:Function = null) {
			if(echo as Function) {
				this.echo = echo;
				echo ("  {GLoaderInfo}");
			}
			if(GLoader.$GLC$) {
				this.GLoader = GLoader;
				// Get info vector
				info = GLoader.getLoadInfo();
				classStatus = GLC;
			}
			if(GMotions&&GMotions.$GMC$) {
				this.GMotions = GMotions;
				classStatus = GMS;
			}
			ITextFormat = new TextFormat("_sans");
			classStatus::drawUI();
			GLoader.addEventListener("onGoing", classStatus::SlideInfo);
			GLoader.addEventListener(Event.COMPLETE, classStatus::onComplete);
		}
		
		GLC function drawUI ():void {
			infoTf = new Vector.<TextField>(GLoader.maxThreads, true);
			for ( var i:int = 0; i < GLoader.maxThreads; i ++ ) {
				infoTf[i] = new TextField;
				addChild(infoTf[i]);
			}
		}
		
		GMS function drawUI ():void {
			// Register infoTf;
			infoTf = new Vector.<TextField>(2*GLoader.maxThreads, true);
			infoName = new Vector.<String>(GLoader.maxThreads, true);
			
			// initialize infoName
			infoName.forEach(initInfoName);
			
			// Draw the loading square
			var LoadSquare:Sprite = drawLoadSquare();
			// scale bigger
			LoadSquare.scaleX = LoadSquare.scaleY = 2;
			LoadSquare.x = 1024 - 50;
			LoadSquare.y = 576 - 50;
			
			for (var i:int = 0; i < GLoader.maxThreads; i ++) {
				var threadStamp:Sprite = drawThreadStamp(i);
				threadStamp.y = i * .5*threadStamp.height;
				addChild(threadStamp);
			}
			
			
			
			
			addChild(LoadSquare);
			GMotions.curveTween(LoadSquare, "DropShadowFilter", 24, [5, 45, 0, .75, 5, 5], .5);
		}
		
		GMS function SlideInfo(e:Event):void {
			for (var i:int = 0, j:int = 0; j < GLoader.maxThreads; i += 2, j ++) {
				if(info[j]) {
					var str:String = info[j] && info[j].split("... ")[0];
					if(infoName[j] == str) {
						infoTf[i].text = "Currently loading " + info[j] + "%";
					} else {
						infoTf[i + 1].text = "Currently loading " + info[j] + "%";
						GMotions.curveTween(infoTf[i], "y", 24, -infoTf[i].height, .2);
						GMotions.curveTween(infoTf[i + 1], "y", 24, 0, .2);
						TfInfo_swapIndex(i, i+1);
					}
					infoTf[i].setTextFormat( ITextFormat );
					infoTf[i+1].setTextFormat( ITextFormat );
					
					// Put infoName for verification
					infoName[j] = str;
					
				}
			}
		}
		private function initInfoName(item:int, index:int, vector:Vector.<String>):void {
			vector[index] = "";
		}
		protected function TfInfo_swapIndex(a:int, b:int):void {
			var f:TextField = infoTf[a];
			infoTf[a] = infoTf[b];
			infoTf[b] = f;
			f = null;
		}
		GMS function onComplete(e:Event):void {
			for(var i:int = 0; i < GLoader.maxThreads; i ++) {
				var stamp:Sprite = Sprite(getChildAt(i));
				GMotions.curveTween(stamp, "y", 24, -stamp.height, .5);
			}
			stamp.addEventListener("All_Tweened", function (e:Event):void {
				e.target.removeEventListener(e.type, arguments.callee);
				dispatchEvent(new Event("CleanedUp"));
			});
			stamp = Sprite(getChildAt(i));
			GMotions.curveTween(stamp, "x", 24, 1200, .5, 1);
		}
		
		protected function drawThreadStamp(sn:int):Sprite {
		// Create | Thread n |   Sliding info   |
			var stamp:Sprite = new Sprite
			, content:Sprite = new Sprite
			, tfTitle:TextField = new TextField
			, tfInfo:TextField = new TextField
			, tfInfod:TextField = new TextField
			, contentMask:Shape = new Shape;

			// Sizing and positioning
			tfTitle.text = "Thread " + String(sn) + " :";
			tfInfod.text = tfInfo.text = "Ready"
			tfTitle.autoSize = TextFieldAutoSize.LEFT;
			tfInfod.width = tfInfo.width = 200;
			tfInfod.height = tfInfo.height = tfTitle.height;
			tfInfod.x = tfInfo.x = tfTitle.width + 10;
			tfInfod.y = tfInfo.height;
			tfInfo.textColor = tfTitle.textColor = tfInfod.textColor = 0xFFFFFF;
			tfInfod.selectable = tfTitle.selectable = tfInfo.selectable = false;

			// Mask
			contentMask.graphics.beginFill(0);
			contentMask.graphics.drawRect(0, 0, tfTitle.width + tfInfo.width, tfInfo.height);
			contentMask.graphics.endFill();
			
			infoTf[sn] = tfInfo;
			infoTf[sn + 1] = tfInfod;

			content.mask = contentMask;
			
			tfTitle.setTextFormat( ITextFormat );
			tfInfo.setTextFormat( ITextFormat );
			tfInfod.setTextFormat( ITextFormat );

			content.addChild(tfTitle);
			content.addChild(tfInfo);
			content.addChild(tfInfod);
			stamp.addChild(content);
			stamp.addChild(contentMask);
			
			return stamp;
		}
		
		protected function drawLoadSquare():Sprite {
			var lSquare:Sprite = new Sprite
				, s0:Sprite = new Sprite
				, s1:Shape = new Shape
				, s2:Shape = new Shape
				, s3:Shape = new Shape
				, s4:Shape = new Shape
				;
			function quickSquare(s:Shape):void {
				s.graphics.beginFill(0xFFFFFF);
				s.graphics.drawRect(-2.5, -2.5, 5, 5);
				s.graphics.endFill();
				s0.addChild(s);
			}
			quickSquare(s1);
			quickSquare(s2);
			quickSquare(s3);
			quickSquare(s4);
			lSquare.addChild(s0);
			GMotions.regFrameFunction(lSquare, function():void {
				s1.rotation = s2.rotation = s3.rotation = (s4.rotation -= 10);
				s1.x = s3.x = s1.y = s4.y = 5*Math.sin((s0.rotation += 2)/180*Math.PI);
				s2.x = s4.x = s2.y = s3.y = -s1.x;
			});
			return lSquare;
		}
		
		GLC function SlideInfo(e:Event): void {
			var px:int = 0
			, py:int = 0
			;
			// Simple TextField handles info
			for ( var i:int = 0; i < GLoader.maxThreads; i ++ ) {
				var t:TextField = infoTf[i];
				t.text = "Thread " + String(i) + ": ";
				t.appendText( info[i] ? "Currently loading " + info[i] + "%":"Ready" );
				t.autoSize = TextFieldAutoSize.LEFT;
				t.x = px;
				t.y = (py += t.height);
				t.setTextFormat( ITextFormat );
			}
		}
		
		GLC function onComplete (e:Event):void {
			for ( var i:int = 0; i < GLoader.maxThreads; i ++ ) {
				removeChildAt(0);
			}
		}
		
		

	}
}
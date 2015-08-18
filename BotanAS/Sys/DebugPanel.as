package BotanAS.Sys {
	import flash.utils.getTimer;
	import flash.system.System;
	import flash.system.System;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class DebugPanel extends Sprite {
		public var fmt:TextFormat = new TextFormat("_sans", 12)
		, listObL:Boolean = false
		;
		
		private var out_que:Array = []
		, verbose:TextField
		, fpsStmp:TextField
		, memStmp:TextField
		, nameChild:TextField
		, ssc:int = 0
		, ttt:int = 0
		, GMotions:*
		, echo:Function = function (...msg:*):void { trace(msg); }
		;
		
		public function DebugPanel(g:*, echo:Function = null):void {
			if(g['$GMC$'] as Boolean)
			this.GMotions = g;
			else {
				trace('Error:Class "GMotions" is required.');
				return;
			}
			if(echo as Function) {
				this.echo = echo;
				echo ("  {DebugPanel}");
			}
			debugUI();
		}
		
		protected function debug_GMs():Boolean {
			output("Currently "+String(GMotions.debug_countobL())+" objects in GMs::obL.\n"
						+ "Triggers " + String(GMotions.debug_getTriggered() - ttt)+" times/frame.\n"
						+ "Motion cycle intervals: " + String(GMotions.debug_getLoopTime()) + "ms\n"
						+ String(GMotions.debug_getDone())+" objects removed from motion.", 0);
			
			if( GMotions.debug_getLoopTime() > 200 ) {
				echo("Posible issue detected:");
				echo("Pausing GMs ...");
				GMotions.debug_pauseWorld();
				if(listObL) {
					echo("  Listing ObL ...");
					GMotions.debug_listobL();
				}
				return false;
			}
			ttt = GMotions.debug_getTriggered();
			return true;
		}

		protected function drawBasics():void {
			var dte:Number = 0;
			fpsStmp = new TextField();
			memStmp = new TextField();
			verbose = new TextField();
			nameChild = new TextField();
			verbose.selectable
				= fpsStmp.selectable
				= memStmp.selectable
				= nameChild.selectable
				= false;
			fpsStmp.setTextFormat(fmt);
			memStmp.setTextFormat(fmt);
			fpsStmp.autoSize = memStmp.autoSize = "left";
			fpsStmp.x = memStmp.x = 5;
			fpsStmp.y = 556;
			memStmp.y = 536;
			this.addChild(fpsStmp);
			this.addChild(memStmp);
			this.addChild(nameChild);
			this.addChild(verbose);
			function getRec(e:Event):void {
				var fps:Number = 1000/(getTimer() - dte)
				, bn:String = " B"
				, mem:Number = System.totalMemory;
				if(mem > 1024) {
					mem = Number(mem/1024);
					bn = " KB";
				}
				if(mem > 1024) {
					mem = Number(mem/1024);
					bn = " MB";
				}
				if(fps > 58)fpsStmp.textColor = 0;
				else fpsStmp.textColor = 0xFF0000;
				if(mem < 5 && bn == " MB")memStmp.textColor = 0;
				else memStmp.textColor = 0xFF0000;
				fpsStmp.text = "FPS:" + fps.toFixed(4);
				memStmp.text = "Memory:" + mem.toFixed(4) + bn;
				nameChild.text = GMotions.debug_child;
				fpsStmp.autoSize
					= nameChild.autoSize
					= memStmp.autoSize
					= "left";

				verbose.x
					= fpsStmp.x
					= memStmp.x
					= nameChild.x
					= mouseX + 16;
				nameChild.y = mouseY;
				memStmp.y = nameChild.y - 20;
				fpsStmp.y = memStmp.y - 15;
				verbose.y = nameChild.y + 20;
				
				dte = getTimer();
				fpsStmp.setTextFormat(fmt);
				memStmp.setTextFormat(fmt);
				if(!debug_GMs()) {
					e.target.removeEventListener(e.type, arguments.callee);
				}
			}
			addEventListener(Event.ENTER_FRAME, getRec);
		}

		protected function debugUI():void {
			drawBasics();
			fpsStmp.defaultTextFormat = memStmp.defaultTextFormat = fmt;
			verbose.defaultTextFormat = new TextFormat("_sans");
			fpsStmp.embedFonts = memStmp.embedFonts = true;
		}
		
		private function output(str:String, i:int):void {
			out_que[i] = str;
			verbose.text = out_que.join('\n\n');
			verbose.width = 600;
			verbose.wordWrap = true;
			verbose.autoSize = "left";
		}
		
	}
}
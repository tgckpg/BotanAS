package BotanAS.Sys {
	import flash.external.ExternalInterface;
	import flash.utils.Timer;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.system.Security;

	public class ExtAPI
	{
		Security.allowDomain("*.astropenguin.net");

		private const debug:Boolean = true;

		private var enableQue:Boolean = false
			, isExt:Boolean = false
			, ique:Vector.<String> = new Vector.<String>
			, que:Vector.<String> = new Vector.<String>
			, fque:Vector.<Array> = new Vector.<Array>
			, receivedFromJavaScript:Function
			, currentWait:int = 0
			, nextWait: int = 1
		;

		private var rJSCall:String = String( <![CDATA[
			function() {
				return window.BotanJS && BotanJS.import( "Dandelion.Swf.ExtAPI" ).ready();
			}
		]]> );

		private var sendToJavaScript:String = String( <![CDATA[
			function( mesg ) {
				if( window.BotanJS )
				{
					var debug = BotanJS.import( "System.Debug" );
					if( debug ) debug.Info( mesg );
				}
			}
		]]> );

		public function ExtAPI():void
		{
			if ( ExternalInterface.available )
			{
				try
				{
					if ( !checkExt() )
					{
						var readyTimer:Timer = new Timer( 100, 0 );
						readyTimer.addEventListener( TimerEvent.TIMER, timerHandler );
						readyTimer.start();
						sysOut( "Listening ..." );
					}
					else
					{
						extReady();
					}
				}
				catch (error:SecurityError)
				{
					sysOut( "A SecurityError occurred: " + error.message );
				}
				catch (error:Error)
				{
					sysOut( "An Error occurred: " + error.message );
				}
			}
			else
			{
				sysOut( "External interface is not available for this container." );
			}
		}

		public function getEcho(enableQue:Boolean = false):Function
		{
			this.enableQue = enableQue;
			return echo;
		}

		public function get isLocal():Boolean
		{
			return ExternalInterface.available;
		}

		public function addCall(id:String, handler:Function):void
		{
			if( isExt )
			{
				sysOut( "Adding callback: " + id );
				ExternalInterface.addCallback(id, handler);
			}
			else if( enableQue )
			{
				sysOut( "Queueing callback: " + id );
				fque[fque.length] = [id, handler];
			}
			else
			{
				sysOut( "Method \"" + id + "\" is not added: swf is not initiated yet." );
			}
		}

		public function getCall( id:String, ...vars:* ):*
		{
			if( isExt )
				return ExternalInterface.call(id, vars);
		}

		private function checkExt():Boolean
		{
			if( ExternalInterface.call( this.rJSCall ) )
			{
				isExt = true;
			}

			return isExt;
		}

		private function timerHandler( event:TimerEvent ):void
		{
			if( currentWait ++ < nextWait ) return;

			currentWait = 0;
			nextWait *= 2;

			if ( checkExt() )
			{
				Timer( event.target ).stop();
				releaseQues();
				extReady();
			}
		}

		private function extReady():void
		{
			// dummy function
			addCall( "dummy", function ():Boolean { return true } );
			sysOut( "Ready." );
		}

		private function releaseQues():void
		{
			var msgs:Vector.<String> = ique.concat(que);

			for each(var i:* in msgs)
			{
				echo(i);
			}

			for each( var callBack:Array in fque )
			{
				sysOut( "Adding callback \"" + callBack[0] + "\" ..." );
				ExternalInterface.addCallback( callBack[0], callBack[1] );
			}

			fque.length = 0;
			ique.length = que.length = 0;
		}

		private function echo( ...message:* ):void
		{
			var msg:String = (message is Array) ? message.join(" ") : message.toString();
			writeMesg( msg );
		}
		
		private function sysOut( ...message:* ):void
		{
			var msg:String = "[Swf:ExtAPI] " + ((message is Array) ? message.join(" ") : message.toString());
			writeMesg( msg );
		}

		private function writeMesg( mesg:String ):void
		{
			if( debug ) trace( mesg );

			if (isExt)
			{
				ExternalInterface.call( this.sendToJavaScript, mesg );
			}
			else if( enableQue )
			{
				que[que.length] = mesg;
			}
		}
	}
}

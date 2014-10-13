package  {
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.net.InterfaceAddress;
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	import flash.net.Socket;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import myClasses.events.DatEvent;
	
	public class NetWorkSeaching extends EventDispatcher{

		private var self:NetWorkSeaching;
		public static const FIND:String="find";
		private var num:int;
		private var sockets:Array;
		public var isSearching:Boolean;
		public function NetWorkSeaching() {
			self=this;
		}

		public function getIp():Array{
			var v:Vector.<NetworkInterface>=NetworkInfo.networkInfo.findInterfaces();
			var addresses:Array=[];
			for(var i=0;i<v.length;i++){
				if(v[i].active){
					var a:Vector.<InterfaceAddress>=v[i].addresses;
					for(var j=0;j<a.length;j++){
						if(a[j].address&&testIp(a[j].address)){
							addresses.push(a[j].address);
						}
					}
				}
			}
			return addresses;
		}
		
		private function testIp(s:String):Boolean{
			
			return (/\d+\.\d+\.\d+\.\d+/.test(s))&&s!="127.0.0.1";
		}
		
		public function startSearch(port:int):void{
			var ips:Array=getIp();
			isSearching=true;
			sockets=[];
			if(ips.length==0){
				self.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"无网络连接",0));
				return;
			}
			this.num=0;
			for(var i=0;i<ips.length;i++){
				testOne(ips[i],port);
			}
		}
		private function testOne(ip:String,port:int):void{
			var a:Array=ip.split(".");
			var index:int=int(a[3]);
			for(var i=index-1;i>=0;i--){
				var cip:String=a[0]+"."+a[1]+"."+a[2]+"."+i;
				test(cip,port);
				num++;
			}
			for(var i=index+1;i<=255;i++){
				var cip:String=a[0]+"."+a[1]+"."+a[2]+"."+i;
				test(cip,port);
				num++;
			}
			
		}
		public function stopAll():void{
			if(isSearching){
				for each(var s:Socket in sockets){
					try{
						s.close();
					}catch(e){
						
					}
				}
				sockets=null;
			}
		}
		public function test(ip:String,port:int){
			var s:Socket=new Socket();
			s.addEventListener(Event.CONNECT,hcon);
			s.addEventListener(IOErrorEvent.IO_ERROR,herr);
			s.connect(ip,port);
			sockets.push(s);
			//var t:Timer=new Timer(2000,1);
			//t.start();
			//t.addEventListener(TimerEvent.TIMER,htime);
			function hcon(e:Event){
				s.removeEventListener(Event.CONNECT,hcon);
				s.removeEventListener(IOErrorEvent.IO_ERROR,herr);
				//t.removeEventListener(TimerEvent.TIMER,htime);
				self.dispatchEvent(new DatEvent(NetWorkSeaching.FIND,ip));
				num--;
				s.close();
				if(sockets.indexOf(s)!=-1) sockets.splice(sockets.indexOf(s),1);
				if(num==0){
					self.dispatchEvent(new Event(Event.COMPLETE));
				}
				//trace("find");
			}
			function herr(e:Event){
				s.removeEventListener(Event.CONNECT,hcon);
				s.removeEventListener(IOErrorEvent.IO_ERROR,herr);
				num--;
				if(sockets.indexOf(s)!=-1) sockets.splice(sockets.indexOf(s),1);
				if(num==0){
					isSearching=false;
					self.dispatchEvent(new Event(Event.COMPLETE));
				}
				//trace("error");
			}
		}

	}
	
}

package myClasses{
	import flash.utils.Timer;
	import flash.display.DisplayObject;
	import flash.events.TimerEvent;
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import myClasses.lang.Stack;
	import flash.events.EventDispatcher;
	import flash.events.ProgressEvent;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import myClasses.maths.Vec;
	import myClasses.maths.Mat;

	public class Utils extends EventDispatcher{
		private var thisDispatcher:Utils;
		public function Utils(){
			thisDispatcher=this;
		}
		public static function show(str:String,op:*,timeBreak:uint,over:Function=null):Object {
			var timer:Timer=new Timer(timeBreak);
			var str:String;
			var counter:uint=0;
			var func:Function;
			//op.text="";
			func=over;
			timer.start();
			timer.addEventListener(TimerEvent.TIMER,time);
			function time(e):void {
				if (counter>=str.length) {
					timer.stop();
					timer.removeEventListener(TimerEvent.TIMER,time);
					if (func!=null) {
						func();
					}
					return;
				} else {
					op.text+=str.charAt(counter++);
					op.setSelection(op.length,op.length);
					if(op.hasOwnProperty("verticalScrollPosition")) op.verticalScrollPosition=op.maxVerticalScrollPosition;
				}
			}
			return {timer:timer,string:str,output:op,over:over};
		}
		public static function mess(array:Array):Array {
			var a:Array=[];
			for(var i=0;i<array.length;i++){
				a.push(array[i]);
			}
			for (var i =0; i<a.length; i++) {
				var temp=a[i];
				var ran=Math.floor(Math.random()*a.length);
				a[i]=a[ran];
				a[ran]=temp;
			}
			return a;
		}
		public static function getRandom(a:Array):* {
			return a[rand(0,a.length-1)];
		}
		public static function rand(a:int,b:int):int {
			if (a>b) {
				throw new ArgumentError("The first number should be smaller than the second one.");
			}
			return Math.floor(Math.random()*(b-a+1))+a;
		}


		public static function eval(s:String) {

			var sopr:Stack=new Stack();
			var snum:Stack=new Stack();
			var prep:String="";
			var def:Object={"+":1,"-":1,"*":2,"/":2,"^":3,"(":4};

			s="("+s+")";
			for (var i=0; i<s.length; i++) {
				var now=s.charAt(i);
				//trace(sopr);
				//trace(snum);
				//trace(prep);
				//trace("\n");
				//trace(i,now);
				
				if (isNaN(now)&&now!="."&&!(now=="-"&&prep==""&&sopr.getTop()!=")")) {
					if (prep) {
						snum.push(Number(prep));
						prep="";
					}
					if (sopr.isEmpty) {
						sopr.push(now);
					} else {
						while (comp(now,sopr.getTop())<=0&&!sopr.isEmpty&&sopr.getTop()!="(") {
							snum.push(exe(snum.pop(),snum.pop(),sopr.pop()));
						}
						if (comp(now,sopr.getTop())==0) {
							sopr.pop();
						} else {
							sopr.push(now);
						}
					}
				} else {
					prep+=now;
				}
			}
			function comp(a:String,b:String):int {
				if (! b||def[a]==def[b]) {
					return -1;
				} else if (a==")") {
					return 0;
				} else {
					return def[a]-def[b];
				}
			}
			function exe(b:Number,a:Number,opr:String) {
				switch (opr) {
					case "+" :
						return a+b;
					case "-" :
						return a-b;
					case "*" :
						return a*b;
					case "/" :
						return a/b;
					case "^" :
						return Math.pow(a,b);
				}
			}
			return snum.pop();
		}


		static public function XMLToObject(dp:XML,ignoreNamespace:Boolean=false):Object {
			if (dp) {
				var _obj={};
				dp.ignoreWhitespace=true;
				pNode(dp,_obj,ignoreNamespace);
				return _obj;
			}
			return null;
		}

		static private function pNode(node,obj:Object,ignoreNamespace:Boolean):void {
			//
			if (ignoreNamespace) {
				node.setNamespace("");
			}//
			var nodeName=node.name().toString();
			var o:Object={};
			var j;
			if (node.attributes().length()>0) {
				for (j in node.attributes()) {
					o[node.attributes()[j].name().toString()]=node.attributes()[j];
				}
				if (node.children().length()<=1&&o["value"]==undefined) {
					o["value"]=node.toString();
				}
			} else {
				if (node.children().length()<=1&&! node.hasComplexContent()) {
					o=node.toString();
				}
			}
			//------------------------------
			if (obj[nodeName]==undefined) {
				obj[nodeName]=o;
			} else {
				if (obj[nodeName] is Array) {
					obj[nodeName].push(o);
				} else {
					obj[nodeName]=[obj[nodeName],o];
				}
			}
			try {
				toObj(node,obj[nodeName],ignoreNamespace);
			} catch (e) {
			}

		}

		static private function toObj(dp:XML,obj:Object,ignoreNamespace:Boolean):void {
			var i,j,nodeName,nl;
			nl=dp.children().length();
			for (i=0; i<nl; i++) {
				var node=dp.children()[i];
				if (obj is Array) {
					pNode(node,obj[obj.length-1],ignoreNamespace);
				} else {
					pNode(node,obj,ignoreNamespace);
				}//
			}
		}
		
		public static function callDelay(f:Function,delay:Number,... paras):void{
			var t:Timer=new Timer(delay,1);
			t.addEventListener(TimerEvent.TIMER,time);
			t.start();
			times.push(t);
			function time(e:TimerEvent){
				t.removeEventListener(TimerEvent.TIMER,time);
				times.splice(times.indexOf(t),1);
				t=null;
				if(paras.length==0){
					f();
				}else{
					f.apply(null,paras);
				}
			}
		}
		public static function stopAll(){
			for each(var i:Timer in times){
				i.stop();
				times=[];
			}
		}
		private static var times:Array=[];
		public static function getRandoms(a:Array,n:uint):Array{
			if(n>a.length){
				throw new Error("n should be smaller than the length of a.");
			}else{
				var clone:Array=[];
				var temp:Array=[];
				for(var i=0;i<a.length;i++){
					clone[i]=a[i];
				}
				for(i=0;i<n;i++){
					var tempint:int=rand(0,clone.length-1);
					temp.push(clone[tempint]);
					clone.splice(tempint,1);
				}
				return temp;
			}
		}
		private var counter:int;
		public function visitAsync(a:Array,f:Function,manual:Boolean=false,interval:int=30,thisobj:Object=null):void{
			counter=0;
			if(manual){
				this.addEventListener("NEXT",visit);
			}
			function visit():void{
				if(counter<a.length){
					counter++;
					f.call(thisobj,a[counter-1],counter-1,a);
					thisDispatcher.dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS,false,false,counter,a.length));
					if(!manual) callDelay(visit,interval);
				}else thisDispatcher.dispatchEvent(new Event(Event.COMPLETE));
			}
			if(a.length==0) return;
			visit();
		}
		public function get now():int{
			return counter;
		}
		public function next():void{
			thisDispatcher.dispatchEvent(new Event("NEXT"));
		}
		public static function packTime(seconds:uint):String{
			var hours:int=Math.floor(seconds/3600);
			seconds-=hours*3600;
			var minutes:int=Math.floor(seconds/60);
			seconds-=minutes*60;
			var str:String="";
			if(hours) str+=hours+"小时";
			if(minutes) str+=minutes+"分";
			if(seconds) str+=seconds+"秒";
			return str;
		}
		static public function checkDate(year:String,month:String,day:String):Boolean{
			var days:Array=[null,31,28,31,30,31,30,31,31,30,31,30,31];
			var daysR:Array=[null,31,29,31,30,31,30,31,31,30,31,30,31];
			if(isNaN(Number(year))||isNaN(Number(month))||isNaN(Number(day))) return false;
			if(int(year)%400==0||(int(year)%4==0&&int(year)%100!=0)){
				return int(day)<=daysR[month];
			}else{
				return int(day)<=days[month];
			}
			return false;
		}
		static public var mat:Mat=new Mat([1,46,7,2],
										  [12,6,7,9],
										  [3,6,25,7],
										  [12,73,5,9]);
		static public function lock(s:String):String{
			var ba:ByteArray=new ByteArray();
			ba.writeMultiByte(s,"utf-8");
			/*if(ba.length>255){
				ba.clear();
				throw new Error("to long!");
				return;
			}*/
			var ans:ByteArray=new ByteArray();
			ans.writeByte(ba.length);
			while(ba.length%4!=0){
				ba.writeByte(0);
			}
			var v:Vec=new Vec();
			ba.position=0;
			while(ba.bytesAvailable>0){
				v.addDimension(ba.readUnsignedByte());
				v.addDimension(ba.readUnsignedByte());
				v.addDimension(ba.readUnsignedByte());
				v.addDimension(ba.readUnsignedByte());
				v.transform(mat);
				ans.writeShort(v.x);
				ans.writeShort(v.y);
				ans.writeShort(v.z);
				ans.writeShort(v.w);
				v.reset();
			}
			ans.compress();
			return "$"+Base64.encodeByteArray(ans);
		}
		static public function unlock(s:String):String{
			if(s=="") return "";
			else if(s.charAt(0)!="$") return s;
			try{
			s=s.slice(1);
			var ba:ByteArray=Base64.decodeToByteArray(s);
			ba.uncompress();
			var ans:ByteArray=new ByteArray();
			var l:int=ba.readUnsignedByte();
			var v:Vec=new Vec();
			var m:Mat=mat.inverse();
			ba.position=1;
			while(ba.bytesAvailable>0){
				v.addDimension(ba.readUnsignedShort());
				v.addDimension(ba.readUnsignedShort());
				v.addDimension(ba.readUnsignedShort());
				v.addDimension(ba.readUnsignedShort());
				v.transform(m);
				ans.writeByte(Math.round(v.x));
				ans.writeByte(Math.round(v.y));
				ans.writeByte(Math.round(v.z));
				ans.writeByte(Math.round(v.w));
				v.reset();
			}
			ans.position=0;
			return ans.readMultiByte(ans.bytesAvailable,"utf-8");
			}catch(e:Error){
				return "";
			}
			return ""
		}
		static public function getLength(o:Object):uint{
			var counter:uint=0;
			for(var i:* in o){
				counter++;
			}
			return counter;
		}
		static public function stringToObject(s:String):*{
			if(!s) return "";
			s=trim(s);
			if(s.charAt(0)=="{"&&s.charAt(s.length-1)=="}"){
				var o:Object=new Object();
				var items:Array=split(s.slice(1,-1),",");
				//trace("items: length:"+items.length);
				//trace(items.join("\n\n"));
				for(var i=0;i<items.length;i++){
					var temp:Array=split(items[i],":");
					var key:String=temp[0];
					key=stringToObject(key);
					var valueRow:String=temp[1];
					var value:*=stringToObject(valueRow);
					o[key]=value;
				}
				return o;
			}else if(s.charAt(0)=="["&&s.charAt(s.length-1)=="]"){
				var a:Array=[];
				items=split(s.slice(1,-1),",");
				for(i=0;i<items.length;i++){
					a[i]=stringToObject(items[i]);
				}
				return a;
			}else{
				if(s.charAt(0)=="\""&&s.charAt(s.length-1)=="\"") return s.slice(1,-1);
				else return s;
			}
		}
		static private function split(s:String,spr:String):Array{
			if(!s) return [];
			var temp:Array=[""];
			var stack:Stack=new Stack();
			for(var j=0;j<s.length;j++){
				if(!stack.isEmpty&&getRight(stack.getTop())==s.charAt(j)){
					stack.pop();
					temp[temp.length-1]+=s.charAt(j);
				}else if(stack.getTop()!="\""&&isLeft(s.charAt(j))){
					stack.push(s.charAt(j));
					temp[temp.length-1]+=s.charAt(j);
				}else if(stack.isEmpty&&s.charAt(j)==spr){
					temp.push("");
				}else{
					temp[temp.length-1]+=s.charAt(j);
				}
			}
			return temp;
		}
		static private function isLeft(s:String):Boolean{
			if(s=="\""||s=="["||s=="{") return true;
			return false
		}
		static private function getRight(s:String):String{
			switch(s){
				case "\"":
				return "\"";
				case "[":
				return "]";
				case "{":
				return "}";
			}
			return s;
		}
		static public function trim(str:String,blank:Array=null):String{
			if(!blank) blank=Utils.blank;
			for(var i=0;i<str.length;i++){
				//trace(str.charCodeAt(i));
				if(blank.indexOf(str.charAt(i))==-1) break;
			}
			for(var j=str.length-1;j>=0;j++){
				if(blank.indexOf(str.charAt(j))==-1) break;
			}
			return str.slice(i,j+1);
		}
		static public var blank:Array=[" ","	","\n","\r"," "];

	}
}
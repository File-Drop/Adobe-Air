package myClasses {
	import flash.display.NativeMenu;
	import flash.display.NativeMenuItem;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.system.fscommand;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.ByteArray;
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.NativeWindowType;
	import flash.events.InvokeEvent;
	
	public class UtilsAIR {

		public static function buildMenu(xmllist:XMLList,funcObj)
		{
			var menu:NativeMenu=new NativeMenu();
			for each (var i:XML in xmllist)
			{
				if (i. @ type == "item")
				{
					if (i. @ cut == "0")
					{
						var nmi:NativeMenuItem = new NativeMenuItem(i);
						nmi.data = i. @ action;
						if (i. @ key)
						{
							nmi.keyEquivalent = i. @ key;
						}
						nmi.addEventListener(Event.SELECT,menuSelect);
					}
					else
					{
						nmi = new NativeMenuItem(i,true);
					}
					menu.addItem(nmi);
				}
				else
				{
					var nm:NativeMenu = buildMenu(i.child("item"),funcObj);
					menu.addSubmenu(nm,i.@name);
				}
			}
			function menuSelect(e)
			{
				funcObj[e.target.data](null);
			}
			return menu;
		}
		public static function remember(objs:Array){
			NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,hin);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING,hout);
			function hin(e:InvokeEvent){
				var f:File=File.applicationStorageDirectory.resolvePath("remember.plist");
				var fs:FileStream=new FileStream();
				if(f.exists){
					try{
						fs.open(f,"read");
						var data:Object=fs.readObject();
						for each(var i:Array in objs){
							for each(var j:String in i[2]){
								i[0][j]=data[i[1]][j];
							}
						}
					}catch(e:Error){
						trace("Error to read menmories.");
					}
				}
			}
			function hout(e:Event){
				var f:File=File.applicationStorageDirectory.resolvePath("remember.plist");
				var fs:FileStream=new FileStream();
				fs.open(f,"write");
				fs.position=0;
				fs.truncate();
				var data:Object=new Object();
				for each(var i:Array in objs){
					data[i[1]]=new Object();
					for each(var j:String in i[2]){
						data[i[1]][j]=i[0][j];
					}
				}
				fs.writeObject(data);
				fs.close();
			}
		}

	}
	
}

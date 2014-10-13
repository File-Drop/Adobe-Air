package myClasses.events {
	import flash.events.Event;
	
	public class DatEvent extends Event{

		public var data:Object;
		public function DatEvent(type:String,data:Object) {
			super(type);
			this.data=data;
		}

	}
	
}

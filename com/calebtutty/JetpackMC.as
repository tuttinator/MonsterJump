package com.calebtutty{
	
	import flash.display.MovieClip;
	
	public class JetpackMC extends MovieClip {

		public var collisionArea:MovieClip;	//this is will hold a reference
											//to the playerMC
											//so we can test if there is a
											//collision
		public var type:String = "Jetpack";
		
		public function JetpackMC()
		{
			trace ("JetpackMC constructed");
		}
		
		public function collisionTest():Boolean {	
			if (hitTestObject(collisionArea)) {
				return true;
			}
			else {
				return false;
			}
		}
	}
	
}
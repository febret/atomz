package atomz 
{
	import flash.display.*;
	import flash.events.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class GameOverlay extends Sprite
	{
		/**********************************************************************************************
		 * Assets
		 */
        [Embed(source="../../assets/Mask1.png")]
        public static const bmpMask1: Class;
        //[Embed(source="../../assets/Mask2.png")]
        //public static const bmpMask2: Class;
		
		/******************************************************************************************
		 */
		public function GameOverlay(game: Game) 
		{
			myGame = game;
			myGame.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			myMask1 = new bmpMask1();
			//myMask2 = new bmpMask2();
			addChild(myMask1);
			//addChild(myMask2);
			mouseEnabled = false;
		}
		
		/******************************************************************************************
		 */
		public function remove() : void
		{
			removeEventListener(Event.ENTER_FRAME, onFrame);
			myGame.removeChild(this);
		}
		
		/******************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myGame.addChildAt(this, myGame.numChildren - 1);
			myMask1.alpha = 0.4 + Math.random() / 50;
			//myMask2.alpha = (!(myFrameCount % 4) ? 0.6 : 0) //+ Math.random() / 50;
			myFrameCount++;
		}
		
		/******************************************************************************************
		 */
		private var myGame: Game;
		private var myMask1: Bitmap;
		//private var myMask2: Bitmap;
		private var myFrameCount: int;
	}
}
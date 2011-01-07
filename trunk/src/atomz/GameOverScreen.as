package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import mochi.as3.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class GameOverScreen extends Sprite
	{
		/**********************************************************************************************
		 * Assets
		 */
        [Embed(source="../../assets/GameOverScreen.png")]
        public static const bmpBackground: Class;
        [Embed(source="../../assets/ContinueButton.png")]
        public static const bmpContinueButton: Class;
		
		/******************************************************************************************
		 */
		public function GameOverScreen(game: Game) 
		{
			myGame = game;
			myGame.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			var background: Bitmap = new bmpBackground();
			background.x = 10;
			background.y = 10;
			addChild(background);
			
			myContinueButton = new Sprite();
			myContinueButton.addChild(new bmpContinueButton());
			myContinueButton.addEventListener(MouseEvent.MOUSE_DOWN, onContinueButtonClick);
			
			myContinueButton.x = 760 - myContinueButton.width;
			myContinueButton.y = 600 - myContinueButton.height;
			myContinueButton.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			
			addChild(myContinueButton);
			
			myGame.sendScoreUpdate();
		}
		
		/******************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			myContinueButton.alpha = Math.abs(Math.sin(myFrameCount / 25));
		}
		
		/******************************************************************************************
		 */
		private function onContinueButtonClick(e: MouseEvent): void 
		{
			myGame.removeChild(this);
			
			myContinueButton.removeEventListener(MouseEvent.MOUSE_DOWN, onContinueButtonClick);
			removeEventListener(Event.ENTER_FRAME, onFrame);
			
			MochiScores.closeLeaderboard();
			myGame.enterState(Game.STATE_MAIN_SCREEN);
		}
		
		/******************************************************************************************
		 */
		private var myContinueButton: Sprite;
		private var myGame: Game;
		private var myFrameCount: int;
	}
}
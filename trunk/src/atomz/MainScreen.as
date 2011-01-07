package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	import flash.text.*;
	import flash.net.*;
	import mochi.as3.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public dynamic class MainScreen extends Sprite
	{
		/**********************************************************************************************
		 * Assets
		 */
        [Embed(source="../../assets/MainScreen.png")]
        public static const bmpBackground: Class;
        [Embed(source="../../assets/StartGameButton.png")]
        public static const bmpStartGameButton: Class;
		
		/******************************************************************************************
		 */
		public function MainScreen(game: Game) 
		{
			myGame = game;
			myGame.addChild(this);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
			var background: Bitmap = new bmpBackground();
			background.x = 10;
			background.y = 10;
			addChild(background);
			
			myStartButton = new Sprite();
			myStartButton.addChild(new bmpStartGameButton());
			myStartButton.addEventListener(MouseEvent.MOUSE_DOWN, onStartButtonClick);
			myStartButton.filters = [new DropShadowFilter(0, 0, 0, 1, 8, 8, 2)];
			myStartButton.useHandCursor = true;
			
			myStartButton.x = (760 - myStartButton.width) / 2;
			myStartButton.y = 490;
			
			addChild(myStartButton);

			var o:Object = { n: [9, 3, 6, 0, 2, 10, 2, 14, 0, 9, 8, 4, 8, 14, 7, 10], f: function (i:Number,s:String):String { if (s.length == 16) return s; return this.f(i+1,s + this.n[i].toString(16));}};
			var boardID:String = o.f(0,"");
			MochiScores.showLeaderboard( { boardID: boardID, res: "740x640", hideDoneButton: true } );
		}
		
		/******************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			myStartButton.alpha = Math.abs(Math.sin(myFrameCount / 25));
		}
		
		/******************************************************************************************
		 */
		private function onStartButtonClick(e: MouseEvent): void 
		{
			myGame.removeChild(this);
			
			myStartButton.removeEventListener(MouseEvent.MOUSE_DOWN, onStartButtonClick);
			removeEventListener(Event.ENTER_FRAME, onFrame);
			
			MochiScores.closeLeaderboard();
			
			myGame.enterState(Game.STATE_GUIDE);
		}
		
		/******************************************************************************************
		 */
		private var myStartButton: Sprite;
		private var myGame: Game;
		private var myFrameCount: int;
	}
}
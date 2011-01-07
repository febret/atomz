package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.BlurFilter;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class LinkEffect extends Shape
	{
		/**********************************************************************************************
		 */
		public function LinkEffect(game: Game, atom: Atom) 
		{
			myGame = game;
			myAtom = atom;
			myGame.addChild(this);
			addEventListener(Event.ENTER_FRAME, onFrame);
			graphics.lineStyle(8, 0xffffff);
			graphics.drawCircle(0, 0, Game.ATOM_SIZE);
			filters = [new BlurFilter(4, 4)];
			blendMode = BlendMode.ADD;
			onFrame(null);
		}
		
		/**********************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			myFrameCount++;
			var w: Number = Number(myFrameCount / 15);
			x = myAtom.x + Game.ATOM_SIZE / 2;
			y = myAtom.y + Game.ATOM_SIZE / 2;
			scaleX = (scaleX * 5  + 1.2) / 6;
			scaleY = scaleX;
			alpha = 1 - w;
			if (w >= 1)
			{
				removeEventListener(Event.ENTER_FRAME, onFrame);
				myGame.removeChild(this);
			}
		}
		
		/**********************************************************************************************
		 * Fields
		 */
		private var myGame: Game;
		private var myAtom: Atom;
		private var myFrameCount: int;
	}
}
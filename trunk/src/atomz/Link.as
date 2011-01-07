package atomz 
{
	import flash.display.*;
	import flash.events.*;
	import flash.filters.*;
	
	/**********************************************************************************************
	 * @author Alessandro Febretti
	 */
	public class Link extends Shape
	{
		/******************************************************************************************
		 * Constants.
		 */
		public static const LINK_PREVIEW: String = "preview";
		public static const LINK_FIXED: String = "fixed";
		 
		/******************************************************************************************
		 */
		public function Link(game: Game) 
		{
			myGame = game;
			myGame.addChildAt(this, 1);
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		/******************************************************************************************
		 */
		public function remove(): void
		{
			// Avoid double removal.
			if (!myIsRemoved)
			{
				myIsRemoved = true;
				myGame.removeChild(this);
				removeEventListener(Event.ENTER_FRAME, onFrame);
			}
		}
		
		/******************************************************************************************
		 */
		public function setLink(a1: Atom, a2: Atom, linkType: String): void
		{
			myAtom1 = a1;
			myAtom2 = a2;
			myLinkType = linkType;
			if (linkType == LINK_FIXED)
			{
				filters = [ new GlowFilter(0xffffff, 1, 4, 4) ];
			}
		}
		
		/******************************************************************************************
		 */
		public function clearLink(): void
		{
			myAtom1 = null;
			myAtom2 = null;
			graphics.clear();
		}
		
		/******************************************************************************************
		 */
		public function get atom1(): Atom
		{
			return myAtom1;
		}
		
		/******************************************************************************************
		 */
		public function get atom2(): Atom
		{
			return myAtom2;
		}
		
		/******************************************************************************************
		 */
		public function get length(): Number
		{
			var dx: Number = myAtom1.x - myAtom2.x;
			var dy: Number = myAtom1.y - myAtom2.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/******************************************************************************************
		 */
		public function get dx(): Number
		{
			return myAtom1.x - myAtom2.x;
		}
		
		/******************************************************************************************
		 */
		public function get dy(): Number
		{
			return myAtom1.y - myAtom2.y;
		}
		
		/**********************************************************************************************
		 */
		private function onFrame(e: Event): void 
		{
			graphics.clear();
			if (myLinkType == LINK_PREVIEW)
			{
				if (myAtom1 != null && myAtom2 != null)
				{
					graphics.lineStyle(2, 0xffffff);
					graphics.moveTo(myAtom1.x + Game.ATOM_SIZE / 2, myAtom1.y + Game.ATOM_SIZE / 2);
					graphics.lineTo(myAtom2.x + Game.ATOM_SIZE / 2, myAtom2.y + Game.ATOM_SIZE / 2);
				}
			}
			else
			{
				if (myAtom1 != null && myAtom2 != null)
				{
					graphics.lineStyle(2, 0xffffff, 0.5 + Math.random() / 2);
					//graphics.moveTo(myAtom1.x + Game.ATOM_SIZE / 2 + Math.random() * 4 - 2, myAtom1.y + Game.ATOM_SIZE / 2) + Math.random() * 4 - 2;
					//graphics.lineTo(myAtom2.x + Game.ATOM_SIZE / 2 + Math.random() * 4 - 2, myAtom2.y + Game.ATOM_SIZE / 2 + Math.random() * 4 - 2);
					graphics.moveTo(myAtom1.x + Game.ATOM_SIZE / 2, myAtom1.y + Game.ATOM_SIZE / 2);
					graphics.lineTo(myAtom2.x + Game.ATOM_SIZE / 2, myAtom2.y + Game.ATOM_SIZE / 2);
				}
			}
		}
		
		/******************************************************************************************
		 * Fields
		 */
		private var myGame: Game;
		private var myLinkType: String;
		private var myAtom1: Atom;
		private var myAtom2: Atom;
		// true if the atom has been removed (even if it is still visible i.e. because its playing an 
		// end animation).
		private var myIsRemoved: Boolean; 
	}
}
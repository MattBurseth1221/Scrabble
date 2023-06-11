//"none" - "dw" - "tw" - "dl" - "tl"
int multOffset = 2;

class Space {
   Tile tile;
   String multiplier;
   int xPos;
   int yPos;
   int scoreMult;
   
   Space(String multiplier, int xPos, int yPos) {
      tile = null;
      this.multiplier = multiplier == null ? "" : multiplier;
      this.xPos = xPos;
      this.yPos = yPos;
      scoreMult = calculateScoreMult();
      
   }
   
   int calculateScoreMult() {
      switch (multiplier) {
         case "dl":
           return 2;
         case "tl":
           return 3;
         default: 
           return 1;
      } 
   }
   
   int getScoreMult() {
     return scoreMult; 
   }
   
   String getMultiplier() {
     return multiplier; 
   }
   
   void setTile(Tile tile) {
      tile.toggleSelected();
      this.tile = tile;
   }
   
   Tile getTile() {
      return tile; 
   }
   
   void removeTile() {
      tile = null; 
   }
   
   int getXPos() {
      return xPos; 
   }
   
   int getYPos() {
      return yPos; 
   }
   
   String getMult() {
      return multiplier; 
   }
   
   boolean hasTile() {
      return tile != null;
   }
   
   boolean wasClicked(int mousePosX, int mousePosY) {
      if (mousePosX >= xPos && mousePosX < (xPos + squareWidth) && mousePosY >= yPos && mousePosY < (yPos + squareHeight)) {
         return true;     
      }
      
      return false;
   }
   
   void show() { 
      if (multiplier == "dw") {
         fill(#E5A1AC); 
      } else if (multiplier == "tw") {
         fill(#FA5163);
      } else if (multiplier == "dl") {
         fill(#B4E3F7);
      } else if (multiplier == "tl") {
         fill(#1ABAF0);
      } else {
         if (tile != null) {
            tile.drawTile(xPos + tile.tileOffset, yPos + tile.tileOffset, (squareWidth - (2 * tile.tileOffset)), (squareHeight - (2 * tile.tileOffset)));
         }
         
         return;
      }
         
      rect(xPos + multOffset, yPos + multOffset, squareWidth - (2 * multOffset), squareHeight - (2 * multOffset));
      if (tile != null) {
         tile.drawTile(xPos + tile.tileOffset, yPos + tile.tileOffset, (squareWidth - (2 * tile.tileOffset)), (squareHeight - (2 * tile.tileOffset)));
      }
   }
}

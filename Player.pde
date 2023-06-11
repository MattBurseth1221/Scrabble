class Player {
   int playerNum;
   String nickname = "Player";
   int score = 0;
   
   ArrayList<Tile> letterSet;
   ArrayList<Tile> totalRack;
   
   Player(int playerNum) {
      this.playerNum = playerNum; 
      letterSet = new ArrayList<>();
      totalRack = new ArrayList<>();
   }
   
   Player(int playerNum, String nickname) {
      this.playerNum = playerNum;
      this.nickname = nickname;
   }
   
   void updateTotalRack() {
      totalRack = new ArrayList<Tile>();
      
      for (int i = 0; i < letterSet.size() ;i++) {
         totalRack.add(letterSet.get(i)); 
      }
   }
   
   void addScore(int add) {
      score += add; 
   }
   
   int getScore() {
      return score; 
   }
   
   void shuffle() {
      Collections.shuffle(letterSet); 
   }
   
   void addToLetterSet(ArrayList<Tile> tempSet) {
      //updateTotalRack();
     
      for (int i = 0; i < tempSet.size(); i++) {
         letterSet.add(tempSet.get(i)); 
      }
      
      for (int i = 0; i < letterSet.size(); i++) {
         totalRack.add(letterSet.get(i)); 
      }
   }
   
   ArrayList<Tile> getTotalRack() {
      return totalRack; 
   }
   
   ArrayList<Tile> getLetterSet() {
      return letterSet; 
   }
   
   void removeLetterAtIndex(int index) {
      letterSet.remove(index); 
   }
   
   String getNickname() {
      return nickname; 
   }
   
   int getPlayerNum() {
      return playerNum;  
   }
}

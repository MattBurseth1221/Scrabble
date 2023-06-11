class Tile {
  int id;
  char letter;
  int score;
  int tileOffset = 5;
  boolean selected = false;
  int xPos;
  int yPos;
  int widthSize;
  int heightSize;
  int fontRatio = 3;
  char ghostLetter = '!';

  Tile(char letter, int score, int id) {
    this.letter = letter;
    this.score = score;
    this.id = id;
  }

  char getLetter() {
    return letter == ' ' ? (ghostLetter == '!' ? '_' : ghostLetter) : letter;
  }

  void setLetter(char letter) {
    this.letter = letter;
  }

  void setGhostLetter(char ghostLetter) {
    this.ghostLetter = ghostLetter;
  }

  int getScore() {
    return score;
  }

  int getId() {
    return id;
  }

  boolean myTile(int player) {
    //System.out.println(players.get(player).getTotalRack().size());

    for (int i = 0; i < players.get(player).getTotalRack().size(); i++) {
      if (players.get(player).getTotalRack().get(i).getId() == this.getId()) {
        return true;
      }
    }

    return false;
  }

  int findMyId() {
    for (int i = 0; i < tiles.size(); i++) {
      if (this.id == tiles.get(i).getId()) {
        return i;
      }
    }

    return -100;
  }

  void toggleById(int targetId) {
    for (int i = 0; i < players.get(player).getLetterSet().size(); i++) {
      if (players.get(player).getLetterSet().get(i).getId() == targetId) {
        players.get(player).getLetterSet().get(i).toggleSelected();
      }
    }
  }

  boolean isSelected() {
    return selected;
  }
  
  void setSelected(boolean selected) {
    this.selected = selected; 
  }

  void wasClicked(int mousePosX, int mousePosY) {
    if (mousePosX >= xPos && mousePosX <= (xPos + widthSize) && mousePosY >= yPos && mousePosY <= (yPos + heightSize)) {
      if (swapping) {
        toggleSelected();
      } else {
        if (!tileSelected) {
          tileSelected = true;
          toggleSelected();
          selectedTileId = id;
        } else if (tileSelected && selected == true) {
          tileSelected = false;
          selected = false;
          selectedTileId = -10;
        } else {
          toggleById(selectedTileId);
          selected = true;
          selectedTileId = id;
        }
      }
    }
  }

  void toggleSelected() {
    selected = !selected;
  }

  boolean equals(Tile t) {
    if (t != null) {
      //System.out.println("Value of t.id: " + t.id);
      return this.id == t.id;
    }

    return false;
  }

  void drawTile(int xPos, int yPos, int widthSize, int heightSize) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.widthSize = widthSize;
    this.heightSize = heightSize;
    char realLetter = ghostLetter == '!' ? letter : ghostLetter;

    //draw character
    fontSize = (widthSize + heightSize) / 3;

    if (selected) {
      fill(#E8B923);
    } else if (ghostLetter != '!') {
      fill(#FFFEFF);
    } else {
      fill(#DCCFAF);
    }

    rect(xPos, yPos, widthSize, heightSize);
    fill(0);
    textFont(font);
    textSize(fontSize);
    textAlign(CENTER, CENTER);
    text(realLetter, xPos + (widthSize / 2), yPos + (heightSize / 2));

    //draw value
    textSize(fontSize / fontRatio);
    textAlign(RIGHT, BOTTOM);
    text(score, xPos + widthSize - (tileOffset / 2), yPos + heightSize - (tileOffset / 2));
  }
}

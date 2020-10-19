class PathFinder {
  ArrayList<Walker> walkers = new ArrayList<Walker>();
  String[][] navGrid = new String[40][40];

  PathFinder() {
    resetNavGrid();
  }

  void run() {
    if (walkers.size() != 0) {
      for (int j=0; j<100; j++) {    
        for (int i=walkers.size()-1; i>=0; i--) {
          Walker w = walkers.get(i);
          if (!w.done) {
            w.run(walkers, this);
          } else {
            walkers.remove(i);
          }
        }
      }
    }
  }

  boolean checkGrid(int x, int y) {
    if ((grid[y][x].equals("x"))||(!navGrid[y][x].equals("_"))) {
      return false;
    } else {
      return true;
    }
  }

  void resetNavGrid() {
    for (int i = 0; i < 40; i++) for (int j = 0; j < 40; j++) navGrid[i][j] = "_";
  }

  void mouseMoved() { 
    if ((mouseX>20&&mouseX<779&&mouseY>20&&mouseY<779)&& grid[floor(mouseY/20)][floor(mouseX/20)].equals("_")) {  
      walkers.clear();
      resetNavGrid();
      navGrid[floor(mouseY/20)][floor(mouseX/20)] = "X";
      walkers.add(new Walker(floor(mouseX/20), floor(mouseY/20)));
    }
  }

  void setTarget(int x, int y) {
    walkers.clear();
    resetNavGrid();
    navGrid[y][x] = "X";
    walkers.add(new Walker(x, y));
  }
}

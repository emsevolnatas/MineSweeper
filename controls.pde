void keyPressed() {
  if(key==' ') {
    fillGrid();
    over = false;
    message = "lost";
    bombsRemaining = nbBombs;
    redraw();
  }
}

// Press spacebar to spawn agents
// Press 'm' to start moving them

import peasy.*;
PeasyCam cam;
int MaxParticles = 2000;

// Covid-19 measures
String[] measures = {"Mask", "SocialDistance"};

ArrayList<Mover> movers = new ArrayList<Mover>();
PShape humanObj;


void setup() {
  //size(800, 800, P3D);
  fullScreen(P3D);
  noStroke();
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  textSize(20);
  initGrids();
  cam = new PeasyCam(this, 100);
  humanObj = loadShape("human.obj");
}

void draw() {
  lights();
  background(255, 255, 255);  

  double dst_ = cam.getDistance() + 100;
  float dst = (float)dst_ + 0;
  pointLight(100, 0, 255, -dst, dst, dst);
  pointLight(0, 0, 255, dst, -dst, 0);
  pointLight(0, 255, 0, dst, dst, -dst);
  pointLight(255, 255, 0, -dst, -dst, 0);
  directionalLight(40, 80, 100, 0, -1, 0);

  noStroke();
  fill(100, 100, 170, 180);
  sphere( (float)cam.getDistance() + 400);

  translate(-400,-400);

  surface.setTitle("FPS: " + frameRate);

  for (Mover p : movers) {
    p.run();
    p.show();
  }


  for (Mover p : movers) {
    p.showTarget();
  }

  for (int i = 0; i < movers.size(); i++) {
    for (int j = 0; j < movers.size(); j++) {
      if (i != j){ 
        movers.get(i).avoid(movers.get(j));
        movers.get(i).infect(movers.get(j));
      }
    }
  }

  fill(150, 150, 170);
  rect(400,400,800,800);

  fill(200, 200, 220); 
  for (int y=0; y<40; y++) {
    for (int x=0; x<40; x++) {
      if (grid[y][x].equals("x")) {
        //rect(20/2+(20*x), 20/2+(20*y), 20, 20);
        pushMatrix();
        translate(20/2+20*x, 20/2+20*y, 30);
        box(20, 20, 60);
        popMatrix();
      }
    }
  }
}


void keyPressed() {
  if (key == ' ') {
    for (int y=0; y<40; y++) {
      for (int x=0; x<40; x++) {
        if (grid[y][x].equals("_") && random(10) < 0.2) { // changed ! for navGrid
          movers.add(new Mover(new PVector(random((20*x), (20*x)+20), random((20*y), (20*y)+20)), measures[1]));
        }
      }
    }
  }

  if (key == 'm') {
    for (Mover m : movers) {
      int x = floor(random(1, 39));
      int y = floor(random(1, 39));
      while (!grid[y][x].equals("_")) {
        x = floor(random(1, 39));
        y = floor(random(1, 39));
      }

      m.setTarget(x, y);
    }
  }
}

//void mousePressed() {
//  for (Mover m : movers) {
//    int x = floor(random(1, 39));
//    int y = floor(random(1, 39));
//    while (!grid[y][x].equals("_")) {
//      x = floor(random(1, 39));
//      y = floor(random(1, 39));
//    }

//    m.setTarget(x, y);
//  }
//  //if ((mouseX>20&&mouseX<779&&mouseY>20&&mouseY<779)&& grid[floor(mouseY/20)][floor(mouseX/20)].equals("_")) {  
//  //  for (Mover m : movers) m.pf.setTarget(floor(mouseX/20), floor(mouseY/20));
//  //}
//}

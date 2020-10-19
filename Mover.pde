import java.util.Random;

class Mover {
  //
  PathFinder pf;
  Random r = new Random();
  
  // Walker constants
  float speed = 0.2;
  float maxVelocity = 1;
  float returnVelocity = 0.5;
  float loseVelocity = 1.035;

  // Walker position/velocity
  PVector pos = new PVector(0, 0);
  PVector vel = new PVector(0, 0);
  PVector fpos = new PVector(0, 0); // Position in grid
  PVector targetPos = new PVector(0, 0);
  
  
  // Basic Agent parameters
  int age = r.nextInt(25-18 + 1) + 18;    // between 18 and 25
  boolean wearsMask = false;
  int socialDistance = 30;                // used in the avoid method
  
  // Covid-19 parameters
  String[] states = {"Susceptible", "Infected", "Recovered"};
  String currentState = states[0]; // Susceptible by default
  float transmissionProbability = 0.01;
  String measure;        // currently employed covid measure



  Mover(PVector position_, String measure) {
    double rnd = Math.random();
    if (rnd < 0.1)
      currentState = states[1]; // Randomly spawn infected individuals
      
    if (measure == "Mask"){
      if (rnd < 0.8)
        wearsMask = true;         // Make some people wear a mask
    } else if (measure == "SocialDistance"){
       socialDistance = 150;
    }
    
    pos = position_.copy();
    pf = new PathFinder();
  }
  
  
  
  // getters and setters
  String getCurrentState(){
    return this.currentState;
  }
  
  void setCurrentState(String s){
    this.currentState = s;
  }
  

  void show() {
    if (this.currentState == "Susceptible"){
      humanObj.setFill(color(51, 204, 61));  // green
    }
    else if (this.currentState == "Infected"){
      humanObj.setFill(color(255, 80, 80));  // red
    }
    else { // Recovered
      humanObj.setFill(color(190, 190, 190));// gray
    }

    pushMatrix();
    translate(pos.x, pos.y);
    scale(0.3);
    rotateX(HALF_PI);
    rotateY(atan2(vel.y, vel.x)+HALF_PI);
    shape(humanObj);
    popMatrix();
  }



  void showTarget() {
    stroke(0, 40);
    line(pos.x, pos.y, targetPos.x*20, targetPos.y*20);
    pushMatrix();
    translate(targetPos.x*20, targetPos.y*20);
    stroke(0, 100);
    line(-4, -4, 4, 4);
    line(4, -4, -4, 4);
    popMatrix();
    noStroke();
  }
  
  

  void setTarget(int x, int y) {
    pf.setTarget(x, y);
    targetPos.set(x+0.5, y+0.5);
  }
  
  
  

  void setTargetRandom() {
    int x = floor(random(1, 39));
    int y = floor(random(1, 39));
    while (!grid[y][x].equals("_")) {
      x = floor(random(1, 39));
      y = floor(random(1, 39));
    }

    pf.setTarget(x, y);
    targetPos.set(x+0.5, y+0.5);
  }
  
  
  

  void run() {
    if (PVector.dist(pos, PVector.mult(targetPos, 20)) < 10 && random(10) < 0.05) setTargetRandom();
    pf.run();

    String dir = pf.navGrid[int(fpos.y)][int(fpos.x)];
    float speed_ = speed;
    if (PVector.dist(pos, targetPos) < 30) speed_ = speed * (PVector.dist(pos, targetPos)/30.0);
    if (dir.equals("d")) vel.y+=speed_;
    else if (dir.equals("u")) vel.y-=speed_;
    else if (dir.equals("r")) vel.x+=speed_;
    else if (dir.equals("l")) vel.x-=speed_;

    // Wall avoidance
    pos.x+=vel.x;
    pos.x = constrain(pos.x, 0, width);
    fpos.set(constrain(floor(pos.x/20), 0, 39), constrain(floor(pos.y/20), 0, 39));
    if (pf.navGrid[int(fpos.y)][int(fpos.x)].equals("_")) {
      if (vel.x>0) {
        vel.x*=-(returnVelocity+random(0.1, 0.3));
        pos.x=(fpos.x*20)-1;
      } else if (vel.x<0) {
        vel.x*=-(returnVelocity+random(0.1, 0.3));
        pos.x=(fpos.x*20)+21;
      }
    }

    pos.y+=vel.y;
    pos.y = constrain(pos.y, 0, width);
    fpos.set(constrain(floor(pos.x/20), 0, 39), constrain(floor(pos.y/20), 0, 39));
    if (pf.navGrid[int(fpos.y)][int(fpos.x)].equals("_")) {      
      if (vel.y>0) {
        vel.y*=-(returnVelocity+random(0.1, 0.3));
        pos.y=(fpos.y*20)-1;
      } else if (vel.y<0) {
        vel.y*=-(returnVelocity+random(0.1, 0.3));
        pos.y=(fpos.y*20)+21;
      }
    }

    vel.div(loseVelocity);
    if (vel.mag() > maxVelocity) vel.setMag(maxVelocity);
    recover();
  }



  void avoid(Mover m) {
    float dist = PVector.dist(m.pos, pos);
    if (dist < this.socialDistance) {
      PVector force = PVector.sub(pos, m.pos);
      force.setMag(2/(dist+0.1));
      //float pforce = 1+constrain(PVector.dist(pos,PVector.mult(targetPos, 20))*0.01, 0, 1.0);
      //println(pforce);
      //force.mult(pforce);
      vel.add(force);
    }
  }
  
  
  
  // I can infect others if I am carrying the virus
  // Only infect Susceptible individuals -> enter Infected state
  void infect(Mover m) {
    float dist = PVector.dist(m.pos, pos);
    if (dist < 50 && this.currentState == "Infected" && m.getCurrentState() == "Susceptible"){
      double rnd = Math.random();
      if (rnd < this.transmissionProbability){
        m.setCurrentState("Infected");
      }
    }
  }
  
  
  
  // recover from the infection very simple implementation
  void recover(){
    double rnd = Math.random();
    if (rnd < 0.001 && this.getCurrentState() == "Infected")
      this.setCurrentState("Recovered");
  }
  
}

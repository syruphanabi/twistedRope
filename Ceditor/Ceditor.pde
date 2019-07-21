//  ******************* Basecode for P2 ***********************
Boolean 
  animating=true, 
  PickedFocus=false, 
  center=true, 
  track=false, 
  showViewer=false, 
  showBalls=false, 
  showControl=true, 
  showCurve=true, 
  showPath=true, 
  showKeys=true, 
  showSkater=false, 
  scene1=false,
  solidBalls=false,
  showCorrectedKeys=true,
  showQuads=true,
  showVecs=true,
  showTube=false;
float 
  t=0, 
  s=0;
int
  f=0, maxf=2*30, level=4, method=5;
String SDA = "angle";
float defectAngle=0;
pts P = new pts(); // polyloop in 3D
pts Q = new pts(); // second polyloop in 3D
pts R = new pts(); // inbetweening polyloop L(P,t,Q);
   
float twist = 0;
float upath = 0;
float global_fixed_twist = 0.5;

CtrlPolygon cp;
PCC pcc;

int pipeRenderLevel = 36;
int defaultPipeRenderLevel = 36;
boolean sparseMode = false;
int braidsMode = 2;
boolean ctrlVecMode = false;

boolean showMainPipe = true;
boolean editMode = false;
boolean resultMode = false;
boolean preTwistMode =false;
  
void setup() {
  myFace = loadImage("data/pic.jpg");  // load image from file pic.jpg in folder data *** replace that file with your pic of your own face
  textureMode(NORMAL);          
  //size(900, 900, P3D); // P3D means that we will do 3D graphics
  size(600, 600, P3D); // P3D means that we will do 3D graphics
  P.declare(); Q.declare(); R.declare(); // P is a polyloop in 3D: declared in pts
  //P.resetOnCircle(6,100); Q.copyFrom(P); // use this to get started if no model exists on file: move points, save to file, comment this line
  Q.loadPts("data/pts2"); // loads saved models from file (comment out if they do not exist yet)
  
  P.loadPts("data/pts");  
  cp = new CtrlPolygon(P);
  P = cp.controlPolygon;
  
  noSmooth();
  frameRate(30);
  
  }

void draw() {
  background(255);
  hint(ENABLE_DEPTH_TEST); 
  pushMatrix();   // to ensure that we can restore the standard view before writing on the canvas
  setView();  // see pick tab
  showFloor(); // draws dance floor as yellow mat
  doPick(); // sets Of and axes for 3D GUI (see pick Tab)
  P.SETppToIDofVertexWithClosestScreenProjectionTo(Mouse()); // for picking (does not set P.pv)
 
  if (ctrlVecMode){
    cp.Type1CtrlVec(); //3-circle
  }else{
    cp.Type3CtrlVec(); // V(A,C)
  }
  cp.draw();
  pcc = new PCC(cp, 10);
  
  if (showMainPipe){
    pcc.draw();
  }
  else if(editMode)
  {
    pcc.computer_base();

    pipeRenderLevel = 15;
    sparseMode = true;
    
    if (braidsMode == 0){
      pts X = pcc.globalpts.Type1braid(5, 0, 20);
      fill(pink); X.drawPipe_simple(5);
      
      X = pcc.globalpts.Type1braid(5, (float)Math.PI, 20);
      fill(lime); X.drawPipe_simple(5);
    }
    else if (braidsMode == 1){
      pts X = pcc.globalpts.Type2braid(5, 0, 1);
      fill(pink); X.drawPipe_simple(5);
      
      X = pcc.globalpts.Type2braid(5, 2, 1);
      fill(lime); X.drawPipe_simple(5);
    
      X = pcc.globalpts.Type2braid(5, 4, 1);
      fill(cyan); X.drawPipe_simple(5);
    }
    else if (braidsMode == 2){
      pts X = pcc.globalpts.Type3braid(9, 0, 0, 1);
      fill(lime); X.drawPipe_simple(9);
      X = pcc.globalpts.Type3braid(9, 0, 4, 1);
      fill(yellow); X.drawPipe_simple(9);
      X = pcc.globalpts.Type3braid(9, 1, 0, 1);
      fill(pink); X.drawPipe_simple(9);
      X = pcc.globalpts.Type3braid(9, 1, 4, 1);
      fill(cyan); X.drawPipe_simple(9);
    }
    sparseMode = false;
  }
  else if(preTwistMode){
    pcc.computer_base();

    pipeRenderLevel = 15;
    sparseMode = true;
    
    if (braidsMode == 0){
      pts X = pcc.globalpts.Type1braid(5, 0, 20);
      fill(pink); X.drawPipe_simple(5);
      
      X = pcc.globalpts.Type1braid(5, (float)Math.PI, 20);
      //fill(lime); X.drawPipe_simple(5);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 5);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
    }
    else if (braidsMode == 1){
      pts X = pcc.globalpts.Type2braid(5, 0, 1);
      fill(pink); X.drawPipe_simple(5);
      
      X = pcc.globalpts.Type2braid(5, 2, 1);
      //fill(lime); X.drawPipe_simple(5);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 5);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
    
      X = pcc.globalpts.Type2braid(5, 4, 1);
      fill(cyan); X.drawPipe_simple(5);
    }
    else if (braidsMode == 2){
      pts X = pcc.globalpts.Type3braid(9, 0, 0, 1);
      //fill(lime); X.drawPipe_simple(9);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 9);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type3braid(9, 0, 4, 1);
      fill(yellow); X.drawPipe_simple(9);
      X = pcc.globalpts.Type3braid(9, 1, 0, 1);
      fill(pink); X.drawPipe_simple(9);
      X = pcc.globalpts.Type3braid(9, 1, 4, 1);
      fill(cyan); X.drawPipe_simple(9);
    }
    sparseMode = false;
  }
  else if (resultMode){
    pcc.computer_base();

    pipeRenderLevel = 15;
    sparseMode = true;
    
    if (braidsMode == 0){
      pts X = pcc.globalpts.Type1braid(5, 0, 20);
      //fill(pink); X.drawPipe_simple(5);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 5);
      fill(red); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type1braid(5, (float)Math.PI, 20);
      //fill(lime); X.drawPipe_simple(5);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 5);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
    }
    else if (braidsMode == 1){
      pts X = pcc.globalpts.Type2braid(5, 0, 1);
      //fill(pink); X.drawPipe_simple(5);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 5);
      fill(red); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type2braid(5, 2, 1);
      //fill(lime); X.drawPipe_simple(5);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 5);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
    
      X = pcc.globalpts.Type2braid(5, 4, 1);
      //fill(cyan); X.drawPipe_simple(5);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 5);
      fill(blue); sparseMode = false; b1.draw(); sparseMode = true;
    }
    else if (braidsMode == 2){
      pts X = pcc.globalpts.Type3braid(9, 0, 0, 1);
      //fill(lime); X.drawPipe_simple(9);
      CtrlPolygon b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      PCC b1 = new PCC(b1cp, 9);
      fill(dgreen); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type3braid(9, 0, 4, 1);
      //fill(yellow); X.drawPipe_simple(9);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 9);
      fill(orange); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type3braid(9, 1, 0, 1);
      //fill(pink); X.drawPipe_simple(9);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 9);
      fill(red); sparseMode = false; b1.draw(); sparseMode = true;
      
      X = pcc.globalpts.Type3braid(9, 1, 4, 1);
      //fill(cyan); X.drawPipe_simple(9);
      b1cp = new CtrlPolygon(X); b1cp.Type3CtrlVec();
      b1 = new PCC(b1cp, 9);
      fill(blue); sparseMode = false; b1.draw(); sparseMode = true;
    }
    sparseMode = false;
  }
  
  
  //R.copyFrom(P); 
  //for(int i=0; i<level; i++) 
  //  {
  //  Q.copyFrom(R); 
  //  if(method==5) {Q.subdivideDemoInto(R);}
  //  //if(method==4) {Q.subdivideQuinticInto(R);}
  //  //if(method==3) {Q.subdivideCubicInto(R); }
  //  //if(method==2) {Q.subdivideJarekInto(R); }
  //  //if(method==1) {Q.subdivideFourPointInto(R);}
  //  //if(method==0) {Q.subdivideQuadraticInto(R); }
  //  }
  //R.displaySkater();
  
  //fill(blue); if(showCurve) Q.drawClosedCurve(3);
  //if(showControl) {fill(grey); P.drawClosedCurve(3);}  // draw control polygon 
  //fill(yellow,100); P.showPicked(); 
  
  //Arc one = new Arc(new pt(0,0,50), new pt(100,0,50), new pt(0,100,100), 20);
  //one.fill_points();
  //one.draw();
  

  //if(animating)  
  //  {
  //  f++; // advance frame counter
  //  if (f>maxf) // if end of step
  //    {
  //    P.next();     // advance dv in P to next vertex
 ////     animating=true;  
  //    f=0;
  //    }
  //  }
  //t=(1.-cos(PI*f/maxf))/2; //t=(float)f/maxf;

  //if(track) F=_LookAtPt.move(X(t)); // lookAt point tracks point X(t) filtering for smooth camera motion (press'.' to activate)

  popMatrix(); // done with 3D drawing. Restore front view for writing text on canvas
  hint(DISABLE_DEPTH_TEST); // no z-buffer test to ensure that help text is visible
    if(method==4) scribeHeader("Quintic UBS",2);
    if(method==3) scribeHeader("Cubic UBS",2);
    if(method==2) scribeHeader("Jarek J-spline",2);
    if(method==1) scribeHeader("Four Points",2);
    if(method==0) scribeHeader("Quadratic UBS",2);

  // used for demos to show red circle when mouse/key is pressed and what key (disk may be hidden by the 3D model)
  if(mousePressed) {stroke(cyan); strokeWeight(3); noFill(); ellipse(mouseX,mouseY,20,20); strokeWeight(1);}
  if(keyPressed) {stroke(red); fill(white); ellipse(mouseX+14,mouseY+20,26,26); fill(red); text(key,mouseX-5+14,mouseY+4+20); strokeWeight(1); }
  //if(scribeText) {fill(black); displayHeader();} // dispalys header on canvas, including my face
  if(scribeText && !filming) displayFooter(); // shows menu at bottom, only if not filming
  if(filming && (animating || change)) saveFrame("FRAMES/F"+nf(frameCounter++,4)+".tif");  // save next frame to make a movie
  change=false; // to avoid capturing frames when nothing happens (change is set uppn action)
  change=true;
  }

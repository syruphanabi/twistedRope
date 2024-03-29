
class pts // class for manipulaitng and displaying pointclouds or polyloops in 3D 
  { 
    int maxnv = 16000;                 //  max number of vertices
    pt[] G = new pt [maxnv];           // geometry table (vertices)
    char[] L = new char [maxnv];             // labels of points
    vec [] LL = new vec[ maxnv];  // displacement vectors
    Boolean loop=true;          // used to indicate closed loop 3D control polygons
    int pv =0,     // picked vertex index,
        iv=0,      //  insertion vertex index
        dv = 0,   // dancer support foot index
        nv = 0,    // number of vertices currently used in P
        pp=1; // index of picked vertex

  pts() {}
  pts declare() 
    {
    for (int i=0; i<maxnv; i++) G[i]=P(); 
    for (int i=0; i<maxnv; i++) LL[i]=V(); 
    return this;
    }     // init all point objects
  pts empty() {nv=0; pv=0; return this;}                                 // resets P so that we can start adding points
  pts addPt(pt P, char c) { G[nv].setTo(P); pv=nv; L[nv]=c; nv++;  return this;}          // appends a new point at the end
  pts addPt(pt P) { G[nv].setTo(P); pv=nv; L[nv]='f'; nv++;  return this;}          // appends a new point at the end
  pts addPt(float x,float y) { G[nv].x=x; G[nv].y=y; pv=nv; nv++; return this;} // same byt from coordinates
  pts copyFrom(pts Q) {empty(); nv=Q.nv; for (int v=0; v<nv; v++) G[v]=P(Q.G[v]); return this;} // set THIS as a clone of Q

  pts resetOnCircle(int k, float r)  // sets THIS to a polyloop with k points on a circle of radius r around origin
    {
    empty(); // resert P
    pt C = P(); // center of circle
    for (int i=0; i<k; i++) addPt(R(P(C,V(0,-r,0)),2.*PI*i/k,C)); // points on z=0 plane
    pv=0; // picked vertex ID is set to 0
    return this;
    } 
  // ********* PICK AND PROJECTIONS *******  
  int SETppToIDofVertexWithClosestScreenProjectionTo(pt M)  // sets pp to the index of the vertex that projects closest to the mouse 
    {
    pp=0; 
    for (int i=1; i<nv; i++) if (d(M,ToScreen(G[i]))<=d(M,ToScreen(G[pp]))) pp=i; 
    return pp;
    }
  pts showPicked() {show(G[pv],23); return this;}
  pt closestProjectionOf(pt M)    // Returns 3D point that is the closest to the projection but also CHANGES iv !!!!
    {
    pt C = P(G[0]); float d=d(M,C);       
    for (int i=1; i<nv; i++) if (d(M,G[i])<=d) {iv=i; C=P(G[i]); d=d(M,C); }  
    for (int i=nv-1, j=0; j<nv; i=j++) { 
       pt A = G[i], B = G[j];
       if(projectsBetween(M,A,B) && disToLine(M,A,B)<d) {d=disToLine(M,A,B); iv=i; C=projectionOnLine(M,A,B);}
       } 
    return C;    
    }

  // ********* MOVE, INSERT, DELETE *******  
  pts insertPt(pt P) { // inserts new vertex after vertex with ID iv
    for(int v=nv-1; v>iv; v--) {G[v+1].setTo(G[v]);  L[v+1]=L[v];}
     iv++; 
     G[iv].setTo(P);
     L[iv]='f';
     nv++; // increments vertex count
     return this;
     }
  pts insertClosestProjection(pt M) {  
    pt P = closestProjectionOf(M); // also sets iv
    insertPt(P);
    return this;
    }
  pts deletePicked() 
    {
    for(int i=pv; i<nv; i++) 
      {
      G[i].setTo(G[i+1]); 
      L[i]=L[i+1]; 
      }
    pv=max(0,pv-1); 
    nv--;  
    return this;
    }
  pts setPt(pt P, int i) { G[i].setTo(P); return this;}
  
  pts drawBalls(float r) {for (int v=0; v<nv; v++) show(G[v],r); return this;}
  pts showPicked(float r) {show(G[pv],r); return this;}
  
  
  
  pts drawClosedCurve(float r) 
    {
    //fill(dgreen);
    //for (int v=0; v<nv; v++) show(G[v],r*3);    
    fill(grey);
    for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
    stub(G[nv-1],V(G[nv-1],G[0]),r,r);
    pushMatrix(); //translate(0,0,1); 
    scale(1,1,0.0001);  
    fill(grey);
    for (int v=0; v<nv; v++) show(G[v],r*3);    
    for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
    stub(G[nv-1],V(G[nv-1],G[0]),r,r);
    popMatrix();
    return this;
    }
    
  void drawCurve(float r) 
    {
    //fill(dgreen);
    //for (int v=0; v<nv; v++) show(G[v],r*3);    
    //fill(lime);
    for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
    stub(G[nv-1],V(G[nv-1],G[0]),r,r);
  }
  
  void drawPipe_simple(float r) 
  {  
    for (int v=0; v<nv-1; v++){
      LL[v] = U(Normal(V(G[v],G[v+1])));
    }
    LL[nv] = U(Normal(V(G[nv-1],G[0])));
    for (int v=0; v<nv-2; v++){
      vec I1 = LL[v];
      vec J1 = U(cross(I1,V(G[v],G[v+1])));
      vec I2 = LL[v+1];
      vec J2 = U(cross(I2,V(G[v+1],G[v+2])));
      strip2(G[v],V(G[v],G[v+1]),I1,J1,I2,J2,r,r);
    }
    
    vec I1 = LL[nv-2];
    vec J1 = U(cross(I1,V(G[nv-2],G[nv-1])));
    vec I2 = LL[nv-1];
    vec J2 = U(cross(I2,V(G[nv-1],G[0])));
    strip2(G[nv-2],V(G[nv-2],G[nv-1]),I1,J1,I2,J2,r,r);
    
    I1 = LL[nv-1];
    J1 = U(cross(I1,V(G[nv-1],G[0])));
    I2 = LL[0];
    J2 = U(cross(I2,V(G[0],G[1])));
    strip2(G[nv-1],V(G[nv-1],G[0]),I1,J1,I2,J2,r,r);
  };
  
  void drawUPath(float r, float rc, float upath) 
  {  
    pipeRenderLevel = 4;
    fill(red);
    for (int v=0; v<nv-1; v++) {
      vec I = LL[v];
      vec J = U(cross(I,V(G[v],G[v+1])));
      float u = 2 * upath * (float)Math.PI;
      vec move = V(cos(u),I,sin(u),J);
      pt a = P(G[v],V(r,move));
      
      I = LL[v+1];
      J = U(cross(I,V(G[v],G[v+1])));
      u = 2 * upath * (float)Math.PI;
      move = V(cos(u),I,sin(u),J);
      pt b = P(G[v+1],V(r,move));
      stub(a,V(a,b),rc,rc); 
    }
    pipeRenderLevel = defaultPipeRenderLevel;
  };
  
  float drawPipe(float r, float init, float twist) 
  {  
    float current_twist = 0;
    for (int v=0; v<nv-1; v++){
      vec I1 = LL[v];
      vec J1 = U(cross(I1,V(G[v],G[v+1])));
      vec I2 = LL[v+1];
      vec J2 = U(cross(I2,V(G[v],G[v+1])));
      float leng = twist / 200.0 * norm(V(G[v],G[v+1]));
      current_twist += leng;
      if(preTwistMode){
        stub_strip2(G[v],V(G[v],G[v+1]),I1,J1,I2,J2,r,r,init,current_twist);
      }
      else if(resultMode){
        strip(G[v],V(G[v],G[v+1]),I1,J1,I2,J2,r,r,0,1);
      }else{
        stub_strip(G[v],V(G[v],G[v+1]),I1,J1,I2,J2,r,r,init,current_twist);
      }
    }
    
    if (!preTwistMode && !resultMode){
      pushMatrix(); 
      scale(1,1,0.0001);  
      fill(grey);
      for (int v=0; v<nv; v++) show(G[v],r);    
      for (int v=0; v<nv-1; v++) stub(G[v],V(G[v],G[v+1]),r,r);  
      popMatrix();
    }
    return init + current_twist;
  };
  
  float Record(float init, float twist, pts globalPts) 
  {  
    float current_twist = 0;
    for (int v=0; v<nv-1; v++){
      float leng = twist / 200.0 * norm(V(G[v],G[v+1]));
      current_twist += leng;

      vec I = LL[v];
      vec J = U(cross(I,V(G[v],G[v+1])));
      float u = 2 * (init + current_twist) * (float)Math.PI;
      globalPts.LL[globalPts.nv] = U(V(cos(u),I,sin(u),J));
      globalPts.addPt(G[v]);
    }
    return init + current_twist;
  };
  

  pts Type1braid(float r, float init, int circle_num){
    //float twist = circle_num * TWO_PI / leng;
    float twist = circle_num * TWO_PI / (nv-1);
    //float pass_leng = 0;
    pts braid_center = new pts();
    braid_center.declare();
    
    for (int v=0; v<nv-1; v++) {
      vec I = LL[v];
      vec J = U(cross(I,V(G[v],G[v+1])));
      //float u = 2 * globalInits.get(v) * (float)Math.PI + init + twist * v;
      //float u = init + twist * pass_leng;
      //pass_leng += norm(V(G[v],G[v+1]));
      float u = init + twist * v;
      vec move = V(cos(u),I,sin(u),J);
      pt a = P(G[v],V(r,move));
      braid_center.addPt(a);
      //braid_center.LL[braid_center.nv-1] = LL[v];
    }
    braid_center.addPt(braid_center.G[0]);
    //braid_center.LL[pv] = braid_center.LL[0];
    return braid_center;
  };
  
  pts Type2braid(float r, int init, int strip){
    pts braid_center = new pts();
    braid_center.declare();
    double status[] = {Math.PI*2/3, -Math.PI/3, 0, Math.PI/3, -Math.PI*2/3, Math.PI};
    int st = init;
    
    for(int v = 0; v < nv/6*6-1; v+=strip){
      float u = (float)status[st];
      st = (st == 5)? 0 : st + 1;
      vec I = LL[v];
      vec J = U(cross(I,V(G[v],G[v+1])));
      vec move = V(cos(u),I,sin(u),J);
      pt a = P(G[v],V(r*1.5,move));
      braid_center.addPt(a);
      //braid_center.LL[braid_center.nv-1] = new vec(0,0,1);
    }
    braid_center.addPt(braid_center.G[0]);
    //braid_center.LL[pv] = braid_center.LL[0];
    return braid_center;
  }
  
  pts Type3braid(float r, int mode, int init, int strip){
    pts braid_center = new pts();
    braid_center.declare();
  //  double status[][] = {{Math.PI/3, Math.PI*2/3, Math.PI*3/4, -Math.PI*3/4, -Math.PI*2/3, -Math.PI/3, -Math.PI/4, Math.PI/4},
  //{Math.PI*3/4, Math.PI/4, Math.PI/6, -Math.PI/6, -Math.PI/4, -Math.PI*3/4, -Math.PI*5/6, Math.PI*5/6}};
  //  double status[][] = {{Math.PI*2/5, Math.PI*3/5, Math.PI*3/4, -Math.PI*3/4, -Math.PI*3/5, -Math.PI*2/5, -Math.PI/4, Math.PI/4},
  //{Math.PI*3/4, Math.PI/4, Math.PI/10, -Math.PI/10, -Math.PI/4, -Math.PI*3/4, -Math.PI*9/10, Math.PI*9/10}};
    double status[][] = {{Math.PI*3/7, Math.PI*4/7, Math.PI*3/4, -Math.PI*3/4, -Math.PI*4/7, -Math.PI*3/7, -Math.PI/4, Math.PI/4},
  {Math.PI*3/4, Math.PI/4, Math.PI/14, -Math.PI/14, -Math.PI/4, -Math.PI*3/4, -Math.PI*13/14, Math.PI*13/14}};
  //  double status[][] = {{Math.PI/2, Math.PI/2, Math.PI*3/4, -Math.PI*3/4, -Math.PI/2, -Math.PI/2, -Math.PI/4, Math.PI/4},
  //{Math.PI*3/4, Math.PI/4, 0, 0, -Math.PI/4, -Math.PI*3/4, Math.PI, Math.PI}};
    float dist[][] = {{2.7,2.7,1.414,1.414,2.7,2.7,1.414,1.414}, {1.414,1.414,2.7,2.7,1.414,1.414,2.7,2.7}};
    int st = init;
    
    for(int v = 0; v < nv/8*8-1; v+=strip){
      float u = (float)status[mode][st];
      float d = dist[mode][st];
      st = (st == 7)? 0 : st + 1;
      vec I = LL[v];
      vec J = U(cross(I,V(G[v],G[v+1])));
      vec move = V(cos(u),I,sin(u),J);
      pt a = P(G[v],V(r*d,move));
      braid_center.addPt(a);
      //braid_center.LL[braid_center.nv-1] = LL[v];
    }
    braid_center.addPt(braid_center.G[0]);
    //braid_center.LL[pv] = braid_center.LL[0];
    return braid_center;
  }

  pts set_pv_to_pp() {pv=pp; return this;}
  pts movePicked(vec V) { G[pv].add(V); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts setPickedTo(pt Q) { G[pv].setTo(Q); return this;}      // moves selected point (index p) by amount mouse moved recently
  pts moveAll(vec V) {for (int i=0; i<nv; i++) G[i].add(V); return this;};   
  pt Picked() {return G[pv];} 
  pt Pt(int i) {if(0<=i && i<nv) return G[i]; else return G[0];} 

  // ********* I/O FILE *******  
 void savePts(String fn) 
    {
    String [] inppts = new String [nv+1];
    int s=0;
    inppts[s++]=str(nv);
    for (int i=0; i<nv; i++) {inppts[s++]=str(G[i].x)+","+str(G[i].y)+","+str(G[i].z)+","+L[i];}
    saveStrings(fn,inppts);
    };
  
  void loadPts(String fn) 
    {
    println("loading: "+fn); 
    String [] ss = loadStrings(fn);
    String subpts;
    int s=0;   int comma, comma1, comma2;   float x, y;   int a, b, c;
    nv = int(ss[s++]); print("nv="+nv);
    for(int k=0; k<nv; k++) 
      {
      int i=k+s; 
      //float [] xy = float(split(ss[i],",")); 
      String [] SS = split(ss[i],","); 
      G[k].setTo(float(SS[0]),float(SS[1]),float(SS[2]));
      L[k]=SS[3].charAt(0);
      }
    pv=0;
    };
 
  // Dancer
  void setPicekdLabel(char c) {L[pp]=c;}
  


  void setFifo() 
    {
    _LookAtPt.reset(G[dv],60);
    }              


  void next() {dv=n(dv);}
  int n(int v) {return (v+1)%nv;}
  int p(int v) {if(v==0) return nv-1; else return v-1;}
  
  pts subdivideDemoInto(pts Q) 
    {
    Q.empty();
    for(int i=0; i<nv; i++)
      {
      Q.addPt(P(G[i])); 
      Q.addPt(P(G[i],G[n(i)])); 
      //...
      }
    return this;
    }  
  
  void displaySkater() 
      {
      if(showCurve) {fill(yellow); for (int j=0; j<nv; j++) caplet(G[j],6,G[n(j)],6); }
      pt[] B = new pt [nv];           // geometry table (vertices)
      for (int j=0; j<nv; j++) B[j]=P(G[j],V(0,0,100));
      if(showPath) {fill(lime); for (int j=0; j<nv; j++) caplet(B[j],6,B[n(j)],6);} 
      if(showKeys) {fill(cyan); for (int j=0; j<nv; j+=4) arrow(B[j],G[j],3);}
      
      if(animating) f=n(f);
      if(showSkater) 
        {
        // ....
        }
      else {fill(red); arrow(B[f],G[f],20);} //
      }

        

} // end of pts class

class CtrlPolygon{
  pts controlPolygon;
  int N;

  CtrlPolygon(pts P){
    controlPolygon = P;
    N = controlPolygon.nv;
  };
  
  void draw(){
    controlPolygon.drawClosedCurve(3);
    for(int i = 0; i < N; i++){
      fill(cyan);arrow(controlPolygon.G[i], P(controlPolygon.G[i], V(100,controlPolygon.LL[i])), 5);
    }
  }
  
  void Type1CtrlVec(){
    
    for (int i = 0; i < N; i++){
      float r[] = new float[3];
      vec tang[] = new vec[3];
      pt P[] = new pt[5];
      P[0] = i > 1 ? controlPolygon.G[i-2] : controlPolygon.G[i-2+N];
      P[1] = i > 0 ? controlPolygon.G[i-1] : controlPolygon.G[i-1+N];
      P[2] = controlPolygon.G[i];
      P[3] = i < N - 1 ? controlPolygon.G[i+1] : controlPolygon.G[i+1-N];
      P[4] = i < N - 2 ? controlPolygon.G[i+2] : controlPolygon.G[i+2-N];
      
      for (int j = 0; j < 3; j++){
        pt O = getCircumCenter(P[j], P[j+1], P[j+2]);
        r[j] = norm(V(O,P[j+1]));
        tang[j] = U(cross(cross(V(O,P[j+1]),V(P[j],P[j+2])),V(O,P[j+1])));
      }
      controlPolygon.LL[i] = U(V(r[0], tang[0]).add(r[1], tang[1]).add(r[2], tang[2]));
    }
  };
  
  pt getCircumCenter(pt A, pt B, pt C){
    vec AB = V(A,B);
    vec BC = V(B,C);
    float alpha = angle(AB, BC);
    pt P = P(A, 0.5, C);
    vec OP;
    if (alpha < Math.PI /2.0){
      OP = cross(cross(AB, BC), V(C,A));
    }else{
      OP = cross(cross(AB, BC), V(A,C));
    }
    OP = V(norm(V(A,C))/ (2 * tan(alpha)), U(OP));
    pt O = P(P, OP);
    return O;
  };

  
  void Type2CtrlVec() {
    controlPolygon.LL[0] = U(V(controlPolygon.G[N-1], controlPolygon.G[0]));
    for (int i = 1; i < N; i++) {
      controlPolygon.LL[i] = U(V(controlPolygon.G[i-1], controlPolygon.G[i]));
    }
  }
  
  void Type3CtrlVec() {
    controlPolygon.LL[0] = U(controlPolygon.G[N-1], controlPolygon.G[1]);
    controlPolygon.LL[N-1] = U(controlPolygon.G[N-2], controlPolygon.G[0]);
    for (int i = 1; i < N - 1; i++) {
      controlPolygon.LL[i] = U(controlPolygon.G[i-1], controlPolygon.G[i+1]);
    }
  }
  
  void Type4CtrlVec() {
    controlPolygon.LL[0] = U(A(U(controlPolygon.G[N-1], controlPolygon.G[0]), U(controlPolygon.G[0], controlPolygon.G[1])));
    controlPolygon.LL[N-1] = U(A(U(controlPolygon.G[N-2], controlPolygon.G[N-1]), U(controlPolygon.G[N-1], controlPolygon.G[0])));
    for (int i = 1; i < N - 1; i++) {
      controlPolygon.LL[i] = U(A(U(controlPolygon.G[i-1], controlPolygon.G[i]), U(controlPolygon.G[i], controlPolygon.G[i+1])));
    }
  }
  
}

class Arc
{
  pt Origin;
  pt Start;
  float ElbowRatio;
  float alpha; //[-pi, pi)
  float piper;
  vec normal;
  vec veci;
  vec vecj;
  pts points = new pts();
  int N = 0;
  float leng;
  
  Arc(pt O, pt S, pt E, float r){
    this.Origin = O;
    this.Start = S;
    this.ElbowRatio = norm(V(O,S));
    this.alpha = angle(V(O,S), V(O,E));
    this.normal = U(cross(V(O,S), V(O,E)));
    this.veci = U(V(O,S));
    this.vecj = U(cross(normal, veci));
    this.piper = r;
    this.leng = abs(alpha*ElbowRatio);
    this.fill_points();
  };

  void draw(){
    points.drawPipe(piper,0.25,twist); // draw 4-strip
    points.drawUPath(piper, piper/10,upath); // draw u-path
  };
  
  void drawUPath(float upath){
    points.drawUPath(piper, piper/10,upath);
  };
  
  
  private void fill_points(){
    // In braids, use sparse mode
    if (sparseMode){
      this.N = 2;
    }else{
      this.N = min(max((int)(ElbowRatio * 0.2 * alpha),5),20);
    }
    float h = alpha/N;
    points.declare();
    for(int i = 0; i <= N; i++){
      vec v = V(cos(i*h)*ElbowRatio, veci);
      v.add(sin(i*h)*ElbowRatio, vecj);
      pt p = P(Origin, v);
      points.addPt(p);
      points.LL[i] = U(v);
    }
  };
}

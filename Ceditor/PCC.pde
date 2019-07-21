import java.util.*;
class PCC {
  pts controlPolygon;
  List<Arc> arcs = new ArrayList<Arc>();
  float[] angle_delta;
  int N;
  float leng;
  float angle = 0;
  float fixed_twist;
  float thin = 10;
  pts globalpts = new pts();
  //boolean sparse;
  
  //PCC(CtrlPolygon ctrlpoly, float thin){
  //  this(ctrlpoly, thin, false);
  //}
  
  PCC(CtrlPolygon ctrlpoly, float thin) {
    //this.sparse = sparse;
    this.thin = thin;
    controlPolygon = ctrlpoly.controlPolygon;
    this.N = controlPolygon.nv;
    globalpts.declare();
    
    //get biarcs
    for (int i = 0; i < N-1; i++) {
      pt A = P(controlPolygon.G[i]);
      pt D = P(controlPolygon.G[i + 1]);
      vec a = V(controlPolygon.LL[i]);
      vec d = V(controlPolygon.LL[i+1]);
      //this.arcs.addAll(getBiArc(A, D, a, d));
      getBiArc(A, D, a, d);
    }
    
    pt A = P(controlPolygon.G[N-1]);
    pt D = P(controlPolygon.G[0]);
    vec a = V(controlPolygon.LL[N-1]);
    vec d = V(controlPolygon.LL[0]);
    //this.arcs.addAll(getBiArc(A, D, a, d));
    getBiArc(A, D, a, d);
    
    
    //get angle differences between arcs
    angle_delta = new float[2*N];
    angle_delta[0] = 0;
    for (int i = 1; i < 2*N; i++){
      vec tmp1 = arcs.get(i-1).points.LL[arcs.get(i-1).points.nv-1];
      vec tmp2 = arcs.get(i).points.LL[0];
      float tmp = d(tmp1, tmp2);
      tmp = max(tmp, -1);
      tmp = min(tmp, 1);
      
      angle_delta[i] = acos(tmp) / (float)(2 * Math.PI);
      //print(angle_delta[i]);
      if (d(cross(tmp1,tmp2),V(arcs.get(i).points.G[0], arcs.get(i).points.G[1])) < 0) angle_delta[i] = - angle_delta[i];
      angle += angle_delta[i];
    }
    
    //get length
    leng = 0;
    for (int i = 0; i < 2*N; i++){
      leng += arcs.get(i).leng;
    }
    
    // computer fixed twist
    fixed_twist(); //print(fixed_twist);
    if (Float.isNaN(fixed_twist)){
      fixed_twist = 0;
    }else{
      global_fixed_twist = fixed_twist;
    }
  };
  
  void draw(){
    if (sparseMode){
      //simple_draw();
      for (int i = 0; i < 2*N; i++){
        Arc tmp = arcs.get(i);
        tmp.points.drawPipe_simple(tmp.piper);
      }
    }else if (preTwistMode){
      //print(twist);
      float current = 0; 
      for (int i = 0; i < 2*N; i++){
        Arc tmp = arcs.get(i);
        current = tmp.points.drawPipe(tmp.piper,current + angle_delta[i],twist);
      }
    }
    else if(resultMode){
      float current = 0; 
      for (int i = 0; i < 2*N; i++){
        Arc tmp = arcs.get(i);
        current = tmp.points.drawPipe(tmp.piper,current + angle_delta[i],twist);
      }
    }else{
      float current = 0; 
      float current_u = 0;
      for (int i = 0; i < 2*N; i++){
        Arc tmp = arcs.get(i);
        current = tmp.points.drawPipe(tmp.piper,current + angle_delta[i],twist);
        current_u += angle_delta[i];
        tmp.drawUPath(current_u + upath);
      }
    }
  };
  
  //void simple_draw(){ //<>//
  //  for (int i = 0; i < 2*N; i++){
  //    Arc tmp = arcs.get(i);
  //    tmp.points.drawPipe_simple(tmp.piper);
  //  }
  //};
  
  private void fixed_twist(){
    vec tmp1 = arcs.get(2*N-1).points.LL[arcs.get(2*N-1).points.nv-1];
    vec tmp2 = arcs.get(0).points.LL[0];
    float tmp = d(tmp1, tmp2);tmp = max(tmp, -1);tmp = min(tmp, 1);
      
    float angle_delta_f = acos(tmp) / (float)(2 * Math.PI);
    if (d(cross(tmp1,tmp2),V(arcs.get(0).points.G[0], arcs.get(0).points.G[1])) < 0) angle_delta_f = - angle_delta_f;
    angle += angle_delta_f;
    float twist_angle = angle;
    if (twist_angle > 0){
      while (abs(twist_angle) > TWO_PI){
        twist_angle -= TWO_PI;
      }
    }else{
      while (abs(twist_angle) > TWO_PI){
        twist_angle += TWO_PI;
      }
    }
    fixed_twist = -twist_angle / leng * 200.0;
  };
  
  void computer_base(){
    float current = 0;
    for (int i = 0; i < 2*N; i++){
      Arc tmp = arcs.get(i);
      current = tmp.points.Record(current + angle_delta[i],fixed_twist, globalpts);
    }
    globalpts.LL[globalpts.nv] = globalpts.LL[0];
    globalpts.addPt(globalpts.G[0]);
  };
  
  private void getBiArc(pt A, pt D, vec a, vec d) {
    //!!! a,d are unit vec.
    a = U(a);
    d = U(d);
    double x = Math.pow((a.x + d.x), 2) + Math.pow((a.y + d.y), 2) + Math.pow((a.z + d.z), 2) - 4;
    double y = 2 * ((a.x + d.x) * (A.x - D.x) + (a.y + d.y) * (A.y - D.y) + (a.z + d.z) * (A.z - D.z));
    double z = Math.pow((A.x - D.x), 2) + Math.pow((A.y - D.y), 2) + Math.pow((A.z - D.z), 2);
    double r1 = (Math.sqrt(y * y - 4 * x * z) - y) / (2 * x);
    double r2 = (- Math.sqrt(y * y - 4 * x * z) - y) / (2 * x);
    double r = r1;
    if (r1 <= 0) r = r2;
    pt B = P(A, (float)r, a);
    pt C = P(D, -(float)r, d);
    pt E = P(B, C);
    
    //List<Arc> biarc = new ArrayList<Arc>();
    pt O1 = getCenter(A, a, E, V(B, C));
    pt O2 = getCenter(E, V(B, C), D, d);
    arcs.add(new Arc(O1, A, E, thin));
    arcs.add(new Arc(O2, E, D, thin)); 
    //return biarc;
  }
  
  private pt getCenter(pt X, vec x, pt Y, vec y) { // get circum center
    float alpha = angle(x, y);
    vec normal = cross(x, y);
    float r = Math.abs(d(X, Y) / (2 * sin(alpha / 2)));
    vec XO = V(r, U(cross(normal, x)));
    return P(X, XO);
  }
}

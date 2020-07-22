class MyPoint{
  PVector pv;
  //float x,y,z; //a 3D coordinate
  color c = color(1); 
  
  MyPoint(float xin, float yin, float zin){
    pv = new PVector(xin, yin, zin);
    //x = xin;
    //y = yin;
    //z = zin;
    
    //c = color(random(1.), random(1.), random(1.));
  } 
}
// https://forum.processing.org/topic/reflecting-a-vector-from-a-plane
class Ray{
  PVector start = new PVector(),end = new PVector();
  Ray(PVector s,PVector e){   start = s ; end = e;  }
  
  void setStart(float xin, float yin, float zin){
    start.set(xin, yin, zin); 
  }
  
  void setStart(PVector v) {
    start = v;
  }
  
  void setEnd(float xin, float yin, float zin){
    end.set(xin, yin, zin); 
  }
  
  void setEnd(PVector v) {
    end = v;
  }
}

class MyFace {
  int npoints = 0; //the number of points
  MyPoint [] points; //array of points
  PVector n;   //normal
  PVector c = new PVector();//centroid
  color f = color(1); //fill color //1
  
  boolean isVisible = false; 
  
  MyFace(MyPoint[] inPoints){
    points = new MyPoint[inPoints.length];
    npoints = inPoints.length;
    for(int i=0; i<inPoints.length; i++)
      points[i] = new
      MyPoint(inPoints[i].pv.x, inPoints[i].pv.y, inPoints[i].pv.z);
  }

  MyFace (){
    points = new MyPoint[0];
  }
  
  void addPoint(MyPoint p) {
    npoints++;
    points=(MyPoint[])append(points, p);
  }
  
  void addPoint(float addX, float addY, float addZ){
    npoints++;
    points=(MyPoint[])append(points, new MyPoint(addX,addY,addZ));
  } 
  
  void normal(){
    PVector cb = PVector.sub(points[2].pv,points[1].pv);
    PVector ab = PVector.sub(points[0].pv,points[1].pv);
    n = cb.cross(ab);  //compute normal
    //n.normalize();
    //return n;
  }
  
  void centroid(){
    for(int i = 0; i < npoints; i++) {
      c.add(points[i].pv);
    }
    c.div(npoints);
  }
  
  void draw(){
      
    beginShape(); //QUADS
    fill(f);
    for(int i = 0; i < npoints; i++){
     // color c1 = color(204, 153, 0);
            //fill(points[i].c); //points[i].c
      vertex(points[i].pv.x,points[i].pv.y, points[i].pv.z);
      //println(points[i].pv.x+" "+points[i].pv.y+" "+points[i].pv.z );
    }
    endShape(CLOSE);
    if(isVisible) {
      pushStyle();
      strokeWeight(10);
      point(c.x,c.y,c.z);
      popStyle();
    }      
    // draw normal
    //line(c.x,c.y,c.z,n.x,n.y,n.z);//draw normal
  }
}

class MySurface {
  int npoints = 0;   //the number of points
  int nfaces = 0;
  int [][] indexes;
  int [] faceid;
  MyPoint [] points; //array of points
  MyFace  [] faces; //array of faces
    
  MySurface(String[] v, String[] n) {
    
    npoints = v.length;
    points = new MyPoint[npoints];
    nfaces = n.length;
    faces = new MyFace[nfaces];

    for(int i=0; i<npoints; i++){
      String[] vVals = splitTokens(v[i], ", ");
      points[i] = new MyPoint(float(vVals[0]), float(vVals[1]), float(vVals[2]));
    }
    
    for(int i=0; i<nfaces; i++){
      String[] nVals = splitTokens(n[i], ",");
      faces[i] = new MyFace();
      
      for(int j=0; j<nVals.length; j++){
           int ndx = int(nVals[j]);
             
           faces[i].addPoint(points[ndx]);
       }
        faces[i].normal();
        faces[i].centroid();     
    }
  }
 
  void draw(){
    for(int i=0; i<nfaces; i++)
      faces[i].draw(); //g
  }
  
}

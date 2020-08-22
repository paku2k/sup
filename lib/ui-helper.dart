double screenHeight;
double screenWidth;

final double standardWidth=392;
final double standardHeigth=803;

double realW(double width){
  return screenWidth*(width/standardWidth);
}
double realH(double height){
  return screenHeight*(height/standardHeigth);
}
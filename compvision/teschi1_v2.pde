import KinectPV2.*;
import KinectPV2.KJoint;
import java.util.ArrayList;

import processing.serial.*;

KinectPV2 kinect;
Serial myPort;

void setup() {
  fullScreen(P3D);
  
  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  
  kinect.enableSkeleton3DMap(true);

  kinect.init();
  
  println(Serial.list());
  String portName = Serial.list()[0];
  myPort = new Serial(this, portName, 115200);
  println("Arduino connesso su: " + portName);
  
}

void draw() {
  background(0);

  PImage colorImg = kinect.getColorImage();

  if (colorImg != null) {
    float imgRatio = (float) colorImg.width / colorImg.height;
    float screenRatio = (float) width / height;

    float newW, newH;

    // fixed image
    if (imgRatio > screenRatio) {
      newW = width;
      newH = width / imgRatio;
    } else {
      newH = height;
      newW = height * imgRatio;
    }

    float xPos = (width - newW)/2;
    float yPos = (height - newH)/2;

    image(colorImg, xPos, yPos, newW, newH);
  }

  // calc X

  ArrayList<KSkeleton> skeletons = kinect.getSkeleton3d();

  fill(255, 0, 0);
  textAlign(LEFT, TOP);
  textSize(height * 0.1);
  
  // Se è presente almeno uno scheletro, prendi il primo
  if (skeletons.size() > 0) {
    KSkeleton sk = skeletons.get(0);
    if (sk.isTracked()) {
      KJoint spineMid = sk.getJoints()[KinectPV2.JointType_SpineMid];
      float xVal = spineMid.getX(); // coordinata X in metri
  
      // Visualizza il valore sullo schermo (opzionale)
      text("0 " + nf(xVal, 1, 3), 40, 40);
      
      float minX = -1.0; 
      float maxX =  1.0;
      
      float mappedVal = map(xVal, minX, maxX, 0, 100);
      mappedVal = constrain(mappedVal, 0, 100);
      
      int servoPos = int(mappedVal);
      myPort.write(servoPos + "\n");
    }
  }
}


void drawBody(KJoint[] joints) {
  drawBone(joints, KinectPV2.JointType_Head, KinectPV2.JointType_Neck);
  drawBone(joints, KinectPV2.JointType_Neck, KinectPV2.JointType_SpineShoulder);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_SpineMid);

  drawBone(joints, KinectPV2.JointType_SpineMid, KinectPV2.JointType_SpineBase);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderRight);
  drawBone(joints, KinectPV2.JointType_SpineShoulder, KinectPV2.JointType_ShoulderLeft);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipRight);
  drawBone(joints, KinectPV2.JointType_SpineBase, KinectPV2.JointType_HipLeft);

  // Right Arm    
  drawBone(joints, KinectPV2.JointType_ShoulderRight, KinectPV2.JointType_ElbowRight);
  drawBone(joints, KinectPV2.JointType_ElbowRight, KinectPV2.JointType_WristRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_HandRight);
  drawBone(joints, KinectPV2.JointType_HandRight, KinectPV2.JointType_HandTipRight);
  drawBone(joints, KinectPV2.JointType_WristRight, KinectPV2.JointType_ThumbRight);

  // Left Arm
  drawBone(joints, KinectPV2.JointType_ShoulderLeft, KinectPV2.JointType_ElbowLeft);
  drawBone(joints, KinectPV2.JointType_ElbowLeft, KinectPV2.JointType_WristLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_HandLeft);
  drawBone(joints, KinectPV2.JointType_HandLeft, KinectPV2.JointType_HandTipLeft);
  drawBone(joints, KinectPV2.JointType_WristLeft, KinectPV2.JointType_ThumbLeft);

  // Right Leg
  drawBone(joints, KinectPV2.JointType_HipRight, KinectPV2.JointType_KneeRight);
  drawBone(joints, KinectPV2.JointType_KneeRight, KinectPV2.JointType_AnkleRight);
  drawBone(joints, KinectPV2.JointType_AnkleRight, KinectPV2.JointType_FootRight);

  // Left Leg
  drawBone(joints, KinectPV2.JointType_HipLeft, KinectPV2.JointType_KneeLeft);
  drawBone(joints, KinectPV2.JointType_KneeLeft, KinectPV2.JointType_AnkleLeft);
  drawBone(joints, KinectPV2.JointType_AnkleLeft, KinectPV2.JointType_FootLeft);

  drawJoint(joints, KinectPV2.JointType_HandTipLeft);
  drawJoint(joints, KinectPV2.JointType_HandTipRight);
  drawJoint(joints, KinectPV2.JointType_FootLeft);
  drawJoint(joints, KinectPV2.JointType_FootRight);

  drawJoint(joints, KinectPV2.JointType_ThumbLeft);
  drawJoint(joints, KinectPV2.JointType_ThumbRight);

  drawJoint(joints, KinectPV2.JointType_Head);
}

void drawJoint(KJoint[] joints, int jointType) {
  strokeWeight(2.0f + joints[jointType].getZ()*8);
  point(joints[jointType].getX(), joints[jointType].getY(), joints[jointType].getZ());
}

void drawBone(KJoint[] joints, int jointType1, int jointType2) {
  strokeWeight(2.0f + joints[jointType1].getZ()*8);
  point(joints[jointType2].getX(), joints[jointType2].getY(), joints[jointType2].getZ());
}

void drawHandState(KJoint joint) {
  handState(joint.getState());
  strokeWeight(5.0f + joint.getZ()*8);
  point(joint.getX(), joint.getY(), joint.getZ());
}

void handState(int handState) {
  switch(handState) {
  case KinectPV2.HandState_Open:
    stroke(0, 255, 0);
    break;
  case KinectPV2.HandState_Closed:
    stroke(255, 0, 0);
    break;
  case KinectPV2.HandState_Lasso:
    stroke(0, 0, 255);
    break;
  case KinectPV2.HandState_NotTracked:
    stroke(100, 100, 100);
    break;
  }
}

void keyPressed() {
  if (key == 'q') {
    try {
      kinect.dispose();
    } catch(Exception e) {
      println("Errore nella dispose della Kinect:", e);
    }
    // exit();
  }
  
  // Disattiva ESC
  if (key == ESC) {
    key = 0;
  }
}

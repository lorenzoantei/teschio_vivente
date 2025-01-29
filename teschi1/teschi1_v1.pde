/*
import KinectPV2.*;
import KinectPV2.KJoint;
import java.util.ArrayList;

KinectPV2 kinect;

void setup() {
  // Avvia Processing a schermo intero in 3D
  fullScreen(P3D);

  kinect = new KinectPV2(this);
  kinect.enableColorImg(true);
  // Per ricavare la posizione X in 3D
  kinect.enableSkeleton3DMap(true);

  kinect.init();
}

void draw() {
  background(0);

  // 1) Disegna l'immagine a colori del Kinect a pieno schermo (senza rompere proporzioni).
  PImage colorImg = kinect.getColorImage();

  if (colorImg != null) {
    // Calcoliamo i rapporti di aspetto
    float imgRatio = (float) colorImg.width / colorImg.height;
    float screenRatio = (float) width / height;

    float newW, newH;

    // "Copri" tutto lo schermo: se l'immagine è più larga dello schermo, la adatta in altezza (e viceversa).
    if (imgRatio > screenRatio) {
      // L'immagine è più larga dello schermo: la larghezza si adatta, l'altezza va in proporzione
      newW = width;
      newH = width / imgRatio;
    } else {
      // L'immagine è più "stretta": l'altezza si adatta
      newH = height;
      newW = height * imgRatio;
    }

    // Centriamo l’immagine in orizzontale/verticale
    float xPos = (width - newW)/2;
    float yPos = (height - newH)/2;

    image(colorImg, xPos, yPos, newW, newH);
  }

  // 2) Calcoliamo la X del primo skeleton (o di tutti) e la mostriamo in testo grande
  ArrayList<KSkeleton> skeletons = kinect.getSkeleton3d();

  fill(255, 0, 0);
  textAlign(LEFT, TOP);
  // Usa una dimensione testo grande, ad esempio 10% dell’altezza schermo
  textSize(height * 0.1);

  float textY = 40;
  for (int i = 0; i < skeletons.size(); i++) {
    KSkeleton sk = skeletons.get(i);
    if (sk.isTracked()) {
      KJoint spineMid = sk.getJoints()[KinectPV2.JointType_SpineMid];
      float xVal = spineMid.getX(); // in metri, relativo al sensore Kinect

      // Stampa la X grande e leggibile
      //text("Skeleton " + i + " - X: " + nf(xVal, 1, 3), 20, textY);
      text(i + " " + nf(xVal, 1, 3), 40, textY);
      // Sposta la riga di testo successiva
      textY += textAscent() + textDescent() + 40;
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
  if (key == 'q') { // ad esempio premi 'q' per uscire
    // Tenta di “disporre” la Kinect
    try {
      kinect.dispose();
    } catch(Exception e) {
      println("Errore nella dispose della Kinect:", e);
    }
    // Poi esci dal programma
    //exit();
  }
  
  // Disattiva ESC
  if (key == ESC) {
    key = 0;
  }
}
*/

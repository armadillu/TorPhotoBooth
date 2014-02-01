//
//  LivePreviewBg.h
//  remoteUI_Sketch
//
//  Created by Oriol Ferrer Mesià on 31/01/14.
//
//

#ifndef __remoteUI_Sketch__LivePreviewBg__
#define __remoteUI_Sketch__LivePreviewBg__

#include <iostream>
#include "ofMain.h"

class LivePreviewBg{

public:

	LivePreviewBg(){
		mode = 0;
	}

	void setup(){
		taxi.loadImage("taxi.png");
		taxiTop.loadImage("taxi_door.png");

		parkImg.loadImage("park.jpg");
		theaterImg.loadImage("theater.jpg");
	}


	void draw( ofImage & maskedPerson, ofFbo & output){

		output.begin();
		switch (mode) {
			case 0: //taxi
				taxi.draw(0,0);
				ofPushMatrix();
					ofTranslate(taxiPersonPos);
					ofScale(-taxiPersonScale, taxiPersonScale, taxiPersonScale);
					maskedPerson.draw(0,0);
				ofPopMatrix();
				taxiTop.draw(0,0);
				break;

			case 1: //theater
				theaterImg.draw(0,0);
				ofPushMatrix();
					ofTranslate(theaterPersonPos);
					ofScale(-theaterPersonScale, theaterPersonScale, theaterPersonScale);
					maskedPerson.draw(0,0);
				ofPopMatrix();
				break;

			case 2: //park
				parkImg.draw(0,0);
				ofPushMatrix();
					ofTranslate(parkPersonPos);
					ofScale(-parkPersonScale, parkPersonScale, parkPersonScale);
					maskedPerson.draw(0,0);
				ofPopMatrix();
				break;

			default:
				break;
		}
		output.end();
	}

	int mode;

	ofVec2f taxiPersonPos;
	float taxiPersonScale;

	ofVec2f parkPersonPos;
	float parkPersonScale;

	ofVec2f theaterPersonPos;
	float theaterPersonScale;

private:

	ofImage taxi;
	ofImage taxiTop;

	ofImage parkImg;

	ofImage theaterImg;

};

#endif /* defined(__remoteUI_Sketch__LivePreviewBg__) */

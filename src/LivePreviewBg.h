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
	}

	void setMode(int mode_){ mode = mode_;}


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

			default:
				break;
		}
		output.end();
	}

	ofVec2f taxiPersonPos;
	float taxiPersonScale;

private:

	int mode;
	ofImage taxi;
	ofImage taxiTop;
};

#endif /* defined(__remoteUI_Sketch__LivePreviewBg__) */

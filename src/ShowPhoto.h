//
//  ShowPhoto.h
//  remoteUI_Sketch
//
//  Created by Oriol Ferrer Mesià on 31/01/14.
//
//

#ifndef remoteUI_Sketch_ShowPhoto_h
#define remoteUI_Sketch_ShowPhoto_h

#include "ofMain.h"

class ShowPhoto{

public:

	void draw( ofImage & maskedPerson, ofFbo & output){

		output.begin();
		ofClear(0,0,0,0);
		ofPushMatrix();
			ofTranslate(pos.x, pos.y);
			ofScale(scale, scale, scale);
			maskedPerson.draw(0,0);
		ofPopMatrix();
		output.end();
	}

	ofVec2f pos;
	float scale;

};

#endif

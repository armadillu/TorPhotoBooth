#pragma once

#include "ofMain.h"
#include "ofxTimeMeasurements.h"
#include "ofxRemoteUIServer.h"

#include "CanonCameraWrapper.h"
#include "stdlib.h"
#include "CanonConstants.h"

#include "ofxOpenCv.h"
#include "ofxGreenscreen.h"

#include "WhiteBgRemover.h"

#include "LivePreviewBg.h"
#include "ShowPhoto.h"

#include "ofxAnimatableFloat.h"

#define PREVIEW_W	640
#define PREVIEW_H	480

/*output from canon*/
#define PHOTO_W		2784
#define PHOTO_H		1856

class testApp : public ofBaseApp{

	public:
		void setup();
		void update();
		void draw();
		void exit();

		void calcWhiteBg();
		void keyPressed(int key);
		void keyReleased(int key);
		void mouseMoved(int x, int y );
		void mouseDragged(int x, int y, int button);
		void mousePressed(int x, int y, int button);
		void mouseReleased(int x, int y, int button);
		void windowResized(int w, int h);
		void dragEvent(ofDragInfo dragInfo);
		void gotMessage(ofMessage msg);

		float outputScale;
		bool timeSample;
	float photoShowTime; //secs

	void photoWasDownloaded(char* path);	//for the ofxCanonAddon

	bool loaded;

	ofImage cameraMasked; //photo taken + mask
	ofColor bgColor;
	int imageShowCounter;
	CanonCameraWrapper * 	cam;

	ofVideoGrabber grabber;
	ofxGreenscreen gs;
	ofColor keyColor;
	ofImage greenInput;

	bool debugMasks;

	WhiteBgRemover bgRem;
	float drawScale;
	float xOffset;

	LivePreviewBg bg;
	ShowPhoto photoResult;

	ofFbo livePreviewFbo;
	ofFbo photoFbo;

	ofxAnimatableFloat photoAnimation;
};

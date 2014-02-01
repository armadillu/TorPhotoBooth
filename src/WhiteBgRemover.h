//
//  WhiteBgRemover.h
//  opencvExample
//
//  Created by Oriol Ferrer Mesià on 31/01/14.
//
//

#ifndef __opencvExample__WhiteBgRemover__
#define __opencvExample__WhiteBgRemover__

#include <iostream>
#include "ofMain.h"
#include "ofxOpenCv.h"


class WhiteBgRemover{

public:

	WhiteBgRemover();

	ofImage removeBg( ofImage & );
	void draw(int x, int y,float drawScale);

	//params
	float shift;
	float scale;
	int threshold;
	int numDilate1stPass;
	int numErode1stPass;
	int numDilate2ndPass;
	int numErode2ndPass;

	int numBlur;

	float drawScale;
	float xOffset;

	ofRectangle photoCrop; //roi

private:


	ofxCvColorImage	colorImg;
	ofxCvGrayscaleImage	grayImage;
	ofxCvGrayscaleImage	grayTh;
	ofxCvGrayscaleImage	grayMorph;
	ofxCvGrayscaleImage	grayBlur;

	ofxCvContourFinder contourFinder;
	ofImage ret;
	int w, h;
};

#endif /* defined(__opencvExample__WhiteBgRemover__) */

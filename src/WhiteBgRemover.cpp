//
//  WhiteBgRemover.cpp
//  opencvExample
//
//  Created by Oriol Ferrer Mesià on 31/01/14.
//
//

#include "WhiteBgRemover.h"

WhiteBgRemover::WhiteBgRemover(){
	w = h = 0;
	photoCrop = ofRectangle(0,0,10,10);
}

ofImage WhiteBgRemover::removeBg( ofImage & input){

	if(threshold > 255) return;

	w = input.getWidth();
	h = input.getHeight();

	bool sizeMatches = (w == colorImg.getWidth()) && (h == colorImg.getHeight());

	if( !colorImg.bAllocated || !sizeMatches ){
		colorImg.allocate(w, h);
		grayImage.allocate(w, h);
		grayTh.allocate(w, h);
		grayMorph.allocate(w, h);
		grayBlur.allocate(w, h);
	}

	colorImg.setFromPixels(input.getPixels(), input.getWidth(), input.getHeight());

	colorImg.setROI(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);
	grayImage.setROI(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);
	grayTh.setROI(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);
	grayMorph.setROI(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);
	grayBlur.setROI(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);

	grayImage = colorImg;
	//grayImage.contrastStretch();
	//cvConvertScale(grayImage.getCvImage(), grayImage.getCvImage(), scale, shift ); //
	grayTh = grayImage;

	grayTh.threshold(threshold, true); //true for invert
	//th += 1;

	grayMorph = grayTh;
	//remove small points
	for(int i = 0; i < numDilate1stPass; i++){
		grayMorph.dilate();
	}
	for(int i = 0; i < numErode1stPass; i++){
		grayMorph.erode();
	}
	for(int i = 0; i < numErode2ndPass; i++){
		grayMorph.erode();
	}
	for(int i = 0; i < numDilate2ndPass; i++){
		grayMorph.dilate();
	}

	contourFinder.findContours(grayMorph, 1000, FLT_MAX, 10, true);
	cout << " got " << contourFinder.blobs.size() << " blobs! " << endl;
	for(int i = 0; i < contourFinder.blobs.size(); i++){
		cout << " blob " << i  << " has hole: " << contourFinder.blobs[i].hole << " area: " << contourFinder.blobs[i].area << endl;

	}
	//	if (contourFinder.blobs.size() == 1){
	//		oneBlob = true; //done!
	//	}


	grayBlur = grayMorph;
	for(int i = 0; i < numBlur; i++){
		grayBlur.blur();
	}

	//apply mask to orinigal image

	ofImage mask;
	mask.setFromPixels(grayBlur.getPixels(), grayBlur.getWidth(), grayBlur.getHeight(), OF_IMAGE_GRAYSCALE);
	ret = input;
	ret.setImageType(OF_IMAGE_COLOR_ALPHA);

	//apply mask
	int totalPixels = w * h;
	unsigned char * maskPix = mask.getPixels();
	unsigned char * targetPix = ret.getPixels();

	for(int i = 0; i < totalPixels; i++){
		targetPix[ 4 * i + 3 ] = maskPix[i];
	}
	ret.update();

	ret.crop(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);

	return ret;

}

void WhiteBgRemover::draw(int x, int y, float drawScale){

	if(!colorImg.bAllocated) return;

	//original image + ROI
	int offset = x;

	colorImg.draw(offset, y, w * drawScale, h * drawScale);
	ofNoFill(); ofSetColor(255,0,0);
	ofRect(offset +  photoCrop.x * drawScale, photoCrop.y * drawScale, photoCrop.width * drawScale, photoCrop.height * drawScale);
	ofFill(); ofSetColor(ofColor::white);
	offset += w * drawScale;

	grayImage.drawROI(offset, y, photoCrop.width * drawScale, photoCrop.height * drawScale);		offset += photoCrop.width * drawScale;
	grayTh.drawROI(offset, y, photoCrop.width * drawScale, photoCrop.height * drawScale);		offset += photoCrop.width * drawScale;
	grayMorph.drawROI(offset, y, photoCrop.width * drawScale, photoCrop.height * drawScale);		offset += photoCrop.width * drawScale;
	//grayBlur.drawROI(offset, 0, photoCrop.width * drawScale, photoCrop.height * drawScale);		offset += photoCrop.width * drawScale;

	contourFinder.draw(w * drawScale + x, y, w * drawScale, h * drawScale);
	for(int i = 0; i < contourFinder.nBlobs; i++){
		string m = "ID :" + ofToString(i) +	"\narea:" + ofToString(contourFinder.blobs[i].area, 1) + string(contourFinder.blobs[i].hole ? "\nhole!" : "");

		ofDrawBitmapStringHighlight( m,
									contourFinder.blobs[i].centroid * drawScale + ofVec2f(w * drawScale + x, 0),
									ofColor(0,128),
									ofColor::white
									);
	}
	//offset += photoCrop.width * drawScale;

	//finalOutput.crop(photoCrop.x, photoCrop.y, photoCrop.width, photoCrop.height);
	ret.draw(offset, y, photoCrop.width * drawScale, photoCrop.height * drawScale);

}
#include "testApp.h"

//--------------------------------------------------------------
void testApp::setup(){

	ofSetFrameRate(60);
	ofSetVerticalSync(true);
	ofEnableAlphaBlending();
	ofBackground(0);

	OFX_REMOTEUI_SERVER_SETUP(); 	//start server

	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("DEBUG");
	OFX_REMOTEUI_SERVER_SHARE_PARAM(timeSample);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(debug);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("screen");
	OFX_REMOTEUI_SERVER_SHARE_PARAM(outputScale, 0, 1);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(photoShowTime, 1, 30);
	OFX_REMOTEUI_SERVER_SHARE_COLOR_PARAM(bgColor);

	OFX_REMOTEUI_SERVER_SHARE_PARAM(drawScale, 0.05, 1.0);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(xOffset, 0, ofGetWidth() * 2);

	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("photo background");
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.photoCrop.x, 0, PHOTO_W);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.photoCrop.y, 0, PHOTO_H);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.photoCrop.width, 0, PHOTO_W);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.photoCrop.height, 0, PHOTO_H);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.threshold, 200, 255);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.scale, 0.1, 3.0);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.shift, -255, 255);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.numDilate1stPass, 0, 5);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.numErode1stPass, 0, 5);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.numErode2ndPass, 0, 5);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.numDilate2ndPass, 0, 5);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);

	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("green screen");
	OFX_REMOTEUI_SERVER_SHARE_COLOR_PARAM(keyColor);


	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.doBaseMask);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.strengthBaseMask, 0, 1);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipBlackBaseMask,0,1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipWhiteBaseMask, 0, 1);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);

	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipBlackEndMask,0,1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipWhiteEndMask, 0, 1);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);

	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.doChromaMask);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.strengthChromaMask, 0, 1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipBlackChromaMask,0,1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipWhiteChromaMask, 0, 1);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.doDetailMask);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipBlackDetailMask,0,1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.clipWhiteDetailMask, 0, 1);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.doGreenSpill);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.strengthGreenSpill, 0, 1);

	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("scenes");

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);

	vector<string> modes; modes.push_back("TAXI");
	modes.push_back("THEATER"); modes.push_back("PARK");
	OFX_REMOTEUI_SERVER_SHARE_ENUM_PARAM(bg.mode, 0, 2, modes);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.taxiPersonPos.x, 0, 1920);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.taxiPersonPos.y, 0, 1080);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.taxiPersonScale, 0, 2);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.theaterPersonPos.x, 0, 1920);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.theaterPersonPos.y, 0, 1080);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.theaterPersonScale, 0, 2);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.parkPersonPos.x, 0, 1920);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.parkPersonPos.y, 0, 1080);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bg.parkPersonScale, 0, 2);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(photoResult.pos.x, 0, 1920);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(photoResult.pos.y, 0, 1080);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(photoResult.scale, 0, 2);


	OFX_REMOTEUI_SERVER_LOAD_FROM_XML();

	TIME_SAMPLE_SET_FRAMERATE(60);

	imageShowCounter = 0;
	cam = new CanonCameraWrapper( (testApp*)this );
	bool set = cam->setup(0);

	cam->openSession();
	cam->enableDownloadOnTrigger();
	cam->setDeleteFromCameraAfterDownload(FALSE);
	cam->setDownloadPath("canonSDKImages/" );
	cam->setFocusModeToLive();
	cam->setImageSizeAndQuality();

	ofSetLogLevel(OF_LOG_VERBOSE);

	loaded = false;
	ofHideCursor();

	bg.setup();

	livePreviewFbo.allocate(1920, 1080);
	photoFbo.allocate(1920, 1080);

	photoAnimation.reset(0);
	photoAnimation.setCurve(TANH);

	//grabber.setDeviceID(1);
	grabber.initGrabber(PREVIEW_W, PREVIEW_H);
	TIME_SAMPLE_SET_AVERAGE_RATE(0.01);

	//fake 1st photo here! 
	loaded = true;
	ofImage photoTaken;
	photoTaken.loadImage("canonSDKImages/IMG_5205.JPG");
	cameraMasked = bgRem.removeBg(photoTaken);

}


//--------------------------------------------------------------
void testApp::update(){

	float dt = 1./60.;
	if(timeSample) TIME_SAMPLE_ENABLE();
	else TIME_SAMPLE_DISABLE();

	photoAnimation.update(dt);

	cam->update();
	imageShowCounter--;

	grabber.update();

	TIME_SAMPLE_START("greenScreen");
	gs.setBgColor(keyColor);
	if(grabber.isFrameNew()){
		gs.setPixels(grabber.getPixelsRef());
	}
	TIME_SAMPLE_STOP("greenScreen");

}

//--------------------------------------------------------------
void testApp::draw(){

	ofSetupScreen();
	ofBackground(bgColor);


	bg.draw( gs, livePreviewFbo); //fill in fbo with bacgrkound and masked live preview of green screen
	photoResult.draw(cameraMasked, photoFbo);

	float vratio = 9./16.;
	ofRectangle r = ofRectangle(0,0, ofGetWidth(), ofGetHeight());
	r.scaleFromCenter(outputScale);
	glColor3ub(255,255,255);
	float x = r.x;
	float y = r.y;
	float ww = r.width;
	float hh = r.height;

	float photoAlpha = photoAnimation.val();

	ofSetColor(255);
	if(!debug){
		livePreviewFbo.draw(x,y,ww,hh);
		if(photoAlpha > 0.0){
			ofSetColor(255, 25 * photoAlpha);
			photoFbo.draw(x, y, ww, hh);
		}
	}else{
		gs.draw(ofGetWidth() - PREVIEW_W, ofGetHeight() - PREVIEW_H, PREVIEW_W, PREVIEW_H);
	}

	if ( imageShowCounter < 0 && loaded && !photoAnimation.isAnimating() && photoAnimation.val() > 0.9){
		//time to lower the photo preview
		photoAnimation.animateTo(0);
	}

	if ( cam->isCameraSendingPixels() ){
		cam->getLiveViewImage()->draw(x,y, ww, hh);
		glColor3ub(255,0,0);
		ofCircle( 40,40, 20);
	}

	//GREEN SCREEN
	//grabber.draw(0, 400);
//	gs.draw(0, PHOTO_H * drawScale, 2 * drawScale * gs.getWidth(),2 * drawScale * gs.getHeight());
	//grabber.draw(0, 0, 214, 160);
//	gs.drawBgColor();

	if(debug){
		//original image + ROI
		int offset = -xOffset;
		float s = 0.6;
		bgRem.draw(offset, 0, drawScale);
		cameraMasked.draw(0,1856 * drawScale,cameraMasked.getWidth() * s, cameraMasked.getHeight() * s );
	}

	//rotating cube
	glPushMatrix();
	glTranslatef(10,10, 0);
	glRotatef( ofGetFrameNum() * 3, 0,0,1);
	glColor3ub(255,255,255);
	ofRect(-5,-5, 10,10);
	glPopMatrix();
}


void testApp::exit(){
	if ( cam->getLiveViewActive() )
		cam->endLiveView();

	cam->closeSession();
	cam->destroy();
	printf("bye!\n");
}


void testApp::photoWasDownloaded(char* path){

	printf("photo downloaded!!!!%s\n", path);
	ofFile f;
	f.open(path);
	if (f.exists()) {
		loaded = true;
		ofImage photoTaken;
		photoTaken.loadImage(path);
		imageShowCounter = 60 * photoShowTime;	//5 seconds
		TIME_SAMPLE_START("masking");
		cameraMasked = bgRem.removeBg(photoTaken);
		TIME_SAMPLE_STOP("masking");

		photoAnimation.animateTo(1);

	}
}


//--------------------------------------------------------------
void testApp::keyPressed(int key){

	switch ( key ) {

		case 't':{
			cam->takePictureThreaded();
		}break;

		case '1':{
			ofImage photoTaken;
			photoTaken.loadImage("canonSDKImages/IMG_5205.JPG");
			cameraMasked = bgRem.removeBg(photoTaken);
			}break;

//		case 'd':{
//			cam->downloadLastImage();
//		}break;

		case 'f':
			ofToggleFullscreen();
			break;

		case ' ':
			bg.mode ++;
			if(bg.mode >=3) bg.mode = 0;
			OFX_REMOTEUI_SERVER_PUSH_TO_CLIENT();
			break;

		case 'l':
			if ( !cam->getLiveViewActive() )
				cam->beginLiveView();
			else
				cam->endLiveView();
			break;

//		case 'f':
//			cam->focusThreaded();
//			break;
	}
}

//--------------------------------------------------------------
void testApp::keyReleased(int key){

}

//--------------------------------------------------------------
void testApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void testApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void testApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void testApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void testApp::dragEvent(ofDragInfo dragInfo){ 

}

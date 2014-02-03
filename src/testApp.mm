#include "testApp.h"

bool recalcNow = false;
void serverCallback(RemoteUIServerCallBackArg arg){
	string paramName = arg.paramName;

	switch (arg.action) {
		case CLIENT_DID_SET_PRESET:
		case CLIENT_UPDATED_PARAM:{
			string match = "bgRem"; //recalc masks when editing bgRem.* params
			auto res = std::mismatch(match.begin(), match.end(), paramName.begin());
			if (res.first == match.end()){
				recalcNow = true;
			}
			}break;
	}
}

//--------------------------------------------------------------
void testApp::setup(){

	ofSetFrameRate(60);
	ofSetVerticalSync(true);
	ofEnableAlphaBlending();
	ofBackground(0);

	gs.setCropLeft(0.0);
	gs.setCropRight(0.0);
	gs.setCropBottom(0.0);
	gs.setCropTop(0.0);

	OFX_REMOTEUI_SERVER_SETUP(); 	//start server
	OFX_REMOTEUI_SERVER_GET_INSTANCE()->setCallback(serverCallback);

	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("DEBUG");
	OFX_REMOTEUI_SERVER_SHARE_PARAM(timeSample);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(debugMasks);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SET_UPCOMING_PARAM_GROUP("screen");
	OFX_REMOTEUI_SERVER_SHARE_PARAM(outputScale, 0, 1);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(photoShowTime, 1, 30);
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_COLOR_PARAM(bgColor);

	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(drawScale, 0.05, 1.0);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(xOffset, 0, ofGetWidth() * 3.5);

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
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(bgRem.numBlur, 0, 5);

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
	OFX_REMOTEUI_SERVER_SET_NEW_COLOR_N(2);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.cropLeft,0,1);
	OFX_REMOTEUI_SERVER_SHARE_PARAM(gs.cropRight,0,1);

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
	recalcNow = false;
	lastPhotoPath = "canonSDKImages/IMG_5205.JPG";
	calcWhiteBg(lastPhotoPath);

}


//--------------------------------------------------------------
void testApp::update(){

	float dt = 1./60.;
	if(timeSample) TIME_SAMPLE_ENABLE();
	else TIME_SAMPLE_DISABLE();


	photoAnimation.update(dt);

	TIME_SAMPLE_START("canon");
	cam->update();
	imageShowCounter -= dt;
	TIME_SAMPLE_STOP("canon");

	TIME_SAMPLE_START("grabber");
	grabber.update();
	TIME_SAMPLE_STOP("grabber");

	if(recalcNow){
		calcWhiteBg(lastPhotoPath);
		recalcNow = false;
	}

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

	float photoAlpha = photoAnimation.val() * 255;

	ofSetColor(255);
	if(!debugMasks){
		ofSetColor(255, 255 - photoAlpha);
		livePreviewFbo.draw(x,y,ww,hh);
		if(photoAlpha > 0.0){
			ofSetColor(255, photoAlpha);
			photoFbo.draw(x, y, ww, hh);
		}
		ofSetColor(255);
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

	if(debugMasks){
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


void testApp::calcWhiteBg(string path){
	TIME_SAMPLE_START("whiteBG");
	ofImage photoTaken;
	photoTaken.loadImage(path);
	cameraMasked = bgRem.removeBg(photoTaken);
	TIME_SAMPLE_STOP("whiteBG");

}

void testApp::photoWasDownloaded(char* path){

	printf("photo downloaded!!!!%s\n", path);
	ofFile f;
	f.open(path);
	lastPhotoPath = path;
	if (f.exists()) {
		loaded = true;
		calcWhiteBg(lastPhotoPath);
		photoAnimation.animateTo(1);
		imageShowCounter = photoShowTime;
	}
}


//--------------------------------------------------------------
void testApp::keyPressed(int key){

	switch ( key ) {

		case 't':{
			cam->takePictureThreaded();
		}break;

		case '1':{
			recalcNow = true;
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

		case 's': imageShowCounter = 0; break;

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

	cam->takePictureThreaded();
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

#include "CanonCameraWrapper.h"
#include "testApp.h"

//---------------------------------------------------------------------
CanonCameraWrapper::CanonCameraWrapper( testApp * delegate_ ){
	
	delegate = delegate_;
	theCamera               = NULL;
	theCameraList           = NULL;

	bDeleteAfterDownload    = false;
	needToOpen              = false;
	registered              = false;
	downloadEnabled         = true;

	lastImageName           = "";
	lastImagePath           = "";

	evfMode                 = 0;
	device                  = kEdsEvfOutputDevice_TFT;
	liveViewFocusMode		= Evf_AFMode_Live;

	livePixels              = NULL;
	livePixelsWidth         = 0;
	livePixelsHeight        = 0;

	resetLiveViewFrameCount();

	state = CAMERA_UNKNOWN;
	
	liveViewImage.allocate( CANON_LIVEVIEW_W, CANON_LIVEVIEW_H, OF_IMAGE_COLOR);
	
	liveViewT = new ThreadedLiveView( this );
	takePictT = new ThreadedTakePicture( this );
	focusT = new ThreadedFocus( this );
	
	printf("Allocate CanonCameraWrapper;\n");
}


//---------------------------------------------------------------------
CanonCameraWrapper::~CanonCameraWrapper(){
	destroy();
}


void CanonCameraWrapper::update(){
	//printf("liveView: %d %d\n",canonSLR->getLiveViewPixelWidth(), canonSLR->getLiveViewPixelHeight() );
	
	if ( liveViewT->isThreadRunning() ){
		if ( isLiveViewPixels() && liveViewT->freshPixelsAvailable() ){
			memcpy( liveViewImage.getPixels(), getLiveViewPixels(), CANON_LIVEVIEW_W * CANON_LIVEVIEW_H * 3 ) ;			
			liveViewImage.update();
		}
	}
}


//---------------------------------------------------------------------
//
//  SDK AND SESSION MANAGEMENT
//
//---------------------------------------------------------------------

//---------------------------------------------------------------------
int CanonCameraWrapper::setup(int cameraID){
	
	if( theCamera != NULL || theCameraList != NULL){
		destroy();
	}

	EdsError err = EDS_ERR_OK;
	EdsUInt32 cameraCount = 0 ;

	err = EdsInitializeSDK();

	if(err != EDS_ERR_OK){
	   printf("Couldn't open sdk!\n");
		return CANT_INIT_SDK_ERROR;
	}else{
		printf("Opening the sdk\n");
		sdkRef++;
	}

	// Initialize
	// Get the camera list
	err = EdsGetCameraList(&theCameraList);

	// Get the number of cameras.
	if( err == EDS_ERR_OK ){
		err = EdsGetChildCount( theCameraList, &cameraCount );
		if ( cameraCount == 0 ){
			err = EDS_ERR_DEVICE_NOT_FOUND;
			printf("No devices found!\n");
			return NO_CAMERA_ERROR;
		}
	}else{
		printf("Cant get camera list");
		return NO_CAMERA_LIST_ERROR;
	}

	// Get the camera
	if ( err == EDS_ERR_OK ){
		if (cameraID >= cameraCount){
			printf("No camera of id %i exists - number of cameras is %i\n", cameraID, cameraCount);
			return REQUESTED_CAMERA_NOT_FOUND_ERROR;
		}

		printf("We are opening camera %i!\n", cameraID);

		err = EdsGetChildAtIndex( theCameraList , cameraID , &theCamera );
		if(err == EDS_ERR_OK){
			printf("We are connected!\n");
			state = CAMERA_READY;
			return NO_ERROR;
		}else{
			printf("We are not connected!\n");
			state = CAMERA_UNKNOWN;
			return CANT_CONNECT_TO_CAMERA_ERROR;
		}
	}
}


//---------------------------------------------------------------------
void CanonCameraWrapper::destroy(){
	if( theCamera != NULL){
		closeSession();
	}

	easyRelease(theCamera);
	easyRelease(theCameraList);

	if( sdkRef > 0 ){
		sdkRef--;
		if( sdkRef == 0 ){
			EdsTerminateSDK();
			printf("Terminating the sdk\n");
		}
	}
}


//---------------------------------------------------------------------
int CanonCameraWrapper::openSession(){
	EdsError err = EDS_ERR_OK;
	
	if(err == EDS_ERR_OK){
		printf("We are opening session!\n");
		state = CAMERA_OPEN;
		registerCallback();
		
		err = EdsOpenSession( theCamera );
		return NO_ERROR;
	}
	else{
		printf("We failed at opening session!\n");
	}
	return CANT_OPEN_SESSION_ERROR;
}


//set image quality 
bool CanonCameraWrapper::setImageSizeAndQuality(){

	EdsError err = EDS_ERR_OK;
	EdsUInt32 size_quality = 0x02120f0f;
	//0x00120f0f 	//large low		180 ms to transfer
	//0x01120f0f 	//med  low		98 ms to transfer
	//0x02120f0f	//small low		48 ms to transfer
							
	err = EdsSetPropertyData(theCamera, kEdsPropID_ImageQuality, 0, sizeof(size_quality), &size_quality);

	return err == EDS_ERR_OK;;
}


//set image quality 
bool CanonCameraWrapper::setAFMode(){

	EdsError err = EDS_ERR_OK;
	EdsUInt32 afMode = 0;
	//0 One-Shot AF 
 	//1 AI Servo AF 
 	//2 AI Focus AF 
							
	err = EdsSetPropertyData(theCamera, kEdsPropID_AFMode, 0, sizeof(afMode), &afMode);

	return err == EDS_ERR_OK;;
}



//---------------------------------------------------------------------
bool CanonCameraWrapper::closeSession(){
	if( state == CAMERA_CLOSED)return false;
	EdsError err = EDS_ERR_OK;

	err = EdsCloseSession( theCamera );
	if(err == EDS_ERR_OK){
		printf("We are closing session!\n");
		state = CAMERA_CLOSED;
		return true;
	}
	else{
		printf("We failed at closing session!\n");
	}
	return false;
}


//---------------------------------------------------------------------
//
//  CONFIG
//
//---------------------------------------------------------------------

//---------------------------------------------------------------------
void CanonCameraWrapper::setDeleteFromCameraAfterDownload(bool deleteAfter){
	bDeleteAfterDownload = deleteAfter;
}


//---------------------------------------------------------------------
void CanonCameraWrapper::setDownloadPath(string downloadPathStr){
	downloadPath = downloadPathStr;
	if( downloadPath != "" ){
		if(downloadPath[ downloadPath.length()-1 ] != '/' ){
			downloadPath  = downloadPath + "/";
		}
	}
}

//--------------------------------------------------------------------
void CanonCameraWrapper::enableDownloadOnTrigger(){
	downloadEnabled = true;
}

//--------------------------------------------------------------------
void CanonCameraWrapper::disableDownloadOnTrigger(){
	downloadEnabled = false;
}

//---------------------------------------------------------------------
//
//  ACTIONS
//
//---------------------------------------------------------------------

//---------------------------------------------------------------------
bool CanonCameraWrapper::takePictureThreaded(){
	takePictT->start();	
	return true;	//TODO!
}


void CanonCameraWrapper::focusThreaded(){
	focusT->start();
}


bool CanonCameraWrapper::startFocus(){
	
	EdsError err = EDS_ERR_OK;
	err = EdsSendCommand( theCamera , kEdsCameraCommand_DoEvfAf, kEdsCameraCommand_EvfAf_ON);
	
	if(err == EDS_ERR_OK){
		return true;	
	}else{
		printf("start focus ERR (%u) ", err);
	}
	return false;
}


bool CanonCameraWrapper::stopFocus(){
	
	EdsError err = EDS_ERR_OK;
	err = EdsSendCommand( theCamera , kEdsCameraCommand_DoEvfAf, kEdsCameraCommand_EvfAf_OFF);
	
	if(err == EDS_ERR_OK){
		return true;
	}else{
		printf("stop focus ERR (%u) ", err);
	}
	return false;
}


//---------------------------------------------------------------------
//
//  LIVE VIEW
//
//---------------------------------------------------------------------

/*

bool beginLiveView();                   //starts live view
bool endLiveView();                     //ends live view

bool grabPixelsFromLiveView();           //capture the live view to rgb pixel array
bool saveImageFromLiveView(string saveName);

bool getLiveViewActive();               //true if live view is enabled
int getLiveViewFrameNo();               //returns the number of live view frames passed
void resetLiveViewFrameCount();         //resets to 0

bool isLiveViewPixels();                //true if there is captured pixels
int getLiveViewPixelWidth();            //width of live view pixel data
int getLiveViewPixelHeight();           //height of live view pixel data
unsigned char * getLiveViewPixels();    //returns captured pixels

*/

//---------------------------------------------------------------------
bool CanonCameraWrapper::beginLiveView(){

printf("Begining live view\n");

preCommand();
		
	EdsError err = EDS_ERR_OK;

	if(evfMode == 0){
		evfMode = 1;
		// Set to the camera.
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_Mode, 0, sizeof(evfMode), &evfMode);
	}

	if( err == EDS_ERR_OK){
		// Set focus mode!
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_AFMode, 0, sizeof(liveViewFocusMode), &liveViewFocusMode);
	}
	
	EdsUInt32 device; 
	err = EdsGetPropertyData(theCamera, kEdsPropID_Evf_OutputDevice,  0  , sizeof(device), &device ); 
		
	// PC live view starts by setting the PC as the output device for the live view image. 
	if(err == EDS_ERR_OK) { 
		device |= kEdsEvfOutputDevice_PC; 
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_OutputDevice, 0 , sizeof(device), &device); 
	} 

	//Notification of error
	if(err != EDS_ERR_OK){
		// It doesn't retry it at device busy
		if(err == EDS_ERR_DEVICE_BUSY){
			printf("BeginLiveView - device is busy\n");
		}else{
			printf("BeginLiveView - device is busy\n");
		}
		return false;
	}
	
	//todo fix return mess
	liveViewT->start(); //Start liveViewThread
	return true;
}

//---------------------------------------------------------------------
bool CanonCameraWrapper::endLiveView(){
	printf("Ending live view\n");

	liveViewT->stop();	//Stop liveViewThread
	
	EdsError err = EDS_ERR_OK; 

	evfMode = 0;
	// Get the output device for the live view image 
	EdsUInt32 device; 
	err = EdsGetPropertyData(theCamera, kEdsPropID_Evf_OutputDevice,  0 ,  sizeof(device), &device ); 

	// PC live view ends if the PC is disconnected from the live view image output device. 
	if(err == EDS_ERR_OK) { 
		device &= ~kEdsEvfOutputDevice_PC; 
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_OutputDevice, 0 , sizeof(device), &device); 
	}			

/*
	EdsError err = EDS_ERR_OK;

	if( err == EDS_ERR_OK){
		// Set the PC as the current output device.
		device = kEdsEvfOutputDevice_TFT;

		// Set to the camera.
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_OutputDevice, 0, sizeof(device), &device);
	}

	if(evfMode == 1){
		printf("stopit!\n");
		evfMode = 0;
		// Set to the camera.
		err = EdsSetPropertyData(theCamera, kEdsPropID_Evf_Mode, 0, sizeof(evfMode), &evfMode);
	}
*/
	bool success = true;

	//Notification of error
	if(err != EDS_ERR_OK){
		// It doesn't retry it at device busy
		if(err == EDS_ERR_DEVICE_BUSY){
			printf("EndLiveView - device is busy\n");
			//CameraEvent e("DeviceBusy");
			//_model->notifyObservers(&e);
		}else{
			printf("EndLiveView - device is busy\n");
		}
		success = false;
	}

	//postCommand();

	return success;
}

//---------------------------------------------------------------------
bool CanonCameraWrapper::grabPixelsFromLiveView(int rotateByNTimes90){
	EdsError err                = EDS_ERR_OK;
	EdsEvfImageRef evfImage     = NULL;
	EdsStreamRef stream         = NULL;
	EdsUInt32 bufferSize        = CANON_LIVEVIEW_W * CANON_LIVEVIEW_H * 3; //CRAPPY!

	bool success = false;

	if( evfMode == 0 ){
		printf("grabPixelsFromLiveView - live view needs to be enabled first\n");
		return false;
	}

	// Create memory stream.
	err = EdsCreateMemoryStream(bufferSize, &stream);

	// Create EvfImageRef.
	if (err == EDS_ERR_OK){
		err = EdsCreateEvfImageRef(stream, &evfImage);
	}else
		printf("a.\n");

	// Download live view image data.
	if (err == EDS_ERR_OK){
		err = EdsDownloadEvfImage(theCamera, evfImage);
	}else
		printf("b.\n");

	if (err == EDS_ERR_OK){
	   // printf("Got live view frame %i \n", liveViewCurrentFrame);
		liveViewCurrentFrame++;

		EdsUInt32 length;
		EdsGetLength(stream, &length);

		if( length > 0 ){

			unsigned char * ImageData;
			EdsUInt32 DataSize = length;

			EdsGetPointer(stream,(EdsVoid**)&ImageData);
			EdsGetLength(stream, &DataSize);

			memoryImage convertor;
			if( convertor.loadFromMemory((int)DataSize, ImageData, rotateByNTimes90) ){

				int imageWidth  = convertor.width;
				int imageHeight = convertor.height;
				//cout << "grabPixelsFromLiveView width: " << imageWidth << "  height: " << imageHeight << endl;

				if( imageWidth > 0 && imageHeight > 0 ){

					if( livePixels == NULL || ( livePixelsWidth != imageWidth || livePixelsHeight != imageHeight ) ){
						if( livePixels != NULL )delete[] livePixels;
						livePixels          = new unsigned char[imageWidth * imageHeight * 3];
						livePixelsWidth     = imageWidth;
						livePixelsHeight    = imageHeight;
					}

					unsigned char * pix = convertor.getPixels();

					int numToCopy = imageWidth * imageHeight * 3;
					for(int i = 0; i < numToCopy; i++){
						livePixels[i] = pix[i];
					}

					//printf("Live view frame converted to pixels\n");
					success = true;

				}else{
					printf("unable to convert the memory stream! width and height 0 \n");
				}
			}else{
				printf("Unable to load from memory\n");
			}
		}
	}

	easyRelease(stream);
	easyRelease(evfImage);

	//Notification of error
	if(err != EDS_ERR_OK){
		if(err == EDS_ERR_OBJECT_NOTREADY){
			printf("grabPixelsFromLiveView - not ready... sleeping a bit\n");
		}else if(err == EDS_ERR_DEVICE_BUSY){
			printf("grabPixelsFromLiveView - device is busy\n");
		}
		else{
			printf("saveImageFromLiveView - some other error\n");
		}
		return false;
	}

	return success;
}

//---------------------------------------------------------------------
bool CanonCameraWrapper::saveImageFromLiveView(string saveName){
	EdsError err                = EDS_ERR_OK;
	EdsEvfImageRef evfImage     = NULL;
	EdsStreamRef stream         = NULL;

	if( evfMode == 0 ){
		printf("Live view needs to be enabled first\n");
		return false;
	}

	//save the file stream to disk
	err = EdsCreateFileStream( ( ofToDataPath(saveName) ).c_str(), kEdsFileCreateDisposition_CreateAlways, kEdsAccess_ReadWrite, &stream);

	// Create EvfImageRef.
	if (err == EDS_ERR_OK){
		err = EdsCreateEvfImageRef(stream, &evfImage);
	}

	// Download live view image data.
	if (err == EDS_ERR_OK){
		err = EdsDownloadEvfImage(theCamera, evfImage);
	}

	if (err == EDS_ERR_OK){
	   // printf("Got live view frame %i \n", liveViewCurrentFrame);
		liveViewCurrentFrame++;
	}

	easyRelease(stream);
	easyRelease(evfImage);

	//Notification of error
	if(err != EDS_ERR_OK){
		if(err == EDS_ERR_OBJECT_NOTREADY){
			printf("saveImageFromLiveView - not ready\n");
		}else if(err == EDS_ERR_DEVICE_BUSY){
			printf("saveImageFromLiveView - device is busy\n");
		}
		else{
			printf("saveImageFromLiveView - some other error\n");
		}
		return false;
	}

	return true;
}

//---------------------------------------------------------------------
bool CanonCameraWrapper::getLiveViewActive(){
	return evfMode;
}

//---------------------------------------------------------------------
int CanonCameraWrapper::getLiveViewFrameNo(){
	return liveViewCurrentFrame;
}

//---------------------------------------------------------------------
void CanonCameraWrapper::resetLiveViewFrameCount(){
	liveViewCurrentFrame = 0;
}

//---------------------------------------------------------------------
bool CanonCameraWrapper::isLiveViewPixels(){
	return (livePixels != NULL);
}

bool CanonCameraWrapper::isCameraSendingPixels(){
	return liveViewT->cameraIsSendingPixels();
}

//---------------------------------------------------------------------
int CanonCameraWrapper::getLiveViewPixelWidth(){
	return livePixelsWidth;
}

//--------------------------------------------------------------------
int CanonCameraWrapper::getLiveViewPixelHeight(){
	return livePixelsHeight;
}

//---------------------------------------------------------------------
unsigned char * CanonCameraWrapper::getLiveViewPixels(){
	return livePixels;
}

void CanonCameraWrapper::setFocusModeToQuick(){ 
	liveViewFocusMode = Evf_AFMode_Quick;
};


void CanonCameraWrapper::setFocusModeToLive(){ 
	liveViewFocusMode = Evf_AFMode_Live;
};


void CanonCameraWrapper::setFocusModeToLiveFace(){ 
	liveViewFocusMode = Evf_AFMode_LiveFace;
};



//---------------------------------------------------------------------
//
//  MISC EXTRA STUFF
//
//---------------------------------------------------------------------

//---------------------------------------------------------------------
string CanonCameraWrapper::getLastImageName(){
	return lastImageName;
}

//---------------------------------------------------------------------
string CanonCameraWrapper::getLastImagePath(){
	return lastImagePath;
}

//This doesn't work perfectly - for some reason it can be one image behind
//something about how often the camera updates the SDK.
//Having the on picture event registered seems to help.
//But downloading via event is much more reliable at the moment.

//---------------------------------------------------------------------
bool CanonCameraWrapper::downloadLastImage(){
	preCommand();

	EdsVolumeRef 		theVolumeRef	    = NULL ;
	EdsDirectoryItemRef	dirItemRef_DCIM	    = NULL;
	EdsDirectoryItemRef	dirItemRef_Sub	    = NULL;
	EdsDirectoryItemRef	dirItemRef_Image    = NULL;

	EdsDirectoryItemInfo dirItemInfo_Image;

	EdsError err    = EDS_ERR_OK;
	EdsUInt32 Count = 0;
	bool success    = false;

	//get the number of memory devices
	err = EdsGetChildCount( theCamera, &Count );
	if( Count == 0 ){
		printf("Memory device not found\n");
		err = EDS_ERR_DEVICE_NOT_FOUND;
		return false;
	}

	// Download Card No.0 contents
	err = EdsGetChildAtIndex( theCamera, 0, &theVolumeRef );
//        if ( err == EDS_ERR_OK ){
//            printf("getting volume info\n");
//            //err = EdsGetVolumeInfo( theVolumeRef, &volumeInfo ) ;
//        }

	//Now lets find out how many Folders the volume has
	if ( err == EDS_ERR_OK ){
		err = EdsGetChildCount( theVolumeRef, &Count );

		if ( err == EDS_ERR_OK ){

			//Lets find the folder called DCIM
			bool bFoundDCIM = false;
			for(int i = 0; i < Count; i++){
				err = EdsGetChildAtIndex( theVolumeRef, i, &dirItemRef_DCIM ) ;
				if ( err == EDS_ERR_OK ){
					EdsDirectoryItemInfo dirItemInfo;
					err = EdsGetDirectoryItemInfo( dirItemRef_DCIM, &dirItemInfo );
					if( err == EDS_ERR_OK){
						string folderName = dirItemInfo.szFileName;
						if( folderName == "DCIM" ){
							bFoundDCIM = true;
							printf("Found the DCIM folder at index %i\n", i);
							break;
						}
					}
				}
				//we want to release the directories that don't match
				easyRelease(dirItemRef_DCIM);
			}

			//This is a bit silly.
			//Essentially we traverse into the DCIM folder, then we go into the last folder in there, then we
			//get the last image in last folder.
			if( bFoundDCIM && dirItemRef_DCIM != NULL){
				//now we are going to look for the last folder in DCIM
				Count = 0;
				err = EdsGetChildCount(dirItemRef_DCIM, &Count);

				bool foundLastFolder = false;
				if( Count > 0 ){
					int lastIndex = Count-1;

					EdsDirectoryItemInfo dirItemInfo_Sub;

					err = EdsGetChildAtIndex( dirItemRef_DCIM, lastIndex, &dirItemRef_Sub ) ;
					err = EdsGetDirectoryItemInfo( dirItemRef_Sub, &dirItemInfo_Sub);

					printf("Last Folder is %s \n", dirItemInfo_Sub.szFileName);

					EdsUInt32 jpgCount = 0;
					err = EdsGetChildCount(dirItemRef_Sub, &jpgCount );

					if( jpgCount > 0 ){
						int latestJpg = jpgCount-1;

						err = EdsGetChildAtIndex(dirItemRef_Sub, latestJpg, &dirItemRef_Image ) ;
						err = EdsGetDirectoryItemInfo(dirItemRef_Image, &dirItemInfo_Image);

						printf("Latest image is %s \n", dirItemInfo_Image.szFileName);
						success = true;
					}else{
						printf("Error - No jpegs inside %s\n", dirItemInfo_Image.szFileName);
					}
				}else{
					printf("Error - No subfolders inside DCIM!\n");
				}
			}
		}
	}
	if( success ){
		//success = downloadImage(dirItemRef_Image);
	}

	easyRelease(theVolumeRef);
	easyRelease(dirItemRef_DCIM);
	easyRelease(dirItemRef_Sub);
	easyRelease(dirItemRef_Image);

	postCommand();

	return success;
}

//Hmm - might be needed for threading
//---------------------------------------------------------------------
bool CanonCameraWrapper::isTransfering(){
	return false;
}





//PROTECTED FUNCTIONS

//---------------------------------------------------------------------
bool CanonCameraWrapper::downloadImage(EdsDirectoryItemRef directoryItem){
	if( !downloadEnabled ) return false;

	EdsError err = EDS_ERR_OK;
	EdsStreamRef stream = NULL;
	EdsDirectoryItemInfo dirItemInfo;

	bool success = false;
	string imageName;
	string imagePath;

	int timeStart = ofGetElapsedTimeMillis();

	err = EdsGetDirectoryItemInfo(directoryItem, &dirItemInfo);
	if(err == EDS_ERR_OK){

		imageName = dirItemInfo.szFileName;
		imagePath = downloadPath + imageName;

		printf("Downloading image %s to %s\n", imageName.c_str(), imagePath.c_str());
		err = EdsCreateFileStream( ofToDataPath( imagePath ).c_str(), kEdsFileCreateDisposition_CreateAlways, kEdsAccess_ReadWrite, &stream);
	}else
		printf("ERROR Downloading image\n");

	if(err == EDS_ERR_OK){
		err = EdsDownload( directoryItem, dirItemInfo.size, stream);
	}

	if(err == EDS_ERR_OK){

		lastImageName = imageName;
		lastImagePath = imagePath;

		printf("Image downloaded in %ims\n", ofGetElapsedTimeMillis()-timeStart);

		err = EdsDownloadComplete(directoryItem);
		if( bDeleteAfterDownload ){
			EdsDeleteDirectoryItem(directoryItem);
			printf("Image deleted\n");
		}
		success = true;
		delegate->photoWasDownloaded( (char*)imagePath.c_str() );	//inform our delegate tgat the pict is ready
	}

	easyRelease(stream);
	return success;
}


//------------------------------------------------------------------------
EdsError EDSCALLBACK CanonCameraWrapper::handleStatusEvent(EdsObjectEvent event, EdsUInt32 object, EdsVoid *context) {
		
	EdsError err = EDS_ERR_OK;
	
	switch (event) {

		case kEdsStateEvent_Shutdown:
			printf("kEdsStateEvent_Shutdown!!! CAMERA IS OFF! \n");
			break;

		case kEdsStateEvent_ShutDownTimerUpdate:
			printf("kEdsStateEvent_ShutDownTimerUpdate!!! \n");
			break;
			
		case kEdsStateEvent_InternalError:
			printf("kEdsStateEvent_InternalError!!!\n");
			break;
			
		case kEdsStateEvent_JobStatusChanged:
			printf("kEdsStateEvent_JobStatusChanged!!! \n");
			break;
			
		case kEdsStateEvent_WillSoonShutDown:{
			

			printf("kEdsStateEvent_WillSoonShutDown!!! (%u)\n", object);
			CanonCameraWrapper * ptr = (CanonCameraWrapper *)context;
			err = EdsSendCommand( *ptr->camera(), kEdsCameraCommand_ExtendShutDownTimer, 0);
			if(err == EDS_ERR_OK){
				printf("Extended Camera powerOff timer ok\n");
			}else{
				printf("Extended Camera powerOff timer KO! (%l)\n", err);
			}
		}
			break;
			
		case kEdsStateEvent_CaptureError:
			printf("kEdsStateEvent_CaptureError (cant focus?)\n");
			break;
			
		case kEdsStateEvent_AfResult:
			printf("kEdsStateEvent_AfResult (%u)\n", object);
			break;

		default:  printf("Undefined State Callback! %i\n", (int)event); 
			break;
	}
		
	return EDS_ERR_OK;
}

//------------------------------------------------------------------------
EdsError EDSCALLBACK CanonCameraWrapper::handleObjectEvent(EdsObjectEvent event, EdsBaseRef object, EdsVoid *context) {
   
	switch (event) {
			
		case kEdsObjectEvent_VolumeInfoChanged:
			printf("kEdsObjectEvent_VolumeInfoChanged!!! \n");
			break;

		case kEdsObjectEvent_DirItemContentChanged:
			printf("kEdsObjectEvent_DirItemContentChanged!\n");
			break;

		case kEdsObjectEvent_DirItemRequestTransferDT:
			printf("kEdsObjectEvent_DirItemRequestTransferDT!\n");
			break;

		case kEdsObjectEvent_DirItemCreated:
		{					
			printf("kEdsObjectEvent_DirItemCreated!\n");
			CanonCameraWrapper * ptr = (CanonCameraWrapper *)context;
			ptr->downloadImage(object);
			break;
		}
			

		case kEdsObjectEvent_FolderUpdateItems:
			printf("kEdsObjectEvent_FolderUpdateItems!\n");
			break;

		case kEdsObjectEvent_DirItemRemoved:
			printf("kEdsObjectEvent_DirItemRemoved!\n");
			break;

		case kEdsObjectEvent_VolumeUpdateItems:
			printf("kEdsObjectEvent_VolumeUpdateItems!\n");
			break;

		case kEdsObjectEvent_DirItemRequestTransfer:
			printf("kEdsObjectEvent_DirItemRequestTransfer!\n");
			break;

		default: printf("Undefined Object Callback! %i\n", (int)event);
			break;
	}
	
	return EDS_ERR_OK;
}

//----------------------------------------------------------------------------
void CanonCameraWrapper::registerCallback(){
	if( registered == false){
		EdsSetObjectEventHandler(theCamera, kEdsObjectEvent_All, handleObjectEvent, this);
		EdsSetCameraStateEventHandler(theCamera, kEdsStateEvent_All, handleStatusEvent, this);
	}
	registered = true;
}


//PRE AND POST COMMAND should be used at the begining and the end of camera interaction functions
//EG: taking a picture or starting / ending live view.
//
//They check if their is an open session to the camera and if there isn't they create a session
//postCommand closes any sessions created by preCommand
//
// eg:
// preCommand
// takePicture
// postCommand
//---------------------------------------------------------------------
bool CanonCameraWrapper::preCommand(){

	printf("pre command \n");

	if( state > CAMERA_UNKNOWN ){
		needToOpen = false;
		int reply  = NO_ERROR;

		if( state != CAMERA_OPEN ){
			needToOpen = true;
		}else{
			reply = NO_ERROR;
			return NO_ERROR;
		}

		if( needToOpen ){
			reply = openSession();
		}

		return reply;

	}else{
		return UNKNOWN_STATE_ERROR;
	}

}

//---------------------------------------------------------------------
void CanonCameraWrapper::postCommand(){
	printf("post command \n");

	if(state == CAMERA_OPEN && needToOpen){
		closeSession();
	}
}

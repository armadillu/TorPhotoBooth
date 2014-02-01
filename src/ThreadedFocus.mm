#include "ThreadedFocus.h"


ThreadedFocus::ThreadedFocus( CanonCameraWrapper * wrap_){
	wrap = wrap_;
}

void ThreadedFocus::start(){
	startThread(false, false);   // blocking, verbose
}

void ThreadedFocus::stop(){
	stopThread();
}
	
//--------------------------
void ThreadedFocus::threadedFunction(){
	
	bool ok = startFocus();
	if(ok == true)
		printf("startFocus() ok %l\n");
	else
		printf("startFocus() KO!!!!!\n");
	
	
	ofSleepMillis( 1200 );

//	ok = stopFocus();
//	if(ok == true)
//		printf("stopFocus() ok %l\n");
//	else
//		printf("stopFocus() KO!!!!!\n");
//
//	printf("Ending FocusThread\n");
	stopThread();
}


bool ThreadedFocus::startFocus(){
	
	EdsError err = EDS_ERR_OK;
	//err = EdsSendCommand( *wrap->camera() , kEdsCameraCommand_DoEvfAf, kEdsCameraCommand_EvfAf_ON);
	err = EdsSendCommand( *wrap->camera() , kEdsCameraCommand_DoEvfAf, Evf_AFMode_Live);
	
	if(err == EDS_ERR_OK){
		return true;	
	}else{
		printf("start focus ERR (%u) ", err);
	}
	return false;
}


bool ThreadedFocus::stopFocus(){
	
	EdsError err = EDS_ERR_OK;
	//err = EdsSendCommand( *wrap->camera() , kEdsCameraCommand_DoEvfAf, kEdsCameraCommand_EvfAf_OFF);
	
	if(err == EDS_ERR_OK){
		return true;
	}else{
		printf("stop focus ERR (%u) ", err);
	}
	return false;
}

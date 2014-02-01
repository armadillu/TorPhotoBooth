#include "ThreadedLiveView.h"



ThreadedLiveView::ThreadedLiveView( CanonCameraWrapper * wrap_){
	wrap = wrap_;
	success = false;
}


void ThreadedLiveView::start(){
	success = false;
	startThread(false, false);   // blocking, verbose
}


void ThreadedLiveView::stop(){
	stopThread();
	success = false;
}


bool ThreadedLiveView::freshPixelsAvailable(){
	if (fresh){
		fresh = false;
		return true;
	}
	return false;
}


bool ThreadedLiveView::cameraIsSendingPixels(){
	return success;
}


void ThreadedLiveView::threadedFunction(){

	while( isThreadRunning() != 0 ){
		
		if( lock() ){
			
			success = wrap->grabPixelsFromLiveView(0);
			
			if (!success){
				ofSleepMillis(900);
			}else{
				fresh = true;
				ofSleepMillis(42);
			}
			
			unlock();
		}
	}
	success = false;
}

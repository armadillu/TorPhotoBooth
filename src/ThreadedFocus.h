#ifndef _THREADED_OBJECT3
#define _THREADED_OBJECT3

#include "ofMain.h"
#include "CanonCameraWrapper.h"
#include "EDSDK.h"
#include "EDSDKErrors.h"
#include "EDSDKTypes.h"



class CanonCameraWrapper;


class ThreadedFocus : public ofThread{

	public:

	CanonCameraWrapper * wrap;
	
	ThreadedFocus( CanonCameraWrapper * wrap_);
	
	void start();
	void stop();
	
	void threadedFunction();
	
    bool startFocus();
    bool stopFocus();

};	//close class {

#endif

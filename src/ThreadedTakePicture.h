#ifndef _THREADED_OBJECT2
#define _THREADED_OBJECT2

#include "ofMain.h"
#include "CanonCameraWrapper.h"
#include "EDSDK.h"
#include "EDSDKErrors.h"
#include "EDSDKTypes.h"


class CanonCameraWrapper;

class ThreadedTakePicture : public ofThread{

	public:

	CanonCameraWrapper * wrap;
	
	ThreadedTakePicture( CanonCameraWrapper * wrap_);
	void start();
	void stop();
	void threadedFunction();
	
};	//close class {

#endif

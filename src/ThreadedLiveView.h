#ifndef _THREADED_OBJECT
#define _THREADED_OBJECT

#include "ofMain.h"
#include "CanonCameraWrapper.h"
#include "EDSDK.h"
#include "EDSDKErrors.h"
#include "EDSDKTypes.h"


class CanonCameraWrapper;

class ThreadedLiveView : public ofThread{

	public:
	
		bool fresh;
		bool success;

		CanonCameraWrapper * wrap;

		
		ThreadedLiveView( CanonCameraWrapper * wrap_);
		
		void start();
		void stop();
		
		bool cameraIsSendingPixels();
		bool freshPixelsAvailable();
		void threadedFunction();
};

#endif

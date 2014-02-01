
#ifndef canonWrap_h
#define canonWrap_h


//Written by Theo Watson - theo@openframeworks.cc

//NOTE
//We are missing code for legacy devices
//We are missing some mac specific snippets
//Both should be easy to integrate

//You also need the Canon SDK which you can request from them or possibily find by other means floating around in the ether. 

#define __MACOS__

#include "CanonConstants.h"

#include "EDSDK.h"
#include "EDSDKErrors.h"
#include "EDSDKTypes.h"
//#include "testApp.h"			//this is ugly, replace with the class you want to be notified when a pciture is downloaded
class testApp;

#include "ThreadedLiveView.h"
#include "ThreadedTakePicture.h"
#include "ThreadedFocus.h"

#include "ofImage.h"
#include "FreeImage.h"
#include "ofPixels.h"


typedef enum{
    CAMERA_UNKNOWN,
    CAMERA_READY,
    CAMERA_OPEN,
    CAMERA_CLOSED,
}cameraState;


static int sdkRef = 0;

static void easyRelease(EdsBaseRef &ref){
    if(ref != NULL){
        EdsRelease(ref);
        ref = NULL;
    }
};

//duplicated code!! declared in ofImage.cpp, can't reach it!
template<typename PixelType>
void putBmpIntoPixels(FIBITMAP * bmp, ofPixels_<PixelType> &pix, bool swapForLittleEndian = true) {
	// some images use a palette, or <8 bpp, so convert them to raster 8-bit channels
	FIBITMAP* bmpConverted = NULL;
	if(FreeImage_GetColorType(bmp) == FIC_PALETTE || FreeImage_GetBPP(bmp) < 8) {
		if(FreeImage_IsTransparent(bmp)) {
			bmpConverted = FreeImage_ConvertTo32Bits(bmp);
		} else {
			bmpConverted = FreeImage_ConvertTo24Bits(bmp);
		}
		bmp = bmpConverted;
	}

	unsigned int width = FreeImage_GetWidth(bmp);
	unsigned int height = FreeImage_GetHeight(bmp);
	unsigned int bpp = FreeImage_GetBPP(bmp);
	unsigned int channels = (bpp / sizeof(PixelType)) / 8;
	unsigned int pitch = FreeImage_GetPitch(bmp);

	// ofPixels are top left, FIBITMAP is bottom left
	FreeImage_FlipVertical(bmp);

	unsigned char* bmpBits = FreeImage_GetBits(bmp);
	if(bmpBits != NULL) {
		pix.setFromAlignedPixels((PixelType*) bmpBits, width, height, channels, pitch);
	} else {
		ofLogError("ofImage") << "putBmpIntoPixels(): unable to set ofPixels from FIBITMAP";
	}

	if(bmpConverted != NULL) {
		FreeImage_Unload(bmpConverted);
	}

#ifdef TARGET_LITTLE_ENDIAN
	if(swapForLittleEndian && sizeof(PixelType) == 1) {
		pix.swapRgb();
	}
#endif
}



class memoryImage : public ofImage{

	public:
	
    bool loadFromMemory(int bytesToRead, unsigned char * jpegBytes, int rotateMode = 0){
        FIMEMORY *hmem = NULL;

        hmem = FreeImage_OpenMemory((unsigned char *)jpegBytes, bytesToRead);
        if (hmem == NULL){
            printf("couldn't create memory handle! \n");
            return false;
        }

        //get the file type!
        FREE_IMAGE_FORMAT fif = FreeImage_GetFileTypeFromMemory(hmem);
        if( fif == -1 ){
            printf("unable to guess format", fif);
            return false;
            FreeImage_CloseMemory(hmem);
        }

        //make the image!!
        FIBITMAP * tmpBmp = FreeImage_LoadFromMemory(fif, hmem, 0);

        if( rotateMode > 0 && rotateMode < 4){
            FIBITMAP * oldBmp = tmpBmp;

            if( rotateMode == 1)tmpBmp = FreeImage_RotateClassic(tmpBmp, 90);
            if( rotateMode == 2)tmpBmp = FreeImage_RotateClassic(tmpBmp, 180);
            if( rotateMode == 3)tmpBmp = FreeImage_RotateClassic(tmpBmp, 270);

            FreeImage_Unload(oldBmp);
        }

        //FreeImage_FlipVertical(tmpBmp);

        putBmpIntoPixels(tmpBmp, pixels);
        width 		= FreeImage_GetWidth(tmpBmp);
        height 		= FreeImage_GetHeight(tmpBmp);
        bpp 		= FreeImage_GetBPP(tmpBmp);

       // swapRgb(pixels);

        FreeImage_Unload(tmpBmp);
        FreeImage_CloseMemory(hmem);

        return true;
    }

    //shouldn't have to redefine this but a gcc bug means we do
    inline void	swapRgb(ofPixels &pix){
        if (pix.getBitsPerPixel() != 8){
            int sizePixels		= pix.getWidth() * pix.getHeight();
            int cnt				= 0;
            unsigned char temp;
            int byteCount		= pix.getBitsPerPixel()/8;

            while (cnt < sizePixels){
                temp					        = pix.getPixels()[cnt*byteCount];
                pix.getPixels()[cnt*byteCount]		= pix.getPixels()[cnt*byteCount+2];
                pix.getPixels()[cnt*byteCount+2]		= temp;
                cnt++;
            }
        }
    }

};

//NOTE
//We are missing code for legacy devices
//We are missing some mac specific snippets
//Both should be easy to integrate


class testApp;
class ThreadedTakePicture;
class ThreadedFocus;
class ThreadedLiveView;

class CanonCameraWrapper{

	public:
	
	void update();
	
 	//---------------------------------------------------------------------
    CanonCameraWrapper(testApp * delegate_);	//ohh I miss Objective-C, testApp will need to be replaced with some class type
    ~CanonCameraWrapper();

    //---------------------------------------------------------------------
    //  SDK AND SESSION MANAGEMENT
    //---------------------------------------------------------------------
    int setup(int cameraID);   //You must call this to init the canon sdk
    void destroy();             //To clean up - also called by destructor

    int openSession();         //Begins communication with camera
    bool closeSession();        //Ends communication with camera.
                                //Note on sessions: Commands like takePicture
                                //will open a session if none exists. This
                                //is slower though so consider calling it
                                //once at the begining of your app.

    //---------------------------------------------------------------------
    //  CONFIG
    //---------------------------------------------------------------------

    void setDeleteFromCameraAfterDownload(bool deleteAfter);
    void setDownloadPath(string downloadPathStr);
    void enableDownloadOnTrigger();     //Trigger meaning takePicture
    void disableDownloadOnTrigger();    //Trigger meaning takePicture

    //---------------------------------------------------------------------
    //  ACTIONS
    //---------------------------------------------------------------------
    bool takePictureThreaded();   	//Takes a picture. If enabled it will also download
                          			//the image to the folder set by the download path.

	void focusThreaded();			//puts camera in focus 
	bool setImageSizeAndQuality();	//setImageSize
	bool setAFMode();
	
    //---------------------------------------------------------------------
    //  LIVE VIEW
    //---------------------------------------------------------------------

    bool beginLiveView();                   //starts live view
    bool endLiveView();                     //ends live view

    bool grabPixelsFromLiveView(int rotateByNTimes90 = 0); //capture the live view to rgb pixel array
    bool saveImageFromLiveView(string saveName);

    bool getLiveViewActive();               //true if live view is enabled
    int getLiveViewFrameNo();               //returns the number of live view frames passed
    void resetLiveViewFrameCount();         //resets to 0

    bool isLiveViewPixels();                //true if there is captured pixels
    int getLiveViewPixelWidth();            //width of live view pixel data
    int getLiveViewPixelHeight();           //height of live view pixel data
    unsigned char * getLiveViewPixels();    //returns captured pixels
	ofImage * getLiveViewImage(){return &liveViewImage;};
	bool isCameraSendingPixels();
	
	//set any of those those BEFORE starting live view for focus to work as u want during live view
	void setFocusModeToQuick();
	void setFocusModeToLive();
	void setFocusModeToLiveFace();

    //---------------------------------------------------------------------
    //  MISC EXTRA STUFF
    //---------------------------------------------------------------------

    string getLastImageName();  //The full path of the last downloaded image
    string getLastImagePath();  //The name of the last downloaded image

    //This doesn't work perfectly - for some reason it can be one image behind
    //something about how often the camera updates the SDK.
    //Having the on picture event registered seems to help.
    //But downloading via event is much more reliable at the moment.

    //WARNING - If you are not taking pictures and you have bDeleteAfterDownload set to true
    //you will be deleting the files that are on the camera.
    //Simplified: be careful about calling this when you haven't just taken a photo.
    bool downloadLastImage();

    //Hmm - might be needed for threading - currently doesn't work
    bool isTransfering();


	EdsCameraRef* camera(){
		return &theCamera;
	}
	
    protected:
        //---------------------------------------------------------------------
        //  PROTECTED STUFF
        //---------------------------------------------------------------------

		bool startFocus();
		bool stopFocus();

	
		ThreadedLiveView * 		liveViewT;
		ThreadedTakePicture * 	takePictT;
		ThreadedFocus * 		focusT;
	
		ofImage					liveViewImage;

        bool downloadImage(EdsDirectoryItemRef directoryItem);
        static EdsError EDSCALLBACK handleObjectEvent(EdsObjectEvent event, EdsBaseRef object, EdsVoid *context);
		static EdsError EDSCALLBACK handleStatusEvent(EdsObjectEvent event, EdsUInt32 object, EdsVoid *context);
        void registerCallback();
        bool preCommand();
        void postCommand();

        int livePixelsWidth;
        int livePixelsHeight;
        unsigned char * livePixels;

        EdsUInt32 evfMode;
        EdsUInt32 device;
		EdsEvfAFMode liveViewFocusMode;

        int liveViewCurrentFrame;

        string lastImageName;
        string lastImagePath;
        string downloadPath;
        bool downloadEnabled;
        bool bDeleteAfterDownload;
        bool registered;
        bool needToOpen;

        cameraState state;	
        EdsCameraRef        theCamera ;
        EdsCameraListRef	theCameraList;
	
		testApp *			delegate;					////this is ugly, replace with the class you want to be notified when a pciture is downloaded

};


#endif
// // C++ Interface: Spider Monkey interface
//
// Description: 
//
//
// Author: Anish Mistry
//      Some modification by mean
//
// Copyright: See COPYING file that comes with this distribution
//
//
#include "config.h"

#include <math.h>

#include "ADM_default.h"
#include "ADM_JSAvidemux.h"
#include "avi_vars.h"
#include "DIA_coreToolkit.h"
#include "../ADM_userInterfaces/ADM_commonUI/GUI_ui.h"
#include "ADM_script/ADM_container.h"

#include "ADM_osSupport/ADM_debugID.h"
#define MODULE_NAME MODULE_SCRIPT
#include "ADM_osSupport/ADM_debug.h"

extern int A_openAvi (const char *name);
extern int A_Save (const char *name);
extern int A_appendAvi (const char *name);
extern uint8_t ogmSave(char *name);
extern int GUI_GoToFrame(uint32_t frame);
extern int filterLoadXml(const char *docname,uint8_t silent);
extern int A_delete(uint32_t start, uint32_t end);

extern uint8_t A_ListAllBlackFrames( char *file );
extern uint8_t A_jumpToTime(uint32_t hh,uint32_t mm,uint32_t ss,uint32_t ms);
extern uint8_t addFile(char *name);

uint8_t A_setContainer(const char *cont);
const char *getCurrentContainerAsString(void);

JSPropertySpec ADM_JSAvidemux::avidemux_properties[] = 
{ 

	{ "markerA", markerA_prop, JSPROP_ENUMERATE },	// set marker A
	{ "markerB", markerB_prop, JSPROP_ENUMERATE },	// set marker B
	{ "audio", audio_prop, JSPROP_ENUMERATE },	// audio object
	{ "video", video_prop, JSPROP_ENUMERATE },	// video object
	{ "container", container_prop, JSPROP_ENUMERATE },	// set container type
	{ "currentFrame", currentframe_prop, JSPROP_ENUMERATE },	// set current frame
	{ "fps", fps_prop, JSPROP_ENUMERATE },	// set movie frame rate
	{ 0 }
};

JSFunctionSpec ADM_JSAvidemux::avidemux_methods[] = 
{
	{ "append", Append, 1, 0, 0 },	// append video
	{ "delete", Delete, 2, 0, 0 },	// delete section
	{ "exit", Exit, 0, 0, 0 },	// exit Avidemux
	{ "load", Load, 1, 0, 0 },	// Load movie
	{ "loadFilters", LoadFilters, 1, 0, 0 },	// Load filters from file
	{ "save", Save, 1, 0, 0 },	// Save movie
/*	{ "saveDVD", SaveDVD, 1, 0, 0 },	// Save movie as DVD
	{ "saveOGM", SaveOGM, 1, 0, 0 },	// Save movie as OGM*/
        { "clearSegments", ClearSegments ,0,0,0}, // Clear all segments
        { "addSegment", AddSegment ,3,0,0}, // Clear all segments
	{ "goToTime", GoToTime, 3, 0, 0 },	// more current frame to time index
	{ "forceUnpack", forceUnpack, 0, 0, 0 },
        { "smartCopyMode", smartcopyMode, 0, 0, 0 },
        { "setContainer", setContainer, 1, 0, 0 },
        { "rebuildIndex", rebuildIndex, 0, 0, 0 },

	{ 0 }
};

JSClass ADM_JSAvidemux::m_classAvidemux = 
{
	"Avidemux", JSCLASS_HAS_PRIVATE,
	JS_PropertyStub, JS_PropertyStub,
	ADM_JSAvidemux::JSGetProperty, ADM_JSAvidemux::JSSetProperty,
	JS_EnumerateStub, JS_ResolveStub, 
	JS_ConvertStub, ADM_JSAvidemux::JSDestructor
};

ADM_JSAvidemux::~ADM_JSAvidemux(void)
{
	if(m_pObject != NULL)
		delete m_pObject;
	m_pObject = NULL;
}

void ADM_JSAvidemux::setObject(ADM_Avidemux *pObject)
{
	m_pObject = pObject; 
}
	
ADM_Avidemux *ADM_JSAvidemux::getObject()
{
	return m_pObject; 
}

JSObject *ADM_JSAvidemux::JSInit(JSContext *cx, JSObject *obj, JSObject *proto)
{
	JSObject *newObj = JS_InitClass(cx, obj, proto, &m_classAvidemux, 
									ADM_JSAvidemux::JSConstructor, 0,
									ADM_JSAvidemux::avidemux_properties, ADM_JSAvidemux::avidemux_methods,
									NULL, NULL);
	return newObj;
}

JSBool ADM_JSAvidemux::JSConstructor(JSContext *cx, JSObject *obj, uintN argc, 
								 jsval *argv, jsval *rval)
{
	if(argc != 0)
		return JS_FALSE;
	ADM_JSAvidemux *p = new ADM_JSAvidemux();
	ADM_Avidemux *pObject = new ADM_Avidemux();
	p->setObject(pObject);
	if ( ! JS_SetPrivate(cx, obj, p) )
		return JS_FALSE;
	*rval = OBJECT_TO_JSVAL(obj);
	return JS_TRUE;
}

void ADM_JSAvidemux::JSDestructor(JSContext *cx, JSObject *obj)
{
	ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
	if(p != NULL)
		delete p;
	p = NULL;
}

JSBool ADM_JSAvidemux::JSGetProperty(JSContext *cx, JSObject *obj, jsval id, jsval *vp)
{
        if (JSVAL_IS_INT(id)) 
        {
                ADM_JSAvidemux *priv = (ADM_JSAvidemux *) JS_GetPrivate(cx, obj);
                switch(JSVAL_TO_INT(id))
                {

                        case markerA_prop:
                                *vp = INT_TO_JSVAL(frameStart);
                                break;
                        case markerB_prop:
                                *vp = INT_TO_JSVAL(frameEnd);
                                break;
                        case audio_prop:
								if (avifileinfo)
									*vp = OBJECT_TO_JSVAL(priv->getObject()->m_pAudio);
								else
									*vp = NULL;

                                break;
                        case video_prop:
								if (avifileinfo)
									*vp = OBJECT_TO_JSVAL(priv->getObject()->m_pVideo);
								else
									*vp = NULL;

                                break;
                        case container_prop:
                                *vp = STRING_TO_JSVAL(priv->getObject()->m_pContainer);
                                break;
                        case currentframe_prop:
                                *vp = INT_TO_JSVAL(priv->getObject()->m_nCurrentFrame);
                                break;
                        case fps_prop:
                                {
                                        aviInfo info;

                                        if (avifileinfo)
                                        {
                                                enterLock();
                                                video_body->getVideoInfo(&info);
                                                priv->getObject()->m_dFPS = info.fps1000/1000.0; 
                                                video_body->updateVideoInfo (&info);
                                                video_body->getVideoInfo (avifileinfo);
                                                leaveLock();
                                        } 
                                        else 
                                        {
                                                return JS_FALSE;
                                        }
                                        *vp = DOUBLE_TO_JSVAL(priv->getObject()->m_dFPS);
                                }
                                break;
                }
        }
        return JS_TRUE;
}

JSBool ADM_JSAvidemux::JSSetProperty(JSContext *cx, JSObject *obj, jsval id, jsval *vp)
{
	if (JSVAL_IS_INT(id)) 
	{
		ADM_JSAvidemux *priv = (ADM_JSAvidemux *) JS_GetPrivate(cx, obj);
		switch(JSVAL_TO_INT(id))
		{
			case markerA_prop:
				if(JSVAL_IS_INT(*vp) == false)
					break;
				{
					int f=JSVAL_TO_INT(*vp);
					if (!avifileinfo)
					{
						return JS_FALSE;
					} 
					if(f==-1)
						f=avifileinfo->nb_frames-1;
					if(f<0 || f>avifileinfo->nb_frames-1)
						return JS_FALSE;
					frameStart=f;
				}
				break;
			case markerB_prop:
				if(JSVAL_IS_INT(*vp) == false)
					break;
				{
					int f=JSVAL_TO_INT(*vp);
					if (!avifileinfo)
					{
						return JS_FALSE;
					} 
					if(f==-1)
						f=avifileinfo->nb_frames-1;
					if(f<0 || f>avifileinfo->nb_frames-1)
						return JS_FALSE;
					frameEnd=f;
				}
				break;
			case audio_prop:
				return JS_FALSE;
				break;
			case video_prop:
				return JS_FALSE;
				break;
			case container_prop:
				if(JSVAL_IS_STRING(*vp) == false)
					break;
				{
					priv->getObject()->m_pContainer = JSVAL_TO_STRING(*vp);
					char *pContainer = JS_GetStringBytes(priv->getObject()->m_pContainer);
					aprintf("Setting container format \"%s\"\n",pContainer);
                                        if(A_setContainer(pContainer))
                                                return JS_TRUE;
                                        return JS_FALSE;
					return JS_FALSE;
				}
				break;
			case currentframe_prop:
				if(JSVAL_IS_INT(*vp) == false)
					break;
				{
					int frameno;
					if (!avifileinfo)
						return JS_FALSE;
					
					frameno = JSVAL_TO_INT(*vp);
					if( frameno<0)
					{
						aviInfo info;
						video_body->getVideoInfo(&info);
						frameno=-frameno;
						if(frameno>info.nb_frames)
							return JS_FALSE;
						
						frameno = info.nb_frames-frameno;
					}
                                        enterLock();
					if(GUI_GoToFrame( frameno ))
					{
						leaveLock();
						return JS_TRUE;
					}
					leaveLock();
					return JS_FALSE;
				}
				break;
			case fps_prop:
				if(JSVAL_IS_DOUBLE(*vp) == false)
					break;
				{
					priv->getObject()->m_dFPS = *JSVAL_TO_DOUBLE(*vp);
					aviInfo info;

					if (avifileinfo)
					{
						video_body->getVideoInfo(&info);				
						info.fps1000 = (uint32_t)floor(priv->getObject()->m_dFPS*1000.f);
						video_body->updateVideoInfo (&info);
						video_body->getVideoInfo (avifileinfo);
						return JS_TRUE;
					} else 
					{
						return JS_FALSE;
					}
				}
				break;
		}
	}
	return JS_TRUE;
}

JSBool ADM_JSAvidemux::Load(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin Load
        JSBool ret=JS_FALSE;
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 1)
                return JS_FALSE;
        if(JSVAL_IS_STRING(argv[0]) == false)
                return JS_FALSE;
        char *pTempStr = JS_GetStringBytes(JSVAL_TO_STRING(argv[0]));
        printf("Loading \"%s\"\n",pTempStr);
        // Do a failure instead of returing ko
        *rval = BOOLEAN_TO_JSVAL(JS_TRUE);
        enterLock();
        if(!A_openAvi(pTempStr)) 
        {
          ret= JS_FALSE;	
        }else 
        {
          ret=JS_TRUE;
        }
        leaveLock();
	return ret;
}// end Load

JSBool ADM_JSAvidemux::LoadFilters(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin LoadFilters
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 1)
                return JS_FALSE;
        if(JSVAL_IS_STRING(argv[0]) == false)
                return JS_FALSE;
        char *pTempStr = JS_GetStringBytes(JSVAL_TO_STRING(argv[0]));
        printf("Loading Filters \"%s\"\n",pTempStr);
        enterLock();
        *rval = BOOLEAN_TO_JSVAL(filterLoadXml(pTempStr,0));
        leaveLock();
	return JS_TRUE;
}// end LoadFilters


JSBool ADM_JSAvidemux::Append(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin Append
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 1)
                return JS_FALSE;
        if(JSVAL_IS_STRING(argv[0]) == false)
                return JS_FALSE;
        char *pTempStr = JS_GetStringBytes(JSVAL_TO_STRING(argv[0]));
        printf("Appending \"%s\"\n",pTempStr);
        enterLock();
        *rval = BOOLEAN_TO_JSVAL(A_appendAvi(pTempStr));
        leaveLock();
	return JS_TRUE;
}// end Append

JSBool ADM_JSAvidemux::Delete(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin Delete
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 2)
                return JS_FALSE;
        if(JSVAL_IS_INT(argv[0]) == false || JSVAL_IS_INT(argv[1]) == false)
                return JS_FALSE;
        int a = JSVAL_TO_INT(argv[0]);
        int b = JSVAL_TO_INT(argv[1]);
        aprintf("Deleting %d-%d\n",a,b);
        enterLock();
        *rval = BOOLEAN_TO_JSVAL(A_delete(a,b));
        leaveLock();
        return JS_TRUE;
}// end Delete

JSBool ADM_JSAvidemux::Save(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin Save
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 1)
                return JS_FALSE;
        if(JSVAL_IS_STRING(argv[0]) == false)
                return JS_FALSE;
        char *pTempStr = JS_GetStringBytes(JSVAL_TO_STRING(argv[0]));
        printf("Saving \"%s\"\n",pTempStr);
        enterLock();
        *rval = BOOLEAN_TO_JSVAL(A_Save(pTempStr));
        leaveLock();
        return JS_TRUE;
}// end Save

static void updateAll(void)
{
        if(!avifileinfo) return;
        if (!video_body->updateVideoInfo (avifileinfo))
        {
                GUI_Error_HIG ("OOPS","Something bad happened when executing that script");
        }
        frameStart=0;
        if(avifileinfo->nb_frames)
                frameEnd=avifileinfo->nb_frames-1;
        else
                frameEnd=0;
}
JSBool ADM_JSAvidemux::ClearSegments(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin ClearSegments
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 0)
                return JS_FALSE;
        printf("clearing segments \n");
        enterLock();
        *rval = BOOLEAN_TO_JSVAL(video_body->deleteAllSegments());
	leaveLock();
        updateAll();
        return JS_TRUE;
}// end ClearSegments
/*
add a segment. addsegment(source video,startframe, nbframes)",     
*/
JSBool ADM_JSAvidemux::AddSegment(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin AddSegment
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 3)
                return JS_FALSE;
	if(JSVAL_IS_INT(argv[0]) == false || JSVAL_IS_INT(argv[1]) == false || JSVAL_IS_INT(argv[2]) == false)
		return JS_FALSE;
        int a = JSVAL_TO_INT(argv[0]);
        int b = JSVAL_TO_INT(argv[1]);
        int c = JSVAL_TO_INT(argv[2]);
        aprintf("adding segment :%d %d %d\n",a,b,c);
        enterLock();
        *rval = BOOLEAN_TO_JSVAL( video_body->addSegment(a,b,c));
	leaveLock();
        updateAll();
        return JS_TRUE;
}// end AddSegment


JSBool ADM_JSAvidemux::Exit(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin Exit
	ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
	// default return value
	*rval = BOOLEAN_TO_JSVAL(false);
	if(argc != 0)
		return JS_FALSE;
	exit(0);
	*rval = INT_TO_JSVAL(1);
	return JS_TRUE;
}// end Exit

JSBool ADM_JSAvidemux::GoToTime(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin GoToTime
	ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
	// default return value
	*rval = BOOLEAN_TO_JSVAL(false);
	if(argc != 3)
		return JS_FALSE;
	if(JSVAL_IS_INT(argv[0]) == false || JSVAL_IS_INT(argv[1]) == false || JSVAL_IS_INT(argv[2]) == false)
		return JS_FALSE;
        enterLock();
	*rval = INT_TO_JSVAL(A_jumpToTime(JSVAL_TO_INT(argv[0]),JSVAL_TO_INT(argv[1]),JSVAL_TO_INT(argv[2]), 0));
	leaveLock();
	return JS_TRUE;
}// end GoToTime

JSBool ADM_JSAvidemux::forceUnpack(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin GoToTime
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 0)
                return JS_FALSE;
        enterLock();
        video_body->setEnv(ENV_EDITOR_PVOP);
        leaveLock();
        *rval = INT_TO_JSVAL(1);
        return JS_TRUE;
}// end GoToTime
JSBool ADM_JSAvidemux::rebuildIndex(JSContext *cx, JSObject *obj, uintN argc, 
                                       jsval *argv, jsval *rval)
{// begin GoToTime
        ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 0)
                return JS_FALSE;
        enterLock();
        if(!video_body->isReordered(0)) // already done
        {
          video_body->rebuildFrameType();
        }
 	leaveLock();
       return JS_TRUE;
}// end GoToTime

JSBool ADM_JSAvidemux::smartcopyMode(JSContext *cx, JSObject *obj, uintN argc, jsval *argv, jsval *rval)
{

ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        printf("[JS]Setting smart copy mode(1)\n");
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 0)
                return JS_FALSE;
        printf("[JS]Setting smart copy mode (2)\n");
        enterLock();
        video_body->setEnv(ENV_EDITOR_SMART);
        *rval = BOOLEAN_TO_JSVAL( true);
        leaveLock();
        return JS_TRUE;
}
JSBool ADM_JSAvidemux::setContainer(JSContext *cx, JSObject *obj, uintN argc, jsval *argv, jsval *rval)
{

ADM_JSAvidemux *p = (ADM_JSAvidemux *)JS_GetPrivate(cx, obj);
        // default return value
        *rval = BOOLEAN_TO_JSVAL(false);
        if(argc != 1)
                return JS_FALSE;
        if(JSVAL_IS_STRING(argv[0]) == false)
                return JS_FALSE;
        char *str = JS_GetStringBytes(JSVAL_TO_STRING(argv[0]));
        enterLock();
        if(A_setContainer(str))
                *rval = BOOLEAN_TO_JSVAL( true);
        leaveLock();
        return JS_TRUE;
}
uint8_t A_setContainer(const char *cont)
{
       for(int i=0;i<NB_CONT;i++)
       {
                printf("%s\n",container[i].name);
                if(!strcasecmp(cont,container[i].name))
                {
                        UI_SetCurrentFormat(container[i].type);
                        return 1;
                }
       }
       printf("Cannot set output format \"%s\"\n",cont);
       return 0;
}

const char *getCurrentContainerAsString(void)
{
        ADM_OUT_FORMAT cont=UI_GetCurrentFormat();
        for(int i=0;i<sizeof(container)/sizeof(ADM_CONTAINER);i++)
        {
                if(container[i].type==cont) 
                        return container[i].name;
        }
        ADM_assert(0);
        return NULL;

}

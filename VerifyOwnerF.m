#include <cstddef>
#include <iostream>
#include <mutex>
#include <condition_variable>
#include <chrono>
#include <utility>

#include <Foundation/Foundation.h>
#include <LocalAuthentication/LocalAuthentication.h>
#include <Cocoa/Cocoa.h>


#define PY_SSIZE_T_CLEAN
#include <Python.h>


using namespace std;
condition_variable cv;

extern "C" int VerifyOwner(const char * prompt, int milliseconds = 0){
    if(prompt==NULL||*prompt==0){
        return -2;
    }
    mutex wait_mutex;
    LAContext * cont = [[[LAContext alloc] init] autorelease];
    NSString * txt = [[[NSString alloc]initWithCString:prompt encoding:NSUTF8StringEncoding] autorelease];
    NSError * err = nil;
    int __block st = -1;
    if ([cont canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&err]){
        [cont evaluatePolicy:LAPolicyDeviceOwnerAuthentication
        localizedReason:txt reply:^(BOOL success, NSError * _Nullable error){
            if(success){
                st = 0;
            }else{
                st = [error code];
            }
            cv.notify_one();
        }];
    }else {
        return -1;
    }
    unique_lock<mutex> lk(wait_mutex);
    if(milliseconds<=0){
        cv.wait(lk);
    }else{
        cv.wait_for(lk,chrono::milliseconds(milliseconds));
    }
    return st;
}

#define NULLA(str) str = (str==NULL)?"":str

extern "C" int SimpleMessageBox(const char * title, const char * info, const char * button){
    NULLA(title);
    NULLA(info);
    NULLA(button);
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    NSString * NSTitle = [[[NSString alloc]initWithCString:title encoding:NSUTF8StringEncoding] autorelease];
    NSString * NSInfo = [[[NSString alloc]initWithCString:info encoding:NSUTF8StringEncoding] autorelease];
    NSString * NSButton = [[[NSString alloc]initWithCString:button encoding:NSUTF8StringEncoding] autorelease];
    [alert addButtonWithTitle:NSButton];
    [alert setMessageText:NSTitle];
    [alert setInformativeText:NSInfo];
    [[alert window]setLevel:NSFloatingWindowLevel];
    [alert runModal];
    return 0;
}

extern "C"{

PyObject * VerifyOwnerF(PyObject *self, PyObject *args){
    char p[1024];
    char * prompt=p;
    //unique_ptr<char> prompt(new char[1024]());
    int mseconds=0;
    PyObject * ret= NULL;
    if(!PyArg_ParseTuple(args,"si",&prompt,&mseconds)){
        PyErr_SetString(PyExc_RuntimeError, "Cannot read arguments");
    }else{
        int st = VerifyOwner(prompt,mseconds);
        ret= PyLong_FromLong(st);
    }
    return ret;
}

static PyMethodDef VOMethods[]={
    {"VerifyOwnerF",VerifyOwnerF,METH_VARARGS,NULL},
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef VO = {PyModuleDef_HEAD_INIT,"VerifyOwnerF",NULL,-1,VOMethods};

PyMODINIT_FUNC PyInit_VerifyOwnerF(void){
    return PyModule_Create(&VO);
}

}
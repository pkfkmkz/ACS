#include "TestComponentImpl.h"
#include <thread>
#include <chrono>

TestComponentImpl::TestComponentImpl(const ACE_CString& name, maci::ContainerServices * containerServices): ACSComponentImpl(name, containerServices) {
}

TestComponentImpl::~TestComponentImpl() {
}

void TestComponentImpl::execute(ACS_Regression::TestCallback_ptr cb) {
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestComponentImpl::execute(cb)", (LM_INFO, "Calling TestCallback::notify()"));
    std::this_thread::sleep_for (std::chrono::milliseconds(1000));
    cb->notify();
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestComponentImpl::execute(cb)", (LM_INFO, "Called TestCallback::notify()"));
}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(TestComponentImpl)
/* ----------------------------------------------------------------*/

#include "CallerComponentImpl.h"
#include <chrono>

CallerComponentImpl::CallerComponentImpl(const ACE_CString& name, maci::ContainerServices * containerServices): ACSComponentImpl(name, containerServices) {
    comp = ACS_Regression::TestComponent::_nil();
}

CallerComponentImpl::~CallerComponentImpl() {
}

void CallerComponentImpl::execute() {
    ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Requesting TestComponent"));
    comp = this->getContainerServices()->getComponent<ACS_Regression::TestComponent>("TEST");
    ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Received TestComponent"));
}

void CallerComponentImpl::cleanUp() {
    if (CORBA::is_nil(comp.in())) {
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Releasing TestComponent"));
        comp = ACS_Regression::TestComponent::_nil();
    	this->getContainerServices()->releaseComponent("TEST");
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Released TestComponent"));
    } else {
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "TestComponent was never acquired"));
    }
}

void CallerComponentImpl::interact() {
    if (CORBA::is_nil(comp)) {
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "For some reason comp is nil! Skipping call to execute"));
    } else {
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Calling TestComponent::execute(tcb)"));
        TestCallbackImpl tcb(this->getContainerServices());
    	comp->execute(tcb.getCORBA());
        ACS_LOG(LM_RUNTIME_CONTEXT, "CallerComponentImpl::interact()", (LM_INFO, "Called TestComponent::execute(tcb)"));
	tcb.wait(2000);
	//usleep(1000);
    }
}

TestCallbackImpl::TestCallbackImpl(maci::ContainerServices* ecs) {
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::TestCallbackImpl()", (LM_INFO, "Callback Constructor Started"));
    cs = ecs;
    ref = ACS_Regression::TestCallback::_nil();
    ACS::OffShoot_var offshoot = cs->activateOffShoot(this);
    ref = ACS_Regression::TestCallback::_narrow(offshoot.in());
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::TestCallbackImpl()", (LM_INFO, "Callback Constructor Finished"));
}

TestCallbackImpl::~TestCallbackImpl() {
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::TestCallbackImpl()", (LM_INFO, "Callback Destructor Started"));
    if (CORBA::is_nil(ref.in())) {
        return;
    }
    cs->deactivateOffShoot(this);
    ref = ACS_Regression::TestCallback::_nil();
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::TestCallbackImpl()", (LM_INFO, "Callback Destructor Finished"));
}

void TestCallbackImpl::notify() {
    ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::notify()", (LM_INFO, "Callback was notified"));
    this->cv.notify_one();
}

void TestCallbackImpl::wait(int ms) {
    std::unique_lock<std::mutex> mlock(block);
    auto res = this->cv.wait_for(mlock, std::chrono::milliseconds(ms));
    if (res == std::cv_status::timeout) {
        ACS_LOG(LM_RUNTIME_CONTEXT, "TestCallbackImpl::wait()", (LM_INFO, "Callback was not called withing the expected time!"));
    }
}

ACS_Regression::TestCallback_ptr TestCallbackImpl::getCORBA() {
    return ACS_Regression::TestCallback::_duplicate(ref.in());
}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(CallerComponentImpl)
/* ----------------------------------------------------------------*/

#ifndef _CALLER_COMPONENT_IMPL_H
#define _CALLER_COMPONENT_IMPL_H
#include <acscomponentImpl.h>
#include <ict12398S.h>

#include <mutex>
#include <condition_variable>

class TestCallbackImpl: public POA_ACS_Regression::TestCallback {
  public:
    TestCallbackImpl(maci::ContainerServices* cs);
    virtual ~TestCallbackImpl();
    virtual void notify();
    virtual void wait(int ms);
    virtual ACS_Regression::TestCallback_ptr getCORBA();
  protected:
    maci::ContainerServices* cs;
    ACS_Regression::TestCallback_var ref;
    std::condition_variable cv;
    std::mutex block;
};

class CallerComponentImpl: public virtual acscomponent::ACSComponentImpl, public POA_ACS_Regression::CallerComponent {
  public:
    CallerComponentImpl(const ACE_CString& name, maci::ContainerServices * containerServices);
    virtual ~CallerComponentImpl();
    virtual void execute();
    virtual void cleanUp();
    virtual void interact();
  protected:
    ACS_Regression::TestComponent_var comp;
};

#endif

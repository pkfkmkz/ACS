#ifndef _TEST_COMPONENT_IMPL_H
#define _TEST_COMPONENT_IMPL_H
#include <acscomponentImpl.h>
#include <ict12398S.h>

class TestComponentImpl: public virtual acscomponent::ACSComponentImpl, public POA_ACS_Regression::TestComponent {
  public:
    TestComponentImpl(const ACE_CString& name, maci::ContainerServices * containerServices);
    virtual ~TestComponentImpl();
    virtual void execute(ACS_Regression::TestCallback_ptr cb);
};
#endif

#ifndef _MIDDLE_CC_IMPL_H_
#define _MIDDLE_CC_IMPL_H_

#include <ParentCCImpl.h>

class MiddleCCImpl: public virtual ParentCCImpl, public virtual POA_ict21770::MiddleCC {
  public:
    MiddleCCImpl(const ACE_CString& name, maci::ContainerServices *, bool monitoring=true);
    virtual ~MiddleCCImpl();

    virtual void printValue2();
    virtual void printValues();

    virtual ACS::ROdouble_ptr prop2();
  private:
    baci::SmartPropertyPointer<baci::ROdouble>  m_prop2_sp;
};

#endif

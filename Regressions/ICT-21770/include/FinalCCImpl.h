#ifndef _FINAL_CC_IMPL_H_
#define _FINAL_CC_IMPL_H_

#include <MiddleCCImpl.h>

class FinalCCImpl: public virtual MiddleCCImpl, public virtual POA_ict21770::FinalCC {
  public:
    FinalCCImpl(const ACE_CString& name, maci::ContainerServices *, bool monitoring=true);
    virtual ~FinalCCImpl();

    virtual void printValue3();
    virtual void printValues();

    virtual ACS::ROdouble_ptr prop3();
  private:
    baci::SmartPropertyPointer<baci::ROdouble>  m_prop3_sp;
};

#endif

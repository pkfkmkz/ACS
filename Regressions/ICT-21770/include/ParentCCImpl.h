#ifndef _PARENT_CC_IMPL_H_
#define _PARENT_CC_IMPL_H_

#include <acsutil.h>

#include <baci.h>
#include <ict21770S.h>

#include <baciROdouble.h>
#include <baciCharacteristicComponentImpl.h>
#include <baciSmartPropertyPointer.h>

class ParentCCImpl: public baci::CharacteristicComponentImpl, public virtual POA_ict21770::ParentCC {
  public:
    ParentCCImpl(const ACE_CString& name, maci::ContainerServices *, bool monitoring=true);
    virtual ~ParentCCImpl();

    virtual void printValue1();
    virtual void printValues();

    virtual ACS::ROdouble_ptr prop1();
  private:
    baci::SmartPropertyPointer<baci::ROdouble>  m_prop1_sp;
};

#endif

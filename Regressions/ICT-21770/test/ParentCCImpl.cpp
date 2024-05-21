#include <iostream>
#include <ParentCCImpl.h>

ParentCCImpl::ParentCCImpl(const ACE_CString& name, maci::ContainerServices *cs, bool monitoring):
    CharacteristicComponentImpl(name, cs, monitoring),
    m_prop1_sp(new baci::ROdouble(name+":prop1", getComponent()),this) {
    std::cout << "Constructor" << std::endl;
}

ParentCCImpl::~ParentCCImpl() {
    std::cout << "Destructor" << std::endl;
}

void ParentCCImpl::printValue1() {
    ACSErr::Completion_var c;
    std::cout << "Value 1: " << prop1()->get_sync(c.out()) << std::endl;
}

void ParentCCImpl::printValues() {
    printValue1();
}

ACS::ROdouble_ptr ParentCCImpl::prop1() {
    if (m_prop1_sp==0)
        return ACS::ROdouble::_nil();
    ACS::ROdouble_var prop = ACS::ROdouble::_narrow(m_prop1_sp->getCORBAReference());
    return prop._retn();
}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(ParentCCImpl)
/* ----------------------------------------------------------------*/

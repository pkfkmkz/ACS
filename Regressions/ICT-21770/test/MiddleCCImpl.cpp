#include <MiddleCCImpl.h>

MiddleCCImpl::MiddleCCImpl(const ACE_CString& name, maci::ContainerServices *cs, bool monitoring):
    ParentCCImpl(name, cs, monitoring),
    m_prop2_sp(new baci::ROdouble(name+":prop2", getComponent()),this) {
}

MiddleCCImpl::~MiddleCCImpl() {
}

void MiddleCCImpl::printValue2() {
    ACSErr::Completion_var c;
    std::cout << "Value 2: " << prop2()->get_sync(c.out()) << std::endl;
}

void MiddleCCImpl::printValues() {
    printValue1();
    printValue2();
}

ACS::ROdouble_ptr MiddleCCImpl::prop2() {
    if (m_prop2_sp==0)
        return ACS::ROdouble::_nil();
    ACS::ROdouble_var prop = ACS::ROdouble::_narrow(m_prop2_sp->getCORBAReference());
    return prop._retn();
}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(MiddleCCImpl)
/* ----------------------------------------------------------------*/

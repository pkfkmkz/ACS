#include <FinalCCImpl.h>

FinalCCImpl::FinalCCImpl(const ACE_CString& name, maci::ContainerServices *cs, bool monitoring):
    ParentCCImpl(name, cs, monitoring),
    MiddleCCImpl(name, cs, monitoring),
    m_prop3_sp(new baci::ROdouble(name+":prop3", getComponent()),this) {
}

FinalCCImpl::~FinalCCImpl() {
}

void FinalCCImpl::printValue3() {
    ACSErr::Completion_var c;
    std::cout << "Value 3: " << prop3()->get_sync(c.out()) << std::endl;
}

void FinalCCImpl::printValues() {
    printValue1();
    printValue2();
    printValue3();
}

ACS::ROdouble_ptr FinalCCImpl::prop3() {
    if (m_prop3_sp==0)
        return ACS::ROdouble::_nil();
    ACS::ROdouble_var prop = ACS::ROdouble::_narrow(m_prop3_sp->getCORBAReference());
    return prop._retn();
}

/* --------------- [ MACI DLL support functions ] -----------------*/
#include <maciACSComponentDefines.h>
MACI_DLL_SUPPORT_FUNCTIONS(FinalCCImpl)
/* ----------------------------------------------------------------*/

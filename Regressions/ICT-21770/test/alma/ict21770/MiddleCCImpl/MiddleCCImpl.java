package alma.ict21770.MiddleCCImpl;

import alma.ACS.ROdouble;
import alma.ACS.ROdoubleHelper;
import alma.ACS.ROdoublePOATie;
import alma.ACS.impl.ROdoubleImpl;
import alma.ACSErr.CompletionHolder;
import alma.acs.container.ContainerServices;
import alma.acs.component.ComponentLifecycleException;

import alma.ACS.jbaci.DataAccess;
import alma.ACS.jbaci.MemoryDataAccess;

import alma.ict21770.MiddleCCOperations;
import alma.ict21770.ParentCCImpl.ParentCCImpl;

public class MiddleCCImpl extends ParentCCImpl implements MiddleCCOperations
{
    protected ROdouble prop2;

	public void initialize(ContainerServices containerServices) throws ComponentLifecycleException {
        super.initialize(containerServices);

        try {
            DataAccess prop2DA = new MemoryDataAccess();
            ROdoubleImpl prop2Impl = new ROdoubleImpl("prop2", this, prop2DA);
            ROdoublePOATie prop2Tie = new ROdoublePOATie(prop2Impl);
            prop2 = ROdoubleHelper.narrow(this.registerProperty(prop2Impl, prop2Tie));
        } catch (Throwable th) {
        	throw new ComponentLifecycleException("Failed to create properties.", th); 
        }
	}
    
	public void printValue2() {
        CompletionHolder ch = new CompletionHolder();
        System.out.println(prop2().get_sync(ch));
	}

	public void printValues() {
        printValue1();
        printValue2();
	}

	public ROdouble prop2() {
		return prop2;
	}
}

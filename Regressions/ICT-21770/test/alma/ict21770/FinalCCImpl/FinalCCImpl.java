package alma.ict21770.FinalCCImpl;

import alma.ACS.ROdouble;
import alma.ACS.ROdoubleHelper;
import alma.ACS.ROdoublePOATie;
import alma.ACS.impl.ROdoubleImpl;
import alma.ACSErr.CompletionHolder;
import alma.acs.container.ContainerServices;
import alma.acs.component.ComponentLifecycleException;

import alma.ACS.jbaci.DataAccess;
import alma.ACS.jbaci.MemoryDataAccess;

import alma.ict21770.FinalCCOperations;
import alma.ict21770.MiddleCCImpl.MiddleCCImpl;

public class FinalCCImpl extends MiddleCCImpl implements FinalCCOperations
{
    protected ROdouble prop3;

	public void initialize(ContainerServices containerServices) throws ComponentLifecycleException {
        super.initialize(containerServices);

        try {
            DataAccess prop3DA = new MemoryDataAccess();
            ROdoubleImpl prop3Impl = new ROdoubleImpl("prop3", this, prop3DA);
            ROdoublePOATie prop3Tie = new ROdoublePOATie(prop3Impl);
            prop3 = ROdoubleHelper.narrow(this.registerProperty(prop3Impl, prop3Tie));
        } catch (Throwable th) {
        	throw new ComponentLifecycleException("Failed to create properties.", th); 
        }
	}
    
	public void printValue3() {
        CompletionHolder ch = new CompletionHolder();
        System.out.println(prop3().get_sync(ch));
	}

	public void printValues() {
        printValue1();
        printValue2();
        printValue3();
	}

	public ROdouble prop3() {
		return prop3;
	}
}

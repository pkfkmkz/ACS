package alma.ict21770.ParentCCImpl;

import alma.ACS.ROdouble;
import alma.ACS.ROdoubleHelper;
import alma.ACS.ROdoublePOATie;
import alma.ACS.impl.ROdoubleImpl;
import alma.ACSErr.CompletionHolder;
import alma.acs.container.ContainerServices;
import alma.ACS.impl.CharacteristicComponentImpl;
import alma.acs.component.ComponentLifecycleException;

import alma.ACS.jbaci.DataAccess;
import alma.ACS.jbaci.MemoryDataAccess;

import alma.ict21770.ParentCCOperations;

public class ParentCCImpl extends CharacteristicComponentImpl implements ParentCCOperations
{
    protected ROdouble prop1;

	public void initialize(ContainerServices containerServices) throws ComponentLifecycleException {
        super.initialize(containerServices);

        try {
            DataAccess prop1DA = new MemoryDataAccess();
            ROdoubleImpl prop1Impl = new ROdoubleImpl("prop1", this, prop1DA);
            ROdoublePOATie prop1Tie = new ROdoublePOATie(prop1Impl);
            prop1 = ROdoubleHelper.narrow(this.registerProperty(prop1Impl, prop1Tie));
        } catch (Throwable th) {
        	throw new ComponentLifecycleException("Failed to create properties.", th); 
        }
	}
    
	public void printValue1() {
        CompletionHolder ch = new CompletionHolder();
        System.out.println(prop1().get_sync(ch));
	}

	public void printValues() {
        printValue1();
	}

	public ROdouble prop1() {
		return prop1;
	}
}

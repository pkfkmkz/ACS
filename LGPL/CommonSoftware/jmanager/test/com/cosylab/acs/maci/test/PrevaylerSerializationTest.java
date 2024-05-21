package com.cosylab.acs.maci.test;

import java.io.File;
import java.util.Properties;

import com.cosylab.util.FileHelper;

import junit.framework.TestCase;

import org.prevayler.Prevayler;
import org.prevayler.PrevaylerFactory;

import java.io.Serializable;

public class PrevaylerSerializationTest extends TestCase {

	private PrevaylerTest test;
	private String recoveryLocation;
	private Prevayler<PrevaylerTest> prevayler;
	
	public PrevaylerSerializationTest(String arg0) {
		super(arg0);
	}

	protected void setUp() throws Exception {
		super.setUp();
		try {
		this.recoveryLocation = FileHelper.getTempFileName(null, "PrevaylerTest_Recovery");
		PrevaylerFactory<PrevaylerTest> factory = new PrevaylerFactory<PrevaylerTest>();
		factory.configurePrevalentSystem(new PrevaylerTest());
		factory.configurePrevalenceDirectory(recoveryLocation);
		factory.configureTransactionDeepCopy(false);
		this.prevayler = factory.create();
		this.test = this.prevayler.prevalentSystem();
		this.test.setValue(1);
		this.prevayler.takeSnapshot();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public PrevaylerTest deserialize(PrevaylerTest system) {
		Prevayler<PrevaylerTest> prevayler = null;
		try {
			PrevaylerFactory<PrevaylerTest> factory = new PrevaylerFactory<PrevaylerTest>();
			factory.configurePrevalentSystem(system);
			factory.configurePrevalenceDirectory(recoveryLocation);
			factory.configureTransactionDeepCopy(false);
			prevayler = factory.create();
		}
		catch (Exception e) {
			e.printStackTrace();
			fail();
		}
		return prevayler.prevalentSystem();
	}

	public void testSerializationBehavior() throws Exception {
		assertEquals(1, this.test.getValue());
                PrevaylerTest ntest = new PrevaylerTest();
		assertEquals(0, ntest.getValue());
		ntest = (PrevaylerTest) deserialize(new PrevaylerTest());
		assertEquals(1, ntest.getValue());
		this.test.setValue(5);
		ntest = (PrevaylerTest) deserialize(new PrevaylerTest());
		assertEquals(1, ntest.getValue());
		this.prevayler.takeSnapshot();
		ntest = (PrevaylerTest) deserialize(new PrevaylerTest());
		assertEquals(5, ntest.getValue());
	}

	public static void main(String[] args) {
		junit.textui.TestRunner.run(PrevaylerSerializationTest.class);
		System.exit(0);
	}
}

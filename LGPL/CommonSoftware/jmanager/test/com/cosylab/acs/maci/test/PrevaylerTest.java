package com.cosylab.acs.maci.test;

import java.io.Serializable;

public class PrevaylerTest implements Serializable {
        private static final long serialVersionUID = 1000011L;
	private int value;
	public PrevaylerTest() {
		this.value = 0;
	}
	public int getValue() {
		return this.value;
	}
	public void setValue(int value) {
		this.value = value;
	}
}

package alma.tools.entitybuilder.jaxb;

import java.util.Map;
import java.util.List;
import java.util.ArrayList;
import java.util.LinkedHashMap;

import javax.xml.namespace.QName;
import jakarta.xml.bind.annotation.XmlAnyElement;
import jakarta.xml.bind.annotation.XmlAnyAttribute;

public class CustomElement {
    @XmlAnyAttribute
    protected Map<QName, String> attributes;
    @XmlAnyElement
    protected List<Object> elements;

    public CustomElement() {
        attributes= new LinkedHashMap<QName, String>();
        elements = new ArrayList<Object>();
    }

    public void addAttribute(QName name, String value) {
        attributes.put(name, value);
    }

    public void addElement(Object element) {
        elements.add(element);
    }
}

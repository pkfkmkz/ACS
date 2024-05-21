package alma.acs.tmcdb.utils;

import jakarta.persistence.Query;
import jakarta.persistence.EntityManager;

import alma.acs.tmcdb.Component;
import alma.acs.tmcdb.Configuration;

public class SwDatabaseHelper {
    protected static Component getComponent(EntityManager em, Configuration conf, String compName) {
        Query q = em.createQuery("SELECT c FROM Component c WHERE c.componentName = :name AND c.configuration = :conf");
        q.setParameter("name", compName);
        q.setParameter("conf", conf);
        Component comp = (Component) q.getSingleResult();
	return comp;
    }

    public static String getComponentCode(EntityManager em, Configuration conf, String compName) {
        em.getTransaction().begin();
	try {
	    String code = SwDatabaseHelper.getComponent(em, conf, compName).getCode();
            em.getTransaction().commit();
	    return code;
	} catch (Throwable th) {
            em.getTransaction().rollback();
	    th.printStackTrace();
	    throw th;
	}
    }

    public static void setComponentCode(EntityManager em, Configuration conf, String compName, String code) {
        em.getTransaction().begin();
	try {
            SwDatabaseHelper.getComponent(em, conf, compName).setCode(code);
            em.getTransaction().commit();
	} catch (Throwable th) {
            em.getTransaction().rollback();
	    th.printStackTrace();
	    throw th;
	}
    }
}

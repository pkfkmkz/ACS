/*******************************************************************************
 * ALMA - Atacama Large Millimeter Array
 * Copyright (c) COSYLAB - Control System Laboratory, 2011
 * (in the framework of the ALMA collaboration).
 * All rights reserved.
 * 
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 * 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
 *******************************************************************************/
/**
 * 
 */
package com.cosylab.cdb.jdal.hibernate.plugin;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.hibernate.Session;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.TypedQuery;
import jakarta.persistence.NoResultException;

import alma.TMCDB.alarm.AlarmDefinition;
import alma.TMCDB.alarm.AlarmSystemConfiguration;
import alma.TMCDB.alarm.Categories;
import alma.TMCDB.alarm.DOMConfigurationAccessor;
import alma.TMCDB.alarm.FaultFamiliesMap;
import alma.TMCDB.alarm.FaultMemberDefault;
import alma.TMCDB.alarm.ReductionDefinitions;
import alma.TMCDB.alarm.ReductionLink;
import alma.TMCDB.alarm.ReductionLinks;
import alma.acs.tmcdb.AlarmCategory;
import alma.acs.tmcdb.Component;
import alma.acs.tmcdb.Configuration;
import alma.acs.tmcdb.Contact;
import alma.acs.tmcdb.DefaultMember;
import alma.acs.tmcdb.FaultCode;
import alma.acs.tmcdb.FaultFamily;
import alma.acs.tmcdb.FaultMember;
import alma.acs.tmcdb.Location;
import alma.acs.tmcdb.ReductionLinkAction;
import alma.acs.tmcdb.ReductionLinkType;
import alma.acs.tmcdb.ReductionThreshold;

import com.cosylab.acs.laser.dao.ACSAlarmDAOImpl;
import com.cosylab.acs.laser.dao.ACSCategoryDAOImpl;
import com.cosylab.acs.laser.dao.ACSResponsiblePersonDAOImpl;
import com.cosylab.acs.laser.dao.ConfigurationAccessor;
import com.cosylab.cdb.client.CDBAccess;
import com.cosylab.cdb.jdal.hibernate.RootMap;

/**
 * @author msekoranja
 *
 */
public class HibernateWDALAlarmPluginImpl implements HibernateWDALPlugin {

	private Logger m_logger = Logger.getLogger(Logger.GLOBAL_LOGGER_NAME);

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#getName()
	 */
	public String getName() {
		return "Alarm System plugin";
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#initialize(java.util.logging.Logger)
	 */
	public void initialize(Logger logger) {
		this.m_logger = logger;
	}

	private static final String nonEmptyString(final String value, final String defaultValue)
	{
		if (value == null)
			return null;
		if (value.length() == 0)
			return defaultValue;
		else
			return value;
	}

	private static final Location getLocation(Session session, alma.acs.alarmsystem.generated.Location daoLocation)
	{
		if (daoLocation == null)
			return null;

		CriteriaBuilder cb = session.getCriteriaBuilder();
		CriteriaQuery<Location> cqLocation = cb.createQuery(Location.class);
		Root<Location> itemLocation = cqLocation.from(Location.class);
		cqLocation.select(itemLocation).where(
			cb.equal(itemLocation.get("building"), daoLocation.getBuilding()),
			cb.equal(itemLocation.get("floor"), daoLocation.getFloor()),
			cb.equal(itemLocation.get("room"), daoLocation.getRoom()),
			cb.equal(itemLocation.get("mnemonic"), daoLocation.getMnemonic()),
			cb.equal(itemLocation.get("locationPosition"), daoLocation.getPosition())
		);
		TypedQuery<Location> queryLocation = session.createQuery(cqLocation);
		Location location = null;
		try {
			location = queryLocation.getSingleResult();
		} catch (NoResultException e) {
			location = null;
		}

		if (location == null)
		{
			location = new Location();
			location.setBuilding(daoLocation.getBuilding());
			location.setFloor(daoLocation.getFloor());
			location.setRoom(daoLocation.getRoom());
			location.setMnemonic(daoLocation.getMnemonic());
			location.setLocationPosition(daoLocation.getPosition());
			session.persist(location);
		}

		return location;
	}

	public static void importAlarms(Session session, Configuration config, ConfigurationAccessor conf, Logger m_logger)
		throws Exception
	{
		// clean up whatever is in the session
		session.getTransaction().commit();
		session.clear();
		session.beginTransaction();

   		// create DAOs
		ACSAlarmDAOImpl alarmDAO = new ACSAlarmDAOImpl(m_logger);
		ACSCategoryDAOImpl categoryDAO = new ACSCategoryDAOImpl(m_logger, alarmDAO);
		ACSResponsiblePersonDAOImpl responsiblePersonDAO = new ACSResponsiblePersonDAOImpl();

		// configure
		alarmDAO.setConfAccessor(conf);
		alarmDAO.setSurveillanceAlarmId("SURVEILLANCE:SOURCE:1");
		alarmDAO.setResponsiblePersonDAO(responsiblePersonDAO);

		categoryDAO.setConfAccessor(conf);
		//categoryDAO.setCategoryTreeRoot("ACS");
		categoryDAO.setCategoryTreeRoot("ROOT");
		categoryDAO.setSurveillanceCategoryPath("ACS.SURVEILLANCE");

		responsiblePersonDAO.setAlarmDAO(alarmDAO);

		// load
		final List<alma.acs.alarmsystem.generated.FaultFamily> families = alarmDAO.loadAlarms();
		final alma.acs.alarmsystem.generated.Category[] categories = categoryDAO.loadCategories();
		Map<String, ArrayList<AlarmCategory>> categoryFaultFamilyLinks = new HashMap<String, ArrayList<AlarmCategory>>();

		CriteriaBuilder cb = session.getCriteriaBuilder();
		// store categories
		if (categories != null)
			for (alma.acs.alarmsystem.generated.Category daoCategory : categories)
			{
				CriteriaQuery<AlarmCategory> cqAlarmCat = cb.createQuery(AlarmCategory.class);
				Root<AlarmCategory> itemAlarmCat = cqAlarmCat.from(AlarmCategory.class);
				cqAlarmCat.select(itemAlarmCat).where(
					cb.equal(itemAlarmCat.get("configuration"), config),
					cb.equal(itemAlarmCat.get("alarmCategoryName"), daoCategory.getPath())
				);
				TypedQuery<AlarmCategory> queryAlarmCat = session.createQuery(cqAlarmCat);
				AlarmCategory category = null;
				try {
					category = queryAlarmCat.getSingleResult();
				} catch (NoResultException e) {
					category = null;
				}
				if (category == null)
				{
					category = new AlarmCategory();
					category.setAlarmCategoryName(daoCategory.getPath());
					category.setConfiguration(config);
				}
				category.setDescription(nonEmptyString(daoCategory.getDescription(), "(description)"));
				category.setPath(daoCategory.getPath());
				category.setIsDefault(daoCategory.getIsDefault());
				session.saveOrUpdate(category);

				// clear first (in case of update)
				category.getFaultFamilies().clear();

				// cache mappings
				String[] faultFamilies = daoCategory.getAlarms().getFaultFamily();
				for (String faultFamily : faultFamilies)
				{
					ArrayList<AlarmCategory> list = categoryFaultFamilyLinks.get(faultFamily);
					if (list == null)
					{
						list = new ArrayList<AlarmCategory>();
						categoryFaultFamilyLinks.put(faultFamily,list);
					}
   				 	list.add(category);
				}
			}

		// store fault families and contacts, etc.
		if (families != null)
			for (alma.acs.alarmsystem.generated.FaultFamily family : families)
			{
				final alma.acs.alarmsystem.generated.Contact daoContact = family.getContact();
				CriteriaQuery<Contact> cqContact = cb.createQuery(Contact.class);
				Root<Contact> itemContact = cqContact.from(Contact.class);
				cqContact.select(itemContact).where(
					cb.equal(itemContact.get("contactName"), daoContact.getName())
				);
				TypedQuery<Contact> queryContact = session.createQuery(cqContact);
				Contact contact = null;
				try {
					contact = queryContact.getSingleResult();
				} catch (NoResultException e) {
					contact = null;
				}

				if (contact == null)
				{
					contact = new Contact();
					contact.setContactName(nonEmptyString(daoContact.getName(), "(empty)"));
					contact.setEmail(daoContact.getEmail());
					contact.setGsm(daoContact.getGsm());
					session.persist(contact);
				}
				// If contact exist, let's check if this contact contains different information. If so,
				// issue an error
				else {
					if( !trimAndNullToEmpty(contact.getEmail()).equals(trimAndNullToEmpty(daoContact.getEmail())) ||
					    !trimAndNullToEmpty(contact.getGsm()).equals(trimAndNullToEmpty(daoContact.getGsm())) ) {
						throw new RuntimeException("Data stored for contact '" + contact.getContactName() + "' in TMCDB " +
								"does not match that comming from the 'contact' node of fault family '" + family.getName() +"'. " +
								"TMCDB: <" + contact.getEmail() +  ", " + contact.getGsm() +">, " +
								"CDB: <" + daoContact.getEmail() +  ", " + daoContact.getGsm() +">");
					}
				}

				CriteriaQuery<FaultFamily> cqFaultFamily = cb.createQuery(FaultFamily.class);
				Root<FaultFamily> itemFaultFamily = cqFaultFamily.from(FaultFamily.class);
				cqFaultFamily.select(itemFaultFamily).where(
					cb.equal(itemFaultFamily.get("configuration"), config),
					cb.equal(itemFaultFamily.get("familyName"), family.getName())
				);
				TypedQuery<FaultFamily> queryFaultFamily = session.createQuery(cqFaultFamily);
				FaultFamily faultFamily = null;
				try {
					faultFamily = queryFaultFamily.getSingleResult();
				} catch (NoResultException e) {
					faultFamily = null;
				}
				if (faultFamily == null)
				{
					faultFamily = new FaultFamily();
					faultFamily.setFamilyName(family.getName());
					faultFamily.setConfiguration(config);
				}
				faultFamily.setAlarmSource(family.getAlarmSource());
				faultFamily.setHelpURL(family.getHelpUrl());
				faultFamily.setContact(contact);
				session.saveOrUpdate(faultFamily);

				// clear first (in case of update)
				faultFamily.getAlarmCategories().clear();
				ArrayList<AlarmCategory> list = categoryFaultFamilyLinks.get(family.getName());
				if (list != null)
					for (AlarmCategory category : list)
					{
						category.getFaultFamilies().add(faultFamily);
						faultFamily.getAlarmCategories().add(category);
						session.update(category);
						session.update(faultFamily);
					}


				// default fault member
				if (family.getFaultMemberDefault() != null)
				{
					DefaultMember defaultMember = null;
					// there can be only one
					if (faultFamily.getDefaultMembers().size() != 0)
						defaultMember = faultFamily.getDefaultMembers().iterator().next();
					if (defaultMember == null)
					{
						defaultMember = new DefaultMember();
						defaultMember.setFaultFamily(faultFamily);
					}
					defaultMember.setLocation(getLocation(session, family.getFaultMemberDefault().getLocation()));
					session.saveOrUpdate(defaultMember);
				}
				else
				{
					for (DefaultMember memberToRemove : faultFamily.getDefaultMembers())
					{
						faultFamily.getDefaultMembers().remove(memberToRemove);
						session.delete(memberToRemove);
					}
					session.update(faultFamily);
				}

				// copy all
			    Set<FaultMember> faultMembersToRemove = new HashSet<FaultMember>(faultFamily.getFaultMembers());

				// add fault members
				for (alma.acs.alarmsystem.generated.FaultMember daoFaultMember : family.getFaultMember())
				{
					CriteriaQuery<FaultMember> cqFaultMember = cb.createQuery(FaultMember.class);
					Root<FaultMember> itemFaultMember = cqFaultMember.from(FaultMember.class);
					cqFaultMember.select(itemFaultMember).where(
						cb.equal(itemFaultMember.get("memberName"), daoFaultMember.getName()),
						cb.equal(itemFaultMember.get("faultFamily"), faultFamily)
					);
					TypedQuery<FaultMember> queryFaultMember = session.createQuery(cqFaultMember);
					FaultMember faultMember = null;
					try {
						faultMember = queryFaultMember.getSingleResult();
					} catch (NoResultException e) {
						faultMember = null;
					}
					faultMembersToRemove.remove(faultMember);
					if (faultMember == null)
					{
						faultMember = new FaultMember();
						faultMember.setMemberName(daoFaultMember.getName());
						faultMember.setFaultFamily(faultFamily);
					}
					faultMember.setLocation(getLocation(session, daoFaultMember.getLocation()));
					session.saveOrUpdate(faultMember);
				}

				if (faultMembersToRemove.size() > 0)
				{
					for (FaultMember faultMemberToRemove : faultMembersToRemove)
					{
						faultFamily.getFaultMembers().remove(faultMemberToRemove);
						session.delete(faultMemberToRemove);
					}
					session.update(faultFamily);
				}

				// copy all
			    Set<FaultCode> faultCodesToRemove = new HashSet<FaultCode>(faultFamily.getFaultCodes());

			    // add fault codes
				for (alma.acs.alarmsystem.generated.FaultCode daoFaultCode : family.getFaultCode())
				{
					CriteriaQuery<FaultCode> cqFaultCode = cb.createQuery(FaultCode.class);
					Root<FaultCode> itemFaultCode = cqFaultCode.from(FaultCode.class);
					cqFaultCode.select(itemFaultCode).where(
						cb.equal(itemFaultCode.get("faultFamily"), faultFamily),
						cb.equal(itemFaultCode.get("codeValue"), (int) daoFaultCode.getValue())
					);
					TypedQuery<FaultCode> queryFaultCode = session.createQuery(cqFaultCode);
					FaultCode faultCode = null;
					try {
						faultCode = queryFaultCode.getSingleResult();
					} catch (NoResultException e) {
						faultCode = null;
					}
					faultCodesToRemove.remove(faultCode);
					if (faultCode == null)
					{
						faultCode = new FaultCode();
						faultCode.setFaultFamily(faultFamily);
						faultCode.setCodeValue((int)daoFaultCode.getValue());
					}
					faultCode.setPriority(daoFaultCode.getPriority());
					faultCode.setCause(daoFaultCode.getCause());
					faultCode.setAction(daoFaultCode.getAction());
					faultCode.setConsequence(daoFaultCode.getConsequence());
					faultCode.setProblemDescription(nonEmptyString(daoFaultCode.getProblemDescription(), "(description)"));
					faultCode.setIsInstant(daoFaultCode.getInstant());
					session.saveOrUpdate(faultCode);
				}

				if (faultCodesToRemove.size() > 0)
				{
					for (FaultCode faultCodeToRemove : faultCodesToRemove)
					{
						faultFamily.getFaultCodes().remove(faultCodeToRemove);
						session.delete(faultCodeToRemove);
					}
					session.update(faultFamily);
				}
			}

		try
		{
			alma.alarmsystem.alarmmessage.generated.ReductionDefinitions redDefs = alarmDAO.getReductionDefinitions();
			if (redDefs != null)
			{
				if (redDefs.getLinksToCreate() != null)
					saveReductionLinks(session, config, redDefs.getLinksToCreate().getReductionLink(), ReductionLinkAction.CREATE);
				if (redDefs.getLinksToRemove() != null)
					saveReductionLinks(session, config, redDefs.getLinksToRemove().getReductionLink(), ReductionLinkAction.REMOVE);

				 int count = 0;
				 if (redDefs.getThresholds() != null)
				 {
					 alma.alarmsystem.alarmmessage.generated.Threshold[] thresholds = redDefs.getThresholds().getThreshold();
					 for ( alma.alarmsystem.alarmmessage.generated.Threshold threshold : thresholds)
					 {
						// also commit first
						if (count % 100 == 0)
						{
							session.getTransaction().commit();
							session.clear();		// cleanup first level cache
							session.beginTransaction();
							config = (Configuration)session.get(Configuration.class, config.getConfigurationId());
						}

						count++;

						alma.acs.tmcdb.AlarmDefinition alarm = getAlarmDefinition(session, config, threshold.getAlarmDefinition(), false);
						alma.acs.tmcdb.ReductionThreshold t = (alma.acs.tmcdb.ReductionThreshold)session.createQuery("from ReductionThreshold " +
						        "where AlarmDefinitionId = " + alarm.getAlarmDefinitionId()).uniqueResult();

						if (t == null)
						{
							t = new ReductionThreshold();
							t.setAlarmDefinition(alarm);
							t.setConfiguration(config);
						}
						t.setValue(threshold.getValue());
						session.saveOrUpdate(t);
					 }
				 }
			}
		}
		finally
		{
			// clear cache (to free memory)
			adCache.clear();
		}
	}

	private static String trimAndNullToEmpty(String s) {
		if( s == null )
			return "";
		return s.trim();
	}

	private static void saveReductionLinks(Session session, Configuration config, alma.alarmsystem.alarmmessage.generated.ReductionLinkType[] links, ReductionLinkAction action)
	{
		int count = 0;

		for (alma.alarmsystem.alarmmessage.generated.ReductionLinkType link : links)
		{
			// also commit first
			if (count % 100 == 0)
			{
				session.getTransaction().commit();
				session.clear();		// cleanup first level cache
				adCache.clear();
				session.beginTransaction();
				// refresh
				config = (Configuration)session.get(Configuration.class, config.getConfigurationId());
			}

			count++;

			alma.acs.tmcdb.AlarmDefinition parent = getAlarmDefinition(session, config, link.getParent().getAlarmDefinition(), true);
			alma.acs.tmcdb.AlarmDefinition child = getAlarmDefinition(session, config, link.getChild().getAlarmDefinition(), true);

			CriteriaBuilder cb = session.getCriteriaBuilder();
			CriteriaQuery<alma.acs.tmcdb.ReductionLink> cqReductionLink = cb.createQuery(alma.acs.tmcdb.ReductionLink.class);
			Root<alma.acs.tmcdb.ReductionLink> itemReductionLink = cqReductionLink.from(alma.acs.tmcdb.ReductionLink.class);
			cqReductionLink.select(itemReductionLink).where(
				cb.equal(itemReductionLink.get("alarmDefinitionByParentalarmdefid"), parent),
				cb.equal(itemReductionLink.get("alarmDefinitionByChildalarmdefid"), child)
			);
			TypedQuery<alma.acs.tmcdb.ReductionLink> queryReductionLink = session.createQuery(cqReductionLink);
			alma.acs.tmcdb.ReductionLink remoteLink = null;
			try {
				remoteLink = queryReductionLink.getSingleResult();
			} catch (NoResultException e) {
				remoteLink = null;
			}
			if (remoteLink == null) {

				remoteLink = new alma.acs.tmcdb.ReductionLink();
				remoteLink.setAlarmDefinitionByChildalarmdefid(child);
				remoteLink.setAlarmDefinitionByParentalarmdefid(parent);
				remoteLink.setConfiguration(config);

			}
			remoteLink.setAction(action);
			remoteLink.setType(ReductionLinkType.valueOf(link.getType().toString()));
			session.saveOrUpdate(remoteLink);
		}

		// and commit
		session.getTransaction().commit();
		session.clear();
		session.beginTransaction();
	}

	// NODE: only FF, FM and FC are checked, and they must be non-null (XSD)
	private static class ADWrapper
	{

		private final alma.alarmsystem.alarmmessage.generated.AlarmDefinition ad;

		public ADWrapper(alma.alarmsystem.alarmmessage.generated.AlarmDefinition ad)
		{
			this.ad = ad;
		}

		@Override
		public int hashCode()
		{
			return 213 * ad.getFaultFamily().hashCode() + 17 * ad.getFaultMember().hashCode() + ad.getFaultCode();
		}

		@Override
		public boolean equals(Object object)
		{
			if (!(object instanceof ADWrapper))
				return false;
			ADWrapper other = (ADWrapper)object;

			return
				ad.getFaultFamily().equals(other.ad.getFaultFamily()) &&
				ad.getFaultMember().equals(other.ad.getFaultMember()) &&
				ad.getFaultCode() == other.ad.getFaultCode();
		}

		@Override
		public String toString()
		{
			StringBuilder sb = new StringBuilder();
			sb.append("FF: ").append(ad.getFaultFamily()).append(", FM: ").append(ad.getFaultMember()).append(", FC:").append(ad.getFaultCode());
			return sb.toString();
		}
	}

	static Map<ADWrapper, alma.acs.tmcdb.AlarmDefinition> adCache = new HashMap<ADWrapper, alma.acs.tmcdb.AlarmDefinition>();

	private static alma.acs.tmcdb.AlarmDefinition getAlarmDefinition(Session session, Configuration config, alma.alarmsystem.alarmmessage.generated.AlarmDefinition alarmDef, boolean allowFMCreation)
	{
		// cache check
		ADWrapper wrappedAD = new ADWrapper(alarmDef);
		alma.acs.tmcdb.AlarmDefinition cachedAD = adCache.get(wrappedAD);
		if (cachedAD != null)
			return cachedAD;

		CriteriaBuilder cb = session.getCriteriaBuilder();
		CriteriaQuery<alma.acs.tmcdb.AlarmDefinition> cqAlarmDef = cb.createQuery(alma.acs.tmcdb.AlarmDefinition.class);
		Root<alma.acs.tmcdb.AlarmDefinition> itemAlarmDef = cqAlarmDef.from(alma.acs.tmcdb.AlarmDefinition.class);
		cqAlarmDef.select(itemAlarmDef).where(
			cb.equal(itemAlarmDef.get("faultFamily"), alarmDef.getFaultFamily()),
			cb.equal(itemAlarmDef.get("faultMember"), alarmDef.getFaultMember()),
			cb.equal(itemAlarmDef.get("faultCode"), String.valueOf(alarmDef.getFaultCode()))
		);
		TypedQuery<alma.acs.tmcdb.AlarmDefinition> queryAlarmDef = session.createQuery(cqAlarmDef);
		alma.acs.tmcdb.AlarmDefinition alarm = null;
		try {
			alarm = queryAlarmDef.getSingleResult();
		} catch (NoResultException e) {
			alarm = null;
		}
		if (alarm == null)
		{
			alarm = new alma.acs.tmcdb.AlarmDefinition();
			alarm.setConfiguration(config);
			alarm.setFaultFamily(alarmDef.getFaultFamily());
			alarm.setFaultMember(alarmDef.getFaultMember());
			alarm.setFaultCode(String.valueOf(alarmDef.getFaultCode()));	// TODO remove
			session.persist(alarm);
		}

		// put to cache
		adCache.put(wrappedAD, alarm);

		return alarm;
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#importEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, com.cosylab.cdb.client.CDBAccess)
	 */
	public void importEpilogue(Session session, Configuration config, final CDBAccess cdbAccess) {

		try
        {
        	m_logger.config("Importing ACS Alarm System configuration...");

    		ConfigurationAccessor conf = new ConfigurationAccessor()
    		{
				public String getConfiguration(String path) throws Exception {
					return cdbAccess.getDAL().get_DAO(path);
				}

				public boolean isWriteable() {
					return false;
				}

				public void setConfiguration(String path, String data) throws Exception {
					// noop
				}

				public void deleteConfiguration(String path) throws Exception {
					// noop
				}
    		};

    		importAlarms(session, config, conf, m_logger);

          }
		catch (Throwable th)
		{
			// ugly but...
			if (th.getMessage() != null && th.getMessage().startsWith("Couldn't read alarm"))
			{
				m_logger.warning("Alarm system configuration could not be read, skipping...");
			}
			else
				m_logger.log(Level.SEVERE, "Failed to import all the alarm data.", th);
		}
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#importPrologue(org.hibernate.Session, alma.acs.tmcdb.Configuration, com.cosylab.cdb.client.CDBAccess)
	 */
	public void importPrologue(Session session, Configuration config, CDBAccess cdbAccess) {
		// noop
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#loadControlDevices(org.hibernate.Session, alma.acs.tmcdb.Configuration, com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin.ControlDeviceBindCallback)
	 */
	public void loadControlDevices(Session session, Configuration config, ControlDeviceBindCallback bindCallback) {
		// noop
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#controlDeviceImportEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, com.cosylab.cdb.client.CDBAccess, java.lang.String, alma.TMCDB.generated.Component)
	 */
	public void controlDeviceImportEpilogue(Session session, Configuration config,
			CDBAccess cdbAccess, String componentName, Component component) {
		// noop
	}

	private static final alma.TMCDB.alarm.Location getLocation(Session session, Location loc)
	{
		if (loc != null)
		{
			return new alma.TMCDB.alarm.Location(
							loc.getBuilding(),
							loc.getFloor(),
							loc.getRoom(),
							loc.getMnemonic(),
							loc.getLocationPosition()
							);
		}
		else
			return null;
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#loadEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	public void loadEpilogue(Session session, Configuration config, Map<String, Object> rootMap) {
		loadEpilogue(session, config, rootMap, m_logger);
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#loadEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	@SuppressWarnings("unchecked")
	public static void loadEpilogue(Session session, Configuration config, Map<String, Object> rootMap, Logger m_logger) {

		try
		{
			DOMConfigurationAccessor conf = new DOMConfigurationAccessor();
			conf.setSession(session);

			Map<String, Object> alarmsRoot = new RootMap<String, Object>();

			Map<String, Object> administrativeRoot = new RootMap<String, Object>();
			alarmsRoot.put("Administrative", administrativeRoot);

			administrativeRoot.put("AlarmSystemConfiguration", new AlarmSystemConfiguration());

			Categories categoriesMap = new Categories(session, config, conf, rootMap, m_logger);
			administrativeRoot.put("Categories", categoriesMap);

			conf.put(Categories.CATEGORY_DEFINITION_PATH, categoriesMap);

			// categories
			int counter = 0;
			CriteriaBuilder cb = session.getCriteriaBuilder();
			CriteriaQuery<AlarmCategory> cqAlarm = cb.createQuery(AlarmCategory.class);
			Root<AlarmCategory> itemAlarm = cqAlarm.from(AlarmCategory.class);
			cqAlarm.select(itemAlarm).where(
				cb.equal(itemAlarm.get("configuration"), config)
			);
			List<AlarmCategory> categories = session.createQuery(cqAlarm).getResultList();
			for (AlarmCategory category : categories)
			{
				ArrayList<String> families = new ArrayList<String>();
				for (FaultFamily family : category.getFaultFamilies())
					families.add(family.getFamilyName());

				categoriesMap.put("category" + String.valueOf(counter++),
						new alma.TMCDB.alarm.Category(
								category.getPath(),
								category.getDescription(),
								category.getIsDefault(),
								families.toArray(new String[families.size()])));
			}

			// fault families
			Map<String, alma.TMCDB.alarm.FaultFamily> faultFamiliesMap = new FaultFamiliesMap(session, config, conf, rootMap, m_logger);
			alarmsRoot.put("AlarmDefinitions", faultFamiliesMap);

			conf.put(FaultFamiliesMap.ALARM_CATEGORY_DEFINITION_PATH, faultFamiliesMap);

			counter = 0;
			CriteriaQuery<FaultFamily> cqFamily = cb.createQuery(FaultFamily.class);
			Root<FaultFamily> itemFamily = cqFamily.from(FaultFamily.class);
			cqFamily.select(itemFamily).where(
				cb.equal(itemFamily.get("configuration"), config)
			);
			cqFamily.orderBy(cb.asc(itemFamily.get("familyName")));
			List<FaultFamily> families = session.createQuery(cqFamily).getResultList();
			for (FaultFamily family : families)
			{
				Contact contact = family.getContact();

				alma.TMCDB.alarm.FaultFamily faultFamily =
					new alma.TMCDB.alarm.FaultFamily(
						family.getFamilyName(),
						family.getAlarmSource(),
						family.getHelpURL(),
						new alma.TMCDB.alarm.Contact(
								contact.getContactName(),
								contact.getEmail(),
								contact.getGsm()));

				faultFamiliesMap.put("fault-family" + String.valueOf(counter++), faultFamily);

				// fault codes
				int codeCounter = 0;
				CriteriaQuery<FaultCode> cqFaultCode = cb.createQuery(FaultCode.class);
				Root<FaultCode> itemFaultCode = cqFaultCode.from(FaultCode.class);
				cqFaultCode.select(itemFaultCode).where(
					cb.equal(itemFaultCode.get("faultFamily"), family)
				);
				List<FaultCode> faultCodes = session.createQuery(cqFaultCode).getResultList();
				for (FaultCode faultCode : faultCodes)
				{
					faultFamily.e.put("fault-code" + String.valueOf(codeCounter++),
							new alma.TMCDB.alarm.FaultCode(
									faultCode.getCodeValue(),
									faultCode.getIsInstant(),
									faultCode.getPriority(),
									faultCode.getCause(),
									faultCode.getAction(),
									faultCode.getConsequence(),
									faultCode.getProblemDescription()));
				}

				// default fault member
				CriteriaQuery<DefaultMember> cqDefault = cb.createQuery(DefaultMember.class);
				Root<DefaultMember> itemDefault = cqDefault.from(DefaultMember.class);
				cqDefault.select(itemDefault).where(
					cb.equal(itemDefault.get("faultFamily"), family)
				);
				TypedQuery<DefaultMember> queryDefault = session.createQuery(cqDefault);
				DefaultMember defaultMember = null;
				try {
					defaultMember = queryDefault.getSingleResult();
				} catch (NoResultException e) {
					defaultMember = null;
				}
				if (defaultMember != null)
				{
					alma.TMCDB.alarm.Location location = getLocation(session, defaultMember.getLocation());

					faultFamily.e.put("fault-member-default", new FaultMemberDefault(location));
				}


				// fault members
				int faultMemberCounter = 0;
				CriteriaQuery<FaultMember> cqFaultMember = cb.createQuery(FaultMember.class);
				Root<FaultMember> itemFaultMember = cqFaultMember.from(FaultMember.class);
				cqFaultMember.select(itemFaultMember).where(
					cb.equal(itemFaultMember.get("faultFamily"), family)
				);
				List<FaultMember> faultMembers = session.createQuery(cqFaultMember).getResultList();
				for (FaultMember faultMember : faultMembers)
				{
					alma.TMCDB.alarm.Location location = getLocation(session, faultMember.getLocation());

					faultFamily.e.put("fault-member" + String.valueOf(faultMemberCounter++),
							new alma.TMCDB.alarm.FaultMember(faultMember.getMemberName(), location));
				}
			}

			// reductions
			ReductionDefinitions redDefs = new ReductionDefinitions(session, config, conf, rootMap, m_logger);
			administrativeRoot.put("ReductionDefinitions", redDefs);

			int linkCount = 0;
			CriteriaQuery<alma.acs.tmcdb.ReductionLink> cqReductionLink = cb.createQuery(alma.acs.tmcdb.ReductionLink.class);
			Root<alma.acs.tmcdb.ReductionLink> itemReductionLink = cqReductionLink.from(alma.acs.tmcdb.ReductionLink.class);
			cqReductionLink.select(itemReductionLink).where(
				cb.equal(itemReductionLink.get("configuration"), config)
			);
			List<alma.acs.tmcdb.ReductionLink> links = session.createQuery(cqReductionLink).getResultList();
			for (alma.acs.tmcdb.ReductionLink link : links)
			{
				alma.acs.tmcdb.AlarmDefinition parent = link.getAlarmDefinitionByParentalarmdefid();
				alma.acs.tmcdb.AlarmDefinition child = link.getAlarmDefinitionByChildalarmdefid();
				ReductionLinks toLink;
				if (link.getAction() == ReductionLinkAction.CREATE)
					toLink = redDefs.getLinksToCreate();
				else if (link.getAction() == ReductionLinkAction.REMOVE)
					toLink = redDefs.getLinksToRemove();
				else
					throw new RuntimeException("unsupported reduction link action '" + link.getAction() + "' for ReductionLink with id: " + link.getReductionLinkId());

				toLink.e.put("link" + (linkCount++),
						new ReductionLink(link.getType().toString(),
								new AlarmDefinition(
										parent.getFaultFamily(),
										parent.getFaultMember(),
										parent.getFaultCode()),
								new AlarmDefinition(
										child.getFaultFamily(),
										child.getFaultMember(),
										child.getFaultCode())
						));
			}


			int thresholdCount = 0;
			CriteriaQuery<alma.acs.tmcdb.ReductionThreshold> cqReductionT = cb.createQuery(alma.acs.tmcdb.ReductionThreshold.class);
			Root<alma.acs.tmcdb.ReductionThreshold> itemReductionT = cqReductionT.from(alma.acs.tmcdb.ReductionThreshold.class);
			cqReductionT.select(itemReductionT).where(
				cb.equal(itemReductionT.get("configuration"), config)
			);
			List<alma.acs.tmcdb.ReductionThreshold> thresholds = session.createQuery(cqReductionT).getResultList();
			for (alma.acs.tmcdb.ReductionThreshold threshold : thresholds)
			{
				alma.acs.tmcdb.AlarmDefinition alarm = threshold.getAlarmDefinition();

				redDefs.getThresholds().e.put("threshold" + (thresholdCount++),
						new alma.TMCDB.alarm.ReductionThreshold(threshold.getValue(),
								new AlarmDefinition(
										alarm.getFaultFamily(),
										alarm.getFaultMember(),
										alarm.getFaultCode())
						));
			}

			// alarm configuration
			rootMap.put("Alarms", alarmsRoot);
		}
		catch (Throwable th)
		{
			m_logger.log(Level.SEVERE, "Failed to load all the alarm data.", th);
		}

	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#loadPrologue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	public void loadPrologue(Session session, Configuration config, Map<String, Object> rootMap) {
		// noop
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#updateControlDevices(org.hibernate.Session, alma.acs.tmcdb.Configuration, com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin.ControlDeviceBindCallback)
	 */
	public void updateControlDevices(Session session, Configuration config, ControlDeviceBindCallback bindCallback, String curl) {
		// noop
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#updateEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	public void updateEpilogue(Session session, Configuration config, Map<String, Object> rootMap, String curl) {
		//updateEpilogue(session, config, rootMap, m_logger, curl);
	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#updateEpilogue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	@SuppressWarnings("unchecked")
	public static void updateEpilogue(Session session, Configuration config, Map<String, Object> rootMap, Logger m_logger, String curl) {
		if(!curl.startsWith("Alarms"))
			return;
		else if(curl.matches("Alarms")) {
			loadEpilogue(session, config, rootMap, m_logger);
			return;
		}
		String c = curl.replaceFirst("Alarms/", "");

		try
		{
			DOMConfigurationAccessor conf = new DOMConfigurationAccessor();
			conf.setSession(session);

			Map<String, Object> alarmsRoot = new RootMap<String, Object>();

			Map<String, Object> administrativeRoot = new RootMap<String, Object>();
			alarmsRoot.put("Administrative", administrativeRoot);

			administrativeRoot.put("AlarmSystemConfiguration", new AlarmSystemConfiguration());

			Categories categoriesMap = new Categories(session, config, conf, rootMap, m_logger);
			administrativeRoot.put("Categories", categoriesMap);

			conf.put(Categories.CATEGORY_DEFINITION_PATH, categoriesMap);

			// categories
			int counter = 0;
			CriteriaBuilder cb = session.getCriteriaBuilder();
			CriteriaQuery<AlarmCategory> cqAlarmCategory = cb.createQuery(AlarmCategory.class);
			Root<AlarmCategory> itemAlarmCategory = cqAlarmCategory.from(AlarmCategory.class);
			cqAlarmCategory.select(itemAlarmCategory).where(
				cb.equal(itemAlarmCategory.get("configuration"), config)
			);
			List<AlarmCategory> categories = session.createQuery(cqAlarmCategory).getResultList();
			for (AlarmCategory category : categories)
			{
				ArrayList<String> families = new ArrayList<String>();
				for (FaultFamily family : category.getFaultFamilies())
					families.add(family.getFamilyName());

				categoriesMap.put("category" + String.valueOf(counter++),
						new alma.TMCDB.alarm.Category(
								category.getPath(),
								category.getDescription(),
								category.getIsDefault(),
								families.toArray(new String[families.size()])));
			}

			// fault families
			Map<String, alma.TMCDB.alarm.FaultFamily> faultFamiliesMap = new FaultFamiliesMap(session, config, conf, rootMap, m_logger);
			alarmsRoot.put("AlarmDefinitions", faultFamiliesMap);

			conf.put(FaultFamiliesMap.ALARM_CATEGORY_DEFINITION_PATH, faultFamiliesMap);

			counter = 0;
			CriteriaQuery<FaultFamily> cqFaultFamily = cb.createQuery(FaultFamily.class);
			Root<FaultFamily> itemFaultFamily = cqFaultFamily.from(FaultFamily.class);
			cqFaultFamily.select(itemFaultFamily).where(
				cb.equal(itemFaultFamily.get("configuration"), config)
			);
			cqFaultFamily.orderBy(cb.asc(itemFaultFamily.get("familyName")));
			List<FaultFamily> families = session.createQuery(cqFaultFamily).getResultList();
			for (FaultFamily family : families)
			{
				Contact contact = family.getContact();

				alma.TMCDB.alarm.FaultFamily faultFamily =
					new alma.TMCDB.alarm.FaultFamily(
						family.getFamilyName(),
						family.getAlarmSource(),
						family.getHelpURL(),
						new alma.TMCDB.alarm.Contact(
								contact.getContactName(),
								contact.getEmail(),
								contact.getGsm()));

				faultFamiliesMap.put("fault-family" + String.valueOf(counter++), faultFamily);

				// fault codes
				int codeCounter = 0;
				CriteriaQuery<FaultCode> cqFaultCode = cb.createQuery(FaultCode.class);
				Root<FaultCode> itemFaultCode = cqFaultCode.from(FaultCode.class);
				cqFaultCode.select(itemFaultCode).where(
					cb.equal(itemFaultCode.get("faultFamily"), family)
				);
				List<FaultCode> faultCodes = session.createQuery(cqFaultCode).getResultList();
				for (FaultCode faultCode : faultCodes)
				{
					faultFamily.e.put("fault-code" + String.valueOf(codeCounter++),
							new alma.TMCDB.alarm.FaultCode(
									faultCode.getCodeValue(),
									faultCode.getIsInstant(),
									faultCode.getPriority(),
									faultCode.getCause(),
									faultCode.getAction(),
									faultCode.getConsequence(),
									faultCode.getProblemDescription()));
				}

				// default fault member
				CriteriaQuery<DefaultMember> cq = cb.createQuery(DefaultMember.class);
				Root<DefaultMember> item = cq.from(DefaultMember.class);
				cq.select(item).where(
					cb.equal(item.get("faultFamily"), family)
				);
				DefaultMember defaultMember = null;
				try {
					defaultMember = session.createQuery(cq).getSingleResult();
				} catch (NoResultException e) {
					defaultMember = null;
				}
				if (defaultMember != null)
				{
					alma.TMCDB.alarm.Location location = getLocation(session, defaultMember.getLocation());

					faultFamily.e.put("fault-member-default", new FaultMemberDefault(location));
				}


				// fault members
				int faultMemberCounter = 0;
				CriteriaQuery<FaultMember> cqFaultMember = cb.createQuery(FaultMember.class);
				Root<FaultMember> itemFaultMember = cqFaultMember.from(FaultMember.class);
				cqFaultMember.select(itemFaultMember).where(
					cb.equal(itemFaultMember.get("faultFamily"), family)
				);
				List<FaultMember> faultMembers = session.createQuery(cqFaultMember).getResultList();
				for (FaultMember faultMember : faultMembers)
				{
					alma.TMCDB.alarm.Location location = getLocation(session, faultMember.getLocation());

					faultFamily.e.put("fault-member" + String.valueOf(faultMemberCounter++),
							new alma.TMCDB.alarm.FaultMember(faultMember.getMemberName(), location));
				}
			}

			// reductions
			ReductionDefinitions redDefs = new ReductionDefinitions(session, config, conf, rootMap, m_logger);
			administrativeRoot.put("ReductionDefinitions", redDefs);

			int linkCount = 0;
			CriteriaQuery<alma.acs.tmcdb.ReductionLink> cq = cb.createQuery(alma.acs.tmcdb.ReductionLink.class);
			Root<alma.acs.tmcdb.ReductionLink> item = cq.from(alma.acs.tmcdb.ReductionLink.class);
			cq.select(item).where(
				cb.equal(item.get("configuration"), config)
			);
			List<alma.acs.tmcdb.ReductionLink> links = session.createQuery(cq).getResultList();
			for (alma.acs.tmcdb.ReductionLink link : links)
			{
				alma.acs.tmcdb.AlarmDefinition parent = link.getAlarmDefinitionByParentalarmdefid();
				alma.acs.tmcdb.AlarmDefinition child = link.getAlarmDefinitionByChildalarmdefid();
				ReductionLinks toLink;
				if (link.getAction() == ReductionLinkAction.CREATE)
					toLink = redDefs.getLinksToCreate();
				else if (link.getAction() == ReductionLinkAction.REMOVE)
					toLink = redDefs.getLinksToRemove();
				else
					throw new RuntimeException("unsupported reduction link action '" + link.getAction() + "' for ReductionLink with id: " + link.getReductionLinkId());

				toLink.e.put("link" + (linkCount++),
						new ReductionLink(link.getType().toString(),
								new AlarmDefinition(
										parent.getFaultFamily(),
										parent.getFaultMember(),
										parent.getFaultCode()),
								new AlarmDefinition(
										child.getFaultFamily(),
										child.getFaultMember(),
										child.getFaultCode())
						));
			}


			int thresholdCount = 0;
			CriteriaQuery<alma.acs.tmcdb.ReductionThreshold> cqReductionTh = cb.createQuery(alma.acs.tmcdb.ReductionThreshold.class);
			Root<alma.acs.tmcdb.ReductionThreshold> itemReductionTh = cqReductionTh.from(alma.acs.tmcdb.ReductionThreshold.class);
			cqReductionTh.select(itemReductionTh).where(
				cb.equal(itemReductionTh.get("configuration"), config)
			);
			List<alma.acs.tmcdb.ReductionThreshold> thresholds = session.createQuery(cqReductionTh).getResultList();
			for (alma.acs.tmcdb.ReductionThreshold threshold : thresholds)
			{
				alma.acs.tmcdb.AlarmDefinition alarm = threshold.getAlarmDefinition();

				redDefs.getThresholds().e.put("threshold" + (thresholdCount++),
						new alma.TMCDB.alarm.ReductionThreshold(threshold.getValue(),
								new AlarmDefinition(
										alarm.getFaultFamily(),
										alarm.getFaultMember(),
										alarm.getFaultCode())
						));
			}

			// alarm configuration
			rootMap.put("Alarms", alarmsRoot);
		}
		catch (Throwable th)
		{
			m_logger.log(Level.SEVERE, "Failed to update all the alarm data.", th);
		}

	}

	/* (non-Javadoc)
	 * @see com.cosylab.cdb.jdal.hibernate.plugin.HibernateWDALPlugin#updatePrologue(org.hibernate.Session, alma.acs.tmcdb.Configuration, java.util.Map)
	 */
	public void updatePrologue(Session session, Configuration config, Map<String, Object> rootMap, String curl) {
		// noop
	}

	public String[] getCreateTablesScriptList(String backend) {
		return null;
	}

}


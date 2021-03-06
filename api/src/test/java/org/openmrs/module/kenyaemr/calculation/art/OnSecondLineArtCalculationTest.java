/**
 * The contents of this file are subject to the OpenMRS Public License
 * Version 1.0 (the "License"); you may not use this file except in
 * compliance with the License. You may obtain a copy of the License at
 * http://license.openmrs.org
 *
 * Software distributed under the License is distributed on an "AS IS"
 * basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 * License for the specific language governing rights and limitations
 * under the License.
 *
 * Copyright (C) OpenMRS, LLC.  All Rights Reserved.
 */
package org.openmrs.module.kenyaemr.calculation.art;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openmrs.Concept;
import org.openmrs.api.context.Context;
import org.openmrs.calculation.patient.PatientCalculationService;
import org.openmrs.calculation.result.CalculationResultMap;
import org.openmrs.module.kenyaemr.regimen.RegimenManager;
import org.openmrs.module.kenyaemr.test.TestUtils;
import org.openmrs.test.BaseModuleContextSensitiveTest;

import java.io.InputStream;
import java.util.Arrays;
import java.util.List;

public class OnSecondLineArtCalculationTest extends BaseModuleContextSensitiveTest {

	@Before
	public void beforeEachTest() throws Exception {
		executeDataSet("test-data.xml");
		executeDataSet("test-drugdata.xml");

		InputStream stream = getClass().getClassLoader().getResourceAsStream("metadata/Kenya_EMR_Regimens.xml");
		RegimenManager.loadDefinitionsFromXML(stream);
	}

	/**
	 * @see OnSecondLineArtCalculation#evaluate(java.util.Collection, java.util.Map, org.openmrs.calculation.patient.PatientCalculationContext)
	 */
	@Test
	public void evaluate_shouldCalculateCurrentArtRegimen() throws Exception {

		Concept azt = Context.getConceptService().getConcept(86663);
		Concept _3tc = Context.getConceptService().getConcept(78643);
		Concept efv = Context.getConceptService().getConcept(75523);
		Concept lpv = Context.getConceptService().getConcept(79040);
		Concept rtv = Context.getConceptService().getConcept(83412);

		// Put patient #7 on AZT + 3TC + EFV
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(7), azt, TestUtils.date(2011, 1, 1), null);
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(7), _3tc, TestUtils.date(2011, 1, 1), null);
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(7), efv, TestUtils.date(2011, 1, 1), null);

		// Put patient #8 on AZT + 3TC + LPV/r
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(8), azt, TestUtils.date(2011, 1, 1), null);
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(8), _3tc, TestUtils.date(2011, 1, 1), null);
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(8), lpv, TestUtils.date(2011, 1, 1), null);
		TestUtils.saveDrugOrder(Context.getPatientService().getPatient(8), rtv, TestUtils.date(2011, 1, 1), null);

		Context.flushSession();
		
		List<Integer> cohort = Arrays.asList(6, 7, 8);

		CalculationResultMap resultMap = new OnSecondLineArtCalculation().evaluate(cohort, null, Context.getService(PatientCalculationService.class).createCalculationContext());
		Assert.assertFalse((Boolean) resultMap.get(6).getValue()); // isn't on any drugs
		Assert.assertFalse((Boolean) resultMap.get(7).getValue()); // is on first line regimen
		Assert.assertTrue((Boolean) resultMap.get(8).getValue()); // is on second line regimen
	}
}
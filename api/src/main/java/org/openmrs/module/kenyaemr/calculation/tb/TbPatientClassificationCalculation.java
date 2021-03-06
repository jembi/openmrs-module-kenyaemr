/*
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

package org.openmrs.module.kenyaemr.calculation.tb;

import org.openmrs.calculation.patient.PatientCalculationContext;
import org.openmrs.calculation.result.CalculationResultMap;
import org.openmrs.module.kenyaemr.MetadataConstants;
import org.openmrs.module.kenyaemr.calculation.BaseKenyaEmrCalculation;

import java.util.Collection;
import java.util.Map;

/**
 * Calculates patient's TB disease classification
 */
public class TbPatientClassificationCalculation extends BaseKenyaEmrCalculation {

    @Override
    public String getShortMessage() {
        return "TB Disease Classification";
    }

	@Override
	public String[] getTags() {
		return new String[] { "tb" };
	}

    @Override
    public CalculationResultMap evaluate(Collection<Integer> cohort, Map<String, Object> arg1, PatientCalculationContext context) {
		return lastObs(MetadataConstants.RESULTS_TUBERCULOSIS_CULTURE_CONCEPT_UUID, cohort, context);
    }
}
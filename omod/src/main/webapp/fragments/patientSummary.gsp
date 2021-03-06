<%
	ui.decorateWith("kenyaemr", "panel", [ heading: "Patient Summary", editUrl: ui.pageLink("kenyaemr", "registrationEditPatient", [patientId: patient.id, returnUrl: ui.thisUrl() ]) ])

	config.require("patient")
	def patient = config.patient

	def ps = context.patientService
	def clinicNumberIdType = ps.getPatientIdentifierTypeByUuid(MetadataConstants.PATIENT_CLINIC_NUMBER_UUID)
	def hivNumberIdType = ps.getPatientIdentifierTypeByUuid(MetadataConstants.UNIQUE_PATIENT_NUMBER_UUID)
%>

<div class="stack-item">
	<b>${ ui.includeFragment("kenyaemr", "kenyaemrPersonName", [ name: patient.personName ]) }<br />
	${ ui.message("Patient.gender." + (patient.gender == 'M' ? 'male' : 'female')) },
	${ ui.includeFragment("kenyaemr", "kenyaemrPersonAgeAndBirthdate", [ person: patient ]) }</b>
</div>

<div class="stack-item">
	<% [ clinicNumberIdType, hivNumberIdType ].each { %>
	<span class="identifier">
		<span class="identifier-type">${ ui.format(it) }:</span>
		<span class="identifier-value">${ ui.format(patient.getPatientIdentifier(it)?.identifier) }</span><br/>
	</span>
	<% } %>
	<% if (patient.patientIdentifier.identifierType.uuid == MetadataConstants.OPENMRS_ID_UUID) {
		def prefId = patient.patientIdentifier
	%>
	<span class="identifier">
		<span class="identifier-type">${ ui.format(prefId.identifierType) }:</span>
		<span class="identifier-value">${ ui.format(prefId.identifier) }</span><br/>
	</span>
	<% } %>
</div>

<div class="stack-item">
	<% patient.activeAttributes.each { %>
	${ ui.includeFragment("kenyaemr", "dataPoint", [ label: ui.format(it.attributeType), value: it ]) }
	<% } %>
</div>
<div class="stack-item">
	${ ui.includeFragment("uilibrary", "widget/button", [
			iconProvider: "kenyaemr",
			icon: "forms/family_history.png",
			label: "Family History",
			href: ui.pageLink("kenyaemr", "editPatientHtmlForm", [
				patientId: patient.id,
				formUuid: MetadataConstants.FAMILY_HISTORY_FORM_UUID,
				returnUrl: ui.thisUrl()
			])
	]) }
	<% if (patient.gender == 'F') { %>
	${ ui.includeFragment("uilibrary", "widget/button", [
			iconProvider: "uilibrary",
			icon: "home_32.png",
			label: "Obstetric History",
			href: ui.pageLink("kenyaemr", "editPatientHtmlForm", [
				patientId: patient.id,
				formUuid: MetadataConstants.OBSTETRIC_HISTORY_FORM_UUID,
				returnUrl: ui.thisUrl()
			])
	]) }
	<% } %>
</div>
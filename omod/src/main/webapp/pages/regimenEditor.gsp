<%
	ui.decorateWith("kenyaemr", "standardKenyaEmrPage", [ patient: patient, layout: "sidebar" ])

	def allowNew = !history.changes
	def allowChange = history.changes && history.changes.last().started
	def allowRestart = history.changes && !history.changes.last().started
	def allowUndo = history.changes && history.changes.size() > 0

	// Create HTML options for each ARV drug
	def drugOptions = arvs.collect {
			"""<option value="${ it.conceptId }">${ it.getPreferredName(Locale.ENGLISH) }</option>"""
	}.join()

	// Create HTML options for each group of ARV regimen
	def refDefIndex = 0;
	def regimenAdult1Options = regimenDefinitions.findAll({ it.group == "adult-first" }).collect { reg ->
		"""<option value="${ refDefIndex++ }">${ reg.name }</option>"""
	}.join()
	def regimenAdult2Options = regimenDefinitions.findAll({ it.group == "adult-second" }).collect { reg ->
		"""<option value="${ refDefIndex++ }">${ reg.name }</option>"""
	}.join()
	def regimenChild1Options = regimenDefinitions.findAll({ it.group == "child-first" }).collect { reg ->
		"""<option value="${ refDefIndex++ }">${ reg.name }</option>"""
	}.join()

	def unitsOptions = [ "mg", "ml", "tab" ].collect { """<option value="${ it }">${ it }</option>""" }.join()
	def frequencyOptions = [ OD: "Once daily", BD: "Twice daily", NOCTE: "Nightly"  ].collect { """<option value="${ it.key }">${ it.key } (${ it.value })</option>""" }.join()

	// Create regimen form controls
	def arvStdRegSelect = { """<select class="standard-regimen-select">
		<option label="Select..." value="" />
		<optgroup label="Adult (first line)">${ regimenAdult1Options }</optgroup>
		<optgroup label="Adult (second line)">${ regimenAdult2Options }</optgroup>
		<optgroup label="Child">${ regimenChild1Options }</optgroup>
	</select>""" }
	def arvDrugSelect = { """<select name="arv${ it }"><option value="" />${ drugOptions }</select>""" }
	def arvDoseInput = { """<input name="dosage${ it }" type="text" size="5" />""" }
	def arvUnitsSelect = { """<select name="units${ it }">${ unitsOptions }</select>""" }
	def arvFreqSelect = { """<select name="frequency${ it }">${ frequencyOptions }</select>""" }

	def arvFields = ui.decorate("uilibrary", "labeled", [ label: "Regimen" ], """
	    <i>Use standard:</i> ${ arvStdRegSelect() }<br />
		<br />
		Drug: ${ arvDrugSelect(1) } Dosage: ${ arvDoseInput(1) }${ arvUnitsSelect(1) } Frequency: ${ arvFreqSelect(1) }<br/>
		Drug: ${ arvDrugSelect(2) } Dosage: ${ arvDoseInput(2) }${ arvUnitsSelect(2) } Frequency: ${ arvFreqSelect(2) }<br/>
		Drug: ${ arvDrugSelect(3) } Dosage: ${ arvDoseInput(3) }${ arvUnitsSelect(3) } Frequency: ${ arvFreqSelect(3) }<br/>
		Drug: ${ arvDrugSelect(4) } Dosage: ${ arvDoseInput(4) }${ arvUnitsSelect(4) } Frequency: ${ arvFreqSelect(4) }
	""")
%>

<script type="text/javascript">

	var standardRegimens = ${ regimenDefinitionsJson };
	
	function choseAction(formId) {
		// Hide the regimen action buttons
		jq('#regimen-action-buttons').hide();

		ui.confirmBeforeNavigating('#' + formId);

		// Show the relevant regimen action form
		jq('#' + formId).show();
	}

	function cancelAction() {
		ui.cancelConfirmBeforeNavigating('.regimen-action-form');

		// Hide and clear all regimen action forms
		jq('.regimen-action-form').hide();
		jq('.regimen-action-form form').get(0).reset();

		// Redisplay the regimen action buttons
		jq('#regimen-action-buttons').show();
	}

	function undoLastChange() {
		if (confirm('Undo the last regimen change?')) {
			ui.getFragmentActionAsJson('kenyaemr', 'arvRegimen', 'undoLastChange', { patient: ${ patient.patientId } }, function (data) {
				ui.reloadPage();
			});
		}
	}
	
	jq(function() {
		jq('.standard-regimen-select').change(function () {
			// Get selected regimen definition
			var stdRegIndex = parseInt(jq(this).val());
			var stdReg = standardRegimens[stdRegIndex];
			var components = stdReg.components;

			// Fill out component array with nulls to make 4
			for (var extra = 0; extra < 4 - components.length; extra++) {
				components.push(null);
			}

			// Set component controls for each component of selected regimen
			for (var c = 0; c < components.length; c++) {
				var component = components[c];
				var drugField = jq(this).parent().parent().find('select[name=arv' + (c + 1) + ']');
				var doseField = jq(this).parent().parent().find('input[name=dosage' + (c + 1) + ']');
				var unitsField = jq(this).parent().parent().find('select[name=units' + (c + 1) + ']');
				var frequencyField = jq(this).parent().parent().find('select[name=frequency' + (c + 1) + ']');

				if (component) {
					drugField.val(component.conceptId);
					doseField.val(component.dose);
					unitsField.val(component.units);
					frequencyField.val(component.frequency);
				} else {
					drugField.val(null);
					doseField.val('');
					unitsField.val(null);
					frequencyField.val(null);
				}
			}

			// Reset select box back to 'Select...'
			jq(this).val('');
		});
	});
</script>

<div id="content-side">
	<div class="panel-frame">
		${ ui.includeFragment("kenyaemr", "widget/panelMenuItem", [ iconProvider: "kenyaemr", icon: "buttons/back.png", label: "Back", href: returnUrl ]) }
	</div>
</div>

<div id="content-main">

<div class="panel-frame">
	<div class="panel-heading">ARV Regimen History</div>
	<div class="panel-content">

	${ ui.includeFragment("kenyaemr", "regimenHistory", [ patient: patient ]) }

	<br/>

	<div id="regimen-action-buttons" style="text-align: center">
	<% if (allowNew) { %>
	${ ui.includeFragment("uilibrary", "widget/button", [ iconProvider: "kenyaemr", icon: "buttons/regimen_start.png", label: "Start", extra: "a new regimen", onClick: "choseAction('start-new-regimen')" ]) }
	<% } %>

	<% if (allowChange) { %>
	${ ui.includeFragment("uilibrary", "widget/button", [ iconProvider: "kenyaemr", icon: "buttons/regimen_change.png", label: "Change", extra: "the current regimen", onClick: "choseAction('change-regimen')" ]) }

	${ ui.includeFragment("uilibrary", "widget/button", [ iconProvider: "kenyaemr", icon: "buttons/regimen_stop.png", label: "Stop", extra: "the current regimen", onClick: "choseAction('stop-regimen')" ]) }
	<% } %>

	<% if (allowRestart) { %>
	${ ui.includeFragment("uilibrary", "widget/button", [ iconProvider: "kenyaemr", icon: "buttons/regimen_restart.png", label: "Restart", extra: "a new regimen", onClick: "choseAction('restart-regimen')" ]) }
	<% } %>

	<% if (allowUndo) { %>
	${ ui.includeFragment("uilibrary", "widget/button", [ iconProvider: "kenyaemr", icon: "buttons/undo.png", label: "Undo", extra: "the last change", onClick: "undoLastChange()" ]) }
	<% } %>
	</div>

	<% if (allowNew) { %>
	<fieldset id="start-new-regimen" class="regimen-action-form" style="display: none">
		<legend>Start ARVs</legend>

		${ ui.includeFragment("uilibrary", "widget/form", [
			fragmentProvider: "kenyaemr",
			fragment: "arvRegimen",
			action: "startRegimen",
			fields: [
				[ hiddenInputName: "patient", value: patient.id ],
				[ label: "Start Date", formFieldName: "startDate", class: java.util.Date, initialValue: new Date(), fieldFragment: "field/java.util.Date.datetime" ],
				[ value: arvFields ]
			],
			submitLabel: "Save",
			successCallbacks: [ "ui.reloadPage();" ],
			cancelLabel: "Cancel",
			cancelFunction: "cancelAction"
		]) }
	</fieldset>
	<% } %>

	<% if (allowChange) { %>
	<fieldset id="change-regimen" class="regimen-action-form" style="display: none">
		<legend>Change ARVs</legend>

		${ ui.includeFragment("uilibrary", "widget/form", [
			fragmentProvider: "kenyaemr",
			fragment: "arvRegimen",
			action: "changeRegimen",
			fields: [
				[ hiddenInputName: "patient", value: patient.id ],
				[ label: "Change Date", formFieldName: "startDate", class: java.util.Date, initialValue: new Date(), fieldFragment: "field/java.util.Date.datetime" ],
				[ value: arvFields ],
				[ label: "Reason for Change", formFieldName: "changeReason", class: java.lang.String ]
			],
			submitLabel: "Save",
			successCallbacks: [ "ui.reloadPage();" ],
			cancelLabel: "Cancel",
			cancelFunction: "cancelAction"
		]) }
	</fieldset>

	<fieldset id="stop-regimen" class="regimen-action-form" style="display: none">
		<legend>Stop ARVs</legend>

		${ ui.includeFragment("uilibrary", "widget/form", [
			fragmentProvider: "kenyaemr",
			fragment: "arvRegimen",
			action: "stopRegimen",
			fields: [
				[ hiddenInputName: "patient", value: patient.id ],
				[ label: "Stop Date", formFieldName: "stopDate", class: java.util.Date, initialValue: new Date(), fieldFragment: "field/java.util.Date.datetime" ],
				[ label: "Reason for Stop", formFieldName: "stopReason", class: java.lang.String ]
			],
			submitLabel: "Save",
			successCallbacks: [ "ui.reloadPage();" ],
			cancelLabel: "Cancel",
			cancelFunction: "cancelAction"
		]) }
	</fieldset>
	<% } %>

	<% if (allowRestart) { %>
	<fieldset id="restart-regimen" class="regimen-action-form" style="display: none">
		<legend>Restart ARVs</legend>

		${ ui.includeFragment("uilibrary", "widget/form", [
			fragmentProvider: "kenyaemr",
			fragment: "arvRegimen",
			action: "startRegimen",
			fields: [
				[ hiddenInputName: "patient", value: patient.id ],
				[ label: "Restart Date", formFieldName: "startDate", class: java.util.Date, initialValue: new Date(), fieldFragment: "field/java.util.Date.datetime" ],
				[ value: arvFields ]
			],
			submitLabel: "Save",
			successCallbacks: [ "ui.reloadPage();" ],
			cancelLabel: "Cancel",
			cancelFunction: "cancelAction"
		]) }
	</fieldset>
	<% } %>

</div>
<%
	ui.decorateWith("kenyaemr", "standardKenyaEmrPage", [ layout: "sidebar" ])
%>

<div id="content-side"></div>
<div id="content-main">
	${
		ui.decorate("kenyaemr", "panel", [ heading: "Create a New Patient Record" ],
			ui.includeFragment("kenyaemr", "registrationEditPatient", [ returnUrl: returnUrl ])
		)
	}
</div>
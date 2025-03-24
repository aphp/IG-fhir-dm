Invariant: dm-0
Description: "Observation.code 72166-2|Tobacco smoking status or 11367-0|History of Tobacco use SHALL use valueCodeableConcept"
Severity: #error
Expression: "code.coding.where(code in '72166-2'|'11367-0').exists() implies value.is(CodeableConcept)"

Invariant: dm-1
Description: "For Observation.code 401201003|Cigarette pack-years or 782516008|Number of calculated smoking pack years SHOULD use valueQuantity"
Severity: #warning
Expression: "code.coding.where(code in '401201003'|'782516008').exists() implies value.is(Quantity)"

Invariant: dm-exercice-minutes-per-day
Description: "Observation.code 68516-4|On those days that you engage in moderate to strenuous exercise, how many minutes, on average, do you exercise use valueQuantity and valueQuantity.unit is minutes per day"
Severity: #error
Expression: "code.coding.where(code in '68516-4').exists() implies (value.is(Quantity) and value.ofType(Quantity).code = 'min/d')"

Invariant: dm-exercice-days-per-week
Description: "Observation.code 89555-7|How many days per week did you engage in moderate to strenuous physical activity in the last 30 days use valueQuantity and valueQuantity.unit is days per week"
Severity: #error
Expression: "code.coding.where(code in '89555-7').exists() implies (value.is(Quantity) and value.ofType(Quantity).code = 'd/wk')"

Invariant: dm-lab-1
Description: "SHALL use UCUM for valueQuantity"
Severity: #error
Expression: "(value.ofType(Quantity).system.empty() or value.ofType(Quantity).system = 'http://unitsofmeasure.org')"

Invariant: dm-lab-2
Description: "SHALL use UCUM for referenceRange unit"
Severity: #error
Expression: "referenceRange.all((low.system.empty() or low.system = 'http://unitsofmeasure.org') and (high.system.empty() or high.system = 'http://unitsofmeasure.org'))" 

Invariant: dm-lab-3
Description: "Value and referenceRange SHALL have the same unit"
Severity: #error
Expression: "((referenceRange.low.code in (value.ofType(Quantity).code)) or referenceRange.low.code.empty()) and ((referenceRange.high.code in (value.ofType(Quantity).code)) or referenceRange.high.code.empty())" 

Invariant: dm-lab-4
Description: "SHALL use UCUM for component.valueQuantity"
Severity: #error
Expression: "component.all(value.ofType(Quantity).system.empty() or value.ofType(Quantity).system = 'http://unitsofmeasure.org')"

Invariant: dm-lab-5
Description: "SHALL use UCUM for component.referenceRange unit"
Severity: #error
Expression: "component.all(referenceRange.all((low.system.empty() or low.system = 'http://unitsofmeasure.org') and (high.system.empty() or high.system = 'http://unitsofmeasure.org')))" 

Invariant: dm-lab-6
Description: "component.value and component.referenceRange SHALL have the same unit.code"
Severity: #error
Expression: "component.all(((referenceRange.low.code in (value.ofType(Quantity).code)) or referenceRange.low.code.empty()) and ((referenceRange.high.code in (value.ofType(Quantity).code)) or referenceRange.high.code.empty()))"
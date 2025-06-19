Logical: CoreAddress
Parent: Base
Characteristics: #can-be-target
Title: "CORE.ADDRESS"
Description: """
Table CORE.ADDRESS (DDL)
"""

* addressNi 1..1 integer "ADDRESS_NI"
* patientNi 1..1 Reference(CorePatient) "PATIENT_NI"
* current 0..1 boolean "CURRENT"
* zipCode 0..1 string "ZIP_CODE"
* city 0..1 string "CITY"
* country 0..1 string "COUNTRY"
* address 0..1 string "ADDRESS"
* latitude 0..1 decimal "LATITUDE"
* longitude 0..1 decimal "LONGITUDE"

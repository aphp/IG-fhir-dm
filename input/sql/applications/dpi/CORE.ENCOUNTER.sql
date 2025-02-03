-- CORE.ENCOUNTER definition

-- Drop table

-- DROP TABLE CORE.ENCOUNTER;

CREATE TABLE CORE.ENCOUNTER (
    ENCOUNTER_NI NUMBER(38,0) NOT NULL,
    PATIENT_NI NUMBER(38,0) NOT NULL,
    ENCOUNTER_TYPE VARCHAR2(50) NOT NULL,
    DATE_CREAT DATE NOT NULL,
    DATE_MODIF DATE NOT NULL,
    DATE_REMOVE DATE NULL,
    ENCOUNTER_START DATE NULL,
    ENCOUNTER_END DATE NULL,
    CONSTRAINT PK_ENCOUNTER PRIMARY KEY (ENCOUNTER_NI),
    CONSTRAINT SYS_C00109590 CHECK ("ENCOUNTER_NI" IS NOT NULL),
    CONSTRAINT SYS_C00109591 CHECK ("ENCOUNTER_TYPE" IS NOT NULL),
    CONSTRAINT FK1_ENCOUNTER FOREIGN KEY (PATIENT_NI) REFERENCES CORE.PATIENT(PATIENT_NI)
);
CREATE UNIQUE INDEX PK_ENCOUNTER ON CORE.ENCOUNTER (ENCOUNTER_NI);
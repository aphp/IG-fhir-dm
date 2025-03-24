-- CORE.SEjOUR definition

-- Drop table

-- DROP TABLE CORE.SEJOUR;

CREATE TABLE CORE.SEJOUR (
    SEJOUR_NI NUMBER(38,0) NOT NULL,
    PATIENT_NI NUMBER(38,0) NOT NULL,
    SEJOUR_TYPE VARCHAR2(50) NOT NULL,
    NDA VARCHAR2(50) NOT NULL,
    DATE_CREAT DATE NOT NULL,
    DATE_MODIF DATE NOT NULL,
    DATE_REMOVE DATE NULL,
    SEJOUR_START DATE NULL,
    SEJOUR_END DATE NULL,
    CONSTRAINT PK_SEJOUR PRIMARY KEY (SEJOUR_NI),
    CONSTRAINT SYS_C00109590 CHECK ("SEJOUR_NI" IS NOT NULL),
    CONSTRAINT SYS_C00109591 CHECK ("SEJOUR_TYPE" IS NOT NULL),
    CONSTRAINT SYS_C00109592 CHECK ("NDA" IS NOT NULL),
    CONSTRAINT FK1_SEJOUR FOREIGN KEY (PATIENT_NI) REFERENCES CORE.PATIENT(PATIENT_NI)
);
CREATE UNIQUE INDEX PK_SEJOUR ON CORE.SEJOUR (SEJOUR_NI);
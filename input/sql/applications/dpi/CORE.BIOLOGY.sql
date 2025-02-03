-- CORE.BIOLOGY definition

-- Drop table

-- DROP TABLE CORE.BIOLOGY;

CREATE TABLE CORE.BIOLOGY (
    BIOLOGY_NI NUMBER(38,0) NOT NULL,
    PATIENT_NI NUMBER(38,0) NOT NULL,
    ENCOUNTER_NI NUMBER(38,0) NOT NULL,
    DATE_CREAT DATE NOT NULL,
    DATE_MODIF DATE NOT NULL,
    DATE_REMOVE DATE NULL,
    BIOLOGY_DATE DATE NULL,
    BIOLOGY_CODE VARCHAR2(50),
    BIOLOGY_VALUE NUMBER(4,2),
    BIOLOGY_UNIT VARCHAR2(10),
    CONSTRAINT PK_BIOLOGY PRIMARY KEY (BIOLOGY_NI),
    CONSTRAINT SYS_C00109590 CHECK ("BIOLOGY_NI" IS NOT NULL),
    CONSTRAINT SYS_C00109591 CHECK ("DATE_CREAT" IS NOT NULL),
    CONSTRAINT SYS_C00109592 CHECK ("DATE_MODIF" IS NOT NULL),
    CONSTRAINT FK1_BIOLOGY FOREIGN KEY (PATIENT_NI) REFERENCES CORE.PATIENT(PATIENT_NI),
    CONSTRAINT FK2_BIOLOGY FOREIGN KEY (ENCOUNTER_NI) REFERENCES CORE.ENCOUNTER(ENCOUNTER_NI)
);
CREATE UNIQUE INDEX PK_BIOLOGY ON CORE.BIOLOGY (BIOLOGY_NI);
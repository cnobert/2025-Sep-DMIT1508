IF OBJECT_ID('dbo.Microchip','U') IS NOT NULL DROP TABLE dbo.Microchip;
IF OBJECT_ID('dbo.Pet','U') IS NOT NULL DROP TABLE dbo.Pet;
IF OBJECT_ID('dbo.Owner','U') IS NOT NULL DROP TABLE dbo.Owner;


CREATE TABLE dbo.Owner
(
    OwnerID   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    FullName  NVARCHAR(100)     NOT NULL,
    Phone     NVARCHAR(20)      NOT NULL,
    Email     NVARCHAR(255)     NOT NULL
);


CREATE TABLE dbo.Pet
(
    PetID        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    OwnerID      INT               NULL,            -- now optional (pets can have no owner)
    PetName      NVARCHAR(60)      NOT NULL,        -- renamed from Name to PetName
    Species      NVARCHAR(30)      NOT NULL,        -- Dog, Cat, Rabbit, etc.
    Breed        NVARCHAR(60)      NULL,
    DateOfBirth  DATE              NULL,
    Sex          NVARCHAR(10)      NULL,
    CONSTRAINT FK_Pet_Owner FOREIGN KEY (OwnerID)
        REFERENCES dbo.Owner(OwnerID)
);


/* Orphan-friendly Microchip table:
   - PetID is NULLable (permits orphan chips)
   - Filtered UNIQUE index enforces 1-to-1 only when PetID IS NOT NULL
   - FK uses ON DELETE SET NULL so deleting a Pet leaves an orphan chip
*/
CREATE TABLE dbo.Microchip
(
    ChipID        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PetID         INT               NULL,
    ChipNumber    NVARCHAR(40)      NOT NULL UNIQUE,
    ImplantedDate DATE              NOT NULL,
    LastScanDate  DATE              NULL,
    CONSTRAINT FK_Microchip_Pet FOREIGN KEY (PetID)
        REFERENCES dbo.Pet(PetID) ON DELETE SET NULL
);


-- Enforce 1-to-1 only for non-NULL PetID
CREATE UNIQUE INDEX UX_Microchip_PetID_NotNull
ON dbo.Microchip(PetID)
WHERE PetID IS NOT NULL;


INSERT INTO dbo.Owner (FullName, Phone, Email) VALUES
  ('Jordan Lee','780-555-0101','jordan.lee@example.ca'),
  ('Casey Patel','587-555-0202','casey.patel@example.ca'),
  ('Riley Chen','825-555-0303','riley.chen@example.ca'),
  ('Morgan Davis','780-555-0404','morgan.davis@example.ca'),
  ('Avery Brooks','587-555-0505','avery.brooks@example.ca'),
  ('Quinn Wright','780-555-0606','quinn.wright@example.ca'),
  ('Jamie Nguyen','587-555-0707','jamie.nguyen@example.ca'),
  ('Taylor Scott','825-555-0808','taylor.scott@example.ca');


-- Original pets (now using PetName) - keep same PetIDs 1..8
INSERT INTO dbo.Pet (OwnerID, PetName, Species, Breed, DateOfBirth, Sex) VALUES
  (1,'Buddy','Dog','Labrador','2020-05-02','M'),
  (1,'Whiskers','Cat','Siamese','2018-09-18','F'),
  (2,'Pepper','Rabbit',NULL,'2021-03-10','F'),
  (3,'Max','Dog','Beagle','2019-11-30','M'),
  (3,'Luna','Cat','Domestic Shorthair','2022-02-14','F'),
  (4,'Rocky','Dog',NULL,'2017-07-07','M'),
  (6,'Milo','Cat','Ragdoll','2020-12-01','M'),
  (7,'Coco','Dog','Poodle','2023-04-22','F');

-- Additional pets with NO owner
INSERT INTO dbo.Pet (OwnerID, PetName, Species, Breed, DateOfBirth, Sex) VALUES
  (NULL,'Shadow','Cat','Tabby','2021-01-11','M'),
  (NULL,'Bailey','Dog','Mixed','2019-03-27','F'),
  (NULL,'Nibbles','Rabbit',NULL,'2024-04-05','F');


-- 8 chips total; 2 are orphans (PetID = NULL)
INSERT INTO dbo.Microchip (PetID, ChipNumber, ImplantedDate, LastScanDate) VALUES
  (1,    'CHIP-AB12-0001', '2021-06-01', '2024-12-01'),
  (3,    'CHIP-XY99-0002', '2020-12-15', NULL),
  (4,    'CHIP-QA77-0003', '2020-01-10', '2025-01-05'),
  (6,    'CHIP-LL42-0004', '2021-12-20', NULL),
  (NULL, 'CHIP-ORPHAN-0005', '2022-07-15', NULL),
  (NULL, 'CHIP-ORPHAN-0006', '2023-03-12', '2024-05-10'),
  (7,    'CHIP-BB11-0007', '2024-02-01', NULL),
  (2,    'CHIP-CC22-0008', '2021-08-20', '2024-09-25');


/* ============================================================
   PARALLEL ASSIGNMENT DATABASE (Vet Clinic Version)
   Mapping to Master DB:
      Course        → Service
      Enrollment    → PetService
      Assessment    → ServiceAssessment
   ============================================================ */

/* -------------------------
   PRE-DROP (child → parent)
   ------------------------- */
IF OBJECT_ID('dbo.ServiceAssessment','U') IS NOT NULL DROP TABLE dbo.ServiceAssessment;
IF OBJECT_ID('dbo.PetService','U')        IS NOT NULL DROP TABLE dbo.PetService;
IF OBJECT_ID('dbo.Service','U')           IS NOT NULL DROP TABLE dbo.Service;

/* =======================
   CREATE: SERVICE (Course)
   ======================= */
CREATE TABLE dbo.Service
(
    ServiceID    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ServiceCode  NVARCHAR(12)      NOT NULL UNIQUE,   -- e.g., VET100, DENT210
    Title        NVARCHAR(120)     NOT NULL,          -- e.g., Annual Wellness Exam
    Department   NVARCHAR(50)      NULL,              -- e.g., General, Dental, Surgery
    BaseFee      DECIMAL(10,2)     NOT NULL
        CONSTRAINT CK_Service_BaseFee CHECK (BaseFee >= 0)
);

/* ============================
   CREATE: PETSERVICE (Enroll.)
   ============================ */
CREATE TABLE dbo.PetService
(
    PetServiceID       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PetID              INT               NOT NULL,
    ServiceID          INT               NOT NULL,
    EnrollDate         DATE              NOT NULL,
    Status             NVARCHAR(12)      NOT NULL
        CONSTRAINT CK_PetService_Status CHECK (Status IN (N'Active', N'Completed', N'Dropped')),
    FinalOutcomeNotes  NVARCHAR(255)     NULL,  -- short note in place of numeric score

    CONSTRAINT FK_PetService_Pet     FOREIGN KEY (PetID)    REFERENCES dbo.Pet(PetID),
    CONSTRAINT FK_PetService_Service FOREIGN KEY (ServiceID) REFERENCES dbo.Service(ServiceID),
    CONSTRAINT UX_PetService UNIQUE (PetID, ServiceID)
);

/* =================================
   CREATE: SERVICEASSESSMENT (child)
   ================================= */
CREATE TABLE dbo.ServiceAssessment
(
    ServiceAssessmentID INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    PetServiceID        INT               NOT NULL,
    Title               NVARCHAR(100)     NOT NULL,  -- e.g., Intake Check, X-Ray Step
    Category            NVARCHAR(20)      NOT NULL
        CONSTRAINT CK_ServiceAssess_Category
            CHECK (Category IN (N'Exam', N'LabTest', N'ProcedureStep', N'FollowUp', N'Other')),
    DueDate             DATE              NULL,      -- scheduled date
    RecordedAt          DATETIME2         NULL,      -- completion time
    Notes               NVARCHAR(255)     NULL,      -- freeform description/outcome

    CONSTRAINT FK_ServiceAssessment_PetService
        FOREIGN KEY (PetServiceID) REFERENCES dbo.PetService(PetServiceID)
        ON DELETE CASCADE
);

/* =====================
   SEED: SERVICE (Course)
   ===================== */
INSERT INTO dbo.Service (ServiceCode, Title, Department, BaseFee) VALUES
('VET100', 'Annual Wellness Exam',         'General',  95.00),
('VET210', 'Dental Cleaning',              'Dental',  220.00),
('VET305', 'Vaccination Package (Core)',   'General',  80.00),
('VET420', 'X-Ray Diagnostic Set',         'Imaging', 160.00),
('VET510', 'Spay/Neuter Surgery',          'Surgery', 350.00),
('VET615', 'Allergy Workup Panel',         'Lab',    180.00);

/* =============================
   SEED: PETSERVICE (Enrollment)
   ============================= */
INSERT INTO dbo.PetService (PetID, ServiceID, EnrollDate, Status, FinalOutcomeNotes) VALUES
(1, 1, '2025-06-15', 'Completed', 'Healthy exam, mild tartar noted'),
(1, 3, '2025-06-15', 'Completed', 'Vaccines up to date'),
(2, 2, '2025-07-10', 'Completed', 'Mild gingivitis resolved'),
(3, 3, '2025-08-05', 'Active',    'Initial visit complete'),
(4, 4, '2025-05-22', 'Completed', 'X-ray normal'),
(5, 6, '2025-09-01', 'Active',    'Pending blood results'),
(6, 5, '2024-12-12', 'Completed', 'Surgery uneventful'),
(7, 1, '2025-06-20', 'Active',    'Exam scheduled'),
(8, 3, '2025-04-30', 'Completed', 'All vaccines administered');

/* =====================================
   SEED: SERVICEASSESSMENT (Assessments)
   ===================================== */

-- Buddy (PetID 1) - Annual Exam &amp; Vaccination
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(1, 'Intake Check',             'Exam',         '2025-06-15', '2025-06-15T09:10:00', 'Vitals normal'),
(1, 'Physical Examination',     'Exam',         '2025-06-15', '2025-06-15T09:30:00', 'Healthy'),
(1, 'Blood Panel',              'LabTest',      '2025-06-15', '2025-06-15T10:15:00', 'All values WNL'),
(2, 'DHPP Vaccine',             'ProcedureStep','2025-06-15', '2025-06-15T10:35:00', 'Tolerated well'),
(2, 'Rabies Vaccine',           'ProcedureStep','2025-06-15', '2025-06-15T10:45:00', 'No reaction');

-- Whiskers (PetID 2) - Dental Cleaning
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(3, 'Pre-Anesthetic Exam',      'Exam',         '2025-07-10', '2025-07-10T08:00:00', 'Cleared for anesthesia'),
(3, 'Scaling and Polishing',    'ProcedureStep','2025-07-10', '2025-07-10T09:30:00', 'Moderate tartar removed'),
(3, 'Dental X-Rays',            'LabTest',      '2025-07-10', '2025-07-10T09:55:00', 'No lesions'),
(3, 'Post-Op Check',            'FollowUp',     '2025-07-17', '2025-07-17T10:00:00', 'Healed well');

-- Pepper (PetID 3) - Vaccination (active)
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(4, 'Intake Check',             'Exam',         '2025-08-05', NULL, NULL),
(4, 'Core Vaccine Dose 1',      'ProcedureStep','2025-08-05', NULL, NULL),
(4, 'Core Vaccine Dose 2',      'ProcedureStep','2025-09-05', NULL, NULL);

-- Max (PetID 4) - X-Ray Set
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(5, 'Sedation and Positioning', 'ProcedureStep','2025-05-22', '2025-05-22T11:05:00', 'Smooth induction'),
(5, 'Thoracic Views',           'LabTest',      '2025-05-22', '2025-05-22T11:20:00', 'No abnormalities'),
(5, 'Findings Review',          'FollowUp',     '2025-05-23', '2025-05-23T09:00:00', 'Client notified');

-- Luna (PetID 5) - Allergy Workup
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(6, 'History and Intake',       'Exam',         '2025-09-01', NULL, 'Pending'),
(6, 'Serum IgE Panel',          'LabTest',      '2025-09-03', NULL, NULL),
(6, 'Diet Trial Setup',         'FollowUp',     '2025-09-05', NULL, NULL);

-- Rocky (PetID 6) - Spay/Neuter
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(7, 'Pre-Op Exam',              'Exam',         '2024-12-12', '2024-12-12T08:10:00', 'Cleared for surgery'),
(7, 'Surgical Procedure',       'ProcedureStep','2024-12-12', '2024-12-12T10:00:00', 'No complications'),
(7, 'Suture Check',             'FollowUp',     '2024-12-19', '2024-12-19T09:20:00', 'Incision healed');

-- Milo (PetID 7) - Annual Exam (active)
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(8, 'Intake Check',             'Exam',         '2025-06-20', NULL, NULL),
(8, 'Physical Examination',     'Exam',         '2025-06-20', NULL, NULL);

-- Coco (PetID 8) - Vaccination (completed)
INSERT INTO dbo.ServiceAssessment (PetServiceID, Title, Category, DueDate, RecordedAt, Notes) VALUES
(9, 'DHPP Vaccine',             'ProcedureStep','2025-04-30', '2025-04-30T13:15:00', 'No issues'),
(9, 'Rabies Vaccine',           'ProcedureStep','2025-04-30', '2025-04-30T13:25:00', 'Tolerated well'),
(9, 'Post-Vax Observation',     'FollowUp',     '2025-05-01', '2025-05-01T10:00:00', 'Normal behavior');
--G_CORRESPONDENCE


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."G_CORRESPONDENCE" ("R_OBJECT_ID", "CORRESPONDENCE_NAME", "IS_ACTIVE", "FULL_TITLE", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_DOMAIN", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "DOCUMENT_STATUS", "DOCUMENT_DATE", "TYPE_OF_COMMUNICATION", "MARKET_NAME", "R_VERSION_LABEL", "PRODUCT_FAMILY_NAME", "RESPONSIBLE_PERSON", "TARGET_COMPLETION_DATE", "I_CHRONICLE_ID", "REGULATORY_APPLICATION_NAME", "R_CREATION_DATE", "ACT_CORRES_LINK", "A_LINK", "TYPE", "DOCUMENT_R_OBJECT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH
        First_View
        AS
            (SELECT DISTINCT 
            a.r_object_id,
A.OBJECT_NAME AS Correspondence_Name,
NVL (d.is_active, A.IS_ACTIVE) AS is_active,
       A.FULL_TITLE,
        A.CLASSIFICATION_ARTIFACT,
       A.CLASSIFICATION_DOMAIN,
       A.CLASSIFICATION_GROUP,
       A.CLASSIFICATION_SUBGROUP,
       A.DOCUMENT_STATUS,
       A.DOCUMENT_DATE,
        B.TYPE_OF_COMMUNICATION,
          B.ORIGINATOR_COUNTRY_NAME MARKET_NAME,
         B.R_VERSION_LABEL,
             B.PRODUCT_FAMILY_NAME,
             b.responsible_person,
             a.TARGET_COMPLETION_DATE,
             a.i_chronicle_id ,b.regulatory_application_name,
                        a.R_CREATION_DATE,
                        d.r_object_id as Act_Corres_link, 'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
       || a.i_chronicle_id
       || ''
          AS A_link,'Correspondence'
 as type

      from    COSMOSDBEXPORT.DOCUMENT a
       INNER JOIN COSMOSDBEXPORT.DOCUMENT_R B
          ON A.r_object_id = B.DOCUMENT_R_OBJECT_ID
       LEFT JOIN
       (SELECT C.correspondence_id,
               C.submission_manager_r_object_id,
               D.r_object_id,
               D.object_name,
               C.regulatory_application_name,
               D.IS_ACTIVE
          FROM COSMOSDBEXPORT.submission_manager_r C
               INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER D
                  ON D.r_object_id = C.submission_manager_r_object_id
         WHERE C.correspondence_id IS NOT NULL) D
          ON   D.correspondence_id =  A.r_object_id  
       LEFT JOIN
       (SELECT A.APPLICATION_NUMBER, B.OBJECT_NAME
          FROM COSMOSDBEXPORT.REGULATORY_APPLICATION A
               INNER JOIN COSMOSDBEXPORT.OBJECT B
                  ON A.R_OBJECT_ID = B.R_OBJECT_ID) E
          ON B.REGULATORY_APPLICATION_NAME = E.OBJECT_NAME

left join COSMOSDBEXPORT.MARKET M on B.MARKET_NAME = M.ISO_COUNTRY_NAME
 WHERE A.CLASSIFICATION_DOMAIN = 'Correspondence'
                    ),
        second_view
        AS
            (select DOCUMENT_R_OBJECT_ID from COSMOSDBEXPORT.document_r where r_version_label = 'CURRENT'
                    )
    SELECT  distinct "R_OBJECT_ID","CORRESPONDENCE_NAME","IS_ACTIVE","FULL_TITLE","CLASSIFICATION_ARTIFACT","CLASSIFICATION_DOMAIN","CLASSIFICATION_GROUP","CLASSIFICATION_SUBGROUP","DOCUMENT_STATUS","DOCUMENT_DATE","TYPE_OF_COMMUNICATION","MARKET_NAME","R_VERSION_LABEL","PRODUCT_FAMILY_NAME","RESPONSIBLE_PERSON","TARGET_COMPLETION_DATE","I_CHRONICLE_ID","REGULATORY_APPLICATION_NAME","R_CREATION_DATE","ACT_CORRES_LINK","A_LINK","TYPE","DOCUMENT_R_OBJECT_ID"
    from  first_view a
    inner join second_view  b on a.r_object_id = b.DOCUMENT_R_OBJECT_ID;







--CHRON_ACTIVITY

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."CHRON_ACTIVITY" ("R_OBJECT_ID", "ACTIVITY_NAME", "IS_ACTIVE", "ACTIVITY_TYPE", "PRODUCT_FAMILY_NAME", "MARKET_NAME", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "TARGET_COMPLETION_DATE", "FULL_DESCRIPTION", "AGENCY_APPROVAL_STATUS", "AGENCY_APPROVAL_DATE", "FIRST_SUBMISSION_DATE", "TYPE_OF_SUBMISSION_NAME", "REGULATORY_APPLICATION_NAME", "R_VERSION_LABEL", "R_CREATION_DATE", "RESPONSIBLE_PERSON", "TYPE", "A_LINK", "SUBMISSION_MANAGER_R_OBJECT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH
        First_View
        AS
            (SELECT DISTINCT a.r_object_id ,b.object_name Activity_name,b.is_active,
c.activity_type,
c.product_family_name,
c.market_name,
b.classification_artifact,
b.classification_group,
b.classification_subgroup,
b.target_completion_date, 
b.full_description,
b.agency_approval_status,
b.agency_approval_date,
b.first_submission_date,
c.type_of_submission_name,c.regulatory_application_name,
c.r_version_label,b.r_creation_date,c.responsible_person, 'Activity' as type,
  'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
       || a.r_object_id
       || ''
          AS A_link



               FROM COSMOSDBEXPORT.SUBMISSION_MANAGER  b
                    INNER JOIN COSMOSDBEXPORT.regulatory_activity a
                        ON b.R_OBJECT_ID = a.R_OBJECT_ID
                    LEFT JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER_R c
                        ON b.R_OBJECT_ID = c.SUBMISSION_MANAGER_R_OBJECT_ID
                    ),
        second_view
        AS
            (select SUBMISSION_MANAGER_R_OBJECT_ID from COSMOSDBEXPORT.SUBMISSION_MANAGER_R where r_version_label = 'CURRENT'
                    )
    SELECT "R_OBJECT_ID","ACTIVITY_NAME","IS_ACTIVE","ACTIVITY_TYPE","PRODUCT_FAMILY_NAME","MARKET_NAME","CLASSIFICATION_ARTIFACT","CLASSIFICATION_GROUP","CLASSIFICATION_SUBGROUP","TARGET_COMPLETION_DATE","FULL_DESCRIPTION","AGENCY_APPROVAL_STATUS","AGENCY_APPROVAL_DATE","FIRST_SUBMISSION_DATE","TYPE_OF_SUBMISSION_NAME","REGULATORY_APPLICATION_NAME","R_VERSION_LABEL","R_CREATION_DATE","RESPONSIBLE_PERSON","TYPE","A_LINK","SUBMISSION_MANAGER_R_OBJECT_ID"  
    from  first_view a
    inner join second_view  b on a.r_object_id = b.SUBMISSION_MANAGER_R_OBJECT_ID;

	
	
	--CHRON_APPLICATION

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."CHRON_APPLICATION" ("R_OBJECT_ID", "APPLICATION_TYPE_NAME", "BASE_APPLICATION_TYPE", "PRODUCT_FAMILY_NAME", "MARKET_NAME", "APPLICATION_NAME", "R_CREATION_DATE", "CONFIG_UID", "RESPONSIBLE_PERSON", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_SUBGROUP", "CLASSIFICATION_GROUP", "TARGET_COMPLETION_DATE", "STATUS", "TYPE", "FULL_DESCRIPTION", "TYPE_OF_SUBMISSION_NAME", "STATUS_DATE", "A_LINK", "SUBMISSION_MANAGER_R_OBJECT_ID", "R_VERSION_LABEL", "REGULATORY_APPLICATION_UID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  with first_view as (select o.r_object_id,smr.submission_manager_r_object_id,o.r_creation_date,o.object_name,o.config_uid from  cosmosdbexport.object o
join COSMOSDBEXPORT.submission_manager_r smr on smr.regulatory_application_uid = o.config_uid),

second_view as (
select submission_manager_r_object_id,r_version_label from  COSMOSDBEXPORT.submission_manager_r where r_version_label = 'CURRENT' 
),
third_view as (
select a.* from first_view a
inner join second_view b on a.submission_manager_r_object_id = b.submission_manager_r_object_id
)


 select distinct r.r_object_id,r.APPLICATION_TYPE_NAME,r.BASE_APPLICATION_TYPE,
r.PRODUCT_FAMILY_NAME,ra.market_name,a.object_name as application_name,
a.r_creation_date,a.config_uid,'' as responsible_person,sm.classification_artifact,sm.classification_subgroup,sm.classification_group,'' as
target_completion_date, '' as status, 'Application' type,'' as full_description,smr.type_of_submission_name, '' as Status_date,
 'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/' || r.r_object_id || '' as A_link,smr.submission_manager_r_object_id,smr.r_version_label
 ,smr.regulatory_application_uid from 
COSMOSDBEXPORT.regulatory_application r
JOIN cosmosdbexport.regulatory_application_r ra ON r.r_object_id = ra.REGULATORY_APPLICATION_R_OBJECT_ID
inner join third_view a on a.r_object_id = r.r_object_id
join COSMOSDBEXPORT.submission_manager sm on a.submission_manager_r_object_id = sm.r_object_id
join COSMOSDBEXPORT.submission_manager_r smr on smr.submission_manager_r_object_id = sm.r_object_id;




--CHRON_ASSEMBLY

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."CHRON_ASSEMBLY" ("R_OBJECT_ID", "I_CHRONICLE_ID", "ASSEMBLY_NAME", "FULL_TITLE", "IS_ACTIVE", "PRODUCT_FAMILY_NAME", "MARKET_NAME", "TYPE_OF_SUBMISSION_NAME", "RESPONSIBLE_PERSON", "SUBMISSION_ACTUAL_DATE", "SUBMISSION_PLANNED_DATE", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_DOMAIN", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "DOCUMENT_STATUS", "DOCUMENT_DATE", "PROCESS_PHASE", "PROCESS_NAME", "PROCESS_STAGE_NAME", "TARGET_COMPLETION_DATE", "R_VERSION_LABEL", "REGULATORY_APPLICATION_NAME", "EVENT_LINK_ASSEMBLY_ID", "ACTIVITY_LINK_ASSEMBLY_ID", "R_CREATION_DATE", "A_LINK", "TYPE", "DOCUMENT_R_OBJECT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH
        First_View
        AS
            (SELECT DISTINCT 
dca.r_object_id ,dca.i_chronicle_id,
dca.object_name Assembly_name,
dca.FULL_TITLE,  (case
when Smr.SUBMISSION_MANAGER_R_OBJECT_ID is null then 'N'  
else  'Y' end ) AS is_active,


trim(DOCUMENT_R.PRODUCT_FAMILY_NAME) PRODUCT_FAMILY_NAME,
DOCUMENT_R.MARKET_NAME,
DOCUMENT_R.TYPE_OF_SUBMISSION_NAME,
DOCUMENT_R.RESPONSIBLE_PERSON,
dca.submission_actual_date,
dca.submission_planned_date,
dca.CLASSIFICATION_ARTIFACT,
dca.CLASSIFICATION_DOMAIN,
dca.CLASSIFICATION_GROUP,
dca.CLASSIFICATION_SUBGROUP,
dca.DOCUMENT_STATUS,
dca.DOCUMENT_DATE,
dca.PROCESS_PHASE,
dca.PROCESS_NAME,
dca.PROCESS_STAGE_NAME,
dca.TARGET_COMPLETION_DATE,
DOCUMENT_R.r_version_label,document_r.regulatory_application_name,
Smr.SUBMISSION_MANAGER_R_OBJECT_ID as Event_link_Assembly_id,
SUBMISSION_MANAGER.R_OBJECT_ID as Activity_link_Assembly_id,
dca.r_creation_date, 'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
       || dca.r_object_id
       || ''
          AS A_link, 'Assembly' as type





            from COSMOSDBEXPORT.document_r  DOCUMENT_R
           INNER JOIN COSMOSDBEXPORT.document dca
               ON dca.R_OBJECT_ID = DOCUMENT_R.DOCUMENT_R_OBJECT_ID
           LEFT JOIN COSMOSDBEXPORT.submission_manager_r smr
               ON dca.I_CHRONICLE_ID = smr.ASSEMBLY_ID
           LEFT JOIN COSMOSDBEXPORT.submission_manager submission_manager
               ON submission_manager.R_OBJECT_ID =
                  smr.SUBMISSION_MANAGER_R_OBJECT_ID
where
                    dca.CLASSIFICATION_SUBGROUP IN
                   ('Main Assembly', 'Sub Assembly')
           AND 
        (dca.PROCESS_NAME IN
                   ('Global Assembly Core Process',
                    'Local Assembly Core Process') )
           AND((dca.classification_artifact IN ('Global Assembly',
                                               'NDA Safety Update',
                                               'Other Sub Assembly',
                                               'PDMA',
                                               'Submission Assembly')) or (dca.classification_artifact is null))
          and  (dca.PROCESS_PHASE IN

                   ('Compile, Publish, Submit','Closed',
                    'Create/Manage Content',
                    'Manage Commitment')) and
            dca.is_assembly = 'Y'
                    ),
        second_view
        AS
            (select DOCUMENT_R_OBJECT_ID from COSMOSDBEXPORT.document_r where r_version_label = 'CURRENT'
                    )
    SELECT distinct "R_OBJECT_ID","I_CHRONICLE_ID","ASSEMBLY_NAME","FULL_TITLE","IS_ACTIVE","PRODUCT_FAMILY_NAME","MARKET_NAME","TYPE_OF_SUBMISSION_NAME","RESPONSIBLE_PERSON","SUBMISSION_ACTUAL_DATE","SUBMISSION_PLANNED_DATE","CLASSIFICATION_ARTIFACT","CLASSIFICATION_DOMAIN","CLASSIFICATION_GROUP","CLASSIFICATION_SUBGROUP","DOCUMENT_STATUS","DOCUMENT_DATE","PROCESS_PHASE","PROCESS_NAME","PROCESS_STAGE_NAME","TARGET_COMPLETION_DATE","R_VERSION_LABEL","REGULATORY_APPLICATION_NAME","EVENT_LINK_ASSEMBLY_ID","ACTIVITY_LINK_ASSEMBLY_ID","R_CREATION_DATE","A_LINK","TYPE","DOCUMENT_R_OBJECT_ID"
    from  first_view a
    inner join second_view  b on a.r_object_id = b.DOCUMENT_R_OBJECT_ID;

	
	
--CHRON_BRIDGE_TABLE


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."CHRON_BRIDGE_TABLE" ("ACTIVITY_ID", "EVENT_ID", "CORR_LINK_ID", "EVENT_TO_ASS_LINK_ID", "ACTIVITY_TO_ASS_LINK_ID", "ASSEMBLY_ID", "G_CORRESPONDENCE_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  with      Assemblies as(
        
        select dca.r_object_id as ASSEMBLY_ID,dca.object_name Assembly_name,
        dca.I_CHRONICLE_ID ,smr.regulatory_application_uid,
        smr.submission_manager_r_object_id 
         FROM COSMOSDBEXPORT.document_r  DOCUMENT_R
           INNER JOIN COSMOSDBEXPORT.document dca
               ON dca.R_OBJECT_ID = DOCUMENT_R.DOCUMENT_R_OBJECT_ID
           LEFT JOIN COSMOSDBEXPORT.submission_manager_r smr
               ON dca.I_CHRONICLE_ID = smr.ASSEMBLY_ID
                WHERE   dca.CLASSIFICATION_SUBGROUP IN
                   ('Main Assembly', 'Sub Assembly')
           AND 
        (dca.PROCESS_NAME IN
                   ('Global Assembly Core Process',
                    'Local Assembly Core Process') )
           AND ((dca.classification_artifact IN ('Global Assembly',
                                               'NDA Safety Update',
                                               'Other Sub Assembly',
                                               'PDMA',
                                               'Submission Assembly')) or (dca.classification_artifact is null))
           AND (dca.PROCESS_PHASE IN

                   ('Compile, Publish, Submit','Closed',
                    'Create/Manage Content',
                    'Manage Commitment'))
           AND dca.is_assembly = 'Y' and DOCUMENT_R.r_version_label = 'CURRENT' 
        ),
          g_Correspondence as(

         select A.r_object_id as Correspondence_ID,D.submission_manager_r_object_id,A.OBJECT_NAME AS Correspondence_Name
        from
        COSMOSDBEXPORT.DOCUMENT A
       INNER JOIN COSMOSDBEXPORT.DOCUMENT_R B
          ON A.r_object_id = B.DOCUMENT_R_OBJECT_ID
       LEFT JOIN
       (SELECT C.correspondence_id,
               C.submission_manager_r_object_id,
               D.r_object_id,
               D.object_name,
               C.regulatory_application_name,
               D.IS_ACTIVE
          FROM COSMOSDBEXPORT.submission_manager_r C
               INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER D
                  ON D.r_object_id = C.submission_manager_r_object_id
         WHERE C.correspondence_id IS NOT NULL) D
          ON   D.correspondence_id = A.r_object_id 



 WHERE A.CLASSIFICATION_DOMAIN = 'Correspondence' and b.r_version_label = 'CURRENT' ),
        Correspondence as(

         select A.r_object_id as Correspondence_ID,D.submission_manager_r_object_id,A.OBJECT_NAME AS Correspondence_Name
        from
        COSMOSDBEXPORT.DOCUMENT A
       INNER JOIN COSMOSDBEXPORT.DOCUMENT_R B
          ON A.r_object_id = B.DOCUMENT_R_OBJECT_ID
       LEFT JOIN
       (SELECT C.correspondence_id,
               C.submission_manager_r_object_id,
               D.r_object_id,
               D.object_name,
               C.regulatory_application_name,
               D.IS_ACTIVE
          FROM COSMOSDBEXPORT.submission_manager_r C
               INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER D
                  ON D.r_object_id = C.submission_manager_r_object_id
         WHERE C.correspondence_id IS NOT NULL) D
          ON   D.correspondence_id = A.i_chronicle_id 



 WHERE A.CLASSIFICATION_DOMAIN = 'Correspondence'

        ),
--        application_t as (
--
--        select r.r_object_id,o.config_uid
--,smr.submission_manager_r_object_id from 
--
--COSMOSDBEXPORT.regulatory_application r
--JOIN cosmosdbexport.regulatory_application_r ra ON r.r_object_id = ra.REGULATORY_APPLICATION_R_OBJECT_ID
--JOIN cosmosdbexport.object o ON r.r_object_id = o.r_object_id
--join COSMOSDBEXPORT.submission_manager_r smr on smr.regulatory_application_uid = o.config_uid
--join COSMOSDBEXPORT.submission_manager sm on smr.submission_manager_r_object_id = sm.r_object_id
--
--        ),

--auth as(
--select r.r_object_id,smr.submission_manager_r_object_id,r.authorisation_status_date from
--
--cosmosdbexport.product_authorisation r  
--INNER JOIN COSMOSDBEXPORT.OBJECT o ON o.CONFIG_UID = r.REGULATORY_APPLICATION_UID
--left  JOIN COSMOSDBEXPORT.OBJECT_r ob ON o.r_object_id = ob.object_r_object_id
--join COSMOSDBEXPORT.submission_manager_r smr on smr.regulatory_application_uid = r.regulatory_application_uid
--join COSMOSDBEXPORT.submission_manager sm on smr.submission_manager_r_object_id = sm.r_object_id
--),
UNIONs as (

select distinct vw_act_evn_corres.event_object_id as Event_id,vw_act_evn_corres.activity_object_id as Activity_ID,
vw_act_evn_corres.activity_object_id as Corr_link_ID,vw_act_evn_corres.activity_object_id as event_to_ass_link_ID,
vw_act_evn_corres.activity_object_id as Activity_to_ass_link_ID,ACTIVITY_NAME from VW_ACT_EVN_CORRES

union all
select distinct vw_act_evn_corres.event_object_id as Event_id,vw_act_evn_corres.activity_object_id as Activity_ID,
vw_act_evn_corres.event_object_id as corr_link_ID,vw_act_evn_corres.event_object_id as event_to_ass_link_ID,
vw_act_evn_corres.event_object_id as Activity_to_ass_link_ID,ACTIVITY_NAME from VW_ACT_EVN_CORRES
),

total as(

select distinct a.Activity_ID,a.Event_id,a.corr_link_ID,event_to_ass_link_ID,Activity_to_ass_link_ID,b.assembly_id,
e.correspondence_id g_correspondence_id

from   unions a 
left join Assemblies b on a.event_to_ass_link_ID = b.submission_manager_r_object_id
--left join correspondence c on a.Corr_link_ID = c.submission_manager_r_object_id
left join g_correspondence e on a.Corr_link_ID = e.submission_manager_r_object_id

union all
select distinct a.Activity_ID,a.Event_id,a.corr_link_ID,event_to_ass_link_ID,Activity_to_ass_link_ID,b.assembly_id,
e.correspondence_id g_correspondence_id

from   unions a 
right join Assemblies b on a.event_to_ass_link_ID = b.submission_manager_r_object_id
--left join correspondence c on a.Corr_link_ID = c.submission_manager_r_object_id
right join g_correspondence e on a.Corr_link_ID = e.submission_manager_r_object_id)

select "ACTIVITY_ID","EVENT_ID","CORR_LINK_ID","EVENT_TO_ASS_LINK_ID","ACTIVITY_TO_ASS_LINK_ID","ASSEMBLY_ID","G_CORRESPONDENCE_ID" from total;



--CHRON_EVENT

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."CHRON_EVENT" ("R_OBJECT_ID", "EVENT_NAME", "PRODUCT_FAMILY_NAME", "MARKET_NAME", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "TARGET_COMPLETION_DATE", "EVENT_FULL_DESCRIPTION", "AGENCY_APPROVAL_STATUS", "AGENCY_APPROVAL_DATE", "FIRST_SUBMISSION_DATE", "TYPE_OF_SUBMISSION_NAME", "R_VERSION_LABEL", "R_CREATION_DATE", "RESPONSIBLE_PERSON", "ACTIVITY_TYPE", "A_LINK", "TYPE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH
        First_View
        AS
            (SELECT DISTINCT a.r_object_id ,b.object_name Event_name,
c.product_family_name,
c.market_name,
b.classification_artifact,
b.classification_group,
b.classification_subgroup,
b.target_completion_date, 
b.full_description as Event_Full_Description,
b.agency_approval_status,
b.agency_approval_date,
b.first_submission_date,
c.type_of_submission_name,
c.r_version_label,b.r_creation_date,c.responsible_person,
c.Activity_type, 'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
       || a.r_object_id
       || ''
          AS A_link,'Event' as type



               FROM COSMOSDBEXPORT.regulatory_event a
    inner join COSMOSDBEXPORT.SUBMISSION_MANAGER b on  a.R_OBJECT_ID = b.R_OBJECT_ID   
     left join COSMOSDBEXPORT.SUBMISSION_MANAGER_R c on  b.R_OBJECT_ID = c.SUBMISSION_MANAGER_R_OBJECT_ID
                    ),
        second_view
        AS
            (select SUBMISSION_MANAGER_R_OBJECT_ID from COSMOSDBEXPORT.SUBMISSION_MANAGER_R where r_version_label = 'CURRENT'
                    )
    SELECT a."R_OBJECT_ID",a."EVENT_NAME",a."PRODUCT_FAMILY_NAME",a."MARKET_NAME",a."CLASSIFICATION_ARTIFACT",a."CLASSIFICATION_GROUP",a."CLASSIFICATION_SUBGROUP",a."TARGET_COMPLETION_DATE",a."EVENT_FULL_DESCRIPTION",a."AGENCY_APPROVAL_STATUS",a."AGENCY_APPROVAL_DATE",a."FIRST_SUBMISSION_DATE",a."TYPE_OF_SUBMISSION_NAME",a."R_VERSION_LABEL",a."R_CREATION_DATE",a."RESPONSIBLE_PERSON",a."ACTIVITY_TYPE",a."A_LINK",a."TYPE" from  first_view a
    inner join second_view  b on a.r_object_id = b.SUBMISSION_MANAGER_R_OBJECT_ID;

	
	
	
	
	

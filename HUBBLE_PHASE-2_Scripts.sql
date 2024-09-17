
--VW_SUSTAINABILITY

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_SUSTAINABILITY" ("R_OBJECT_ID", "INDICATION_NAME", "INDICATION_UID", "REGULATORY_ACTIVITY_NAME", "MARKET_NAME", "PRODUCT_FAMILY_NAME", "DATE_OF_FIRST_AUTHORISATION", "AUTHORISATION_STATUS_DATE", "AUTHORIZATION_NUMBER", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "CLASSIFICATION_ARTIFACT", "CLASSIFICATION_DOMAIN", "SPECIAL_DESIGNATION", "SPECIAL_DESIGNATION_DATE", "BUSINESS_UNIT", "APPLICATION_NAME", "AUTHORISATION_TYPE", "AUTHORISATION_STATUS", "MEDICINAL_PRODUCT_NAME", "PACKAGED_PRODUCT_NAME", "SECURITY_DOMAIN", "INFORMATION_CLASSIFICATION", "IS_ACTIVE", "AUTHORISATION_HOLDER_NAME", "INDICATION_STATUS_DATE", "INDICATION_STATUS", "VALIDITY_PERIOD_START", "VALIDITY_PERIOD_END", "CONCEPT", "CONFIG_UID", "R_MODIFY_DATE", "R_MODIFIER", "HISTORIC_NAME_VALUE", "NAME_VALUE_CHANGE_DATE", "ROSTER_REGION", "IS_EEA", "IS_EU") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT DISTINCT A.r_object_id,
                    B.INDICATION_NAME,
                    B.INDICATION_UID,
                    B.REGULATORY_ACTIVITY_NAME,
                    A.MARKET_NAME,
                    A.PRODUCT_FAMILY_NAME,
                    A.DATE_OF_FIRST_AUTHORISATION,
                    A.AUTHORISATION_STATUS_DATE,
                    E.OBJECT_NAME       AS AUTHORIZATION_NUMBER,
                    SM.CLASSIFICATION_GROUP,
                    SM.CLASSIFICATION_SUBGROUP,
                    SM.CLASSIFICATION_ARTIFACT,
                    SM.CLASSIFICATION_DOMAIN,
                    B.SPECIAL_DESIGNATION,
                    B.SPECIAL_DESIGNATION_DATE,
                    E.BUSINESS_UNIT,
                    F.OBJECT_NAME       AS APPLICATION_NAME,
                    A.AUTHORISATION_TYPE,
                    A.AUTHORISATION_STATUS,
                    B.MEDICINAL_PRODUCT_NAME,
                    B.PACKAGED_PRODUCT_NAME,
                    E.SECURITY_DOMAIN,
                    E.INFORMATION_CLASSIFICATION,
                    E.IS_ACTIVE,
                    A.AUTHORISATION_HOLDER_NAME,
                    --A.AUTHORISATION_STATUS_DATE AS INDICATION_STATUS_DATE,
                    B.INDICATION_STATUS_DATE,
                    B.INDICATION_STATUS,
                    ---NULL AS INDICATION_STATUS,
                    A.VALIDITY_PERIOD_START,
                    A.VALIDITY_PERIOD_END,
                    E.CONCEPT,
                    E.CONFIG_UID,
                    E.R_MODIFY_DATE,
                    E.R_MODIFIER,
                    E.OBJECT_NAME       AS HISTORIC_NAME_VALUE,
                    E.R_MODIFY_DATE     AS NAME_VALUE_CHANGE_DATE,
                    M.ROSTER_REGION,(SELECT MAX (IS_EEA)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = a.MARKET_NAME)
                 IS_EEA,(SELECT MAX (IS_EU)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = a.MARKET_NAME)
               IS_EU
      FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION  A
           INNER JOIN COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R B
               ON A.R_OBJECT_ID = B.PRODUCT_AUTHORISATION_R_OBJECT_ID
           INNER JOIN COSMOSDBEXPORT.OBJECT E
               ON E.R_OBJECT_ID = A.R_OBJECT_ID
           INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER SM
               ON SM.CONFIG_UID = B.REGULATORY_ACTIVITY_UID
           INNER JOIN COSMOSDBEXPORT.OBJECT F
               ON A.REGULATORY_APPLICATION_UID = F.CONFIG_UID
                LEFT JOIN COSMOSDBEXPORT.MARKET M on a.market_name = M.ISO_COUNTRY_NAME;

				
				
				
				
				
				
				
				
				
				
				
				
				
--VW_AUTH_PRODUCT_REG	
				

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_AUTH_PRODUCT_REG" ("R_OBJECT_ID", "R_INDEX", "AUTHORISATION_HOLDER_NAME", "AUTHORISATION_HOLDER_UID", "AUTHORISATION_STATUS", "AUTHORISATION_STATUS_DATE", "AUTHORISATION_TYPE", "DATE_OF_FIRST_AUTHORISATION", "AUTHORIZATION_COUNTRY", "PRODUCT_FAMILY_NAME", "PRODUCT_FAMILY_UID", "REGULATORY_APPLICATION_NAME", "REGULATORY_APPLICATION_UID", "VALIDITY_PERIOD_END", "VALIDITY_PERIOD_START", "VALIDITY_PERIOD", "MEDICINAL_PRODUCT_NAME", "PACKAGED_PRODUCT_NAME", "R_CREATOR_NAME", "R_MODIFY_DATE", "R_MODIFIER", "R_CREATION_DATE", "BUSINESS_UNIT", "CONCEPT", "INFORMATION_CLASSIFICATION", "SECURITY_DOMAIN", "IS_ACTIVE", "AUTHORIZATION_NUMBER", "TRADE_NAME", "DOSE_FORM_NAME", "DOSE_STRENGTH_NAME", "CLASSIFICATION_DOMAIN", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "DOCUMENT_URL", "SPECIAL_DESIGNATION", "SPECIAL_DESIGNATION_DATE", "INDICATION_STATUS_DATE", "INDICATION_STATUS", "ROSTER_REGION", "IS_EEA", "IS_EU", "APPLICATION_NUMBER", "APPLICATION_TYPE_NAME", "TYPE_OF_PROCEDURE", "BASE_APPLICATION_TYPE", "CONFIG_UID", "REVIEWING_MARKET_NAME", "THERAPEUTIC_AREA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH TR
        AS (SELECT DISTINCT MEDICINAL_PRODUCT_UID,
                            TRADE_NAME,
                            DOSE_FORM_NAME,
                            DOSE_STRENGTH_NAME,
                            MARKET_UID,
                            PRODUCT_FAMILY_UID,
                            HISTORIC_NAME_VALUE,
                            CLASSIFICATION_DOMAIN,
                            CLASSIFICATION_GROUP,
                            CLASSIFICATION_SUBGROUP
              FROM COSMOSDBEXPORT.PRODUCT_R, COSMOSDBEXPORT.PRODUCT
             WHERE PRODUCT_R_OBJECT_ID = R_OBJECT_ID),
             
             RAPPR
        AS (SELECT DISTINCT REGULATORY_APPLICATION_R_OBJECT_ID,
                            R_INDEX,
                            MARKET_NAME REVIEWING_MARKET_NAME,
                            MARKET_ROLE
              FROM cosmosdbexport.regulatory_application_r outr
             WHERE     MARKET_ROLE IN
                          ('Reviewing Country',
                           'Rapporteur',
                           'Reference Member State')
                   AND R_INDEX IN
                          (SELECT MAX (R_INDEX)
                             FROM cosmosdbexport.regulatory_application_r inr
                            WHERE     inr.MARKET_ROLE = outr.MARKET_ROLE
                                  AND inr.REGULATORY_APPLICATION_R_OBJECT_ID =
                                         outr.REGULATORY_APPLICATION_R_OBJECT_ID)),
     first_view
        AS (SELECT DISTINCT
                   A.R_OBJECT_ID,
                   B.R_INDEX,
                   A.AUTHORISATION_HOLDER_NAME,
                   A.AUTHORISATION_HOLDER_UID,
                   A.AUTHORISATION_STATUS,
                   A.AUTHORISATION_STATUS_DATE,
                   A.AUTHORISATION_TYPE,
                   A.DATE_OF_FIRST_AUTHORISATION,
                   A.MARKET_NAME AS AUTHORIZATION_COUNTRY,
               
              
                   A.PRODUCT_FAMILY_NAME,
                   A.PRODUCT_FAMILY_UID,
                   A.REGULATORY_APPLICATION_NAME,
                   A.REGULATORY_APPLICATION_UID,
                   A.VALIDITY_PERIOD_END,
                   A.VALIDITY_PERIOD_START,
                   CASE
                      WHEN A.VALIDITY_PERIOD_END IS NULL
                      THEN
                         'Unlimited/No Expiration'
                      ELSE
                         TO_CHAR (A.VALIDITY_PERIOD_END, 'MM/DD/YYYY')
                   END
                      AS Validity_Period,
                   B.MEDICINAL_PRODUCT_NAME,
                   B.PACKAGED_PRODUCT_NAME,
                   E.R_CREATOR_NAME,
                   E.R_MODIFY_DATE,
                   E.R_MODIFIER,
                   E.R_CREATION_DATE,
                   E.BUSINESS_UNIT,
                   E.CONCEPT,
                   E.INFORMATION_CLASSIFICATION,
                   E.SECURITY_DOMAIN,
                   E.IS_ACTIVE,
                   E.object_name AS Authorization_Number,

                   (SELECT MAX (TR.TRADE_NAME)
                      FROM TR
                     WHERE MEDICINAL_PRODUCT_UID = B.MEDICINAL_PRODUCT_UID)
                      AS TRADE_NAME,
                   (SELECT MAX (DOSE_FORM_NAME)
                      FROM TR
                     WHERE     A.MARKET_UID = MARKET_UID
                           AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID
                           AND HISTORIC_NAME_VALUE = B.MEDICINAL_PRODUCT_NAME)
                      AS DOSE_FORM_NAME,

                   (SELECT MAX (DOSE_STRENGTH_NAME)
                      FROM TR
                     WHERE     A.MARKET_UID = MARKET_UID
                           AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID
                           AND HISTORIC_NAME_VALUE = B.MEDICINAL_PRODUCT_NAME)
                      AS DOSE_STRENGTH_NAME,
                   (SELECT MAX (CLASSIFICATION_DOMAIN)
                      FROM TR
                     WHERE     A.MARKET_UID = MARKET_UID
                           AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID AND CLASSIFICATION_DOMAIN IS NOT NULL
                           ---AND HISTORIC_NAME_VALUE = B.MEDICINAL_PRODUCT_NAME
                           )
                      AS CLASSIFICATION_DOMAIN,
                   (SELECT MAX (CLASSIFICATION_GROUP)
                      FROM TR
                     WHERE     A.MARKET_UID = MARKET_UID
                           AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID and CLASSIFICATION_GROUP is not null
                           AND HISTORIC_NAME_VALUE = B.MEDICINAL_PRODUCT_NAME
                           )
                      AS CLASSIFICATION_GROUP,
                   (SELECT MAX (CLASSIFICATION_SUBGROUP)
                      FROM TR
                     WHERE     A.MARKET_UID = MARKET_UID
                           AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID and CLASSIFICATION_SUBGROUP is not null)
                           ---AND HISTORIC_NAME_VALUE = B.MEDICINAL_PRODUCT_NAME)
                      AS CLASSIFICATION_SUBGROUP,
                      --- 'http://uw00020Qk.abbvienet.dmz:8080/cara/drl/objectId/'|| A.r_object_id|| ''
                      'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
                   || A.r_object_id
                   || ''
                      AS Document_URL,
                   B.SPECIAL_DESIGNATION,
                   B.SPECIAL_DESIGNATION_DATE,
                   B.INDICATION_STATUS_DATE,
                   B.INDICATION_STATUS,
                   M.ROSTER_REGION,
                   (SELECT MAX (IS_EEA)
                      FROM COSMOSDBEXPORT.MARKET
                     WHERE ISO_COUNTRY_NAME = A.MARKET_NAME)
                      IS_EEA,
                   (SELECT MAX (IS_EU)
                      FROM COSMOSDBEXPORT.MARKET
                     WHERE ISO_COUNTRY_NAME = A.MARKET_NAME)
                      IS_EU
              FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION A
                   INNER JOIN COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R B
                      ON A.R_OBJECT_ID = B.PRODUCT_AUTHORISATION_R_OBJECT_ID
                   LEFT JOIN COSMOSDBEXPORT.MARKET M
                      ON A.market_name = M.ISO_COUNTRY_NAME
                   INNER JOIN COSMOSDBEXPORT.OBJECT E
                      ON E.R_OBJECT_ID = A.R_OBJECT_ID),

 third_view
        AS (SELECT a.*, appl.APPLICATION_NUMBER,
                           appl.APPLICATION_TYPE_NAME,
                           appl.TYPE_OF_PROCEDURE,
                           appl.BASE_APPLICATION_TYPE,d.config_uid,

                   NVL (
                      (CASE
                          WHEN TRIM (APPL.TYPE_OF_PROCEDURE) IN
                                  ('Mutual Recognition', 'Decentralised')
                          THEN
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                              APPL.R_OBJECT_ID
                                       AND TRIM (MARKET_ROLE) =
                                              TRIM ('Reference Member State')))
                          WHEN TRIM (APPL.TYPE_OF_PROCEDURE) = 'Centralised'
                          THEN
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                              APPL.R_OBJECT_ID
                                       AND TRIM (MARKET_ROLE) =
                                              TRIM ('Rapporteur')))
                          ELSE
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE REGULATORY_APPLICATION_R_OBJECT_ID =
                                          APPL.R_OBJECT_ID))
                       END),
                      A.AUTHORIZATION_COUNTRY)
                      AS REVIEWING_MARKET_NAME
              FROM first_view a
                   INNER JOIN COSMOSDBEXPORT.OBJECT d
                      ON d.CONFIG_UID = a.REGULATORY_APPLICATION_UID
                   LEFT JOIN COSMOSDBEXPORT.regulatory_application appl
                      ON appl.r_object_id = d.r_object_id),
     second_view
        AS (SELECT b.*, a.TA as Therapeutic_area
              FROM third_view b
                   LEFT JOIN VW_TA_PRDFNM a
                      ON b.PRODUCT_FAMILY_NAME = a.product)
SELECT
"R_OBJECT_ID","R_INDEX","AUTHORISATION_HOLDER_NAME","AUTHORISATION_HOLDER_UID","AUTHORISATION_STATUS","AUTHORISATION_STATUS_DATE","AUTHORISATION_TYPE","DATE_OF_FIRST_AUTHORISATION","AUTHORIZATION_COUNTRY","PRODUCT_FAMILY_NAME","PRODUCT_FAMILY_UID","REGULATORY_APPLICATION_NAME","REGULATORY_APPLICATION_UID","VALIDITY_PERIOD_END","VALIDITY_PERIOD_START","VALIDITY_PERIOD","MEDICINAL_PRODUCT_NAME","PACKAGED_PRODUCT_NAME","R_CREATOR_NAME","R_MODIFY_DATE","R_MODIFIER","R_CREATION_DATE","BUSINESS_UNIT","CONCEPT","INFORMATION_CLASSIFICATION","SECURITY_DOMAIN","IS_ACTIVE","AUTHORIZATION_NUMBER","TRADE_NAME","DOSE_FORM_NAME","DOSE_STRENGTH_NAME","CLASSIFICATION_DOMAIN","CLASSIFICATION_GROUP","CLASSIFICATION_SUBGROUP","DOCUMENT_URL","SPECIAL_DESIGNATION","SPECIAL_DESIGNATION_DATE","INDICATION_STATUS_DATE","INDICATION_STATUS","ROSTER_REGION","IS_EEA","IS_EU","APPLICATION_NUMBER","APPLICATION_TYPE_NAME","TYPE_OF_PROCEDURE","BASE_APPLICATION_TYPE","CONFIG_UID","REVIEWING_MARKET_NAME","THERAPEUTIC_AREA"
  FROM second_view;

  
  --VW_PRODUCT_AUTHORISATION
  
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_PRODUCT_AUTHORISATION" ("R_OBJECT_ID", "AUTHORISATION_NUMBER", "IS_ACTIVE", "PRODUCT_FAMILY", "MARKET_NAME", "MEDICINAL_PRODUCT", "AUTHORISATION_STATUS", "INDICATION_NAME", "AUTHORISATION_STATUS_DATE", "AUTHORISATION_TYPE", "VALIDITY_PERIOD_END", "VALIDITY_PERIOD_START", "LAST_MODIFIED", "CREATION_DATE", "MODIFIED_BY", "BUSINESS_UNIT", "INFORMATION_CLASSIFICATION", "SECURITY_DOMAIN", "APPLICATION_NAME", "REGULATORY_ACTIVITY", "PACKAGED_PRODUCT", "AUTHORISATION_HOLDER_NAME", "DATE_OF_FIRST_AUTHORISATION", "MARKET_START_DATE", "MARKET_STOP_DATE", "DATA_EXCLUSIVITY_END", "DATA_EXCLUSIVITY_START", "STUDY_NUMBER", "INVESTIGATION_CODE", "SPONSOR_NAME", "ANTICIPATED_END_DATE", "ORPHAN_INDICATION_TYPE", "CONFIG_ID", "REGULATORY_APPLICATION_UID", "DOCUMENT_URL", "SPECIAL_DESIGNATION", "SPECIAL_DESIGNATION_DATE", "INDICATION_STATUS_DATE", "INDICATION_STATUS", "R_VERSION_LABEL", "ROSTER_REGION", "IS_EEA", "IS_EU", "REVIEWING_MARKET_NAME", "CLASSIFICATION_DOMAIN", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "TYPE_OF_PROCEDURE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  WITH RAPPR
        AS (SELECT DISTINCT REGULATORY_APPLICATION_R_OBJECT_ID,
                            R_INDEX,
                            MARKET_NAME REVIEWING_MARKET_NAME,
                            MARKET_ROLE
              FROM cosmosdbexport.regulatory_application_r outr
             WHERE     MARKET_ROLE IN
                          ('Reviewing Country',
                           'Rapporteur',
                           'Reference Member State')
                   AND R_INDEX IN
                          (SELECT MAX (R_INDEX)
                             FROM cosmosdbexport.regulatory_application_r inr
                            WHERE     inr.MARKET_ROLE = outr.MARKET_ROLE
                                  AND inr.REGULATORY_APPLICATION_R_OBJECT_ID =
                                         outr.REGULATORY_APPLICATION_R_OBJECT_ID)),
     first_view
        AS (SELECT DISTINCT
                   p.r_object_id,
                   d.object_name authorisation_number,
                   d.is_active,
                   p.product_family_name PRODUCT_FAMILY,
                   p.market_name MARKET_name,
                   pr.medicinal_product_name MEDICINAL_PRODUCT,
                   p.authorisation_status,
                   pr.INDICATION_NAME,
                   authorisation_status_date,
                   authorisation_type,
                   validity_period_end,
                   validity_period_start,
                   d.R_MODIFY_DATE last_modified,
                   d.R_CREATION_DATE creation_date,
                   d.R_MODIFIER MODIFIED_BY,
                   d.business_unit,
                   d.information_classification,
                   d.security_domain,
                   p.regulatory_application_name application_name,
                   pr.regulatory_activity_name REGULATORY_ACTIVITY,
                   pr.packaged_product_name PACKAGED_PRODUCT,
                   p.authorisation_holder_name,
                   p.date_of_first_authorisation,
                   p.market_start_date,
                   p.market_stop_date,
                   data_exclusivity_end,
                   data_exclusivity_start,
                   pr.study_number,
                   investigation_code,
                   sponsor_name,
                   anticipated_end_date,
                   pr.orphan_indication_type,
                   d.config_uid config_id,
                   p.REGULATORY_APPLICATION_UID,
                      --- 'http://uw00020Qk.abbvienet.dmz:8080/cara/drl/objectId/'|| p.r_object_id|| ''
                      'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
                   || p.r_object_id
                   || ''
                      AS Document_URL,
                   pr.SPECIAL_DESIGNATION,
                   pr.SPECIAL_DESIGNATION_DATE,
                   pr.INDICATION_STATUS_DATE,
                   pr.INDICATION_STATUS,
                   f.r_version_label,
                   M.ROSTER_REGION,
                   (SELECT MAX (IS_EEA)
                      FROM COSMOSDBEXPORT.MARKET
                     WHERE ISO_COUNTRY_NAME = p.MARKET_NAME)
                      IS_EEA,
                   (SELECT MAX (IS_EU)
                      FROM COSMOSDBEXPORT.MARKET
                     WHERE ISO_COUNTRY_NAME = p.MARKET_NAME)
                      IS_EU,
                   pd.CLASSIFICATION_DOMAIN, /* added as part of Hubble 1.2 in Jun2024*/
                   pd.CLASSIFICATION_GROUP, /* added as part of Hubble 1.2 in Jun2024*/
                   pd.CLASSIFICATION_SUBGROUP /* added as part of Hubble 1.2 in Jun2024*/
              FROM cosmosdbexport.product_authorisation p
                   LEFT JOIN cosmosdbexport.product_authorisation_r pr
                      ON p.r_object_id = pr.product_authorisation_r_object_id
                   INNER JOIN COSMOSDBEXPORT.OBJECT d
                      ON /*d.CONFIG_UID = p.REGULATORY_APPLICATION_UID
                        JOIN COSMOSDBEXPORT.OBJECT dd ON*/
                        p.r_object_id = d.r_object_id
                   JOIN COSMOSDBEXPORT.PRODUCT pd
                      ON p.PRODUCT_FAMILY_UID = pd.CONFIG_UID /* added as part of Hubble 1.2 in Jun2024*/
                   INNER JOIN COSMOSDBEXPORT.OBJECT_r f
                      ON f.object_r_object_id = d.r_object_id
                   LEFT JOIN COSMOSDBEXPORT.MARKET M
                      ON p.market_name = M.ISO_COUNTRY_NAME),
     second_view
        AS (SELECT a.*,
                   APPL.TYPE_OF_PROCEDURE,
                   NVL (
                      (CASE
                          WHEN TRIM (APPL.TYPE_OF_PROCEDURE) IN
                                  ('Mutual Recognition', 'Decentralised')
                          THEN
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                              APPL.R_OBJECT_ID
                                       AND TRIM (MARKET_ROLE) =
                                              TRIM ('Reference Member State')))
                          WHEN TRIM (APPL.TYPE_OF_PROCEDURE) = 'Centralised'
                          THEN
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                              APPL.R_OBJECT_ID
                                       AND TRIM (MARKET_ROLE) =
                                              TRIM ('Rapporteur')))
                          ELSE
                             ( (SELECT DISTINCT REVIEWING_MARKET_NAME
                                  FROM RAPPR
                                 WHERE REGULATORY_APPLICATION_R_OBJECT_ID =
                                          APPL.R_OBJECT_ID))
                       END),
                      A.MARKET_NAME)
                      AS REVIEWING_MARKET_NAME
              FROM first_view a
                   INNER JOIN COSMOSDBEXPORT.OBJECT d
                      ON d.CONFIG_UID = a.REGULATORY_APPLICATION_UID
                   LEFT JOIN COSMOSDBEXPORT.regulatory_application appl
                      ON appl.r_object_id = d.r_object_id)
SELECT "R_OBJECT_ID",
       "AUTHORISATION_NUMBER",
       "IS_ACTIVE",
       "PRODUCT_FAMILY",
       "MARKET_NAME",
       "MEDICINAL_PRODUCT",
       "AUTHORISATION_STATUS",
       "INDICATION_NAME",
       "AUTHORISATION_STATUS_DATE",
       "AUTHORISATION_TYPE",
       "VALIDITY_PERIOD_END",
       "VALIDITY_PERIOD_START",
       "LAST_MODIFIED",
       "CREATION_DATE",
       "MODIFIED_BY",
       "BUSINESS_UNIT",
       "INFORMATION_CLASSIFICATION",
       "SECURITY_DOMAIN",
       "APPLICATION_NAME",
       "REGULATORY_ACTIVITY",
       "PACKAGED_PRODUCT",
       "AUTHORISATION_HOLDER_NAME",
       "DATE_OF_FIRST_AUTHORISATION",
       "MARKET_START_DATE",
       "MARKET_STOP_DATE",
       "DATA_EXCLUSIVITY_END",
       "DATA_EXCLUSIVITY_START",
       "STUDY_NUMBER",
       "INVESTIGATION_CODE",
       "SPONSOR_NAME",
       "ANTICIPATED_END_DATE",
       "ORPHAN_INDICATION_TYPE",
       "CONFIG_ID",
       "REGULATORY_APPLICATION_UID",
       "DOCUMENT_URL",
       "SPECIAL_DESIGNATION",
       "SPECIAL_DESIGNATION_DATE",
       "INDICATION_STATUS_DATE",
       "INDICATION_STATUS",
       "R_VERSION_LABEL",
       "ROSTER_REGION",
       "IS_EEA",
       "IS_EU",
       "REVIEWING_MARKET_NAME",
       "CLASSIFICATION_DOMAIN",    /* added as part of Hubble 1.2 in Jun2024*/
       "CLASSIFICATION_GROUP",     /* added as part of Hubble 1.2 in Jun2024*/
       "CLASSIFICATION_SUBGROUP",  /* added as part of Hubble 1.2 in Jun2024*/
       TYPE_OF_PROCEDURE           /* added as part of Hubble 1.2 in Jun2024*/
  FROM second_view;

  
  
  
  --VW_AUTH_PRODUCT_REG_PSMF
  
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_AUTH_PRODUCT_REG_PSMF" ("R_OBJECT_ID", "MARKETING_AUTHORIZATION_NUMBER", "R_INDEX", "AUTHORISATION_HOLDER_NAME", "AUTHORISATION_HOLDER_UID", "AUTHORISATION_STATUS", "AUTHORISATION_STATUS_DATE", "AUTHORISATION_TYPE", "DATE_OF_FIRST_AUTHORISATION", "AUTHORIZATION_COUNTRY", "MARKET_NAME", "REVIEWING_MARKET_NAME", "PRODUCT_FAMILY_NAME", "PRODUCT_FAMILY_UID", "REGULATORY_APPLICATION_NAME", "REGULATORY_APPLICATION_UID", "VALIDITY_PERIOD_END", "VALIDITY_PERIOD_START", "MEDICINAL_PRODUCT_NAME", "PACKAGED_PRODUCT_NAME", "R_CREATOR_NAME", "R_MODIFY_DATE", "R_MODIFIER", "R_CREATION_DATE", "BUSINESS_UNIT", "CONCEPT", "INFORMATION_CLASSIFICATION", "SECURITY_DOMAIN", "IS_ACTIVE", "APPLICATION_NUMBER", "APPLICATION_TYPE_NAME", "TYPE_OF_PROCEDURE", "BASE_APPLICATION_TYPE", "TRADE_NAME", "DOSE_FORM_NAME", "REGULATORY_APPLICATION_R_OBJECT_ID", "DOSE_STRENGTH_NAME", "CLASSIFICATION_DOMAIN", "MARKET_ROLE", "IS_EEA", "IS_EU", "ROSTER_REGION") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  with TR
        AS
            (SELECT DISTINCT CONFIG_UID,
                             MEDICINAL_PRODUCT_UID,
                             TRADE_NAME,
                             DOSE_FORM_NAME,
                             DOSE_STRENGTH_NAME,
                             MARKET_UID,
                             PRODUCT_FAMILY_UID,
                             HISTORIC_NAME_VALUE,
                             CLASSIFICATION_DOMAIN
               FROM COSMOSDBEXPORT.PRODUCT_R, COSMOSDBEXPORT.PRODUCT
              WHERE PRODUCT_R_OBJECT_ID = R_OBJECT_ID),
        MKT
        AS
            (SELECT DISTINCT CONFIG_UID,
                             OBJECT_NAME,
                             APPLICATION_TYPE_NAME,
                             APPLICATION_TYPE_UID,
                             AUTHORISATION_HOLDER_NAME,
                             AUTHORISATION_HOLDER_UID,
                             GROUP_MEMBER_NAME,
                             GROUP_MEMBER_UID
               FROM COSMOSDBEXPORT.MARKET    MK,
                    COSMOSDBEXPORT.OBJECT    OB,
                    COSMOSDBEXPORT.MARKET_R  MKR
              WHERE     MK.R_OBJECT_ID = OB.R_OBJECT_ID
                    AND MK.R_OBJECT_ID = MKR.MARKET_R_OBJECT_ID),
        RAPPR
        AS
            (SELECT DISTINCT REGULATORY_APPLICATION_R_OBJECT_ID,
                             R_INDEX,
                             MARKET_NAME,
                             MARKET_ROLE,
                             MARKET_UID     REVIEWING_MARKET_NAME,
                             REVIEWING_MARKET_UID,
                             STUDY_NUMBER
               FROM cosmosdbexport.regulatory_application_r outr
              WHERE     MARKET_ROLE IN
                            ('Reviewing Country',
                             'Rapporteur',
                             'Reference Member State')
                    AND R_INDEX IN
                            (SELECT MAX (R_INDEX)
                               FROM cosmosdbexport.regulatory_application_r
                                    inr
                              WHERE     inr.MARKET_ROLE = outr.MARKET_ROLE
                                    AND inr.REGULATORY_APPLICATION_R_OBJECT_ID =
                                        outr.REGULATORY_APPLICATION_R_OBJECT_ID)),
        PAUTHR
        AS
            (SELECT PRODUCT_AUTHORISATION_R_OBJECT_ID,
                    MEDICINAL_PRODUCT_UID      MEDICINAL_PRODUCT_UID_AUTH,
                    MEDICINAL_PRODUCT_NAME     MEDICINAL_PRODUCT_NAME_AUTH,
                    PACKAGED_PRODUCT_NAME      PACKAGED_PRODUCT_NAME_AUTH
               FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R OUTR
              WHERE R_INDEX IN
                        (SELECT MAX (R_INDEX)
                           FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R INR
                          WHERE     INR.PRODUCT_AUTHORISATION_R_OBJECT_ID =
                                    OUTR.PRODUCT_AUTHORISATION_R_OBJECT_ID
                                AND (   MEDICINAL_PRODUCT_UID IS NOT NULL
                                     OR MEDICINAL_PRODUCT_NAME IS NOT NULL
                                     OR PACKAGED_PRODUCT_NAME IS NOT NULL)))
      SELECT DISTINCT
             A.R_OBJECT_ID,
             AO.OBJECT_NAME
                 Marketing_Authorization_Number,
             (CASE
                  WHEN TRIM (APPL.TYPE_OF_PROCEDURE) =
                       'Mutual Recognition'
                  THEN
                      ((SELECT DISTINCT R_INDEX
                          FROM RAPPR
                         WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                   APPL.R_OBJECT_ID
                               AND TRIM (MARKET_ROLE) =
                                   TRIM ('Reference Member State')))
                  WHEN TRIM (APPL.TYPE_OF_PROCEDURE) = 'Centralised'
                  THEN
                      ((SELECT DISTINCT R_INDEX
                          FROM RAPPR
                         WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                   APPL.R_OBJECT_ID
                               AND TRIM (MARKET_ROLE) =
                                   TRIM ('Rapporteur')))
                  ELSE
                      ((SELECT DISTINCT R_INDEX
                          FROM RAPPR
                         WHERE REGULATORY_APPLICATION_R_OBJECT_ID =
                               APPL.R_OBJECT_ID))
              END)
                 AS R_INDEX,
             A.AUTHORISATION_HOLDER_NAME,
             A.AUTHORISATION_HOLDER_UID,
             A.AUTHORISATION_STATUS,
             A.AUTHORISATION_STATUS_DATE,
             A.AUTHORISATION_TYPE,
             A.DATE_OF_FIRST_AUTHORISATION,
             A.MARKET_NAME
                 AS AUTHORIZATION_COUNTRY,
             /*(SELECT max OBJECT_NAME
                FROM MKT, RAPPR
               WHERE     CONFIG_UID = MARKET_IID
                     AND REGULATORY_APPLICATION_R_OBJECT_ID = APPL.R_OBJECT_ID
                     AND AUTHORISATION_HOLDER_UID = A.AUTHORISATION_HOLDER_UID
                     --AND APPLICATION_TYPE_UID = E.CONFIG_UID
                     )*/
             A.MARKET_NAME
                 AS market_name,
             NVL (
                 (CASE
                      WHEN TRIM (APPL.TYPE_OF_PROCEDURE) =
                           'Mutual Recognition'
                      THEN
                          ((SELECT DISTINCT MARKET_NAME
                              FROM RAPPR
                             WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                       APPL.R_OBJECT_ID
                                   AND TRIM (MARKET_ROLE) =
                                       TRIM ('Reference Member State')))
                      WHEN TRIM (APPL.TYPE_OF_PROCEDURE) =
                           'Centralised'
                      THEN
                          ((SELECT DISTINCT MARKET_NAME
                              FROM RAPPR
                             WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                       APPL.R_OBJECT_ID
                                   AND TRIM (MARKET_ROLE) =
                                       TRIM ('Rapporteur')))
                      ELSE
                          ((SELECT DISTINCT MARKET_NAME
                              FROM RAPPR
                             WHERE REGULATORY_APPLICATION_R_OBJECT_ID =
                                   APPL.R_OBJECT_ID))
                  END),
                 A.MARKET_NAME)
                 AS REVIEWING_MARKET_NAME,
             A.PRODUCT_FAMILY_NAME,
             A.PRODUCT_FAMILY_UID,
             A.REGULATORY_APPLICATION_NAME,
             A.REGULATORY_APPLICATION_UID,
             A.VALIDITY_PERIOD_END,
             A.VALIDITY_PERIOD_START,
             (SELECT MEDICINAL_PRODUCT_NAME_AUTH
                FROM PAUTHR
               WHERE PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS MEDICINAL_PRODUCT_NAME,
             (SELECT PACKAGED_PRODUCT_NAME_AUTH
                FROM PAUTHR
               WHERE PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS PACKAGED_PRODUCT_NAME,
             --B.PACKAGED_PRODUCT_NAME,
             E.R_CREATOR_NAME,
             E.R_MODIFY_DATE,
             E.R_MODIFIER,
             E.R_CREATION_DATE,
             E.BUSINESS_UNIT,
             E.CONCEPT,
             E.INFORMATION_CLASSIFICATION,
             E.SECURITY_DOMAIN,
             E.IS_ACTIVE,
             --- E.object_name AS Authorization_NAME,
             APPL.APPLICATION_NUMBER,
             APPL.APPLICATION_TYPE_NAME,
             APPL.TYPE_OF_PROCEDURE,
             APPL.BASE_APPLICATION_TYPE,
             (SELECT MAX (TR.TRADE_NAME)
                FROM TR, PAUTHR
               WHERE     MEDICINAL_PRODUCT_UID = MEDICINAL_PRODUCT_UID_AUTH
                     AND PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS TRADE_NAME,
             (SELECT MAX (DOSE_FORM_NAME)
                FROM TR, PAUTHR
               WHERE     A.MARKET_UID = MARKET_UID
                     AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID
                     AND HISTORIC_NAME_VALUE = MEDICINAL_PRODUCT_NAME_AUTH
                     AND PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS DOSE_FORM_NAME,
             APPL.R_OBJECT_ID
                 REGULATORY_APPLICATION_R_OBJECT_ID,
             (SELECT MAX (DOSE_STRENGTH_NAME)
                FROM TR, PAUTHR
               WHERE     A.MARKET_UID = MARKET_UID
                     AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID
                     AND HISTORIC_NAME_VALUE = MEDICINAL_PRODUCT_NAME_AUTH
                     AND PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS DOSE_STRENGTH_NAME,
             (SELECT MAX (CLASSIFICATION_DOMAIN)
                FROM TR, PAUTHR
               WHERE     A.MARKET_UID = MARKET_UID
                     AND A.PRODUCT_FAMILY_UID = PRODUCT_FAMILY_UID
                     AND HISTORIC_NAME_VALUE = MEDICINAL_PRODUCT_NAME_AUTH
                     AND PRODUCT_AUTHORISATION_R_OBJECT_ID = A.R_OBJECT_ID)
                 AS CLASSIFICATION_DOMAIN,
             NVL (
                 (CASE
                      WHEN TRIM (APPL.TYPE_OF_PROCEDURE) = 'Mutual Recognition'
                      THEN
                          ((SELECT DISTINCT MARKET_ROLE
                              FROM RAPPR
                             WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                       APPL.R_OBJECT_ID
                                   AND TRIM (MARKET_ROLE) =
                                       TRIM ('Reference Member State')))
                      WHEN TRIM (APPL.TYPE_OF_PROCEDURE) = 'Centralised'
                      THEN
                          ((SELECT DISTINCT MARKET_ROLE
                              FROM RAPPR
                             WHERE     REGULATORY_APPLICATION_R_OBJECT_ID =
                                       APPL.R_OBJECT_ID
                                   AND TRIM (MARKET_ROLE) = TRIM ('Rapporteur')))
                      ELSE
                          ((SELECT DISTINCT MARKET_ROLE
                              FROM RAPPR
                             WHERE REGULATORY_APPLICATION_R_OBJECT_ID =
                                   APPL.R_OBJECT_ID))
                  END),
                 'Reviewing Country')
                 AS MARKET_ROLE,
             (SELECT MAX (IS_EEA)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = A.MARKET_NAME)
                 IS_EEA,(SELECT MAX (IS_EU)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = A.MARKET_NAME)
               IS_EU,M.roster_region
        FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION A,
             COSMOSDBEXPORT.REGULATORY_APPLICATION APPL,
             COSMOSDBEXPORT.OBJECT                E, ----,         COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R B
             COSMOSDBEXPORT.OBJECT                AO,
             COSMOSDBEXPORT.MARKET M
       WHERE     A.REGULATORY_APPLICATION_UID = E.CONFIG_UID
             AND APPL.R_OBJECT_ID = E.R_OBJECT_ID
             AND A.R_OBJECT_ID = AO.R_OBJECT_ID
             AND E.IS_ACTIVE = 'Y'
             AND AO.IS_ACTIVE = 'Y'
             AND A.AUTHORISATION_STATUS = 'Approved' --and auth.is_active=true
             ---AND A.R_OBJECT_ID = B.PRODUCT_AUTHORISATION_R_OBJECT_ID
             AND APPL.APPLICATION_TYPE_NAME IN
                     ('Market Authorisation Application',
                      'New Drug Application',
                      'New Drug Submission',
                      'Abbreviated New Drug Application',
                      'Biologic License Application',
                      'Article 58',
                      'Medical Device',
                      'Product Notification',
                      'CE Mark')
             --- AND EXISTS (select 1 from COSMOSDBEXPORT.MARKET where ISO_COUNTRY_NAME=A.MARKET_NAME and IS_EEA='Y')
             AND EXISTS
                     (SELECT 1
                        FROM VW_PSMF_MAA_EAA
                       WHERE OBJECT_NAME = A.PRODUCT_FAMILY_NAME) and  A.Market_Name = M.ISO_COUNTRY_NAME(+)

    --and E.object_name='Adalimumab - EMEA/H/C/000481 - EU'
    ---  AND APPL.R_OBJECT_ID ='0800f9f684eb94e2'
    ORDER BY 1, 2;

	
	
	
	
	--VW_REGULATORY_APPLICATION

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_REGULATORY_APPLICATION" ("R_OBJECT_ID", "BASE_APPLICATION_TYPE", "TYPE_OF_PROCEDURE", "OBJECT_NAME", "APPLICATION_TYPE_NAME", "APPLICATION_NUMBER", "PRODUCT_FAMILY_NAME", "MARKET_NAME", "REVIEWING_MARKET_NAME", "STUDY_NUMBER", "MEDICINAL_PRODUCT_NAME", "BUSINESS_UNIT", "INFORMATION_CLASSIFICATION", "SECURITY_DOMAIN", "MODIFIED_DATE", "CREATION_DATE", "MODIFIED_BY", "IS_ACTIVE", "HISTORIC_NAME_VALUE", "NAME_VALUE_CHANGE_DATE", "CONFIG_UID", "DOCUMENT_URL", "ROSTER_REGION", "IS_EEA", "IS_EU", "R_VERSION_LABEL", "PRD_CLASSIFICATION_DOMAIN", "PRD_CLASSIFICATION_GROUP", "PRD_CLASSIFICATION_SUBGROUP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT r.r_object_id,
       BASE_APPLICATION_TYPE,
       type_of_procedure,
       o.object_name,
       application_type_name,
       application_number,
       product_family_name,
       MARKET_NAME,
       REVIEWING_MARKET_NAME,
       STUDY_NUMBER,
       MEDICINAL_PRODUCT_NAME,
       o.BUSINESS_UNIT,
       o.INFORMATION_CLASSIFICATION,
       o.SECURITY_DOMAIN,
       O.R_MODIFY_DATE MODIFIED_DATE,
       o.R_CREATION_DATE CREATION_DATE,
       o.R_MODIFIER MODIFIED_BY,
       o.IS_ACTIVE,
       HISTORIC_NAME_VALUE,
       NAME_VALUE_CHANGE_DATE,
       o.config_uid,
       'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/' || r.r_object_id || ''
          AS Document_URL,
       M.roster_region,(SELECT MAX (IS_EEA)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = ra.MARKET_NAME)
                 IS_EEA,(SELECT MAX (IS_EU)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = ra.MARKET_NAME)
               IS_EU,
       ob.r_version_label,
	   prd.CLASSIFICATION_DOMAIN prd_CLASSIFICATION_DOMAIN,
	   prd.CLASSIFICATION_GROUP prd_CLASSIFICATION_GROUP,
	   prd.CLASSIFICATION_SUBGROUP prd_CLASSIFICATION_SUBGROUP
  FROM COSMOSDBEXPORT.regulatory_application r
       JOIN cosmosdbexport.regulatory_application_r ra
          ON r.r_object_id = ra.REGULATORY_APPLICATION_R_OBJECT_ID
       JOIN cosmosdbexport.object o ON r.r_object_id = o.r_object_id
       JOIN cosmosdbexport.object_r ob
          ON ob.OBJECT_R_OBJECT_ID = r.r_object_id
       LEFT JOIN COSMOSDBEXPORT.MARKET M on ra.market_name = M.ISO_COUNTRY_NAME
	   JOIN cosmosdbexport.product prd
	   ON prd.CONFIG_UID=r.PRODUCT_FAMILY_UID;

	   
	   
	   
--VW_PSMF_MAA_EAA
	   
	   
	   
	   
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_PSMF_MAA_EAA" ("OBJECT_NAME", "DEVELOPMENT_NUMBER") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT d.object_name, /*LISTAGG (DISTINCT DEVELOPMENT_NUMBER, ',')
                   WITHIN GROUP (ORDER BY B.R_INDEX)
                   OVER (PARTITION BY A.R_OBJECT_ID) */
             LISTAGG (DISTINCT DEVELOPMENT_NUMBER, ',')
                 WITHIN GROUP (ORDER BY B.R_INDEX)    AS DEVELOPMENT_NUMBER
        FROM cosmosdbexport.substance  a,
             cosmosdbexport.substance_r b,
             object                    c,
             (SELECT object_name, DRUG_SUBSTANCE_UID
                FROM cosmosdbexport.product prd, cosmosdbexport.product_r prd_r
               WHERE     prd.r_object_id = prd_r.PRODUCT_R_OBJECT_ID
                     AND is_active = 'Y'
                     AND classification_domain <> 'Medical Device'
                     AND (   EXISTS
                                 (SELECT 1
                                    FROM dup_product_authorisation pa,
                                         cosmosdbexport.object    b
                                   WHERE     pa.r_object_id = b.r_object_id
                                         AND (   market_name IN
                                                     (SELECT DISTINCT
                                                             group_member_name
                                                        FROM cosmosdbexport.market
                                                             a,
                                                             cosmosdbexport.MARKET_R
                                                             b,
                                                             cosmosdbexport.object
                                                             c
                                                       WHERE     a.r_object_id =
                                                                 b.MARKET_R_OBJECT_ID
                                                             AND a.r_object_id =
                                                                 c.r_object_id
                                                             AND object_name =
                                                                 'European Union'
                                                             AND group_member_name
                                                                     IS NOT NULL)
                                              OR market_name = 'European Union')
                                         AND authorisation_status = 'Approved'
                                         AND is_active = 'Y'
                                         AND authorisation_type =
                                             'Marketing Application'
                                         AND EXISTS
                                                 (SELECT 1
                                                    FROM cosmosdbexport.regulatory_application
                                                         a,
                                                         cosmosdbexport.object
                                                         b
                                                   WHERE     a.r_object_id =
                                                             b.r_object_id
                                                         AND application_type_name =
                                                             'Market Authorisation Application'
                                                         AND config_uid =
                                                             pa.regulatory_application_uid)
                                         AND product_family_uid =
                                             prd.config_uid)
                          OR EXISTS
                                 (SELECT 1
                                    FROM TA_DRUG_LIST
                                   WHERE     EAA_APPLICABLE_FLAG = 'Y'
                                         AND PRODUCT = OBJECT_NAME))) d
       WHERE     a.R_OBJECT_ID = SUBSTANCE_R_OBJECT_ID --and DEVELOPMENT_NUMBER is not null
             AND a.R_OBJECT_ID = c.R_OBJECT_ID
             AND c.CONFIG_UID = d.DRUG_SUBSTANCE_UID
    GROUP BY d.object_name
    ORDER BY d.object_name;

	
	
	
--VW_COMMITMENTS

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_COMMITMENTS" ("R_OBJECT_ID", "ACTIVITY_NAME", "ACTIVITY_TYPE", "STATUS_DATE", "AGENCY_STATUS", "AGENCY_NAME", "AGENCY_QUALIFICATION", "AGENCY_RESPONSE", "AGENCY_RESPONSE_DATE", "AGENCY_UID", "APPLICATION_NUMBER", "APPLICATION_TYPE_NAME", "APPLICATION_TYPE_UID", "ASSEMBLY_ID", "APPLICATION_TYPE", "BU_ABBREV", "BUSINESS_UNIT", "CCDS_CHANGE_DESCRIPTION", "CCDS_CHANGE_IMPLEMENTATION", "CCDS_CHANGE_TYPE", "CHANGE_NUMBER", "ACTIVITY_ARTIFACT", "CLASSIFICATION_DOMAIN", "ACTIVITY_GROUP", "ACTIVITY_SUBGROUP", "COMMITMENT_START_DATE", "STATUS", "CONFIG_UID", "CORRESPONDENCE_ID", "DATE_ARCHIVED", "DATE_OPENED", "FIRST_SUBMISSION_DATE", "FULL_DESCRIPTION", "GLOBAL_PRODUCT", "GLOBAL_PRODUCT_UID", "INFORMATION_CLASSIFICATION", "INITIAL_SEQUENCE_NUMBER", "IS_ACTIVE", "IS_CCDS", "IS_ORIGINAL", "RECONCILIATION_STATUS", "LINKED_ACTIVITY_NAME", "LINKED_ACTIVITY_UID", "EVENT_NAME", "LINKED_EVENT_UID", "MARKET_APPROVAL_DATE", "MARKET", "MARKET_ROLE", "MARKET_SUBMISSION_DATE", "MARKET_UID", "MEDICINAL_PRODUCT", "MEDICINAL_PRODUCT_UID", "PACKAGED_PRODUCT_NAME", "PACKAGED_PRODUCT_UID", "PARENT_EVENT_NAME", "PARENT_EVENT_UID", "PROCESS_ACTION_RECORD_ID", "PROCESS_NAME", "PROCESS_PHASE", "PROCESS_STAGE", "PROCESS_STAGE_UID", "PROCESS_UID", "PRODUCT_FAMILY", "PRODUCT_FAMILY_UID", "REFERENCE_MARKET_NAME", "REFERENCE_MARKET_UID", "APPLICATION_NAME", "REGULATORY_APPLICATION_UID", "RESPONSIBLE_PERSON", "RESPONSIBLE_PERSON_ID", "REVIEWING_MARKET", "REVIEWING_MARKET_UID", "SAFETY_PV_FLAGGED", "SAFETY_SIGNAL_NUMBER", "SECURITY_DOMAIN", "STUDY_NUMBER", "STUDY_UID", "SUBMISSION_MANAGER_TYPE", "SUPPORTING_DOCUMENT_ID", "TARGET_COMPLETION_DATE", "TARGET_COMPLETION_DATE_IND", "TRACKING_NUMBER", "TYPE_OF_PROCEDURE", "TYPE_OF_REPORT", "TYPE_OF_SUBMISSION_NAME", "TYPE_OF_SUBMISSION_UID", "WAVE_GROUP", "CREATION_DATE", "LAST_MODIFIED", "JOIN_EVENT_NAME", "DOCUMENT_URL", "R_VERSION_LABEL", "ROSTER_REGION", "IS_EEA", "IS_EU", "THERAPEUTIC_AREA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  with first_view as(
SELECT DISTINCT
           a.R_OBJECT_ID                                                        R_OBJECT_ID,

           b.OBJECT_NAME                                                        Activity_Name,
           c.activity_type,
           B.agency_approval_date                                               Status_Date,
           B.agency_approval_status                                             Agency_Status,
           agency_name,
           agency_qualification,
           agency_response,
           agency_response_date,
           agency_uid,
           application_number,
           application_type_name,
           application_type_uid,
           assembly_id,
           B.base_application_type                                              Application_Type,
           B.bu_abbrev,
           B.business_unit,
           ccds_change_description,
           ccds_change_implementation,
           ccds_change_type,
           change_number,
           B.classification_artifact                                            Activity_Artifact,
           B.classification_domain,
           B.classification_group                                               Activity_Group,
           B.classification_subgroup                                            Activity_Subgroup,
           commitment_start_date,
           commitment_status                                                    Status,
           config_uid,
           correspondence_id,
           date_archived,
           date_opened,
           first_submission_date                                                First_submission_date,
           full_description,
           global_product_name                                                  Global_Product,
           global_product_uid,
           B.information_classification,
           initial_sequence_number,
           B.is_active,
           is_ccds,
           is_original,
           is_reconciled                                                        reconciliation_status,
           linked_activity_name,
           linked_activity_uid,
           linked_event_name                                                    Event_name,
           linked_event_uid,
           market_approval_date,
           market_name                                                          Market,
           market_role,
           market_submission_date,
           market_uid,
           medicinal_product_name                                               medicinal_product,
           medicinal_product_uid,
           packaged_product_name,
           packaged_product_uid,
           parent_event_name,
           parent_event_uid,
           process_action_record_id,
           B.process_name,
           B.process_phase                                                      Process_Phase,
           B.process_stage_name                                                 Process_Stage,
           b.process_stage_uid,
           B.process_uid,
           product_family_name                                                  Product_Family,
           product_family_uid,
           reference_market_name,
           reference_market_uid,
           regulatory_application_name                                          application_name,
           regulatory_application_uid,
           responsible_person,
      
           responsible_person_id,
           reviewing_market_name                                                reviewing_market,
           reviewing_market_uid,
           safety_pv_flagged,
           safety_signal_number,
           b.security_domain,
           study_number                                                         Study_Number,
           study_uid,
           submission_manager_type,
           supporting_document_id,
           B.target_completion_date,
           (CASE
                WHEN    (    B.agency_approval_status IN
                                 ('Ongoing', 'Delayed', 'Pending')
                         AND TRUNC (SYSDATE) >
                             B.target_completion_date)
                     OR (B.agency_approval_status = 'Not Submitted')
                THEN
                    2
                WHEN     B.agency_approval_status IN
                             ('Ongoing', 'Delayed', 'Pending')
                     AND ((SELECT MONTHS_BETWEEN (
                                      B.target_completion_date,
                                      TRUNC (SYSDATE))
                             FROM DUAL) BETWEEN 0
                                            AND 3)
                THEN
                    1
                ELSE
                    0
            END)                                                                target_completion_date_ind,
           tracking_number,
           type_of_procedure                                                    Type_of_Procedure,
           type_of_report,
           type_of_submission_name,
           type_of_submission_uid,
           wave_group,
           b.R_CREATION_DATE                                                    Creation_Date,
           b.R_MODIFY_DATE                                                      Last_Modified,
           NVL (parent_event_UID, linked_event_UID)                             JOIN_EVENT_NAME,
           'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/' || b.r_object_id || ''    AS Document_URL,
         c.r_version_label,M.ROSTER_REGION,(SELECT MAX (IS_EEA)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = c.MARKET_NAME)
                 IS_EEA,(SELECT MAX (IS_EU)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = c.MARKET_NAME)
               IS_EU
      FROM COSMOSDBEXPORT.SUBMISSION_MANAGER b
     inner JOIN COSMOSDBEXPORT.regulatory_activity a
          ON b.R_OBJECT_ID = a.R_OBJECT_ID
       left JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER_R c
          ON b.R_OBJECT_ID = c.SUBMISSION_MANAGER_R_OBJECT_ID
           LEFT JOIN COSMOSDBEXPORT.MARKET M on c.market_name = M.ISO_COUNTRY_NAME),



second_view as (select SUBMISSION_MANAGER_R_OBJECT_ID
from COSMOSDBEXPORT.SUBMISSION_MANAGER_R where ACTIVITY_TYPE IN ('Regulatory Commitment')),
third_view as (
select a.* from first_view a
inner join second_view b on a.R_OBJECT_ID =b.SUBMISSION_MANAGER_R_OBJECT_ID)

select b."R_OBJECT_ID",b."ACTIVITY_NAME",b."ACTIVITY_TYPE",b."STATUS_DATE",b."AGENCY_STATUS",b."AGENCY_NAME",b."AGENCY_QUALIFICATION",b."AGENCY_RESPONSE",b."AGENCY_RESPONSE_DATE",b."AGENCY_UID",b."APPLICATION_NUMBER",b."APPLICATION_TYPE_NAME",b."APPLICATION_TYPE_UID",b."ASSEMBLY_ID",b."APPLICATION_TYPE",b."BU_ABBREV",b."BUSINESS_UNIT",b."CCDS_CHANGE_DESCRIPTION",b."CCDS_CHANGE_IMPLEMENTATION",b."CCDS_CHANGE_TYPE",b."CHANGE_NUMBER",b."ACTIVITY_ARTIFACT",b."CLASSIFICATION_DOMAIN",b."ACTIVITY_GROUP",b."ACTIVITY_SUBGROUP",b."COMMITMENT_START_DATE",b."STATUS",b."CONFIG_UID",b."CORRESPONDENCE_ID",b."DATE_ARCHIVED",b."DATE_OPENED",b."FIRST_SUBMISSION_DATE",b."FULL_DESCRIPTION",b."GLOBAL_PRODUCT",b."GLOBAL_PRODUCT_UID",b."INFORMATION_CLASSIFICATION",b."INITIAL_SEQUENCE_NUMBER",b."IS_ACTIVE",b."IS_CCDS",b."IS_ORIGINAL",b."RECONCILIATION_STATUS",b."LINKED_ACTIVITY_NAME",b."LINKED_ACTIVITY_UID",b."EVENT_NAME",b."LINKED_EVENT_UID",b."MARKET_APPROVAL_DATE",b."MARKET",b."MARKET_ROLE",b."MARKET_SUBMISSION_DATE",b."MARKET_UID",b."MEDICINAL_PRODUCT",b."MEDICINAL_PRODUCT_UID",b."PACKAGED_PRODUCT_NAME",b."PACKAGED_PRODUCT_UID",b."PARENT_EVENT_NAME",b."PARENT_EVENT_UID",b."PROCESS_ACTION_RECORD_ID",b."PROCESS_NAME",b."PROCESS_PHASE",b."PROCESS_STAGE",b."PROCESS_STAGE_UID",b."PROCESS_UID",b."PRODUCT_FAMILY",b."PRODUCT_FAMILY_UID",b."REFERENCE_MARKET_NAME",b."REFERENCE_MARKET_UID",b."APPLICATION_NAME",b."REGULATORY_APPLICATION_UID",b."RESPONSIBLE_PERSON",b."RESPONSIBLE_PERSON_ID",b."REVIEWING_MARKET",b."REVIEWING_MARKET_UID",b."SAFETY_PV_FLAGGED",b."SAFETY_SIGNAL_NUMBER",b."SECURITY_DOMAIN",b."STUDY_NUMBER",b."STUDY_UID",b."SUBMISSION_MANAGER_TYPE",b."SUPPORTING_DOCUMENT_ID",b."TARGET_COMPLETION_DATE",b."TARGET_COMPLETION_DATE_IND",b."TRACKING_NUMBER",b."TYPE_OF_PROCEDURE",b."TYPE_OF_REPORT",b."TYPE_OF_SUBMISSION_NAME",b."TYPE_OF_SUBMISSION_UID",b."WAVE_GROUP",b."CREATION_DATE",b."LAST_MODIFIED",b."JOIN_EVENT_NAME",b."DOCUMENT_URL",b."R_VERSION_LABEL",b."ROSTER_REGION",b."IS_EEA",b."IS_EU",a.ta as therapeutic_area
from third_view  b 

left join  VW_TA_PRDFNM a on b.Product_Family = a.product;





--VW_OBLIGATION



  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_OBLIGATION" ("R_OBJECT_ID", "ACTIVITY_NAME", "ACTIVITY_TYPE", "STATUS_DATE", "AGENCY_STATUS", "AGENCY_NAME", "AGENCY_QUALIFICATION", "AGENCY_RESPONSE", "AGENCY_RESPONSE_DATE", "AGENCY_UID", "APPLICATION_NUMBER", "APPLICATION_TYPE_NAME", "APPLICATION_TYPE_UID", "ASSEMBLY_ID", "APPLICATION_TYPE", "BU_ABBREV", "BUSINESS_UNIT", "CCDS_CHANGE_DESCRIPTION", "CCDS_CHANGE_IMPLEMENTATION", "CCDS_CHANGE_TYPE", "CHANGE_NUMBER", "ACTIVITY_ARTIFACT", "CLASSIFICATION_DOMAIN", "ACTIVITY_GROUP", "ACTIVITY_SUBGROUP", "COMMITMENT_START_DATE", "STATUS", "CONFIG_UID", "CORRESPONDENCE_ID", "DATE_ARCHIVED", "DATE_OPENED", "FIRST_SUBMISSION_DATE", "FULL_DESCRIPTION", "GLOBAL_PRODUCT", "GLOBAL_PRODUCT_UID", "INFORMATION_CLASSIFICATION", "INITIAL_SEQUENCE_NUMBER", "IS_ACTIVE", "IS_CCDS", "IS_ORIGINAL", "RECONCILIATION_STATUS", "LINKED_ACTIVITY_NAME", "LINKED_ACTIVITY_UID", "EVENT_NAME", "LINKED_EVENT_UID", "MARKET_APPROVAL_DATE", "MARKET", "MARKET_ROLE", "MARKET_SUBMISSION_DATE", "MARKET_UID", "MEDICINAL_PRODUCT", "MEDICINAL_PRODUCT_UID", "PACKAGED_PRODUCT_NAME", "PACKAGED_PRODUCT_UID", "PARENT_EVENT_NAME", "PARENT_EVENT_UID", "PROCESS_ACTION_RECORD_ID", "PROCESS_NAME", "PROCESS_PHASE", "PROCESS_STAGE", "PROCESS_STAGE_UID", "PROCESS_UID", "PRODUCT_FAMILY", "PRODUCT_FAMILY_UID", "REFERENCE_MARKET_NAME", "REFERENCE_MARKET_UID", "APPLICATION_NAME", "REGULATORY_APPLICATION_UID", "RESPONSIBLE_PERSON", "RESPONSIBLE_PERSON_ID", "REVIEWING_MARKET", "REVIEWING_MARKET_UID", "SAFETY_PV_FLAGGED", "SAFETY_SIGNAL_NUMBER", "SECURITY_DOMAIN", "STUDY_NUMBER", "STUDY_UID", "SUBMISSION_MANAGER_TYPE", "SUPPORTING_DOCUMENT_ID", "TARGET_COMPLETION_DATE", "TARGET_COMPLETION_DATE_IND", "TRACKING_NUMBER", "TYPE_OF_PROCEDURE", "TYPE_OF_REPORT", "TYPE_OF_SUBMISSION_NAME", "TYPE_OF_SUBMISSION_UID", "WAVE_GROUP", "CREATION_DATE", "LAST_MODIFIED", "JOIN_EVENT_NAME", "DOCUMENT_URL", "R_VERSION_LABEL", "ROSTER_REGION", "IS_EEA", "IS_EU", "THERAPEUTIC_AREA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  with first_view as(
SELECT DISTINCT
           a.R_OBJECT_ID                                                        R_OBJECT_ID,

           b.OBJECT_NAME                                                        Activity_Name,
           c.activity_type,
           B.agency_approval_date                                               Status_Date,
           B.agency_approval_status                                             Agency_Status,
           agency_name,
           agency_qualification,
           agency_response,
           agency_response_date,
           agency_uid,
           application_number,
           application_type_name,
           application_type_uid,
           assembly_id,
           B.base_application_type                                              Application_Type,
           B.bu_abbrev,
           B.business_unit,
           ccds_change_description,
           ccds_change_implementation,
           ccds_change_type,
           change_number,
           B.classification_artifact                                            Activity_Artifact,
           B.classification_domain,
           B.classification_group                                               Activity_Group,
           B.classification_subgroup                                            Activity_Subgroup,
           commitment_start_date,
           commitment_status                                                    Status,
           config_uid,
           correspondence_id,
           date_archived,
           date_opened,
           first_submission_date                                                First_submission_date,
           full_description,
           global_product_name                                                  Global_Product,
           global_product_uid,
           B.information_classification,
           initial_sequence_number,
           B.is_active,
           is_ccds,
           is_original,
           is_reconciled                                                        reconciliation_status,
           linked_activity_name,
           linked_activity_uid,
           linked_event_name                                                    Event_name,
           linked_event_uid,
           market_approval_date,
           market_name                                                          Market,
           market_role,
           market_submission_date,
           market_uid,
           medicinal_product_name                                               medicinal_product,
           medicinal_product_uid,
           packaged_product_name,
           packaged_product_uid,
           parent_event_name,
           parent_event_uid,
           process_action_record_id,
           B.process_name,
           B.process_phase                                                      Process_Phase,
           B.process_stage_name                                                 Process_Stage,
           b.process_stage_uid,
           B.process_uid,
           product_family_name                                                  Product_Family,
           product_family_uid,
           reference_market_name,
           reference_market_uid,
           regulatory_application_name                                          application_name,
           regulatory_application_uid,
           responsible_person,
      
           responsible_person_id,
           reviewing_market_name                                                reviewing_market,
           reviewing_market_uid,
           safety_pv_flagged,
           safety_signal_number,
           b.security_domain,
           study_number                                                         Study_Number,
           study_uid,
           submission_manager_type,
           supporting_document_id,
           B.target_completion_date,
           (CASE
           WHEN     B.agency_approval_status = 'Open'
                AND TRUNC (SYSDATE) > B.target_completion_date
           THEN
              2
           WHEN     B.agency_approval_status = 'Open'
                AND ( (SELECT MONTHS_BETWEEN (B.target_completion_date,
                                              TRUNC (SYSDATE))
                         FROM DUAL) BETWEEN 0
                                        AND 3)
           THEN
              1
           ELSE
              0
        END)                                                               target_completion_date_ind,
           tracking_number,
           type_of_procedure                                                    Type_of_Procedure,
           type_of_report,
           type_of_submission_name,
           type_of_submission_uid,
           wave_group,
           b.R_CREATION_DATE                                                    Creation_Date,
           b.R_MODIFY_DATE                                                      Last_Modified,
          
           NVL (parent_event_UID, linked_event_UID)                             JOIN_EVENT_NAME,
           'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/' || b.r_object_id || ''    AS Document_URL,
         c.r_version_label,M.ROSTER_REGION,(SELECT MAX (IS_EEA)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = c.MARKET_NAME)
                 IS_EEA,(SELECT MAX (IS_EU)
                FROM COSMOSDBEXPORT.MARKET
               WHERE ISO_COUNTRY_NAME = c.MARKET_NAME)
               IS_EU
      FROM COSMOSDBEXPORT.SUBMISSION_MANAGER b
     inner JOIN COSMOSDBEXPORT.regulatory_activity a
          ON b.R_OBJECT_ID = a.R_OBJECT_ID
       left JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER_R c
          ON b.R_OBJECT_ID = c.SUBMISSION_MANAGER_R_OBJECT_ID

           LEFT JOIN COSMOSDBEXPORT.MARKET M on c.market_name = M.ISO_COUNTRY_NAME),

second_view as (select SUBMISSION_MANAGER_R_OBJECT_ID
from COSMOSDBEXPORT.SUBMISSION_MANAGER_R where ACTIVITY_TYPE IN ('Regulatory Obligation')),

third_view as (
select a.* from first_view a
inner join second_view b on a.R_OBJECT_ID =b.SUBMISSION_MANAGER_R_OBJECT_ID)

select b."R_OBJECT_ID",b."ACTIVITY_NAME",b."ACTIVITY_TYPE",b."STATUS_DATE",b."AGENCY_STATUS",b."AGENCY_NAME",b."AGENCY_QUALIFICATION",b."AGENCY_RESPONSE",b."AGENCY_RESPONSE_DATE",b."AGENCY_UID",b."APPLICATION_NUMBER",b."APPLICATION_TYPE_NAME",b."APPLICATION_TYPE_UID",b."ASSEMBLY_ID",b."APPLICATION_TYPE",b."BU_ABBREV",b."BUSINESS_UNIT",b."CCDS_CHANGE_DESCRIPTION",b."CCDS_CHANGE_IMPLEMENTATION",b."CCDS_CHANGE_TYPE",b."CHANGE_NUMBER",b."ACTIVITY_ARTIFACT",b."CLASSIFICATION_DOMAIN",b."ACTIVITY_GROUP",b."ACTIVITY_SUBGROUP",b."COMMITMENT_START_DATE",b."STATUS",b."CONFIG_UID",b."CORRESPONDENCE_ID",b."DATE_ARCHIVED",b."DATE_OPENED",b."FIRST_SUBMISSION_DATE",b."FULL_DESCRIPTION",b."GLOBAL_PRODUCT",b."GLOBAL_PRODUCT_UID",b."INFORMATION_CLASSIFICATION",b."INITIAL_SEQUENCE_NUMBER",b."IS_ACTIVE",b."IS_CCDS",b."IS_ORIGINAL",b."RECONCILIATION_STATUS",b."LINKED_ACTIVITY_NAME",b."LINKED_ACTIVITY_UID",b."EVENT_NAME",b."LINKED_EVENT_UID",b."MARKET_APPROVAL_DATE",b."MARKET",b."MARKET_ROLE",b."MARKET_SUBMISSION_DATE",b."MARKET_UID",b."MEDICINAL_PRODUCT",b."MEDICINAL_PRODUCT_UID",b."PACKAGED_PRODUCT_NAME",b."PACKAGED_PRODUCT_UID",b."PARENT_EVENT_NAME",b."PARENT_EVENT_UID",b."PROCESS_ACTION_RECORD_ID",b."PROCESS_NAME",b."PROCESS_PHASE",b."PROCESS_STAGE",b."PROCESS_STAGE_UID",b."PROCESS_UID",b."PRODUCT_FAMILY",b."PRODUCT_FAMILY_UID",b."REFERENCE_MARKET_NAME",b."REFERENCE_MARKET_UID",b."APPLICATION_NAME",b."REGULATORY_APPLICATION_UID",b."RESPONSIBLE_PERSON",b."RESPONSIBLE_PERSON_ID",b."REVIEWING_MARKET",b."REVIEWING_MARKET_UID",b."SAFETY_PV_FLAGGED",b."SAFETY_SIGNAL_NUMBER",b."SECURITY_DOMAIN",b."STUDY_NUMBER",b."STUDY_UID",b."SUBMISSION_MANAGER_TYPE",b."SUPPORTING_DOCUMENT_ID",b."TARGET_COMPLETION_DATE",b."TARGET_COMPLETION_DATE_IND",b."TRACKING_NUMBER",b."TYPE_OF_PROCEDURE",b."TYPE_OF_REPORT",b."TYPE_OF_SUBMISSION_NAME",b."TYPE_OF_SUBMISSION_UID",b."WAVE_GROUP",b."CREATION_DATE",b."LAST_MODIFIED",b."JOIN_EVENT_NAME",b."DOCUMENT_URL",b."R_VERSION_LABEL",b."ROSTER_REGION",b."IS_EEA",b."IS_EU",a.ta as therapeutic_area
from third_view  b 
left join  VW_TA_PRDFNM a on b.Product_Family = a.product;


--VW_CARA_WORKFLOW_VW


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_CARA_WORKFLOW_VW" ("WORKFLOW_OBJECT_ID", "COMPONENT_CHRONICLE_ID", "TEMPLATE_NAME", "TARGET_START_DATE", "TARGET_DURATION", "ACTUAL_START_DATE", "ACTUAL_FINISH_DATE", "ISSUE_DATE", "CREATOR", "COMMENTS", "ACTIVITY_STATUS", "COMPLETION_STATUS", "RECIPIENT", "ACTIVITY_OBJECT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select "WORKFLOW_OBJECT_ID","COMPONENT_CHRONICLE_ID","TEMPLATE_NAME","TARGET_START_DATE","TARGET_DURATION","ACTUAL_START_DATE","ACTUAL_FINISH_DATE","ISSUE_DATE","CREATOR","COMMENTS","ACTIVITY_STATUS","COMPLETION_STATUS","RECIPIENT","ACTIVITY_OBJECT_ID" from cosmosdbexport.CARA_WORKFLOW_VW;

  
  --VW_COUNTRY_DISPOSITION
  
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_COUNTRY_DISPOSITION" ("R_OBJECT_ID", "EVNT_OBJECT_ID", "OBJECT_NAME", "CONFIG_UID", "FULL_DESCRIPTION", "PRODUCT_FAMILY_NAME", "PRODUCT_FAMILY_UID", "GLOBAL_PRODUCT_NAME", "MARKET_NAME", "CLASSIFICATION_GROUP", "CLASSIFICATION_SUBGROUP", "CLASSIFICATION_ARTIFACT", "CCDS_DISTRIBUTION_DATE", "TARGET_COMPLETION_DATE", "ACT_TARGET_COMPLETION_DATE", "EVNT_SUBMISSION_PLANNED_DATE", "EVNT_VERSION_NUMBER", "EVNT_CCDS_APPROVAL_DATE", "CD_A_ACTUAL_COMPLETION_DATE", "CD_ACTION_DEFINITION_NAME", "CD_A_OUTCOME", "CD_A_OUTCOME_COMMENT", "DC_A_MARKET_NAME", "ROSTER_REGION", "EEA_COUNTRY", "EU_COUNTRY", "URL_LINK", "R_CREATION_DATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT DISTINCT
       ctr_ob.r_object_id r_object_id,
       MGRM.SUBMISSION_MANAGER_R_OBJECT_ID EVNT_Object_ID,
       MGRM.Object_Name,
       nvl(ctr_ob.owning_object_uid,MGRM.CONFIG_UID) CONFIG_UID,
       MGRM.FULL_DESCRIPTION FULL_DESCRIPTION,
       MGRM.PRODUCT_FAMILY_NAME PRODUCT_FAMILY_NAME,
       MGRM.PRODUCT_FAMILY_UID PRODUCT_FAMILY_UID,
       MGRM.GLOBAL_PRODUCT_NAME GLOBAL_PRODUCT_NAME,
       --       MGRM.GLOBAL_PRODUCT_UID GLOBAL_PRODUCT_UID,
       MGRM.MARKET_NAME,
       MGRM.CLASSIFICATION_GROUP CLASSIFICATION_GROUP,
       MGRM.CLASSIFICATION_SUBGROUP CLASSIFICATION_SUBGROUP,
       MGRM.CLASSIFICATION_ARTIFACT CLASSIFICATION_ARTIFACT,
       MGRM.CCDS_DISTRIBUTION_DATE CCDS_DISTRIBUTION_DATE,
       ctr_ob.CD_A_TARGET_COMPLETION_DATE TARGET_COMPLETION_DATE,
       MGRM.TARGET_COMPLETION_DATE AS ACT_TARGET_COMPLETION_DATE,
       ---MGRM.ASSEMBLY_ID

       (SELECT MAX (SUBMISSION_PLANNED_DATE)
          FROM COSMOSDBEXPORT.DOCUMENT a
         WHERE     CLASSIFICATION_ARTIFACT = 'Global Assembly'
               AND a.R_OBJECT_ID = MGRM.ASSEMBLY_ID
               AND SUBMISSION_PLANNED_DATE IS NOT NULL)
          EVNT_SUBMISSION_PLANNED_DATE,
       (SELECT MAX (VERSION_NUMBER)
          FROM COSMOSDBEXPORT.DOCUMENT a
         WHERE     CLASSIFICATION_ARTIFACT = 'Global Assembly'
               AND a.R_OBJECT_ID = MGRM.ASSEMBLY_ID
               AND VERSION_NUMBER IS NOT NULL)
          EVNT_VERSION_NUMBER,
       (SELECT MAX (CCDS_APPROVAL_DATE)
          FROM COSMOSDBEXPORT.DOCUMENT a
         WHERE     CLASSIFICATION_ARTIFACT = 'Global Assembly'
               AND a.R_OBJECT_ID = MGRM.ASSEMBLY_ID
               AND CCDS_APPROVAL_DATE IS NOT NULL)
          EVNT_CCDS_APPROVAL_DATE,
       ---ACT_R_OBJECT_ID,
       CD_A_ACTUAL_COMPLETION_DATE,
       CD_ACTION_DEFINITION_NAME,
       CD_A_OUTCOME,
       CD_A_OUTCOME_COMMENT,
       DC_A_MARKET_NAME,
       Roster_region,
       IS_EEA EEA_Country,
       IS_EU EU_Country,
       'https://cosmos-dev1.abbvienet.com/cosmos-new/drl/objectId/'
               || nvl(ctr_ob.r_object_id,SUBMISSION_MANAGER_R_OBJECT_ID)
               || ''
                  AS URL_Link,
       ctr_ob.r_creation_date
  FROM (SELECT DISTINCT
               act.r_object_id,
               act.ACTION_DEFINITION_NAME CD_ACTION_DEFINITION_NAME,
               act.ACTION_STATUS,
               TRIM (act.ACTUAL_COMPLETION_DATE) CD_A_ACTUAL_COMPLETION_DATE,
               act.TARGET_COMPLETION_DATE CD_A_TARGET_COMPLETION_DATE,
               ---act.INSTRUCTIONS,
               act.OUTCOME CD_A_OUTCOME,
               act.OUTCOME_COMMENT CD_A_OUTCOME_COMMENT,
               act.OUTCOME_SATISFACTORY,
               act.OWNING_OBJECT_NAME,
               act.OWNING_OBJECT_UID,
               act_ref.MARKET_NAME DC_A_MARKET_NAME, /*,act.PROCESS_PHASE,act.STAGE_DEFINITION_NAME,act.STAGE_DEFINITION_UID,
--                                     act.TARGET_COMPLETION_DATE,act.TASK_TEMPLATE_NAME*/
               m.roster_region,
               (SELECT MAX (IS_EEA)
                  FROM COSMOSDBEXPORT.MARKET
                 WHERE ISO_COUNTRY_NAME = act_ref.MARKET_NAME)
                  IS_EEA,
               (SELECT MAX (IS_EU)
                  FROM COSMOSDBEXPORT.MARKET
                 WHERE ISO_COUNTRY_NAME = act_ref.MARKET_NAME)
                  IS_EU,
               act_ob.r_creation_date,
               act.action_definition_name
          FROM COSMOSDBEXPORT.action_record act,
               cosmosdbexport.object act_ob,
               cosmosdbexport.action_record_r act_ref,
               cosmosdbexport.market m
         WHERE     act.r_object_id = act_ob.r_object_id
               AND act.r_object_id = act_ref.ACTION_RECORD_R_OBJECT_ID
               AND act_ref.MARKET_NAME = m.ISO_COUNTRY_NAME(+)
               AND (  /* act.action_definition_uid IN
                          (SELECT od.config_uid
                             FROM cosmosdbexport.action_definition ad,
                                  cosmosdbexport.object od
                            WHERE     ad.r_object_id = od.r_object_id
                                  AND od.object_name = 'Country Disposition')
                    OR*/ act.action_definition_name = 'Country Disposition Set'))
       ctr_ob,
       (SELECT DISTINCT FULL_DESCRIPTION,
                        PRODUCT_FAMILY_NAME,
                        PRODUCT_FAMILY_UID,
                        GLOBAL_PRODUCT_NAME,
                        CLASSIFICATION_GROUP,
                        CLASSIFICATION_SUBGROUP,
                        CLASSIFICATION_ARTIFACT,
                        CCDS_DISTRIBUTION_DATE,
                        ASSEMBLY_ID,
                        config_uid,
                        OBJECT_NAME,
                        target_completion_date,
                        SUBMISSION_MANAGER_R_OBJECT_ID,
                        market_name
          FROM (SELECT *
                  FROM COSMOSDBEXPORT.SUBMISSION_MANAGER a
                 WHERE ---object_name='Labeling- CCDS v4.0 - Pediatric MDD age range update-August-2023' and 
				 classification_subgroup IN ('Labeling')) MGR,
               COSMOSDBEXPORT.REGULATORY_EVENT EVNT,
               ( SELECT distinct SUBMGR_A.SUBMISSION_MANAGER_R_OBJECT_ID,
                       SUBMGR_A.market_name,
                       SUBMGR_AA.PRODUCT_FAMILY_NAME,
                       SUBMGR_AA.PRODUCT_FAMILY_UID,
                       SUBMGR_AA.GLOBAL_PRODUCT_NAME,
                       SUBMGR_AA.assembly_id
                  FROM COSMOSDBEXPORT.SUBMISSION_MANAGER_R SUBMGR_A,
                  (select distinct SUBMISSION_MANAGER_R_OBJECT_ID,
                  PRODUCT_FAMILY_NAME,
                       PRODUCT_FAMILY_UID,
                       GLOBAL_PRODUCT_NAME,
                       assembly_id from 
                       COSMOSDBEXPORT.SUBMISSION_MANAGER_R  where ---SUBMISSION_MANAGER_R_OBJECT_ID='0800f9f686474cc2' and 
                       PRODUCT_FAMILY_NAME IS NOT NULL 
                       ) SUBMGR_AA
                  where SUBMGR_A.SUBMISSION_MANAGER_R_OBJECT_ID=SUBMGR_AA.SUBMISSION_MANAGER_R_OBJECT_ID) SUBMGR_R
         WHERE     MGR.R_OBJECT_ID = EVNT.R_OBJECT_ID
               AND MGR.R_OBJECT_ID = SUBMGR_R.SUBMISSION_MANAGER_R_OBJECT_ID --- and MGRM.DC_A_MARKET_NAME=SUBMGR_R.MARKET_NAME
                                                                            )
       MGRM
 WHERE MGRM.config_uid = ctr_ob.owning_object_uid(+) /* commented as part of Hubble1.2 fix(+)*/
 AND MGRM.MARKET_NAME = ctr_ob.DC_A_MARKET_NAME(+);



--VW_COUNTRY_DISPOSITION_CONFIG_UID

  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_COUNTRY_DISPOSITION_CONFIG_UID" ("OBJECT_NAME", "CONFIG_UID", "R_OBJECT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select object_name,config_uid,r_object_id from COSMOSDBEXPORT.submission_manager;

  
  
  
  --VW_COUNTRY_DISPOSITION_TARGET_COMPLETION_ACTIVITY
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_COUNTRY_DISPOSITION_TARGET_COMPLETION_ACTIVITY" ("EVENT_NAME", "EVENT_OBJECT_ID", "CONFIG_UID", "TARGET_COMPLETION_DATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT DISTINCT
                    b.object_name     AS Event_name,
                    b.r_object_id     AS Event_object_id,
                    b.config_uid,
                 b.target_completion_date
               FROM COSMOSDBEXPORT.REGULATORY_EVENT  A
                    INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER B
                        ON A.R_OBJECT_ID = B.R_OBJECT_ID
                    INNER JOIN COSMOSDBEXPORT.SUBMISSION_MANAGER_R C
                        ON B.R_OBJECT_ID = C.SUBMISSION_MANAGER_R_OBJECT_ID
                         where b.classification_subgroup = 'Labeling';

						 
						 
						 
--VW_PRODUCT_SKU
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SVC_HUBBLE"."VW_PRODUCT_SKU" ("PRODUCT_AUTHORISATION_R_OBJECT_ID", "PRODUCT_NAME", "PRODUCT_FULL_DESCRIPTION", "PRODUCT_SKU", "AUTHORISATION_HOLDER_NAME", "AUTHORISATION_HOLDER_UID", "AUTHORISATION_STATUS", "AUTHORISATION_STATUS_DATE", "AUTHORISATION_TYPE", "DATE_OF_FIRST_AUTHORISATION", "AUTHORIZATION_COUNTRY", "PRODUCT_FAMILY_NAME", "PRODUCT_FAMILY_UID", "REGULATORY_APPLICATION_NAME", "REGULATORY_APPLICATION_UID", "VALIDITY_PERIOD_END", "VALIDITY_PERIOD_START", "LEGAL_STATUS", "REGISTRATION_STATUS", "REGISTRATION_STATUS_DATE", "MARKET_NAME", "REVIEWING_MARKET_NAME", "APPLICATION_NUMBER", "APPLICATION_TYPE_NAME", "TYPE_OF_PROCEDURE", "BASE_APPLICATION_TYPE", "R_CREATOR_NAME", "R_MODIFY_DATE", "R_MODIFIER", "R_CREATION_DATE", "BUSINESS_UNIT", "CONCEPT", "INFORMATION_CLASSIFICATION", "SECURITY_DOMAIN", "IS_ACTIVE", "AUTHORIZATION_NUMBER", "GLOBAL_PRODUCT_NAME", "INDICATION_NAME", "LEGAL_MANUFACTURER_NAME", "TRADE_NAME", "INTEGRAL_DEVICE_NAME", "RISK_CLASSIFICATION_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT DISTINCT
       B.PRODUCT_AUTHORISATION_R_OBJECT_ID,
       B.MEDICINAL_PRODUCT_NAME AS Product_name,
       b.PACKAGED_PRODUCT_NAME AS Product_Full_Description,
       F_SKU (B.PRODUCT_AUTHORISATION_R_OBJECT_ID, b.r_index) AS Product_SKU,
       A.AUTHORISATION_HOLDER_NAME,
       A.AUTHORISATION_HOLDER_UID,
       A.AUTHORISATION_STATUS,
       A.AUTHORISATION_STATUS_DATE,
       A.AUTHORISATION_TYPE,
       A.DATE_OF_FIRST_AUTHORISATION,
       A.MARKET_NAME AS AUTHORIZATION_COUNTRY,
       A.PRODUCT_FAMILY_NAME,
       A.PRODUCT_FAMILY_UID,
       A.REGULATORY_APPLICATION_NAME,
       A.REGULATORY_APPLICATION_UID,
       A.VALIDITY_PERIOD_END,
       A.VALIDITY_PERIOD_START,
       A.LEGAL_STATUS,
       A.authorisation_status AS REGISTRATION_STATUS,
       A.authorisation_status_date AS REGISTRATION_STATUS_DATE,
       A.MARKET_NAME AS market_name,
       NVL (C.REVIEWING_MARKET_NAME, A.MARKET_NAME) AS REVIEWING_MARKET_NAME,
       C.APPLICATION_NUMBER,
       C.APPLICATION_TYPE_NAME,
       C.TYPE_OF_PROCEDURE,
       C.BASE_APPLICATION_TYPE,
       E.R_CREATOR_NAME,
       E.R_MODIFY_DATE,
       E.R_MODIFIER,
       E.R_CREATION_DATE,
       E.BUSINESS_UNIT,
       E.CONCEPT,
       E.INFORMATION_CLASSIFICATION,
       E.SECURITY_DOMAIN,
       E.IS_ACTIVE,
       E.object_name AS Authorization_Number,
       PR.GLOBAL_PRODUCT_NAME,
       NVL (B.INDICATION_NAME, PR.INDICATION_NAME) AS INDICATION_NAME,
       PR.LEGAL_MANUFACTURER_NAME,
       NVL (PR.TRADE_NAME, CR.TRADE_NAME) AS TRADE_NAME,
       --CR.RISK_CLASSIFICATION_NAME,
       PR.MEDICINAL_PRODUCT_NAME AS INTEGRAL_DEVICE_NAME,
       (SELECT MAX (RISK_CLASSIFICATION_NAME)
          FROM COSMOSDBEXPORT.PRODUCT
         WHERE object_name =
                  (SELECT MEDICINAL_PRODUCT_NAME
                     FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R
                    WHERE     PRODUCT_AUTHORISATION_R_OBJECT_ID =
                                 B.PRODUCT_AUTHORISATION_R_OBJECT_ID
                          AND r_index = 1))
          AS RISK_CLASSIFICATION_NAME
  FROM COSMOSDBEXPORT.PRODUCT_AUTHORISATION A
       INNER JOIN COSMOSDBEXPORT.PRODUCT_AUTHORISATION_R B
          ON A.R_OBJECT_ID = B.PRODUCT_AUTHORISATION_R_OBJECT_ID
       INNER JOIN COSMOSDBEXPORT.OBJECT E ON E.R_OBJECT_ID = A.R_OBJECT_ID
       LEFT JOIN
       (SELECT DISTINCT
               C.OBJECT_NAME APPLICATION_NAME,
               DR.REGULATORY_APPLICATION_R_OBJECT_ID,
               D.APPLICATION_NUMBER,
               D.APPLICATION_TYPE_NAME,
               D.TYPE_OF_PROCEDURE,
               D.BASE_APPLICATION_TYPE,
               C.CONFIG_UID,
               --DR.MARKET_NAME,
               (SELECT market_name
                  FROM COSMOSDBEXPORT.REGULATORY_APPLICATION_R
                 WHERE     market_role = 'Rapporteur'
                       AND REGULATORY_APPLICATION_R_OBJECT_ID =
                              DR.REGULATORY_APPLICATION_R_OBJECT_ID)
                  AS REVIEWING_MARKET_NAME,
               DR.market_role
          FROM COSMOSDBEXPORT.REGULATORY_APPLICATION D
               INNER JOIN COSMOSDBEXPORT.REGULATORY_APPLICATION_R DR
                  ON D.R_OBJECT_ID = DR.REGULATORY_APPLICATION_R_OBJECT_ID
               INNER JOIN COSMOSDBEXPORT.OBJECT C
                  ON C.R_OBJECT_ID = D.R_OBJECT_ID) C
          ON C.CONFIG_UID = A.REGULATORY_APPLICATION_UID
       LEFT JOIN
       (SELECT DISTINCT A.GLOBAL_PRODUCT_NAME,
                        A.INDICATION_NAME,
                        A.LEGAL_MANUFACTURER_NAME,
                        A.TRADE_NAME,
                        B.OBJECT_NAME,
                        A.MEDICINAL_PRODUCT_UID,
                        B.RISK_CLASSIFICATION_NAME,
                        A.INTEGRAL_DEVICE_NAME,
                        B.CONFIG_UID,
                        A.product_family_name,
                        A.medicinal_product_name
          FROM COSMOSDBEXPORT.PRODUCT_R A
               INNER JOIN COSMOSDBEXPORT.PRODUCT B
                  ON A.PRODUCT_R_OBJECT_ID = B.R_OBJECT_ID
         WHERE A.PRODUCT_FAMILY_NAME IN
                  ('breast aesthetics', 'body contouring')) PR
          ON B.PACKAGED_PRODUCT_NAME = PR.OBJECT_NAME
       LEFT JOIN
       (SELECT DISTINCT A.GLOBAL_PRODUCT_NAME,
                        A.INDICATION_NAME,
                        A.LEGAL_MANUFACTURER_NAME,
                        A.TRADE_NAME,
                        B.OBJECT_NAME,
                        A.MEDICINAL_PRODUCT_UID,
                        B.RISK_CLASSIFICATION_NAME,
                        A.INTEGRAL_DEVICE_NAME,
                        B.CONFIG_UID,
                        A.product_family_name,
                        A.medicinal_product_name
          FROM COSMOSDBEXPORT.PRODUCT_R A
               INNER JOIN COSMOSDBEXPORT.PRODUCT B
                  ON A.PRODUCT_R_OBJECT_ID = B.R_OBJECT_ID
         WHERE A.PRODUCT_FAMILY_NAME IN
                  ('breast aesthetics', 'body contouring')) CR
          ON B.MEDICINAL_PRODUCT_NAME = CR.OBJECT_NAME
 WHERE     a.PRODUCT_FAMILY_NAME IN ('breast aesthetics', 'body contouring')
       AND b.PACKAGED_PRODUCT_NAME IS NOT NULL
       AND NOT EXISTS
              (SELECT 1
                 FROM T_SKU_EXCEPTION SKUEX
                WHERE     SKUEX.PRODUCT_AUTH_R_OBJECT_ID =
                             B.PRODUCT_AUTHORISATION_R_OBJECT_ID
                      AND EXCL_FLAG = 'Y');

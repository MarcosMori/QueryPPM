----QUERY NO SQL----
---===20/03/2009===---


SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID_R:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:RECURSO:Recurso@,
         @SELECT:METRIC:USER_DEF:IMPLIED:SUM(Trabalhadas):Horas_Trabalhadas:AGG@

FROM(
	SELECT
	CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
	CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
	INV.Name NOMEPROJETO,
	R.First_name +' '+R.Last_name RECURSO,
	CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END Trabalhadas,
	entry.PRMODTIME DATE,
	('2009-02-01 00:00:00.000')datefrom,
	('2009-02-28 00:00:00.000')dateto

	 FROM 
	niku.PRTASK T
	FULL OUTER join niku.INV_INVESTMENTS INV
	on INV.id = T.prprojectid  
	inner Join niku.PRASSIGNMENT A
	on A.PRTASKID = T.PRID
	FULL OUTER Join niku.PRTIMEENTRY ENTRY
	on A.PRID = ENTRY.PRASSIGNMENTID
	FULL OUTER Join niku.SRM_RESOURCES AS R         
	on A.PRRESOURCEID = R.ID   

	 WHERE 
	INV.IS_ACTIVE = 1
	AND ENTRY.PRACTSUM<>0
) A


WHERE ((A.DATE IS NULL) OR (@WHERE:PARAM:USER_DEF:DATE: A.DATE:DATA@))
AND DATE>=A.DATEFROM
AND DATE<=A.DATETO
AND   @FILTER@

GROUP BY ID_R, RECURSO
HAVING   @HAVING_FILTER@



-------------------------------------------------------------------------------------------------
----QUERY NO SQL----
---===05/03/2009===---



DECLARE @DATEFROM DATETIME
DECLARE @DATETO DATETIME
SET @DATEFROM = '2009-01-01 00:00:00.000'
SET	@DATETO ='2009-12-31 00:00:00.000'


SELECT ID_R ID,RECURSO, SUM(TRABALHADAS)TRABALHADAS

FROM(
	SELECT
		CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
		CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
		INV.Name NOMEPROJETO,
		R.First_name +' '+R.Last_name RECURSO,
		CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END Trabalhadas,
		entry.PRMODTIME DATE,


	 FROM 
		niku.PRTASK T
		FULL OUTER join niku.INV_INVESTMENTS INV
		on INV.id = T.prprojectid  
		inner Join niku.PRASSIGNMENT A
		on A.PRTASKID = T.PRID
		FULL OUTER Join niku.PRTIMEENTRY ENTRY
		on A.PRID = ENTRY.PRASSIGNMENTID
		FULL OUTER Join niku.SRM_RESOURCES AS R         
		on A.PRRESOURCEID = R.ID   

	 WHERE 
		INV.IS_ACTIVE = 1
		AND ENTRY.PRACTSUM<>0) A

WHERE DATE>=A.DATEFROM
AND DATE<=A.DATETO

GROUP BY ID_R, RECURSO

--------------------------------------------------------------------------------------------------

FINAL 03/03/2009


SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:cast(ID_R as varchar) + cast(ID_INV as varchar):ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:NOMEPROJETO:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:RECURSO:Recurso@,
         @SELECT:METRIC:USER_DEF:IMPLIED:SUM(Trabalhadas):Horas_Trabalhadas:AGG@


FROM (SELECT
            CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
            CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
            INV.Name NOMEPROJETO,
            R.First_name +' '+R.Last_name RECURSO,
            CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END Trabalhadas,
A.PRID ID

         FROM 
            niku.PRTASK T
            FULL OUTER join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            inner Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            FULL OUTER Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   

         WHERE 
            INV.IS_ACTIVE = 1
AND ENTRY.PRACTSUM<>0
)A 
INNER JOIN PRTIMEENTRY J ON A.ID=J.PRASSIGNMENTID
 
@PAMAM_DATA_FROM = 2009-01-01 00:00:00.937
WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((ID_R IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_R:Recurso@))
AND   J.PRMODTIME=((J.PRMODTIME IS NULL) OR (@WHERE:PARAM:USER_DEF:DATE:J.PRMODTIME:DATA@))
AND   J.PRMODTIME = @param_data
AND   J.PRMODTIME >= @param_data_from
AND   J.PRMODTIME <= @param_data_to
AND   @FILTER@

GROUP BY

 ID_R,
 ID_INV,
         NOMEPROJETO,
         RECURSO
HAVING   @HAVING_FILTER@


-----------------------------------------------------------
--==HORAS TRABALHADAS NO PERIODO==---
------02/03/2009 16:47---------------FINAL


SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:cast(A.ID_R as varchar) + cast(A.ID_INV as varchar):ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:A.Descricao_do_Projeto:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:A.Recurso_Horas_Consumidas:Recurso@,
         @SELECT:METRIC:USER_DEF:IMPLIED:SUM(*):Trabalhadas:Horas_Trabalhadas@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:ENTRY.PRMODTIME:Data@


FROM (SELECT
            CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
            CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
            INV.Name Descricao_do_Projeto,
            R.First_name +' '+R.Last_name Recurso_Horas_Consumidas,
            sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END) Trabalhadas,
			A.PRID ID

         FROM 
            niku.PRTASK T
            FULL OUTER join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            inner Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            FULL OUTER Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   

         WHERE 
            INV.IS_ACTIVE = 1
			AND ENTRY.PRACTSUM<>0


         GROUP BY 
            INV.Name,
            R.First_name,
            R.Last_name,
            INV.ID,
            R.ID,
			A.PRID)A 
			INNER JOIN PRTIMEENTRY ENTRY ON A.ID=ENTRY.PRASSIGNMENTID

) 
   
WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((ID_R IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_R:Recurso@))
AND   ((STATUS IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:STATUS:Status@))
AND   ((Investimento IS NULL) OR (@WHERE:PARAM:USER_DEF:STRING:Investimento:Investimento@))
AND   ((DATALANCAMENTO IS NULL) OR (@WHERE:PARAM:USER_DEF:DATE: DATALANCAMENTO:DATA@))
AND   @FILTER@

 AND ID_INV =@where:param:xml:integer:/data/ProjetoID/@value@






-----------------------------------------------------------
--==HORAS TRABALHADAS NO PERIODO==---
------02/03/2009 16:46---------------SUB


SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:cast(ID_R as varchar) + cast(ID_INV as varchar):ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Codigo_do_Projeto:Codigo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Descricao_do_Projeto:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Investimento:Investimento@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:STATUS:STATUS@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Recurso_Horas_Consumidas:Recurso@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Trabalhadas:Horas_Trabalhadas@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Estimada:Estimada@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(Estimada-Trabalhadas):Restante@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(DATALANCAMENTO):Data@


FROM (SELECT
      ID_INV ID_INV,
      ID_R ID_R,
      Codigo_do_Projeto Codigo_do_Projeto,
      INVESTIMENTO Investimento,
      Descricao_do_Projeto Descricao_do_Projeto,
      Recurso_Horas_Consumidas Recurso_Horas_Consumidas,
      STATUS_PROJETOS STATUS,
      sum(Estimada) Estimada,
      sum(Trabalhadas) Trabalhadas,
  DATALANCAMENTO

    FROM(
       SELECT
            CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
            CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
            ca.CODPROJETO Codigo_do_Projeto,
            INV.Name Descricao_do_Projeto,
            INV.odf_object_code INVESTIMENTO,
            R.First_name +' '+R.Last_name Recurso_Horas_Consumidas,
            T.PRNAME tarefa,
            INV.PROGRESS STATUS_PROJETOS,
CASE WHEN (A.PRESTSUM/3600) IS NULL THEN 0 ELSE (A.PRESTSUM/3600) END Estimada,
            sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END) Trabalhadas,
ENTRY.PRMODTIME DATALANCAMENTO

         FROM 
            niku.PRTASK T
            FULL OUTER join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            FULL OUTER Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            FULL OUTER Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   
            FULL OUTER join niku.odf_ca_project as ca
            on INV.ID = CA.ID

         WHERE 
            INV.IS_ACTIVE = 1

   


         GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            R.First_name,
            R.Last_name,
            INV.ID,
            T.PRNAME,
            R.ID,
            ENTRY.PRMODTIME) A

     GROUP BY
        ID_INV,
        ID_R,
        STATUS_PROJETOS,
        INVESTIMENTO,
        Descricao_do_Projeto,
        Codigo_do_Projeto,
        Recurso_Horas_Consumidas,
DATALANCAMENTO) B
   
WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((ID_R IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_R:Recurso@))
AND   ((STATUS IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:STATUS:Status@))
AND   ((Investimento IS NULL) OR (@WHERE:PARAM:USER_DEF:STRING:Investimento:Investimento@))
AND   ((DATALANCAMENTO IS NULL) OR (@WHERE:PARAM:USER_DEF:DATE: DATALANCAMENTO:DATA@))
AND   @FILTER@

 AND ID_INV =@where:param:xml:integer:/data/ProjetoID/@value@




-----------------------------------------------------------
--==HORAS TRABALHADAS NO PERIODO==---
------02/03/2009 12:00---------------SUB



SELECT
            CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
            CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
            ca.CODPROJETO Codigo_do_Projeto,
            INV.Name Descricao_do_Projeto,
            INV.odf_object_code INVESTIMENTO,
            R.First_name +' '+R.Last_name Recurso_Horas_Consumidas,
            T.PRNAME tarefa,
            CASE WHEN (A.PRESTSUM/3600) IS NULL THEN 0 ELSE (A.PRESTSUM/3600) END Estimada,
            INV.PROGRESS STATUS_PROJETOS,
            sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END) Trabalhadas,
			ENTRY.PRMODTIME

         FROM 
            niku.PRTASK T
            FULL OUTER join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            FULL OUTER Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            FULL OUTER Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   
            FULL OUTER join niku.odf_ca_project as ca
            on INV.ID = CA.ID

         WHERE 
            INV.IS_ACTIVE = 1
            AND T.PRSTATUS <> 2
			AND ENTRY.PRMODTIME =@WHERE.PARAM:DATALANCAMENTO@


         GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            R.First_name,
            R.Last_name,
            INV.ID,
            T.PRNAME,
            R.ID,
			ENTRY.PRMODTIME 



--SELECT * FROM PRTIMEENTRY;
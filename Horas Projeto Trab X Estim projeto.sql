--===Query: Horas Projeto Trab X Estim projeto===--

SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID_INV:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Codigo_do_Projeto:Codigo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Descricao_do_Projeto:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Investimento:Investimento@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:STATUS:STATUS@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Trabalhadas:Horas_Trabalhadas@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Estimada:Estimada@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(Estimada-Trabalhadas):Restante@



FROM 
   (SELECT
      ID_INV ID_INV,
      Codigo_do_Projeto Codigo_do_Projeto,
      INVESTIMENTO Investimento,
      Descricao_do_Projeto Descricao_do_Projeto,
      STATUS_PROJETOS STATUS,
      sum(Estimada) Estimada,
      sum(Trabalhadas) Trabalhadas

    FROM(
        SELECT
INV.ID ID_INV,
ca.CODPROJETO Codigo_do_Projeto,
INV.Name Descricao_do_Projeto,
INV.odf_object_code INVESTIMENTO,
T.PRNAME tarefa,
(A.PRESTSUM/3600) Estimada,
INV.PROGRESS STATUS_PROJETOS,
sum(CASE WHEN (THRT.HORASEFETIVAS) IS NULL THEN 0 ELSE (THRT.HORASEFETIVAS) END) Trabalhadas

     FROM 
        niku.PRTASK T
        FULL OUTER join niku.INV_INVESTMENTS INV
        on INV.id = T.prprojectid  
        INNER JOIN( 
			SELECT   cast(INV.ID as varchar) + cast(SRM.ID as varchar) ID,
				 THRT.RESOURCE_ID RESOURCE_ID,
				 INV.CODE CODIGO,
				 INV.ID PROJECT_ID,
				 SUM(THRT.ACTUAL_QTY) HORASEFETIVAS

			FROM INV_INVESTMENTS INV
				 INNER JOIN NBI_PRT_FACTS THRT ON INV.ID = THRT.PROJECT_ID
				 INNER JOIN SRM_RESOURCES SRM ON THRT.RESOURCE_ID = SRM.ID
			GROUP BY THRT.RESOURCE_ID,INV.CODE, INV.ID, SRM.FIRST_NAME, SRM.LAST_NAME, INV.ID, SRM.ID) THRT ON THRT.PROJECT_ID = INV.ID

        FULL OUTER Join niku.PRASSIGNMENT A
        on A.PRTASKID = T.PRID
        FULL OUTER Join niku.SRM_RESOURCES AS R         
        on A.PRRESOURCEID = R.ID   
        FULL OUTER join niku.odf_ca_project as ca
        on INV.ID = CA.ID

         WHERE 
            INV.IS_ACTIVE = 1
            AND T.PRSTATUS <> 2


        GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            INV.ID,
            T.PRNAME,
            R.ID) A

    GROUP BY
        ID_INV,
        STATUS_PROJETOS,
        INVESTIMENTO,
        Descricao_do_Projeto,
        Codigo_do_Projeto) B

WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((STATUS IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:STATUS:Status@))
AND   ((Investimento IS NULL) OR (@WHERE:PARAM:USER_DEF:STRING:Investimento:Investimento@))
AND   @FILTER@


--===Query: Horas Projeto Trab X Estim projeto===--
--===QUERY ANTIGA, ANTES DAS HORAS POSTADAS(TABELA PRTIMEENTRY)===--

SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID_INV:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Codigo_do_Projeto:Codigo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Descricao_do_Projeto:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Investimento:Investimento@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:STATUS:STATUS@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Trabalhadas:Horas_Trabalhadas@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Estimada:Estimada@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(Estimada-Trabalhadas):Restante@


FROM 
   (SELECT
      ID_INV ID_INV,
      Codigo_do_Projeto Codigo_do_Projeto,
      INVESTIMENTO Investimento,
      Descricao_do_Projeto Descricao_do_Projeto,
      STATUS_PROJETOS STATUS,
      sum(Estimada) Estimada,
      sum(Trabalhadas) Trabalhadas

    FROM(
        SELECT
INV.ID ID_INV,
ca.CODPROJETO Codigo_do_Projeto,
INV.Name Descricao_do_Projeto,
INV.odf_object_code INVESTIMENTO,
T.PRNAME tarefa,
(A.PRESTSUM/3600) Estimada,
INV.PROGRESS STATUS_PROJETOS,
sum(CASE WHEN (THRT.ACTUAL_QTY) IS NULL THEN 0 ELSE (THRT.ACTUAL_QTY) END) Trabalhadas

         FROM 
            niku.PRTASK T
            inner join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            Inner Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            left Join NBI_PRT_FACTS THRT 
ON INV.ID = THRT.PROJECT_ID             
            Inner Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   
left join niku.odf_ca_project as ca
on INV.ID = CA.ID

         WHERE 
            INV.IS_ACTIVE = 1
            AND T.PRSTATUS <> 2
            AND A.PRESTSUM <> 0
            AND INV.odf_object_code = 'project'

         GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            INV.ID,
            T.PRNAME,
            R.ID) A

    GROUP BY
        ID_INV,
        STATUS_PROJETOS,
        INVESTIMENTO,
        Descricao_do_Projeto,
        Codigo_do_Projeto) B

WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((STATUS IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:STATUS:Status@))
AND   ((Investimento IS NULL) OR (@WHERE:PARAM:USER_DEF:STRING:Investimento:Investimento@))
AND   @FILTER@


---===PRIMEIRA QUERY===----

SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID_INV:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Codigo_do_Projeto:Codigo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Descricao_do_Projeto:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Investimento:Investimento@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:STATUS:STATUS@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Trabalhadas:Horas_Trabalhadas@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Estimada:Estimada@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(Estimada-Trabalhadas):Restante@


FROM 
   (SELECT
      ID_INV ID_INV,
      Codigo_do_Projeto Codigo_do_Projeto,
      INVESTIMENTO Investimento,
      Descricao_do_Projeto Descricao_do_Projeto,
      STATUS_PROJETOS STATUS,
      sum(Estimada) Estimada,
      sum(Trabalhadas) Trabalhadas

    FROM(
        SELECT
INV.ID ID_INV,
ca.CODPROJETO Codigo_do_Projeto,
INV.Name Descricao_do_Projeto,
INV.odf_object_code INVESTIMENTO,
T.PRNAME tarefa,
(A.PRESTSUM/3600) Estimada,
INV.PROGRESS STATUS_PROJETOS,
sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END) Trabalhadas

         FROM 
            niku.PRTASK T
            inner join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            Inner Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            left Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            Inner Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   
left join niku.odf_ca_project as ca
on INV.ID = CA.ID

         WHERE 
            INV.IS_ACTIVE = 1
            AND T.PRSTATUS <> 2
            AND A.PRESTSUM <> 0
            AND INV.odf_object_code = 'project'

         GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            INV.ID,
            T.PRNAME,
            R.ID) A

    GROUP BY
        ID_INV,
        STATUS_PROJETOS,
        INVESTIMENTO,
        Descricao_do_Projeto,
        Codigo_do_Projeto) B

WHERE ((ID_INV IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:ID_INV:Projeto@))
AND   ((STATUS IS NULL) OR (@WHERE:PARAM:USER_DEF:INTEGER:STATUS:Status@))
AND   ((Investimento IS NULL) OR (@WHERE:PARAM:USER_DEF:STRING:Investimento:Investimento@))
AND   @FILTER@
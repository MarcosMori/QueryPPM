-- todos os recursos deste projeto 
-- Mori
-- Importante: rodar primeiro Datamart Extraction
-- Depois rodar Datamart Rollout
--Se vc não rodar estes dois jobs ns sequencia os dados não são transferidos do Timeslice para o Datamart

select  INV.CODE CODIGO,
		INV.NAME PROJETO, 
		(SRM.FIRST_NAME+ ' ' + SRM.LAST_NAME) NAME,
		(ACTUAL_QTY) 'HORAS EFETIVAS'




FROM INV_INVESTMENTS INV
--UNI A TABLE DE HORAS "APROVADAS" DO TIMESHEET COM A TABLE DE PROJETOS
INNER JOIN NBI_PRT_FACTS THRT ON INV.ID = THRT.PROJECT_ID
--UNI A TABELA DE RECURSOS COM A TABELA GERADA NA UNIÃO ACIMA
INNER JOIN SRM_RESOURCES SRM ON THRT.RESOURCE_ID = SRM.ID
INNER JOIN (SELECT DISTINCT PRPROJECTID, PRID FROM PRTASK) TASK ON TASK.PRPROJECTID=INV.ID
FULL OUTER Join niku.PRASSIGNMENT A ON TASK.PRID = A.PRID



where THRT.PROJECT_ID=5007124
--AND T.FACT_DATE BETWEEN @WHERE:PARAM:USER_DEF:DATE:pBeginDate@ AND @WHERE:PARAM:USER_DEF:DATE:pEndDate@
-- FILTROS POR PERÍODO
--AND T.FACT_DATE<='2009-02-28 00:00:00.000'
--AND T.FACT_DATE>='2009-02-01 00:00:00.000'
GROUP BY INV.NAME, SRM.FIRST_NAME, SRM.LAST_NAME, INV.CODE


--------------------------------------------------------------------------------------------------------------------

SELECT * FROM INV_INVESTMENTS INV
--INNER JOIN PRASSIGNMENT A ON A.PRID=INV.ID
SELECT * FROM PRASSIGNMENT
SELECT * FROM PRTASK

SELECT PRPROJECTID, PRID FROM PRTASK

--------------------------------------------------------------------------------------------------------------------

SELECT   cast(ID_R as varchar) + cast(ID_INV as varchar) ID,
         Codigo_do_Projeto Codigo,
         Descricao_do_Projeto Projeto,
         Investimento Investimento,
         STATUS STATUS,
         Recurso_Horas_Consumidas Recurso,
         Trabalhadas Horas_Trabalhadas,
         Estimada Estimada,
         (Estimada-Trabalhadas) Restante


FROM 
   (SELECT
      ID_INV ID_INV,
      ID_R ID_R,
      Codigo_do_Projeto Codigo_do_Projeto,
      INVESTIMENTO Investimento,
      Descricao_do_Projeto Descricao_do_Projeto,
      Recurso_Horas_Consumidas Recurso_Horas_Consumidas,
      STATUS_PROJETOS STATUS,
      sum(Estimada) Estimada,
      sum(Trabalhadas) Trabalhadas

    FROM(
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
            SUM(CASE WHEN THRT.ACTUAL_QTY IS NULL THEN 0 ELSE (THRT.ACTUAL_QTY) END) Trabalhadas

         FROM 
            niku.PRTASK T
            FULL OUTER join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            FULL OUTER Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join NBI_PRT_FACTS THRT
            on T.PRID= THRT.TASK_ID
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
            R.First_name,
            R.Last_name,
            INV.ID,
            T.PRNAME,
            R.ID) A

     GROUP BY
        ID_INV,
        ID_R,
        STATUS_PROJETOS,
        INVESTIMENTO,
        Descricao_do_Projeto,
        Codigo_do_Projeto,
        Recurso_Horas_Consumidas) B


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
      CASE WHEN (INV.ID) IS NULL THEN 0 ELSE (INV.ID) END ID_INV,
      CASE WHEN (R.ID) IS NULL THEN 0 ELSE (R.ID) END ID_R,
      ca.CODPROJETO Codigo_do_Projeto,
      INV.odf_object_code INVESTIMENTO,
      INV.Name Descricao_do_Projeto,
      R.First_name +' '+R.Last_name Recurso_Horas_Consumidas,
      INV.PROGRESS STATUS,
      sum(CASE WHEN (A.PRESTSUM/3600) IS NULL THEN 0 ELSE (A.PRESTSUM/3600) END )Estimada,
      sum(CASE WHEN (THRT.HORASEFETIVAS) IS NULL THEN 0 ELSE (THRT.HORASEFETIVAS) END )Trabalhadas

     FROM 
        niku.PRTASK T
        FULL OUTER join niku.INV_INVESTMENTS INV
        on INV.id = T.prprojectid  
        INNER JOIN( 
			SELECT   cast(INV.ID as varchar) + cast(SRM.ID as varchar) ID,
				 THRT.RESOURCE_ID RESOURCE_ID,
				 INV.CODE CODIGO,
				 INV.ID PROJECT_ID,
				 (SRM.FIRST_NAME+ ' ' + SRM.LAST_NAME) NAME,
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
      INV.ID,
      R.ID,
      ca.CODPROJETO,
      INV.odf_object_code,
      INV.Name,
      R.First_name,
	  R.Last_name,
      INV.PROGRESS)B


-----------------------------------------------
--ANTIGA
-- HORAS SELECIONADAS DA TABELA PRTIMEENTRY

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
            sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN 0 ELSE (ENTRY.PRACTSUM/3600) END) Trabalhadas

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






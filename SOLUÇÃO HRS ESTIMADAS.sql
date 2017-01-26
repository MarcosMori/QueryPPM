SELECT
			DISTINCT INV.Name Descricao_do_Projeto

         FROM 
            niku.PRTASK T
            inner join niku.INV_INVESTMENTS INV
            on INV.id = T.prprojectid  
            Inner Join niku.PRASSIGNMENT A
            on A.PRTASKID = T.PRID
            FULL OUTER Join niku.PRTIMEENTRY ENTRY
            on A.PRID = ENTRY.PRASSIGNMENTID
            Inner Join niku.SRM_RESOURCES AS R         
            on A.PRRESOURCEID = R.ID   
			FULL OUTER join niku.odf_ca_project as ca
			on INV.ID = CA.ID
--CRIAR UMA SUB QUERY DOS INNER JOINS QUE EXCLUI OS PROJETOS POR CAUSA DA TAREFA

         WHERE 
            INV.IS_ACTIVE = 1
            AND INV.odf_object_code = 'project'

         GROUP BY 
            ca.CODPROJETO,
            A.PRESTSUM,
            INV.Name,
            INV.PROGRESS,
            INV.odf_object_code,
            INV.ID,
            T.PRNAME,
            R.ID
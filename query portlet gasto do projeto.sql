SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:CODIGO:Codigo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:PROJETO:Projeto@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:PLANEJADO:Planejado@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:EFETIVO:Efetivo@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:saldo:Saldo@

FROM(SELECT CODIGO, PROJETO, SUM(PLANEJADO) PLANEJADO, SUM(EFETIVO) EFETIVO,SUM(PLANEJADO-EFETIVO) Saldo, SUM(PRJ_PLAN+PRJ_EFE) ID

	FROM
		(SELECT 
		CASE WHEN (SL.CODE) IS NULL THEN EFE.CODE ELSE (SL.CODE)END CODIGO, 
		CASE WHEN (SL.NAME) IS NULL THEN EFE.NAME ELSE (SL.NAME)END PROJETO, 
		SUM(CASE WHEN (SL.SLICE) IS NULL THEN 0 ELSE (SL.SLICE) END) PLANEJADO, 
		SUM(CASE WHEN (EFE.SLICE) IS NULL THEN 0 ELSE (EFE.SLICE) END) EFETIVO,
		SUM(CASE WHEN (SL.PRJ_OBJECT_ID) IS NULL THEN 0 ELSE (SL.PRJ_OBJECT_ID)END) PRJ_PLAN,
		SUM(CASE WHEN (EFE.PRJ_OBJECT_ID) IS NULL THEN 0 ELSE (EFE.PRJ_OBJECT_ID)END) PRJ_EFE
		FROM

			(SELECT ca.CODPROJETO CODE, INV.NAME NAME, SUM(SL.SLICE) SLICE, SUM(SL.PRJ_OBJECT_ID) PRJ_OBJECT_ID
			FROM
			NIKU.ODF_CA_CONTROLEFINAN CON
			INNER JOIN NIKU.ODF_SL_5025018 SL ON CON.ID = SL.PRJ_OBJECT_ID
			INNER JOIN NIKU.INV_INVESTMENTS INV ON CON.ODF_CNCRT_PARENT_ID = INV.ID
			LEFT JOIN NIKU.ODF_CA_PROJECT AS CA ON INV.ID = CA.ID
			WHERE INV.IS_ACTIVE = 1
			GROUP BY ca.CODPROJETO, INV.NAME
			) SL

		FULL OUTER JOIN 


			(SELECT ca.CODPROJETO CODE, INV.NAME NAME, SUM(SL.SLICE) SLICE, SUM(SL.PRJ_OBJECT_ID) PRJ_OBJECT_ID
			FROM
			NIKU.ODF_CA_CONTROLEFINAN CON
			INNER JOIN NIKU.ODF_SL_5025020 SL ON CON.ID = SL.PRJ_OBJECT_ID
			INNER JOIN NIKU.INV_INVESTMENTS INV ON CON.ODF_CNCRT_PARENT_ID = INV.ID
			LEFT JOIN NIKU.ODF_CA_PROJECT AS CA ON INV.ID = CA.ID
			WHERE INV.IS_ACTIVE = 1
			GROUP BY ca.CODPROJETO, INV.NAME
			) EFE ON SL.PRJ_OBJECT_ID = EFE.PRJ_OBJECT_ID

		GROUP BY SL.CODE, SL.NAME, EFE.NAME, EFE.CODE) A

	GROUP BY CODIGO, A.PROJETO
	) final



WHERE @FILTER@
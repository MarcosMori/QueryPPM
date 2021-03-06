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
		entry.PRMODTIME DATE


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

WHERE DATE>=@DATEFROM
AND DATE<=@DATETO

GROUP BY ID_R, RECURSO

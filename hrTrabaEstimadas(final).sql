select 
	INV.CODE 'Código do Projeto',
	INV.Name 'Descrição do Projeto',
	R.First_name +' '+R.Last_name 'Recurso	Horas Consumidas',
	sum(CASE WHEN (ENTRY.PRACTSUM/3600) IS NULL THEN '' ELSE (ENTRY.PRACTSUM/3600) END) "Worked",
	sum(A.PRESTSUM/3600) Estimed

from 
	niku.PRTASK T
	inner join niku.INV_INVESTMENTS INV
	on INV.id = T.prprojectid  
	Inner Join PRASSIGNMENT A
	on A.PRTASKID = T.PRID
	left Join PRTIMEENTRY ENTRY
	on A.PRID = ENTRY.PRASSIGNMENTID
	Inner Join SRM_RESOURCES AS R         
	on A.PRRESOURCEID = R.ID   

where 
	INV.odf_object_code = 'project'
	AND INV.IS_ACTIVE = 1
	AND T.PRSTATUS <> 2
	AND A.PRESTSUM <> 0

GROUP BY 
	INV.CODE,
	INV.Name,
	R.First_name,
	R.Last_name


order by INV.name
;



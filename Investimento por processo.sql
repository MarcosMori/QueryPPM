SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:process_instance_id:process_id@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:process_instance_id:process_instance_id@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:process_name:process_name@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:process_code:process_code@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:status_code:status_code@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:start_date:start_date@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:end_date:end_date@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:Run_By:Run_By@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:inv_id:inv_id@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:name:Investimento@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:code:codigo@,
		 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:tipo:tipo@
		 

FROM
(	


	select 
		caption.name process_name,
		defn.process_code,
		runs.id process_instance_id,
		runs.status_code,
		runs.start_date,
		runs.end_date,
		csu.first_name||' '||csu.last_name Run_By,
		inv.name,
		inv.code,
		inv.id inv_id,
		inv.odf_object_code tipo
	from
		BPM_RUN_PROCESSES runs
		inner join BPM_RUN_STEPS steps on steps.process_instance_id=runs.id
		inner join BPM_DEF_PROCESS_VERSIONS ver on ver.id=runs.process_version_id
		inner join BPM_DEF_PROCESSES defn on defn.id=ver.process_id
		inner join CMN_CAPTIONS_NLS caption on (caption.table_name='BPM_DEF_PROCESSES' AND caption.language_code ='en' AND caption.pk_id=defn.id)
		left join CMN_SEC_USERS csu on csu.id=runs.created_by
		INNER JOIN BPM_RUN_OBJECTS OBJ ON RUNS.ID = OBJ.PK_ID AND OBJ.TABLE_NAME = 'BPM_RUN_PROCESSES'
		INNER JOIN INV_INVESTMENTS INV ON INV.ID = OBJ.OBJECT_ID 

		
		group by caption.name, defn.process_code, runs.id, runs.status_code, runs.start_date, runs.end_date, csu.first_name||' '||csu.last_name,
			inv.name, inv.code, inv.id, inv.odf_object_code
		order by process_name, process_instance_id
	)
WHERE @FILTER@

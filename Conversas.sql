SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:idea_id:idea_id@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:id:id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:demanda:demanda@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:created_date:created_date@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:entrada_id:entrada_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:entrada_lbl:entrada_lbl@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:segmento_id:segmento_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:segmento_lbl:segmento_lbl@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:status_id:status_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:status_lbl:status_lbl@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:dt_desejada:dt_desejada@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:solicitante_id:solicitante_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:solicitante_lbl:solicitante_lbl@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:tipo_id:tipo_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:tipo_lbl:tipo_lbl@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:ultima_atualizacao:ultima_atualizacao@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:ultima_msg:ultima_msg@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:criado_por_id:criado_por_id@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:atualizado_por:atualizado_por@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:responsavel:responsavel@
		 ,@SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:responsavel_id:responsavel_id@
FROM     (

	select
		idea.id idea_id,
		inv.code id,
		inv.name demanda,
		inv.created_date,
		idea.tel_entrada entrada_id,
		ENTRADA_LKP.NAME entrada_lbl,
		idea.tel_segmento segmento_id,
		SEGMENTO_LKP.NAME segmento_lbl,
		idea.tel_status_comunic status_id,
		status_lkp.NAME status_lbl,
		idea.tel_dt_desejada_acao dt_desejada,
		ii.INITIATOR_ID solicitante_id,
		srm.first_name || ' ' || srm.last_name solicitante_lbl,
		idea.tel_tp_do_prj tipo_id,
		tipo_lkp.NAME tipo_lbl,
		conversa_tbl.data ultima_atualizacao,
		conversa_tbl.msg ultima_msg,
		conversa_tbl.created_by criado_por_id,
		recurso_tbl.first_name|| ' '|| recurso_tbl.last_name atualizado_por,
		resp.first_name|| ' '|| resp.last_name responsavel,
		resp.id responsavel_id
		
	from inv_investments inv
	inner join odf_ca_idea idea on idea.id = inv.id
	inner join inv_ideas ii on ii.id = inv.id
	LEFT join CMN_LOOKUPS_V ENTRADA_LKP
						on idea.tel_entrada = ENTRADA_LKP.lookup_code 
						AND ENTRADA_LKP.lookup_type = 'TEL_ENTRADA'
						AND ENTRADA_LKP.LANGUAGE_CODE = 'pt'
	LEFT join CMN_LOOKUPS_V SEGMENTO_LKP
						on idea.tel_segmento = SEGMENTO_LKP.lookup_code 
						AND SEGMENTO_LKP.lookup_type = 'TEL_SEGMENTO'
						AND SEGMENTO_LKP.LANGUAGE_CODE = 'pt'
	LEFT join CMN_LOOKUPS_V tipo_lkp
						on idea.tel_tp_do_prj = tipo_lkp.lookup_code 
						AND tipo_lkp.lookup_type = 'TEL_TIPO_PROJETO'
						AND tipo_lkp.LANGUAGE_CODE = 'pt'
	LEFT join CMN_LOOKUPS_V status_lkp
						on idea.tel_status_comunic = status_lkp.lookup_code 
						AND status_lkp.lookup_type = 'TEL_LKP_STATUS_COMUNICACAO'
						AND status_lkp.LANGUAGE_CODE = 'pt'
	inner join srm_resources srm on srm.user_id = ii.INITIATOR_ID
	left join srm_resources resp on resp.id = idea.tel_resp_com_com
	inner join inv_investments inv_prj on inv_prj.idea_id = inv.id
	inner join (
		select id,
			created_date data,
			message msg,
			created_by created_by,
			resource_id
		from nmc_conversations c

		where id in (
			select c.id
			from (
				select 
					max(created_date) created_date,
					resource_id
				from nmc_conversations c
				group by resource_id
			)ultima_data
			inner join nmc_conversations c 
				on c.resource_id = ultima_data.resource_id
				and ultima_data.created_date = c.created_date
		)
	) conversa_tbl on conversa_tbl.resource_id = inv_prj.id
	left join srm_resources recurso_tbl on recurso_tbl.user_id = conversa_tbl.created_by

	where idea.partition_code = 'tel_comunicacao'
	and inv.is_active = 1
	) a
WHERE @FILTER@

-- Query NS/SQL--
--Faturamentos atrasados milestone-- 
--24/03/2009--

SELECT   @SELECT:DIM:USER_DEF:IMPLIED:RESOURCE:ID:ID@,
         @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:PROJETO:PROJETO@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:CODIGO:CODIGO@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:TAREFA:TAREFA@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:VALORPAG:VALOR@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:DATAFAT:DATAAFATURAR@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:DATARECEBIMENTO:DATADOFATURAMENTO@,
 @SELECT:DIM_PROP:USER_DEF:IMPLIED:RESOURCE:(CAST(DATARECEBIMENTO AS NUMERIC))-(CAST(GETDATE() AS NUMERIC)):DIASAFATURAR@
         


FROM     
(SELECT INV.NAME PROJETO, INV.CODE CODIGO, T.PRNAME TAREFA, A.VALORPAG VALORPAG, A.DATAFAT DATAFAT, A.DATARECEBIMENTO DATARECEBIMENTO ,T.PRID ID, GETDATE() HOJE
FROM INV_INVESTMENTS INV 
INNER JOIN PRTASK T
 ON T.PRPROJECTID = INV.ID
 INNER JOIN ODF_CA_TASK A
 ON T.PRID = A.ID
 WHERE PRISMILESTONE = 1 
 AND A.DATAFAT>=GETDATE()
 AND A.DATAFAT<=(DATEADD(DAY,10,GETDATE()))
) RES

WHERE    @FILTER@
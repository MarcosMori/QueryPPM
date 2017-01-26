Title:  I have created a custom user-defined Lookup. What table are the display names in for each value in the Lookup (Niku KB ID: 7312) 


Applies To:
Clarity 7.x, 8.x

Question:
I have created a custom user-defined Lookup. What table are the display names in for each value in the Lookup?
Answer:
Here is a simple query that will provide you with the English translation of the Lookup Value Name fo
 a static list.
If you need more assistance in developing custom queries or portlets, please contact your CA Clarity Division Technical Consulting Services Representative.

 SELECT L.LOOKUP_TYPE, L.LOOKUP_CODE, N.NAME, N.DESCRIPTION
FROM CMN_LOOKUPS L, CMN_CAPTIONS_NLS N
WHERE L.ID = N.PK_ID
AND N.LANGUAGE_CODE = 'en'

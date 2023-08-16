USE [P21Dev]
GO

/****** Object:  StoredProcedure [dbo].[processofMDM]    Script Date: 8/16/2023 10:21:13 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO









CREATE OR ALTER                  PROCEDURE [dbo].[processofMDM]  (@supplier_ID NVARCHAR(MAX))
AS
  BEGIN


  -- Insert MDM test

   insert into mdm_test
select file_item,Description,Material_id,supplier_part_no,item_id,item_status,count_of_items,@supplier_id as supplier_ids,backup_date,
case when count_of_items = 1 and item_status = 'item and part no matches' then 'Perfect match without Duplicates'
 when count_of_items = 1 and item_status != 'item and part no matches' then 'Issue with part no or item id or both switched' 
 else 'potential duplicates' end as 'item_final_status',net_price,list_price
from (select st.item_id as file_item,Description,st.material_id,invs.supplier_part_no,invs.item_id,backup_date,
'item missmatches part no matches'  as item_status,net_price,st.list_price
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.supplier_part_no and st.Item_ID != invs.item_id where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))

union(select st.item_id as file_item,Description,st.material_id,invs.supplier_part_no,invs.item_id,backup_date,
'item and part no matches' as item_status,net_price,st.list_price
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.supplier_part_no and st.Item_ID = invs.item_id where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)
union (
select st.item_id  as file_item,Description,material_id,invs.supplier_part_no,invs.item_id,backup_date,
 ' item id in file mismatched with supplier part no(Material id = item_id)'  as item_status,net_price,st.list_price
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.item_id and st.item_id = invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.Item_ID != invs.supplier_part_no
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)
union(
select st.item_id  as file_item,Description,material_id,invs.supplier_part_no,invs.item_id,backup_date,
'part no missmatches(item id = item id)'  as item_status,net_price,st.list_price
from sandvik_test st join p21_view_inventory_supplier invs on st.Item_ID = invs.item_id and st.Material_id != invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)union (
select st.item_id  as file_item,Description,material_id,invs.supplier_part_no,invs.item_id,backup_date,
case when st.Material_id = invs.item_id and invs.supplier_part_no != invs.item_id then '(item id= part no) (values switched)'
when st.Material_id != invs.item_id then ' material Id mismatches with item id (item id = supplier part no)' end as item_status,net_price,st.list_price
from sandvik_test st join p21_view_inventory_supplier invs on st.Item_ID = invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_part_no != invs.item_id
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
))
s1 join  (select count(*) as count_of_items,file_item as item_id_in_file from (select st.item_id as file_item,st.material_id,invs.supplier_part_no,invs.item_id,
'item missmatches part no matches'  as item_status
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.supplier_part_no and st.Item_ID != invs.item_id where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))

union(select st.item_id as file_item,st.material_id,invs.supplier_part_no,invs.item_id,
'item and part no matches' as item_status
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.supplier_part_no and st.Item_ID = invs.item_id where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)
union (
select st.item_id  as file_item,material_id,invs.supplier_part_no,invs.item_id,
 ' item id in file mismatched with supplier part no(Material id = item_id)'  as item_status
from sandvik_test st join p21_view_inventory_supplier invs on st.Material_id = invs.item_id and st.item_id = invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and   invs.supplier_part_no != invs.item_id
				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)
union(
select st.item_id  as file_item,material_id,invs.supplier_part_no,invs.item_id,
'part no missmatches(item id = item id)'  as item_status
from sandvik_test st join p21_view_inventory_supplier invs on st.Item_ID = invs.item_id and st.Material_id != invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				  and backup_date > getdate() - 0.02083 
				  and   invs.supplier_part_no != invs.item_id

				  and st.supplier_id = @supplier_ID
				  and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
)union (
select st.item_id  as file_item,material_id,invs.supplier_part_no,invs.item_id,
case when st.Material_id = invs.item_id and invs.item_id != invs.supplier_part_no then '(item id= part no) (values switched)'
when st.Material_id != invs.item_id then ' material Id mismatches with item id (item id = supplier part no)' end as item_status
from sandvik_test st join p21_view_inventory_supplier invs on st.Item_ID = invs.supplier_part_no where invs.delete_flag = 'N' and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
and backup_date > getdate() - 0.02083
				  and st.supplier_id = @supplier_ID
				   and invs.supplier_part_no != invs.item_id
				   and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))
				   
))sn group by file_item)s2 on s1.file_item = s2.item_id_in_file



    -- Perfect Match Items

    INSERT INTO sandvik_test2
    SELECT DISTINCT t1.material_id,
                    t1.description,
                    t1.backup_date,
                    t1.item_id,
                    t1.short_description,
                    t1.mpg_discount,
                    t1.net_price,
                    t1.list_price,
					case when t1.Description = t3.item_desc then 'Everything including desctiption Matches'
					else 'Description Mismatches'
					end as 'Description Details',
					t3.item_desc,
					@supplier_ID

    FROM            sandvik_test t1
    JOIN            p21_view_inventory_supplier t2
	
	
    ON              t1.item_id = t2.item_id

	JOIN			mdm_test  t4 
	ON				t4.item_id_in_file = t1.item_id and t4.backup_date = t1.backup_date and t1.Supplier_ID = t4.supplier_ids
    AND             t1.material_id = t2.supplier_part_no
	JOIN			p21_view_inv_mast t3 on t1.item_id = t3.item_id
	where
	                t1.backup_date > getdate() - 0.02083 
	AND				t4.backup_date > getdate() - 0.02083				
	AND
					t1.supplier_id = @supplier_ID
	AND				t4.item_final_status = 'Perfect match without Duplicates'

    
    -- Only Item ID matches

   insert into sandvik_test3
select material_id,Description_in_file,backup_date,item_id_in_file,net_price,list_price,item_status,item_id_p21,supplier_part_no_p21,supplier_ids from mdm_test
where item_final_status != 'Perfect match without Duplicates'   AND             backup_date > getdate() - 0.02083 and supplier_ids = @supplier_ID
union 
    SELECT DISTINCT material_id,
                    t1.description,
                    backup_date,
                    t1.item_id,
                    t1.net_price,
                    t1.list_price,
                    'Item match Special characters',
                    t2.item_id,
                    t2.supplier_part_no,
                    @supplier_id

    FROM            sandvik_test t1
    JOIN            p21_view_inventory_supplier t2
    ON              t1.material_id = t2.supplier_part_no
    AND             t1.item_id IN
                    (
                           SELECT
                                  CASE
                                         WHEN item_id LIKE '%''%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%\%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%!%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%~%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%@%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%:%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%^%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%`%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%`%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%-%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%''''%' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%/_%'ESCAPE '/' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         WHEN item_id LIKE '%/%%'ESCAPE '/' THEN dbo.Fn_stripcharacters((item_id), '^a-z0-9')
                                         ELSE item_id
                                  END
                           FROM   p21_view_inventory_supplier
                           WHERE  item_id LIKE '%''%'
                           OR     item_id LIKE '%\%'
                           OR     item_id LIKE '%!%'
                           OR     item_id LIKE '%~%'
                           OR     item_id LIKE '%@%'
                           OR     item_id LIKE '%:%'
                           OR     item_id LIKE '%^%'
                           OR     item_id LIKE '%"%'
                           OR     item_id LIKE '%`%'
                           OR     item_id LIKE '%-%'
                           OR     item_id LIKE '%`%'
                           OR     item_id LIKE '%''''%'
                           OR     item_id LIKE '%/_%' ESCAPE '/'
                           OR     item_id LIKE '%/%%' ESCAPE '/'
						   and supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ',')) )
						    
    
    AND             t1.item_id IN
                    (
                           SELECT item_id
                           FROM   p21_view_inventory_supplier where supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ',')) )
    AND             backup_date > getdate() - 0.02083 
	and t2.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ',')) 



	union 
    SELECT DISTINCT material_id,
                    t1.description,
                    backup_date,
                    t1.item_id,
                    t1.net_price,
                    t1.list_price,
                    'Item match Special characters',
                    t2.item_id,
                    t2.supplier_part_no,
                    @supplier_id

    FROM            sandvik_test t1
    JOIN            p21_view_inventory_supplier t2
    ON              t1.material_id = t2.supplier_part_no
    AND             t1.material_id IN
                    (
                           SELECT
                                  CASE
                                         WHEN material_id LIKE '%''%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%\%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%!%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%~%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%@%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%:%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%^%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%`%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%`%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%-%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%''''%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%/_%'ESCAPE '/' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%/%%'ESCAPE '/' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         ELSE material_id
                                  END
                           FROM   p21_view_inventory_supplier
                           WHERE  material_id LIKE '%''%'
                           OR     material_id LIKE '%\%'
                           OR     material_id LIKE '%!%'
                           OR     material_id LIKE '%~%'
                           OR     material_id LIKE '%@%'
                           OR     material_id LIKE '%:%'
                           OR     material_id LIKE '%^%'
                           OR     material_id LIKE '%"%'
                           OR     material_id LIKE '%`%'
                           OR     material_id LIKE '%-%'
                           OR     material_id LIKE '%`%'
                           OR     material_id LIKE '%''''%'
                           OR     material_id LIKE '%/_%' ESCAPE '/'
                           OR     material_id LIKE '%/%%' ESCAPE '/')
    
    AND             t1.material_id IN
                    (
                           SELECT supplier_part_no
                           FROM   p21_view_inventory_supplier  )
    AND             backup_date > getdate() - 0.02083 
	

		union 
    SELECT DISTINCT material_id,
                    t1.description,
                    backup_date,
                    t1.item_id,
                    t1.net_price,
                    t1.list_price,
                    'Item match Special characters',
                    t2.item_id,
                    t2.supplier_part_no,
                    @supplier_id

    FROM            sandvik_test t1
    JOIN            p21_view_inventory_supplier t2
    ON              t1.Item_ID = t2.item_id
    AND             t1.material_id IN
                    (
                           SELECT
                                  CASE
                                         WHEN material_id LIKE '%''%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%\%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%!%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%~%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%@%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%:%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%^%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%`%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%`%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%-%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%''''%' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%/_%'ESCAPE '/' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         WHEN material_id LIKE '%/%%'ESCAPE '/' THEN dbo.Fn_stripcharacters((material_id), '^a-z0-9')
                                         ELSE material_id
                                  END
                           FROM   p21_view_inventory_supplier
                           WHERE  material_id LIKE '%''%'
                           OR     material_id LIKE '%\%'
                           OR     material_id LIKE '%!%'
                           OR     material_id LIKE '%~%'
                           OR     material_id LIKE '%@%'
                           OR     material_id LIKE '%:%'
                           OR     material_id LIKE '%^%'
                           OR     material_id LIKE '%"%'
                           OR     material_id LIKE '%`%'
                           OR     material_id LIKE '%-%'
                           OR     material_id LIKE '%`%'
                           OR     material_id LIKE '%''''%'
                           OR     material_id LIKE '%/_%' ESCAPE '/'
                           OR     material_id LIKE '%/%%' ESCAPE '/')
    
    AND             t1.Item_ID IN
                    (
                           SELECT supplier_part_no
                           FROM   p21_view_inventory_supplier )
    AND             backup_date > getdate() - 0.02083 
	;


    
 

    -- New Item ID setup


    INSERT INTO sandvik_test1
    SELECT DISTINCT *
    FROM            sandvik_test
    WHERE           item_id NOT IN
                   (SELECT item_id
                       FROM   p21_view_inventory_supplier where supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','))  

                       UNION
                       SELECT item_id
                       FROM   sandvik_test2
                       UNION
                       SELECT item_id
                       FROM   sandvik_test3)
       AND material_id NOT IN ((SELECT material_id
                                FROM   sandvik_test
                                WHERE
           material_id IN (SELECT DISTINCT supplier_part_no
                           FROM   p21_view_inventory_supplier))
                               UNION
                               SELECT material_id
                               FROM   sandvik_test2 where  backup_date > getdate() - 0.02083 
                               UNION
                               SELECT material_id
                               FROM   sandvik_test3 where backup_date > getdate() - 0.02083 ) ;


----- Items available in P21 but not in file
insert into sandvik_itemstoremove
SELECT distinct  invs.item_id,
           supplier_part_no,
	       item_desc,  
           Getdate() AS backup_date,
		    @supplier_id
    FROM   p21_view_inventory_supplier invs
   JOIN   p21_view_inv_mast im
    ON     im.item_id = invs.item_id

				   where     NOT EXISTS
           (
                  SELECT Material_id
                  FROM   sandvik_test st
                  WHERE  invs.supplier_part_no = st.Material_id
				  
				  and backup_date > getdate() - 0.02083 
				  and supplier_id = @supplier_ID)
				  and not exists 
				   (
                  SELECT item_id
                  FROM   sandvik_test st
                  WHERE  invs.item_id = st.Item_ID
				  
				  and backup_date > getdate() - 0.02083 
				  and supplier_id = @supplier_ID)
				  and not exists 
				   (
                  SELECT item_id
                  FROM   sandvik_test st
                  WHERE  invs.item_id = st.Material_id
				  
				  and backup_date > getdate() - 0.02083 
				  and supplier_id = @supplier_ID)
				  and not exists 
				   (
                  SELECT Material_id
                  FROM   sandvik_test st
                  WHERE  invs.supplier_part_no = st.Item_ID
				  
				  and backup_date > getdate() - 0.02083 
				  and supplier_id = @supplier_ID)

    AND    invs.delete_flag = 'N'






and invs.supplier_id in (SELECT value FROM STRING_SPLIT(@supplier_ID, ','));


-- Final Duplicate identification

insert into mdm_duplicates select *,case when item_id_p21 like '%;%' and supplier_part_no_p21 like '%;%' then 'Duplicates in both Item id and part number'
when item_id_p21 like '%;%' and supplier_part_no_p21 not like '%;%' then 'Duplicates in Item id' 
when item_id_p21 not like '%;%' and supplier_part_no_p21  like '%;%' then 'Duplicates in Supplier part no' 
when item_id_p21 not like '%;%' and supplier_part_no_p21  not like '%;%' and item_id_in_file != item_id_p21 and 
part_no_in_file = supplier_part_no_p21 
then 'Different Item ID' 
when item_id_p21 not like '%;%' and supplier_part_no_p21  not like '%;%' and item_id_in_file = item_id_p21 then 'Different Supplier part no' 
else 'Duplicates in Item id'  end as issue,getdate() as backup_date,@supplier_ID as supplier_IDs
from(select distinct item_id_in_file, STUFF((SELECT distinct '; ' + item_id_p21
          FROM mdm_test st3
          WHERE st3.item_id_in_file = st31.item_id_in_file 
          
          FOR XML PATH('')), 1, 1, '') item_id_p21,STUFF((SELECT distinct '; ' + material_id
          FROM mdm_test st3
          WHERE st3.item_id_in_file = st31.item_id_in_file 
          
          FOR XML PATH('')), 1, 1, '') part_no_in_file,STUFF((SELECT distinct '; ' + supplier_part_no_p21
          FROM mdm_test st3
          WHERE st3.item_id_in_file = st31.item_id_in_file 
          
          FOR XML PATH('')), 1, 1, '') supplier_part_no_p21


		  from mdm_test st31
		 where (count_of_items != 1 and item_status != 'item and part no matches') and supplier_ids = @supplier_id and  backup_date > getdate() - 0.02083 
		
		  group by item_id_in_file )x

  END
GO



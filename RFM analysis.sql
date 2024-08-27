-- RFM Analysis: Xác định phân khúc khách hàng cho sản phẩm thanh toán hóa đơn tiền điện 
  -- Bước 1: tính RFM cho từng khách hàng (retention - frequency - monetary) 
with table_rfm as (
select customer_id
    , datediff (day, max(transaction_date), '2018-12-31' ) as retention 
    , count (order_id) as frequency 
    , sum (cast (final_price as bigint)) as monetary 
from (select * from payment_history_17 as his17 union select * from payment_history_18 ) as his 
left join product as pro
     on his.product_id = pro.product_number
where message_id = 1  -- đơn hàng thành công
   and sub_category = 'electricity' -- phân loại chỉ hóa đơn tiền điện 
group by customer_id )
 -- Bước 2: dùng percentile để xác định vị trí từng khách hàng (đứng ở % thứ mấy)
, table_rank as (
select *
    , percent_rank () over (order by retention asc) as r_rank 
    , percent_rank () over (order by frequency desc) as f_rank 
    , percent_rank () over (order by monetary desc) as m_rank 
from table_rfm )
 -- bước 3: chia thành 4 tiers cho mỗi chỉ số 
, table_tier as (
    select * 
     , case when r_rank <= 0.25 then 1
            when r_rank <= 0.5 then 2 
            when r_rank <= 0.75 then 3
            else 4 end as r_tier 
    , case when f_rank <= 0.25 then 1
            when f_rank <= 0.5 then 2 
            when f_rank <= 0.75 then 3
            else 4 end as f_tier 
    , case when m_rank <= 0.25 then 1
            when m_rank <= 0.5 then 2 
            when m_rank <= 0.75 then 3
            else 4 end as m_tier 
from table_rank )
, table_score as (select * 
     , concat (r_tier , f_tier, m_tier) as rfm_score 
from table_tier )
 --Bước 4: phân nhóm theo tổ hợp hành vi 
, table_segment as (
    select *
     , case 
       when rfm_score = 111 then 'Best Customers' -- Khách hàng tốt nhất
       when rfm_score like '[3-4][3-4][1-4]' then 'Lost Bad Customers' --Khách hàng rời bỏ (trên 55ds, mua 1-2 đơn) 
       when rfm_score like '[3-4]2[1-4]' then 'Lost Customers' -- Khách hàng cũng rời bỏ nhưng có giá trị (mua 3 4 5 6 đơn) 
       when rfm_score like '21[1-4]' then 'Almost Lost' -- Khách hàng tốt nhưng có nguy cơ sắp mất những khách hàng này
       when rfm_score like '11[2-4]' then 'Loyal Customers' -- Khách hàng trung thành 
       when rfm_score like '[1-2][1-3]1' then 'Big Spender' -- chi nhiều tiền 
       when rfm_score like '[1-2]4[1-4]' then 'New Customers' -- Khách hàng mới nên giao dịch ít (gần đây nhưng ít mua) 
       when rfm_score like '[3-4]1[1-4]' then 'Hibernating' -- ngủ đông (trước đó rất tốt) 
       when rfm_score like '[1-2][2-3][2-4]' then 'Potential Loyalists'-- có tiềm năng
       else 'unknown' end as segment -- kiểm tra còn sót nhóm nào không 
from table_score)
select segment
    , count (customer_id) as number_customers 
from table_segment
group by segment 
order by number_customers desc 
 /*  trả lời cho câu hỏi tối ưu việc phát voucher cho các nhóm Khách hàng như thế nào:
 - Khách hàng tốt: có thể voucher giá trị thấp (vì họ vẫn sẽ tiếp tục mua hàng của mình)
 - Khách hàng tiềm năng: voucher cao hơn nhóm khách hàng tốt
 - Khách hàng ngủ đông: voucher cao hơn nhóm khách hàng tốt 
 - Khách hàng xấu: không phát voucher, nên tìm hiểu thêm  nguyên nhân nhóm khách này*/
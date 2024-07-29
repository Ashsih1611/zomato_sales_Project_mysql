create database zomato;
use zomato;
create table users (Userid int primary key auto_increment , signup_date date not null );
insert into users (signup_date) values ("2014-09-02"),("2015-01-15"),("2014-04-11");
select * from users;

-- creating sales table --

create table sales( userid int not null , created_date date not null , product_id int not null);
insert into sales values (1,"2017-4-19",2),(3,"2019-12-18",1),(2,"2020-7-20",3),(1,"2019-10-23",2),
(1,"2018-3-19",3),(3,"2016-12-20",2),(1,"2016-11-9",1),(1,"2016-5-20",3),(2,"2017-9-24",1),
(1,"2017-3-11",2),(1,"2016-3-11",1),(3,"2016-11-10",1),(3,"2017-12-7",2),(3,"2016-12-15",2),(2,"2017-11-8",2),(2,"2018-9-10",3);
select * from sales;

-- creating a product table 

create table product (product_id int not null , product_name varchar(2) not null , price int not null);
insert into product values (1,"p1",980),(2,"p2",870),(3,"p3",330);
 
 select * from product ;
 
 -- creating gold user table 
 
 create table gold_user (userid int  not null ,gold_signup_date date not null);
 
 insert into gold_user values (1,"2017-09-22"),(3,"2017-04-21");
 
 select * from gold_user;
 
 -- Questions:--
-- 1.what is total amount each customer spent on zomato ?

select userid , sum(price) as total_price from sales inner join product on sales .product_id = product.product_id group by userid;

-- 2.How many days has each customer visited zomato?

select userid,count(created_date) from sales group by userid;

-- 3.what was the first product purchased by each customer?
select * from
(select userid,product_id,created_date,row_number() over(partition by userid order by created_date) as rn from sales) as t where rn=1     ;
-- 4.what is most purchased item on menu & how many times was it purchased by all customers ?
select product_id ,count(product_id) from sales group by product_id;
select userid ,product_id ,count(product_id) from sales group by userid,product_id having product_id =2;
-- 5.which item was most popular for each customer?
select * from
(select  userid ,product_id ,row_number() over(partition by userid order by count(product_id) desc) as rn from sales group by userid,product_id) t where rn=1 ;
-- 6.which item was purchased first by customer after they become a member ?
select * from sales;
select * from gold_user;
select * from product;
select userid,product_id,product_name ,created_date, gold_signup_date from
 (select userid,product_id,product_name ,created_date, gold_signup_date ,row_number () over(partition by userid order by created_date) as rn from
 (select sales.userid,sales.product_id,product.product_name,sales.created_date,gold_user.gold_signup_date  from sales
 inner join product on sales.product_id = product.product_id 
 inner join gold_user on sales.userid=gold_user.userid
 where created_date>= gold_signup_date  ) as t) as b where rn=1  ;
-- 7. which item was purchased just before the customer became a member?
select userid,product_id ,product_name,created_date,gold_signup_date from
(select userid,product_id ,product_name,created_date,gold_signup_date, row_number() over(partition by userid order by  created_date desc) as rn from
(select sales.userid,sales.product_id ,product.product_name,sales.created_date,gold_user.gold_signup_date from sales inner join
product on product.product_id=sales.product_id inner join  gold_user on gold_user.userid =sales.userid where created_date<=gold_signup_date) as t) as b where rn=1 ;
-- 8. what is total orders and amount spent for each member before they become a member?
select * from sales;
select * from gold_user;
select * from product;
select sales.userid,sum(price) over(partition by userid ) as summ  from sales inner join
product on product.product_id=sales.product_id inner join  gold_user on gold_user.userid =sales.userid where created_date<=gold_signup_date  ;

--  or ----

select userid,sum(price) from 
 (select sales.userid,sales.product_id,product.product_name,sales.created_date,gold_user.gold_signup_date ,product.price from sales inner join
product on product.product_id=sales.product_id inner join  gold_user on gold_user.userid =sales.userid where created_date<=gold_signup_date) as a group by userid  ;

-- 9. If buying each product generates points for eg 5rs=2 zomato point 
--   and each product has different purchasing points for eg for p1 5rs=1 zomato point,for p2 10rs=zomato point and p3 5rs=1 zomato point  2rs =1zomato point, calculate points collected by each customer and for which product most points have been given till now.
select * from product;
select * from sales;
select userid,product_id, round(p/point,1) from
(select userid,product_id,p ,case when product_id=1 then 5 when product_id =2 then 2 when product_id=3 then  5 else 0 end as point from
(select userid,product_id ,sum(price) as p from
(select sales.product_id,sales.userid,product.price from product inner join sales on sales.product_id = product.product_id) as a group by userid ,product_id) as b) as c;


-- 10. rnk all transaction of the customers:
select * from sales;
select * from product;
select sales.userid,sales.product_id,product.product_name,product.price,sales.created_date,dense_rank()over( partition by userid order by created_date) from sales inner join product on product.product_id=sales.product_id;
-- 11. rank all transaction for each member whenever they are zomato gold member for every non gold member transaction mark as na
select userid,created_date,gold_signup_date ,case when gold_signup_date is null then "na" else rank() over(partition by userid order by created_date desc ) end rankk from
(select sales.userid,sales.product_id,sales.created_date,gold_user.gold_signup_date  from sales
 left join gold_user on sales.userid=gold_user.userid
 and  created_date>= gold_signup_date  )as t

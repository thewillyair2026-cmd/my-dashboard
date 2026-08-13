-- 인사 대시보드 (WILLY 버전) — 실제 재직 인원(대표/경리/마케팅/B2B/B2C) 9명 기준입니다.
-- 설치기사는 도급이라 여기(인사)가 아니라 손익 대시보드의 '설치도급비'에 들어갑니다.
-- 기존 hr_monthly/hr_dept/hr_tenure/hr_overtime 표가 있다면 아래로 교체됩니다.

drop table if exists hr_monthly;
drop table if exists hr_dept;
drop table if exists hr_tenure;
drop table if exists hr_overtime;

create table hr_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null, month text not null, headcount int not null, payroll bigint not null,
  joined int not null, left_count int not null, revenue bigint not null
);
insert into hr_monthly (sort_order, month, headcount, payroll, joined, left_count, revenue) values
  (1,'2월',7,1450,0,0,6200),
  (2,'3월',7,1450,0,0,6900),
  (3,'4월',8,1500,1,0,7100),
  (4,'5월',8,1500,0,0,7310),
  (5,'6월',9,1550,1,0,8050),
  (6,'7월',9,1550,0,0,8470);

-- 대표 1 / 경리 1 / 마케팅 1 / B2B영업 2 / B2C영업 4 = 9명
create table hr_dept (
  id bigint primary key generated always as identity,
  dept text not null, headcount int not null, payroll bigint not null
);
insert into hr_dept (dept, headcount, payroll) values
  ('대표',    1, 300),
  ('경리',    1, 220),
  ('마케팅',  1, 230),
  ('B2B영업', 2, 400),
  ('B2C영업', 4, 400);

create table hr_tenure (
  id bigint primary key generated always as identity,
  sort_order int not null, bucket text not null, count int not null
);
insert into hr_tenure (sort_order, bucket, count) values
  (1,'3년 이상',2), (2,'1-3년',3), (3,'6개월-1년',2), (4,'6개월 미만',2);

create table hr_overtime (
  id bigint primary key generated always as identity,
  dept text not null, bucket text not null, count int not null   -- bucket: '0h','1-10','11-20','21-30','30h+'
);
insert into hr_overtime (dept, bucket, count) values
  ('대표','11-20',1),
  ('경리','0h',1),
  ('마케팅','1-10',1),
  ('B2B영업','1-10',1),('B2B영업','11-20',1),
  ('B2C영업','0h',1),('B2C영업','1-10',1),('B2C영업','11-20',2);

alter table hr_monthly  enable row level security;
alter table hr_dept     enable row level security;
alter table hr_tenure   enable row level security;
alter table hr_overtime enable row level security;
create policy "read" on hr_monthly  for select to anon using (true);
create policy "read" on hr_dept     for select to anon using (true);
create policy "read" on hr_tenure   for select to anon using (true);
create policy "read" on hr_overtime for select to anon using (true);

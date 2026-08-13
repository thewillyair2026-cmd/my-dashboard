-- 고객 대시보드 (WILLY 버전) — 시스템에어컨은 B2C는 한 번 설치하면 끝이라
-- 이탈률/재구매 대신 AS 발생률과 B2B(부동산·인테리어) 재발주 중심으로 설계했습니다.
-- 기존 customer_summary/customer_cohort/customer_repeat 표가 있다면 아래로 교체됩니다.

drop table if exists customer_summary;
drop table if exists customer_as_cohort;
drop table if exists customer_type;
drop table if exists b2b_partners;
drop table if exists customer_cohort;
drop table if exists customer_repeat;

create table customer_summary (
  id bigint primary key generated always as identity,
  sort_order int not null,
  month text not null,
  new_customers bigint not null,     -- 신규 설치 건수 (B2C+B2B)
  as_rate numeric not null,          -- AS(하자) 발생률 %
  avg_deal bigint not null,          -- 평균 계약단가 (만원)
  active_partners int not null       -- 이번 달 발주가 있었던 B2B 파트너사 수
);
insert into customer_summary (sort_order, month, new_customers, as_rate, avg_deal, active_partners) values
  (1,'2월',132, 3.2, 248, 6),
  (2,'3월',148, 3.5, 251, 7),
  (3,'4월',151, 3.0, 255, 6),
  (4,'5월',156, 3.8, 258, 8),
  (5,'6월',171, 3.4, 262, 8),
  (6,'7월',195, 4.1, 266, 9);

-- 설치 후 몇 달째까지 AS 요청 없이 잘 쓰고 있는지 (무AS 유지율, 100%에서 서서히 감소)
create table customer_as_cohort (
  id bigint primary key generated always as identity,
  sort_order int not null,
  install_month text not null,
  months_after int not null,
  issue_free_rate numeric not null
);
insert into customer_as_cohort (sort_order, install_month, months_after, issue_free_rate) values
  (1,'2월',0,100),(1,'2월',1,98),(1,'2월',2,96),(1,'2월',3,95),(1,'2월',4,94),(1,'2월',5,93),
  (2,'3월',0,100),(2,'3월',1,97),(2,'3월',2,95),(2,'3월',3,94),(2,'3월',4,93),
  (3,'4월',0,100),(3,'4월',1,98),(3,'4월',2,96),(3,'4월',3,95),
  (4,'5월',0,100),(4,'5월',1,97),(4,'5월',2,95),
  (5,'6월',0,100),(5,'6월',1,96),
  (6,'7월',0,100);

-- 거래 구성 (설치 건수 기준)
create table customer_type (
  id bigint primary key generated always as identity,
  kind text not null,     -- 'B2C 신규' / 'B2B 신규' / 'B2B 재발주'
  count bigint not null
);
insert into customer_type (kind, count) values
  ('B2C 신규', 150),
  ('B2B 신규', 18),
  ('B2B 재발주', 27);

-- B2B 파트너사(부동산·인테리어 등) 순위
create table b2b_partners (
  id bigint primary key generated always as identity,
  partner_name text not null,
  order_count int not null,
  revenue bigint not null     -- 누적 매출 (만원)
);
insert into b2b_partners (partner_name, order_count, revenue) values
  ('한빛부동산',      12, 2400),
  ('모던인테리어',     9, 1850),
  ('스마트공인중개사', 7, 1400),
  ('그린인테리어',     5, 980),
  ('행복공인중개사',   4, 760);

alter table customer_summary  enable row level security;
alter table customer_as_cohort enable row level security;
alter table customer_type     enable row level security;
alter table b2b_partners      enable row level security;
create policy "read" on customer_summary  for select to authenticated using (true);
create policy "read" on customer_as_cohort for select to authenticated using (true);
create policy "read" on customer_type     for select to authenticated using (true);
create policy "read" on b2b_partners      for select to authenticated using (true);

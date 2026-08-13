-- 손익 대시보드 (WILLY 버전) — 기기매입비/설치도급비/인건비를 분리했습니다.
-- (설치기사는 직원이 아니라 도급이라 인건비와 별도 항목입니다.)
-- 기존 pl_summary/pl_cost/pl_margin 표가 있다면 아래로 교체됩니다.

drop table if exists pl_summary;
drop table if exists pl_cost;
drop table if exists pl_margin;

create table pl_summary (
  id bigint primary key generated always as identity,
  sort_order int not null,
  month text not null,
  revenue bigint not null,       -- 매출
  device_cost bigint not null,   -- 기기 매입비
  install_fee bigint not null,   -- 설치기사 도급비
  payroll bigint not null,       -- 인건비 (대표/경리/마케팅/B2B/B2C 9명)
  other_cost bigint not null     -- 광고비 + 임대료 등 기타
);
insert into pl_summary (sort_order, month, revenue, device_cost, install_fee, payroll, other_cost) values
  (1,'2월',6200,2480,930,1450,892),
  (2,'3월',6900,2760,1035,1450,965),
  (3,'4월',7100,2840,1065,1500,1056),
  (4,'5월',7310,2920,1097,1500,1174),
  (5,'6월',8050,3220,1208,1550,1288),
  (6,'7월',8470,3390,1270,1550,1380);

create table pl_cost (
  id bigint primary key generated always as identity,
  item text not null,
  amount bigint not null,
  cost_type text not null       -- '고정' 또는 '변동'
);
insert into pl_cost (item, amount, cost_type) values
  ('기기매입비', 3390, '변동'),
  ('설치도급비', 1270, '변동'),
  ('인건비',     1550, '고정'),
  ('광고비',     1230, '변동'),
  ('기타(임대료 등)', 150, '고정');

create table pl_margin (
  id bigint primary key generated always as identity,
  product text not null,
  margin_rate numeric not null   -- 공헌이익률 %
);
insert into pl_margin (product, margin_rate) values
  ('삼성 스탠드형', 38),
  ('LG 스탠드형',   35),
  ('삼성 벽걸이',   25),
  ('LG 벽걸이',     22),
  ('시스템(빌트인)', 12);

alter table pl_summary enable row level security;
alter table pl_cost    enable row level security;
alter table pl_margin  enable row level security;
create policy "read" on pl_summary for select to authenticated using (true);
create policy "read" on pl_cost    for select to authenticated using (true);
create policy "read" on pl_margin  for select to authenticated using (true);

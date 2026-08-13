-- 마케팅 대시보드 (WILLY 버전) — 기존 marketing_* 표가 있다면 아래로 교체됩니다.

drop table if exists marketing_channel;
drop table if exists marketing_monthly;
drop table if exists marketing_budget;

-- 채널: 네이버 키워드광고 / 파워링크 / 쇼핑검색광고 / 쿠팡광고 / 네이버 블로그(체험단) / 전단지
-- 전단지는 오프라인이라 클릭이 없어서(0) 대시보드에서 CTR·CPC는 "–"로 표시됩니다.
create table marketing_channel (
  id bigint primary key generated always as identity,
  channel text not null,
  spend bigint not null,
  impressions bigint not null,
  clicks bigint not null,
  conversions bigint not null,
  revenue bigint not null
);
insert into marketing_channel (channel, spend, impressions, clicks, conversions, revenue) values
  ('네이버 키워드광고', 380, 620000, 15200, 98, 1850),
  ('파워링크',          290, 410000, 9800,  62, 1180),
  ('쇼핑검색광고',      210, 340000, 7200,  44, 820),
  ('쿠팡광고',          150, 180000, 3600,  21, 390),
  ('네이버 블로그(체험단)', 120, 95000, 4100, 18, 310),
  ('전단지',            80,  15000,  0,     8,  140);

create table marketing_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null, month text not null, spend bigint not null, roas numeric not null
);
insert into marketing_monthly (sort_order, month, spend, roas) values
  (1,'2월',742,368), (2,'3월',815,392), (3,'4월',906,381),
  (4,'5월',1024,404), (5,'6월',1138,396), (6,'7월',1230,412);

create table marketing_budget (
  id bigint primary key generated always as identity,
  month text not null, budget bigint not null, days_total int not null, days_passed int not null
);
insert into marketing_budget (month, budget, days_total, days_passed) values ('7월', 1500, 31, 24);

alter table marketing_channel enable row level security;
alter table marketing_monthly enable row level security;
alter table marketing_budget  enable row level security;
create policy "read" on marketing_channel for select to anon using (true);
create policy "read" on marketing_monthly for select to anon using (true);
create policy "read" on marketing_budget  for select to anon using (true);

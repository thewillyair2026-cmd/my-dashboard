-- 영업 대시보드 (WILLY 버전) — 기존 sales_monthly/sales_pipeline/sales_rank 표가 있다면 아래로 교체됩니다.
-- 처음 만드는 경우: 그냥 전체 실행하면 됩니다.
-- 이미 만든 적 있는 경우: 아래 drop 구문이 기존 표를 지우고 새로 만듭니다 (샘플 데이터라 안전합니다).

drop table if exists sales_rank;
drop table if exists sales_pipeline;
drop table if exists sales_deal_type;
drop table if exists sales_monthly;

create table sales_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null, month text not null,
  revenue bigint not null, target bigint not null
);
insert into sales_monthly (sort_order, month, revenue, target) values
  (1,'2월',6200,9200),(2,'3월',6900,9200),(3,'4월',7100,9200),
  (4,'5월',7310,9200),(5,'6월',8050,9200),(6,'7월',8470,9200);

-- 영업 단계: 문의 → 견적 → 계약 → 설치완료 (현장실측은 예외적인 경우라 단계에서 제외)
create table sales_pipeline (
  id bigint primary key generated always as identity,
  sort_order int not null, stage text not null, count bigint not null
);
insert into sales_pipeline (sort_order, stage, count) values
  (1,'문의',620),(2,'견적',340),(3,'계약',210),(4,'설치완료',195);

-- 거래 유형별 매출 (B2C: 설치 후 종료 / B2B: 부동산·인테리어 등 재발주)
create table sales_deal_type (
  id bigint primary key generated always as identity,
  kind text not null,   -- 'B2B' 또는 'B2C'
  revenue bigint not null,
  count int not null
);
insert into sales_deal_type (kind, revenue, count) values
  ('B2C', 5270, 150),
  ('B2B', 3200, 45);

-- 담당자별 실적(B2B/B2C 팀 표시) + 브랜드별 실적(LG/삼성)
create table sales_rank (
  id bigint primary key generated always as identity,
  kind text not null,          -- 'person' 또는 'brand'
  name text not null,
  amount bigint not null,
  team text                    -- kind가 person일 때만: 'B2B' 또는 'B2C'
);
insert into sales_rank (kind, name, amount, team) values
  ('person','김도현',1820,'B2C'),
  ('person','이수진',1460,'B2C'),
  ('person','박민재',1280,'B2C'),
  ('person','정하늘', 970,'B2C'),
  ('person','최윤서',1650,'B2B'),
  ('person','한지원',1290,'B2B'),
  ('brand','삼성',4620,null),
  ('brand','LG',3850,null);

alter table sales_monthly   enable row level security;
alter table sales_pipeline  enable row level security;
alter table sales_deal_type enable row level security;
alter table sales_rank      enable row level security;
create policy "read" on sales_monthly   for select to anon using (true);
create policy "read" on sales_pipeline  for select to anon using (true);
create policy "read" on sales_deal_type for select to anon using (true);
create policy "read" on sales_rank      for select to anon using (true);

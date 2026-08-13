-- 영업 대시보드 (실데이터 반영판) — 에어테이블 "진행현황-1.견적제출(전체)" 기준
-- 처리: 취소건 제외(48건) + 동일고객 중복견적 근사 통합(단지명+제출일 기준) + 재직자만 랭킹
-- 기존 표가 있다면 아래로 교체됩니다.

drop table if exists sales_rank;
drop table if exists sales_pipeline;
drop table if exists sales_deal_type;
drop table if exists sales_monthly;

-- 월별 실적 (연월 표기, 계약일 기준)
create table sales_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null,
  ym text not null,          -- '2025.09' 형식
  quotes bigint not null,    -- 견적 건수
  revenue bigint not null,   -- 계약금액 합계(원)
  target bigint not null     -- 월 목표금액(원) — 필요시 직접 수정하세요
);
insert into sales_monthly (sort_order, ym, quotes, revenue, target) values
  (1,'2025.09', 29,   31249998,    500000000),
  (2,'2025.10', 260,  411524512,  600000000),
  (3,'2025.11', 317,  516861869,  600000000),
  (4,'2025.12', 342,  574537940,  700000000),
  (5,'2026.01', 473,  849359621,  800000000),
  (6,'2026.02', 480,  683849947,  800000000),
  (7,'2026.03', 658,  1118058617, 1000000000),
  (8,'2026.04', 657,  1188297230, 1000000000),
  (9,'2026.05', 570,  819181794,  1000000000),
  (10,'2026.06',591,  833833300,  1000000000),
  (11,'2026.07',478,  850454936,  1000000000),
  (12,'2026.08',180,  249055060,  1000000000);

-- 영업 퍼널: 견적 → 계약 → 설치완료 (전체 기간 누적, 기계설치일 존재 여부로 설치완료 판정)
create table sales_pipeline (
  id bigint primary key generated always as identity,
  sort_order int not null,
  stage text not null,
  count bigint not null
);
insert into sales_pipeline (sort_order, stage, count) values
  (1,'견적',5035),
  (2,'계약',1638),
  (3,'설치완료',1593);

-- 거래유형별(채널 기반: 인테리어·부동산=B2B, 나머지=B2C)
create table sales_deal_type (
  id bigint primary key generated always as identity,
  kind text not null,
  revenue bigint not null,
  count int not null
);
insert into sales_deal_type (kind, revenue, count) values
  ('B2C', 6402712966, 1287),
  ('B2B', 1729824585, 351);

-- 담당자별 실적(재직자만) + 브랜드별 실적(LG/삼성, 실외기 모델코드 AJ접두사=삼성 기준 근사)
create table sales_rank (
  id bigint primary key generated always as identity,
  kind text not null,          -- 'person' 또는 'brand'
  name text not null,
  amount bigint not null,
  team text                    -- person: 직급 표기용(선택)
);
insert into sales_rank (kind, name, amount, team) values
  ('person','신제호 과장',2667033934,null),
  ('person','오형민 대리',1657341222,null),
  ('person','정현수 대표',1397065948,null),
  ('person','민대기 대리', 906044009,null),
  ('person','김지연 주임', 237331818,null),
  ('person','이유진 사원', 127672715,null),
  ('person','이지은 대리',  75355629,null),
  ('person','서은지 주임',  37263478,null),
  ('brand','삼성',4102428586,null),
  ('brand','LG', 4030108965,null);

-- B2B/B2C 월별 계약 건수 (채널 기반 분류)
create table sales_deal_type_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null,
  ym text not null,
  b2b_count int not null,
  b2c_count int not null
);
insert into sales_deal_type_monthly (sort_order, ym, b2b_count, b2c_count) values
  (1,'2025.09', 3,  5),
  (2,'2025.10', 19, 65),
  (3,'2025.11', 25, 86),
  (4,'2025.12', 24, 96),
  (5,'2026.01', 39, 134),
  (6,'2026.02', 27, 113),
  (7,'2026.03', 35, 185),
  (8,'2026.04', 39, 197),
  (9,'2026.05', 37, 123),
  (10,'2026.06',52, 115),
  (11,'2026.07',36, 131),
  (12,'2026.08',14, 37);

alter table sales_deal_type_monthly enable row level security;
create policy "read" on sales_deal_type_monthly for select to anon using (true);

alter table sales_monthly   enable row level security;
alter table sales_pipeline  enable row level security;
alter table sales_deal_type enable row level security;
alter table sales_rank      enable row level security;
create policy "read" on sales_monthly   for select to anon using (true);
create policy "read" on sales_pipeline  for select to anon using (true);
create policy "read" on sales_deal_type for select to anon using (true);
create policy "read" on sales_rank      for select to anon using (true);

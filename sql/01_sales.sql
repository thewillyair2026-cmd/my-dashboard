-- 영업 대시보드 (실데이터 반영판) — 에어테이블 "진행현황-1.견적제출(전체)" 기준
-- 처리: 취소건 제외(48건) + 동일고객 중복견적 근사 통합(단지명+제출일 기준) + 재직자만 랭킹
-- 기존 표가 있다면 아래로 교체됩니다.

drop table if exists sales_rank;
drop table if exists sales_pipeline;
drop table if exists sales_pipeline_monthly;
drop table if exists sales_deal_type;
drop table if exists sales_deal_type_monthly;
drop table if exists sales_rank_monthly;
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

-- 영업 퍼널 월별: 견적 제출월 / 계약 체결월 / 설치완료월 각각 기준 (기간 선택 필터용)
-- 세 값은 같은 건을 추적하는 코호트가 아니라, 각 월에 발생한 이벤트 건수입니다 (견적일/계약일/기계설치일 각각 기준)
create table sales_pipeline_monthly (
  id bigint primary key generated always as identity,
  ym text not null,
  quotes int not null,
  contracts int not null,
  installs int not null
);
insert into sales_pipeline_monthly (ym, quotes, contracts, installs) values
  ('2025.09', 29, 8, 1),
  ('2025.10', 260, 84, 26),
  ('2025.11', 316, 111, 81),
  ('2025.12', 342, 119, 86),
  ('2026.01', 472, 173, 128),
  ('2026.02', 480, 140, 152),
  ('2026.03', 657, 219, 197),
  ('2026.04', 657, 233, 189),
  ('2026.05', 570, 158, 201),
  ('2026.06', 591, 167, 177),
  ('2026.07', 478, 166, 146),
  ('2026.08', 180, 51, 114);

alter table sales_pipeline_monthly enable row level security;
create policy "read" on sales_pipeline_monthly for select to anon using (true);

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

-- B2B/B2C 월별 계약 건수 + 계약금액 (채널 기반 분류: 인테리어·부동산·에어컨설팅=B2B)
create table sales_deal_type_monthly (
  id bigint primary key generated always as identity,
  sort_order int not null,
  ym text not null,
  b2b_count int not null,
  b2c_count int not null,
  b2b_revenue bigint not null default 0,
  b2c_revenue bigint not null default 0
);
insert into sales_deal_type_monthly (sort_order, ym, b2b_count, b2c_count, b2b_revenue, b2c_revenue) values
  (1,'2025.09', 3,  5,  12263636,  18986362),
  (2,'2025.10', 19, 65, 92019088,  319505424),
  (3,'2025.11', 25, 86, 114331358, 402530511),
  (4,'2025.12', 24, 96, 113401627, 457054495),
  (5,'2026.01', 39, 134,205460898, 643898723),
  (6,'2026.02', 27, 113,159090446, 524759501),
  (7,'2026.03', 35, 185,188395443, 924626811),
  (8,'2026.04', 39, 197,191134988, 981289516),
  (9,'2026.05', 37, 123,187969865, 619253293),
  (10,'2026.06',52, 115,247036342, 586796958),
  (11,'2026.07',36, 131,179709079, 665754948),
  (12,'2026.08',14, 37, 76572720,  172482340);

alter table sales_deal_type_monthly enable row level security;
create policy "read" on sales_deal_type_monthly for select to anon using (true);

-- 담당자/브랜드 월별 실적 (기간 선택 드롭다운용, 퇴사자 포함 전체)
create table sales_rank_monthly (
  id bigint primary key generated always as identity,
  kind text not null,       -- 'person' 또는 'brand'
  name text not null,
  ym text not null,
  quotes int not null,
  contracts int not null,
  revenue bigint not null
);
insert into sales_rank_monthly (kind, name, ym, quotes, contracts, revenue) values
  ('person','정현수 대표','2025.08',0,1,6272727),
  ('person','김혜란 대리','2025.09',8,0,0),
  ('person','신제호 과장','2025.09',11,3,11963635),
  ('person','정현수 대표','2025.09',10,5,19286363),
  ('person','김혜란 대리','2025.10',54,16,78228174),
  ('person','김희성 대리','2025.10',1,0,0),
  ('person','신제호 과장','2025.10',81,31,148028168),
  ('person','정현수 대표','2025.10',124,37,185268170),
  ('person','김혜란 대리','2025.11',60,13,59820450),
  ('person','김희성 대리','2025.11',5,0,0),
  ('person','신제호 과장','2025.11',100,44,203948892),
  ('person','오형민 대리','2025.11',46,6,28945451),
  ('person','정현수 대표','2025.11',106,48,224147076),
  ('person','김혜란 대리','2025.12',34,9,39977271),
  ('person','김희성 대리','2025.12',26,2,9477272),
  ('person','민대기 대리','2025.12',1,0,0),
  ('person','신제호 과장','2025.12',106,41,190529056),
  ('person','오형민 대리','2025.12',105,26,121516170),
  ('person','정현수 대표','2025.12',70,42,213038171),
  ('person','김혜란 대리','2026.01',0,2,13909090),
  ('person','김희성 대리','2026.01',111,32,152759077),
  ('person','민대기 대리','2026.01',12,3,14227272),
  ('person','신제호 과장','2026.01',119,65,319900562),
  ('person','오형민 대리','2026.01',142,34,170969990),
  ('person','정현수 대표','2026.01',89,37,177593630),
  ('person','김희성 대리','2026.02',113,24,116790899),
  ('person','민대기 대리','2026.02',66,16,77226812),
  ('person','서은지 주임','2026.02',2,2,5202815),
  ('person','신제호 과장','2026.02',76,38,184244892),
  ('person','오형민 대리','2026.02',165,34,175098714),
  ('person','정현수 대표','2026.02',58,26,125285815),
  ('person','김지연 주임','2026.03',4,1,5426636),
  ('person','김희성 대리','2026.03',158,34,169654986),
  ('person','민대기 대리','2026.03',118,36,188072891),
  ('person','서은지 주임','2026.03',3,3,7525200),
  ('person','신제호 과장','2026.03',124,75,382323015),
  ('person','오형민 대리','2026.03',200,46,233946799),
  ('person','정현수 대표','2026.03',51,25,131109090),
  ('person','김지연 주임','2026.04',25,7,37445454),
  ('person','김희성 대리','2026.04',181,54,265579431),
  ('person','민대기 대리','2026.04',144,32,171381805),
  ('person','서은지 주임','2026.04',5,5,12308500),
  ('person','신제호 과장','2026.04',101,64,313247336),
  ('person','오형민 대리','2026.04',164,53,283587975),
  ('person','정현수 대표','2026.04',36,21,104746729),
  ('person','김지연 주임','2026.05',54,7,34863636),
  ('person','김희성 대리','2026.05',115,22,121232148),
  ('person','민대기 대리','2026.05',114,24,129664625),
  ('person','서은지 주임','2026.05',2,2,5717520),
  ('person','신제호 과장','2026.05',114,61,302228702),
  ('person','오형민 대리','2026.05',139,34,176038800),
  ('person','정현수 대표','2026.05',32,10,49436363),
  ('person','김지연 주임','2026.06',89,17,96457274),
  ('person','민대기 대리','2026.06',151,24,126179987),
  ('person','신제호 과장','2026.06',116,61,288328792),
  ('person','오형민 대리','2026.06',179,44,221930887),
  ('person','이유진 사원','2026.06',6,1,6081818),
  ('person','정현수 대표','2026.06',50,20,94854542),
  ('person','김지연 주임','2026.07',43,10,52120636),
  ('person','민대기 대리','2026.07',125,27,138617896),
  ('person','서은지 주임','2026.07',3,3,6027087),
  ('person','신제호 과장','2026.07',85,49,253163617),
  ('person','오형민 대리','2026.07',127,35,186815532),
  ('person','이유진 사원','2026.07',43,18,92927264),
  ('person','이지은 대리','2026.07',30,11,54755632),
  ('person','정현수 대표','2026.07',21,14,66027272),
  ('person','김지연 주임','2026.08',2,2,11018182),
  ('person','민대기 대리','2026.08',44,12,60672721),
  ('person','서은지 주임','2026.08',2,2,482356),
  ('person','신제호 과장','2026.08',31,14,69127267),
  ('person','오형민 대리','2026.08',47,11,58490904),
  ('person','이유진 사원','2026.08',23,6,28663633),
  ('person','이지은 대리','2026.08',30,4,20599997),
  ('person','정현수 대표','2026.08',1,0,0),
  ('brand','삼성','2025.08',0,1,6272727),
  ('brand','LG','2025.09',18,4,16281817),
  ('brand','삼성','2025.09',11,4,14968181),
  ('brand','LG','2025.10',140,46,232378163),
  ('brand','삼성','2025.10',120,38,179146349),
  ('brand','LG','2025.11',164,61,295923978),
  ('brand','삼성','2025.11',153,50,220937891),
  ('brand','LG','2025.12',163,45,230612759),
  ('brand','삼성','2025.12',179,75,343925181),
  ('brand','LG','2026.01',227,90,466016919),
  ('brand','삼성','2026.01',246,83,383342702),
  ('brand','LG','2026.02',234,62,307425229),
  ('brand','삼성','2026.02',246,78,376424718),
  ('brand','LG','2026.03',316,107,569263323),
  ('brand','삼성','2026.03',342,113,548795294),
  ('brand','LG','2026.04',354,126,653689959),
  ('brand','삼성','2026.04',303,110,534607271),
  ('brand','LG','2026.05',276,76,391897157),
  ('brand','삼성','2026.05',294,84,427284637),
  ('brand','LG','2026.06',271,65,328235433),
  ('brand','삼성','2026.06',320,102,505597867),
  ('brand','LG','2026.07',240,81,420674609),
  ('brand','삼성','2026.07',238,86,429780327),
  ('brand','LG','2026.08',88,24,117709619),
  ('brand','삼성','2026.08',92,27,131345441);

alter table sales_rank_monthly enable row level security;
create policy "read" on sales_rank_monthly for select to anon using (true);

alter table sales_monthly   enable row level security;
alter table sales_deal_type enable row level security;
alter table sales_rank      enable row level security;
create policy "read" on sales_monthly   for select to anon using (true);
create policy "read" on sales_deal_type for select to anon using (true);
create policy "read" on sales_rank      for select to anon using (true);

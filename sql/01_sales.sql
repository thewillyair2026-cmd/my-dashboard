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
  (1,'2025.09', 30, 34772725, 500000000),
  (2,'2025.10', 260, 411524512, 600000000),
  (3,'2025.11', 321, 530880232, 600000000),
  (4,'2025.12', 344, 562810667, 700000000),
  (5,'2026.01', 472, 855323257, 800000000),
  (6,'2026.02', 482, 689940856, 800000000),
  (7,'2026.03', 658, 1111204070, 1000000000),
  (8,'2026.04', 655, 1165615414, 1000000000),
  (9,'2026.05', 577, 814572704, 1000000000),
  (10,'2026.06', 600, 833482618, 1000000000),
  (11,'2026.07', 481, 844996794, 1000000000),
  (12,'2026.08', 473, 753176108, 1000000000),
  (13,'2026.09', 453, 715113985, 1000000000),
  (14,'2026.10', 114, 244394832, 1000000000);

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
  ('2025.09', 30, 9, 1),
  ('2025.10', 260, 84, 27),
  ('2025.11', 321, 114, 84),
  ('2025.12', 344, 119, 86),
  ('2026.01', 472, 174, 129),
  ('2026.02', 482, 141, 153),
  ('2026.03', 658, 219, 199),
  ('2026.04', 655, 231, 190),
  ('2026.05', 577, 159, 203),
  ('2026.06', 600, 167, 178),
  ('2026.07', 481, 167, 150),
  ('2026.08', 473, 145, 132),
  ('2026.09', 453, 138, 139),
  ('2026.10', 114, 50, 130);

alter table sales_pipeline_monthly enable row level security;
create policy "read" on sales_pipeline_monthly for select to authenticated using (true);

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
  (1,'2025.09', 4, 5, 15263636, 19509089),
  (2,'2025.10', 27, 57, 132800903, 278723609),
  (3,'2025.11', 32, 82, 150313174, 380567058),
  (4,'2025.12', 33, 86, 167347079, 395463588),
  (5,'2026.01', 55, 119, 269133620, 586189637),
  (6,'2026.02', 43, 98, 214967171, 474973685),
  (7,'2026.03', 54, 165, 278195891, 833008179),
  (8,'2026.04', 59, 172, 296771342, 868844072),
  (9,'2026.05', 52, 107, 272610768, 541961936),
  (10,'2026.06', 75, 92, 368594517, 464888101),
  (11,'2026.07', 59, 108, 308915436, 536081358),
  (12,'2026.08', 58, 87, 318472696, 434703412),
  (13,'2026.09', 67, 71, 348790880, 366323105),
  (14,'2026.10', 13, 37, 66118175, 178276657);

alter table sales_deal_type_monthly enable row level security;
create policy "read" on sales_deal_type_monthly for select to authenticated using (true);

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
  ('person','신제호 팀장','2025.09',11,3,11963635),
  ('person','정현수 대표','2025.09',11,6,22809090),
  ('person','김혜란 대리','2025.10',54,16,78228174),
  ('person','김희성 대리','2025.10',1,0,0),
  ('person','신제호 팀장','2025.10',81,31,148028168),
  ('person','정현수 대표','2025.10',124,37,185268170),
  ('person','김혜란 대리','2025.11',60,13,59820450),
  ('person','김희성 대리','2025.11',5,0,0),
  ('person','신제호 팀장','2025.11',102,46,212758165),
  ('person','오형민 팀장','2025.11',47,6,28945451),
  ('person','정현수 대표','2025.11',107,49,229356166),
  ('person','김혜란 대리','2025.12',34,9,39977271),
  ('person','김희성 대리','2025.12',26,2,9477272),
  ('person','민대기 대리','2025.12',1,0,0),
  ('person','신제호 팀장','2025.12',106,41,190529056),
  ('person','오형민 팀장','2025.12',107,26,121516170),
  ('person','정현수 대표','2025.12',70,41,201310898),
  ('person','김혜란 대리','2026.01',0,2,13909090),
  ('person','김희성 대리','2026.01',112,32,152759077),
  ('person','민대기 대리','2026.01',12,3,14227272),
  ('person','신제호 팀장','2026.01',119,65,319900562),
  ('person','오형민 팀장','2026.01',142,35,176933626),
  ('person','정현수 대표','2026.01',87,37,177593630),
  ('person','김희성 대리','2026.02',113,25,122881808),
  ('person','민대기 대리','2026.02',66,16,77226812),
  ('person','서은지 주임','2026.02',2,2,5202815),
  ('person','신제호 팀장','2026.02',77,38,184244892),
  ('person','오형민 팀장','2026.02',166,34,175098714),
  ('person','정현수 대표','2026.02',58,26,125285815),
  ('person','김지연 주임','2026.03',4,1,5426636),
  ('person','김희성 대리','2026.03',158,34,169654986),
  ('person','민대기 대리','2026.03',118,36,188072891),
  ('person','서은지 주임','2026.03',3,3,7525200),
  ('person','신제호 팀장','2026.03',124,74,377368470),
  ('person','오형민 팀장','2026.03',200,46,233946799),
  ('person','정현수 대표','2026.03',51,25,129209088),
  ('person','김지연 주임','2026.04',26,7,37445454),
  ('person','김희성 대리','2026.04',181,54,265579431),
  ('person','민대기 대리','2026.04',143,32,171381805),
  ('person','서은지 주임','2026.04',5,5,12308500),
  ('person','신제호 팀장','2026.04',97,60,297529156),
  ('person','오형민 팀장','2026.04',166,52,277224339),
  ('person','정현수 대표','2026.04',36,21,104146729),
  ('person','김지연 주임','2026.05',55,7,34863636),
  ('person','김희성 대리','2026.05',115,22,121232148),
  ('person','민대기 대리','2026.05',115,24,129082807),
  ('person','서은지 주임','2026.05',2,2,5717520),
  ('person','신제호 팀장','2026.05',117,62,307410520),
  ('person','오형민 팀장','2026.05',141,32,166829710),
  ('person','정현수 대표','2026.05',32,10,49436363),
  ('person','김지연 주임','2026.06',88,17,96988401),
  ('person','민대기 대리','2026.06',153,25,131216350),
  ('person','신제호 팀장','2026.06',116,61,287701528),
  ('person','오형민 팀장','2026.06',186,43,216630888),
  ('person','이유진 사원','2026.06',6,1,6081818),
  ('person','이지은 실장','2026.06',1,0,0),
  ('person','정현수 대표','2026.06',50,20,94863633),
  ('person','김지연 주임','2026.07',45,11,56793363),
  ('person','민대기 대리','2026.07',126,27,140606080),
  ('person','서은지 주임','2026.07',4,4,8594667),
  ('person','신제호 팀장','2026.07',83,48,247079709),
  ('person','오형민 팀장','2026.07',131,36,192188260),
  ('person','이유진 사원','2026.07',41,17,84815447),
  ('person','이지은 실장','2026.07',29,10,48891996),
  ('person','정현수 대표','2026.07',21,14,66027272),
  ('person','김지연 주임','2026.08',8,5,26645454),
  ('person','민대기 대리','2026.08',113,27,142045441),
  ('person','서은지 주임','2026.08',2,2,482356),
  ('person','신제호 팀장','2026.08',87,38,192699983),
  ('person','오형민 팀장','2026.08',134,34,188209072),
  ('person','이유진 사원','2026.08',55,19,95081810),
  ('person','이지은 실장','2026.08',62,18,96975629),
  ('person','정현수 대표','2026.08',12,2,11036363),
  ('person','김지연 주임','2026.09',3,2,8098304),
  ('person','민대기 대리','2026.09',63,26,131534397),
  ('person','서은지 주임','2026.09',3,3,27625862),
  ('person','신제호 팀장','2026.09',55,34,171227261),
  ('person','오형민 팀장','2026.09',119,30,159845441),
  ('person','이유진 사원','2026.09',69,17,80900911),
  ('person','이지은 실장','2026.09',46,10,52418177),
  ('person','전윤진 대리','2026.09',84,11,56863632),
  ('person','정현수 대표','2026.09',8,5,26600000),
  ('person','민대기 대리','2026.10',13,3,14836362),
  ('person','서은지 주임','2026.10',1,1,2567580),
  ('person','신제호 팀장','2026.10',33,18,84527267),
  ('person','오형민 팀장','2026.10',25,11,58145449),
  ('person','이유진 사원','2026.10',16,6,26418180),
  ('person','이지은 실장','2026.10',1,0,0),
  ('person','전윤진 대리','2026.10',24,11,57899994),
  ('person','정현수 대표','2026.10',1,0,0),
  ('brand','삼성','2025.08',0,1,6272727),
  ('brand','LG','2025.09',18,4,16281817),
  ('brand','삼성','2025.09',12,5,18490908),
  ('brand','LG','2025.10',140,46,232378163),
  ('brand','삼성','2025.10',120,38,179146349),
  ('brand','LG','2025.11',165,62,301133068),
  ('brand','삼성','2025.11',156,52,229747164),
  ('brand','LG','2025.12',162,44,218885486),
  ('brand','삼성','2025.12',182,75,343925181),
  ('brand','LG','2026.01',226,91,471980555),
  ('brand','삼성','2026.01',246,83,383342702),
  ('brand','LG','2026.02',234,62,307425229),
  ('brand','삼성','2026.02',248,79,382515627),
  ('brand','LG','2026.03',316,107,567363321),
  ('brand','삼성','2026.03',342,112,543840749),
  ('brand','LG','2026.04',356,123,642180869),
  ('brand','삼성','2026.04',299,108,523434545),
  ('brand','LG','2026.05',274,75,388015339),
  ('brand','삼성','2026.05',303,84,426557365),
  ('brand','LG','2026.06',273,65,327253614),
  ('brand','삼성','2026.06',327,102,506229004),
  ('brand','LG','2026.07',239,80,410583430),
  ('brand','삼성','2026.07',242,87,434413364),
  ('brand','LG','2026.08',238,69,361891416),
  ('brand','삼성','2026.08',235,76,391284692),
  ('brand','LG','2026.09',220,69,360740882),
  ('brand','삼성','2026.09',233,69,354373103),
  ('brand','LG','2026.10',52,17,89218175),
  ('brand','삼성','2026.10',62,33,155176657);

alter table sales_rank_monthly enable row level security;
create policy "read" on sales_rank_monthly for select to authenticated using (true);

alter table sales_monthly   enable row level security;
alter table sales_deal_type enable row level security;
alter table sales_rank      enable row level security;
create policy "read" on sales_monthly   for select to authenticated using (true);
create policy "read" on sales_deal_type for select to authenticated using (true);
create policy "read" on sales_rank      for select to authenticated using (true);

-- 마케팅 대시보드 (실데이터 반영판)
-- 유입경로 데이터는 광고비가 없는 오가닉/제휴 채널이 대부분이라 ROAS 대신 전환율 중심으로 구성했습니다.
-- 네이버 유료광고(파워링크/쇼핑검색)는 유입경로에서 분리 추적이 안 되는 구조라 별도 표로 관리합니다.
-- 기존 표가 있다면 아래로 교체됩니다.

drop table if exists marketing_channel;
drop table if exists marketing_naver_ads;
drop table if exists marketing_monthly;
drop table if exists marketing_budget;

-- 채널별 성과 (취소건 제외 + 중복 근사 통합 반영). is_b2b = 인테리어/부동산 제휴 채널 여부
create table marketing_channel (
  id bigint primary key generated always as identity,
  channel text not null,
  quotes bigint not null,
  contracts bigint not null,
  revenue bigint not null,
  is_b2b boolean not null default false
);
insert into marketing_channel (channel, quotes, contracts, revenue, is_b2b) values
  ('네이버 블로그',      2286, 609, 2999381539, false),
  ('베스트샵&갤러리아',   620,  148, 792308036,  false),
  ('카카오톡 채널',       463,  110, 533465729,  false),
  ('네이버 카페',        385,  171, 866900532,  false),
  ('인테리어',           361,  214, 1092478029, true),
  ('부동산',             272,  137, 637346556,  true),
  ('지인소개',           161,  81,  403235428,  false),
  ('명함 배포',          108,  37,  191049991,  false),
  ('네이버 톡톡',        67,   11,  57470271,   false),
  ('전단지광고',         60,   24,  118082447,  false),
  ('업체소개',           55,   31,  166436350,  false),
  ('에어컨설팅',         55,   13,  53960904,   false),
  ('공사안내문',         28,   9,   45963634,   false),
  ('스마트스토어',       20,   5,   24675181,   false),
  ('설치자',             16,   16,  37063478,   false),
  ('쿠팡',               16,   3,   15237907,   false),
  ('뽐뿌',               12,   7,   33790906,   false),
  ('기타',               42,   8,   54126998,   false);

-- 네이버 유료광고 — 대행사 리포트 보고 매달 직접 입력 (자동 집계 불가한 영역)
-- 대행사 수수료는 광고비의 10%가 별도로 빠져나갑니다 (아래 agency_fee_rate 참고)
create table marketing_naver_ads (
  id bigint primary key generated always as identity,
  month text not null,
  product text not null,        -- '파워링크' 또는 '쇼핑검색'
  impressions bigint not null,
  clicks bigint not null,
  spend bigint not null,        -- 광고비 (VAT포함, 대행사 수수료 포함 총액)
  conversions int not null,
  conversion_revenue bigint not null,
  agency_fee_rate numeric not null default 10  -- 대행사 수수료율 %
);
insert into marketing_naver_ads (month, product, impressions, clicks, spend, conversions, conversion_revenue) values
  ('2026.07','파워링크',  60283,  393,  1112690, 0,  0),
  ('2026.07','쇼핑검색',  602386, 1299, 626716,  21, 2400000);

alter table marketing_channel   enable row level security;
alter table marketing_naver_ads enable row level security;
create policy "read" on marketing_channel   for select to anon using (true);
create policy "read" on marketing_naver_ads for select to anon using (true);

-- 마케팅 일별 성과 (매일 아침 모닝브리핑 수치) — 하루 1행, 같은 날짜로 다시 저장하면 덮어씁니다.
-- 읽기: 로그인한 모든 사용자 / 쓰기: owner·marketing 역할만. 기존 표를 지우지 않으므로 다시 실행해도 안전합니다.
create table if not exists marketing_daily (
  day date primary key,
  google_impr bigint not null default 0,
  google_clicks bigint not null default 0,
  google_cost bigint not null default 0,
  google_conv int not null default 0,
  naver_impr bigint not null default 0,
  naver_clicks bigint not null default 0,
  naver_cost bigint not null default 0,
  naver_conv int not null default 0,
  coupang_impr bigint not null default 0,
  coupang_clicks bigint not null default 0,
  coupang_cost bigint not null default 0,
  coupang_orders int not null default 0,
  insta_cost bigint not null default 0,
  insta_impr bigint not null default 0,
  insta_link_clicks bigint not null default 0,
  insta_landing int not null default 0,
  ga_visits int not null default 0,
  ga_phone int not null default 0,
  ga_kakao int not null default 0,
  ga_form int not null default 0,
  inquiries int not null default 0,
  memo text,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);
alter table marketing_daily enable row level security;
drop policy if exists "read" on marketing_daily;
drop policy if exists "write" on marketing_daily;
create policy "read" on marketing_daily for select to authenticated using (true);
create policy "write" on marketing_daily for all to authenticated
  using (has_role(array['owner','marketing']))
  with check (has_role(array['owner','marketing']));

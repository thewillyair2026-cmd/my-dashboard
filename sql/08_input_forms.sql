-- 데이터 입력 기능 (3단계): 계정 역할 + 인사/마케팅비용/손익비용 입력용 표
-- 기존 hr_monthly/hr_dept/hr_tenure/hr_overtime/pl_summary/pl_cost 표는 더 이상 사용하지 않습니다.
-- (대시보드가 아래 새 표들로부터 값을 직접 계산하는 방식으로 바뀝니다.)

-- 계정별 역할 (owner=전체관리, marketing=마케팅담당, hr=인사담당)
drop table if exists user_roles;
create table user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner','marketing','hr')),
  display_name text
);
alter table user_roles enable row level security;
create policy "read own" on user_roles for select to authenticated using (auth.uid() = user_id);

-- 로그인한 사용자가 특정 역할(들) 중 하나인지 확인하는 헬퍼 함수 (RLS 정책에서 재사용)
create or replace function has_role(roles text[])
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(
    select 1 from user_roles where user_id = auth.uid() and role = any(roles)
  );
$$;

-- 직원 명부: 인사 대시보드가 이 표에서 재직인원/부서별인건비/근속연수를 계산합니다.
drop table if exists hr_leave_usage;
drop table if exists hr_employees;
create table hr_employees (
  id bigint primary key generated always as identity,
  name text not null,
  dept text not null,                        -- '대표','경리','마케팅','B2B영업','B2C영업' 등
  join_date date not null,
  leave_date date,                            -- 비어있으면 재직중
  monthly_salary bigint not null,             -- 현재 월 급여(원)
  annual_leave_granted numeric not null default 15,  -- 올해 부여 연차일수
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);
alter table hr_employees enable row level security;
create policy "read" on hr_employees for select to authenticated using (true);
create policy "write" on hr_employees for all to authenticated
  using (has_role(array['owner','hr']))
  with check (has_role(array['owner','hr']));

-- 연차 사용 내역 (직원별 월별 사용일수)
create table hr_leave_usage (
  id bigint primary key generated always as identity,
  employee_id bigint not null references hr_employees(id) on delete cascade,
  ym text not null,
  days_used numeric not null,
  note text,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);
alter table hr_leave_usage enable row level security;
create policy "read" on hr_leave_usage for select to authenticated using (true);
create policy "write" on hr_leave_usage for all to authenticated
  using (has_role(array['owner','hr']))
  with check (has_role(array['owner','hr']));

-- 마케팅 비용 (채널 × 월 합계 — 네이버 유료광고는 기존 marketing_naver_ads 표 유지)
drop table if exists marketing_cost_monthly;
create table marketing_cost_monthly (
  id bigint primary key generated always as identity,
  ym text not null,
  channel text not null,
  amount bigint not null,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now(),
  unique(ym, channel)
);
alter table marketing_cost_monthly enable row level security;
create policy "read" on marketing_cost_monthly for select to authenticated using (true);
create policy "write" on marketing_cost_monthly for all to authenticated
  using (has_role(array['owner','marketing']))
  with check (has_role(array['owner','marketing']));

-- 손익 비용 (기기매입비 / 설치도급비 / 기타 — 매출·인건비·광고비는 다른 표에서 자동 집계)
drop table if exists pl_cost_monthly;
create table pl_cost_monthly (
  id bigint primary key generated always as identity,
  ym text not null unique,
  device_cost bigint not null default 0,
  install_fee bigint not null default 0,
  other_cost bigint not null default 0,
  updated_by uuid references auth.users(id),
  updated_at timestamptz not null default now()
);
alter table pl_cost_monthly enable row level security;
create policy "read" on pl_cost_monthly for select to authenticated using (true);
create policy "write" on pl_cost_monthly for all to authenticated
  using (has_role(array['owner']))
  with check (has_role(array['owner']));

-- 현재 로그인 계정을 우선 owner로 등록 (다른 계정 만드시면 role을 직접 update 해주세요)
insert into user_roles (user_id, role, display_name)
select id, 'owner', 'WILLY 관리자' from auth.users where email = 'thewillyair2026@gmail.com'
on conflict (user_id) do update set role = excluded.role;

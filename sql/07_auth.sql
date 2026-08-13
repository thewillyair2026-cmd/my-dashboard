-- 로그인 기반 접근 제어 1단계: 모든 대시보드 표의 읽기 권한을 anon(누구나) -> authenticated(로그인한 사람만)으로 변경
-- ⚠️ 이 스크립트를 실행하면 로그인하지 않은 사람은 대시보드에서 데이터를 볼 수 없게 됩니다.
-- ⚠️ 실행 전에 Supabase Dashboard > Authentication > Users 에서 최소 1개 이상의 계정을 먼저 만들어두세요.

-- 영업
drop policy if exists "read" on sales_monthly;
create policy "read" on sales_monthly for select to authenticated using (true);

drop policy if exists "read" on sales_pipeline_monthly;
create policy "read" on sales_pipeline_monthly for select to authenticated using (true);

drop policy if exists "read" on sales_deal_type;
create policy "read" on sales_deal_type for select to authenticated using (true);

drop policy if exists "read" on sales_deal_type_monthly;
create policy "read" on sales_deal_type_monthly for select to authenticated using (true);

drop policy if exists "read" on sales_rank;
create policy "read" on sales_rank for select to authenticated using (true);

drop policy if exists "read" on sales_rank_monthly;
create policy "read" on sales_rank_monthly for select to authenticated using (true);

-- 마케팅
drop policy if exists "read" on marketing_channel;
create policy "read" on marketing_channel for select to authenticated using (true);

drop policy if exists "read" on marketing_naver_ads;
create policy "read" on marketing_naver_ads for select to authenticated using (true);

drop policy if exists "read" on marketing_channel_monthly;
create policy "read" on marketing_channel_monthly for select to authenticated using (true);

-- 고객
drop policy if exists "read" on customer_summary;
create policy "read" on customer_summary for select to authenticated using (true);

drop policy if exists "read" on customer_as_cohort;
create policy "read" on customer_as_cohort for select to authenticated using (true);

drop policy if exists "read" on customer_type;
create policy "read" on customer_type for select to authenticated using (true);

drop policy if exists "read" on b2b_partners;
create policy "read" on b2b_partners for select to authenticated using (true);

-- 손익
drop policy if exists "read" on pl_summary;
create policy "read" on pl_summary for select to authenticated using (true);

drop policy if exists "read" on pl_cost;
create policy "read" on pl_cost for select to authenticated using (true);

drop policy if exists "read" on pl_margin;
create policy "read" on pl_margin for select to authenticated using (true);

-- 인사
drop policy if exists "read" on hr_monthly;
create policy "read" on hr_monthly for select to authenticated using (true);

drop policy if exists "read" on hr_dept;
create policy "read" on hr_dept for select to authenticated using (true);

drop policy if exists "read" on hr_tenure;
create policy "read" on hr_tenure for select to authenticated using (true);

drop policy if exists "read" on hr_overtime;
create policy "read" on hr_overtime for select to authenticated using (true);

-- 경영
drop policy if exists "read" on exec_target;
create policy "read" on exec_target for select to authenticated using (true);
